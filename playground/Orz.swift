//
//  Orz.swift
//  playground
//
//  Created by dsxs on 2017/12/23.
//  Copyright © 2017年 dsxs. All rights reserved.
//

import Foundation
import FMDB

final class Orz {
    typealias Callback<M> = (Result<M>)->Void
    enum Result<M>{
        case data([M])
        case done
        case failed(with:Error)
    }
    
    let queue:DispatchQueue
    let dbQueue:FMDatabaseQueue
    
    init?(name:String, use q:DispatchQueue? = nil) {
        guard
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path,
            let dbq = FMDatabaseQueue(path: "\(path)/\(name).db") else{
            return nil
        }
        queue = q ?? DispatchQueue(label: "me.dsxs.orz.dispatch", attributes: .concurrent)
        dbQueue = dbq
    }
    func transaction(_ fn:@escaping (FMDatabase, UnsafeMutablePointer<ObjCBool>)->Void) {
//        queue.async { [dbQueue] in
            dbQueue.inTransaction(fn)
//        }
    }
    func database(_ fn:@escaping (FMDatabase)->Void) {
        queue.async { [dbQueue] in
            dbQueue.inDatabase(fn)
        }
    }
    func execute<M:OrzModel>(update sqls:[String], values:[Any], cb:Callback<M>?=nil) {
        transaction{ db, rollback in
            do{
                for sql in sqls{
                    try db.executeUpdate(sql, values: values)
                }
                cb?(.done)
            }catch let err{
                rollback.pointee = true
                cb?(.failed(with: err))
            }
        }
    }
    func execute<M:OrzModel>(query sql:String, proto:M, cb:Callback<M>?) {
        database{ db in
            do{
                let rs = try db.executeQuery(sql, values: nil)
                var set:[M] = []
                while rs.next(){
                    if let d = rs.resultDictionary as? [String:Any]{
                        if let m = proto.fromDictionary(d) as? M{
                            set.append(m)
                        }else{
                            throw NSError(domain: "could not convert to Model", code: 4, userInfo: d)
                        }
                    }
                }
                cb?(.data(set))
                
            }catch let err{
                cb?(.failed(with: err))
            }
        }
    }
    
    enum CRU{
        case create
        case insert
        case update
        case delete
        case drop
    }
    func execute<M:OrzModel>(models:[M], action:CRU, cb:Callback<M>?) {
        queue.async { [weak self] in
            do {
                var sqls:[String] = [], vals:[Any] = []
                for model in models{
                    switch action {
                    case .create:
                        let sql = try model.toSchema()
                        sqls.append(sql)
                    case .insert:
                        let (sql, val) = try model.toInsert()
                        sqls.append(sql)
                        vals.append(val)
                    case .update:
                        let (sql, val) = try model.toUpdate()
                        sqls.append(sql)
                        vals.append(val)
                    case .delete:
                        let (sql, val) = try model.toDelete()
                        sqls.append(sql)
                        vals.append(val)
                    case .drop:
                        let sql = "DROP TABLE `\(type(of: model))`;"
                        sqls.append(sql)
                    }
                }
                self?.execute(update: sqls, values: vals, cb:cb)
            } catch let err {
                cb?(.failed(with: err))
            }
        }
    }
    func create<M:OrzModel>(models:[M], cb:Callback<M>?) {
        execute(models: models, action: .create, cb: cb)
    }
    func drop<M:OrzModel>(models:[M], cb:Callback<M>?) {
        execute(models: models, action: .drop, cb: cb)
    }
    func drop<M:OrzModel>(model:M, cb:Callback<M>?) {
        execute(models: [model], action: .drop, cb: cb)
    }
    func insert<M:OrzModel>(models:[M], cb:Callback<M>?) {
        execute(models: models, action: .insert, cb: cb)
    }
    func update<M:OrzModel>(models:[M], cb:Callback<M>?) {
        execute(models: models, action: .update, cb: cb)
    }
    func delete<M:OrzModel>(models:[M], cb:Callback<M>?) {
        execute(models: models, action: .delete, cb: cb)
    }
    func create<M:OrzModel>(model:M, cb:Callback<M>?) {
        execute(models: [model], action: .create, cb: cb)
    }
    func insert<M:OrzModel>(model:M, cb:Callback<M>?) {
        execute(models: [model], action: .insert, cb: cb)
    }
    func update<M:OrzModel>(model:M, cb:Callback<M>?) {
        execute(models: [model], action: .update, cb: cb)
    }
    func delete<M:OrzModel>(model:M, cb:Callback<M>?) {
        execute(models: [model], action: .delete, cb: cb)
    }
    func select<M:OrzModel>(from model:M, `where` query:String, orderBy:String?=nil, cb:Callback<M>?) {
        let sql = "SELECT * FROM \(type(of: model)) WHERE \(query) \(orderBy == nil ? "":"ORDER BY \(orderBy!)");"
        execute(query: sql, proto: model, cb: cb)
    }
}

enum PrimaryKeyDecorator:String{
    case none = ""
    case autoIncrement = " AUTOINCREMENT"
}

protocol OrzModel{
    func primaryKey() -> (String, PrimaryKeyDecorator)
    func options() -> [String:String]?
    func fromDictionary(_ obj:[String:Any]) -> OrzModel?
}
extension OrzModel{
    
    func toSchema()throws ->String {
        let mirror = Mirror(reflecting: self)
        var opts:[String:String] = self.options() ?? [:]
        let (pk, decorator) = primaryKey()
        if let pkopt = opts[pk]{
            opts[pk] = "PRIMARY KEY\(decorator.rawValue) NOT NULL \(pkopt)"
        }else{
            opts[pk] = "PRIMARY KEY\(decorator.rawValue) NOT NULL"
        }
        let INTEGER = "INTEGER", BOOL = "BOOL", TEXT = "TEXT", REAL = "REAL", DATETIME = "DATETIME", BLOB = "BLOB"
        let toSqlType:[String:String] = [
            String(describing: Int.self): INTEGER,
            String(describing: Int?.self):INTEGER,
            String(describing: Bool.self): BOOL,
            String(describing: Bool?.self):BOOL,
            String(describing: String.self): TEXT,
            String(describing: String?.self):TEXT,
            String(describing: Double.self): REAL,
            String(describing: Double?.self):REAL,
            String(describing: Date.self): DATETIME,
            String(describing: Date?.self):DATETIME,
            String(describing: Data.self): BLOB,
            String(describing: Data?.self):BLOB,
            
            ]
        print(String(describing: Date?.self))
        let settings = try mirror.children.map{ property in
            let column = property.label ?? ""
            guard let columnType = toSqlType["\(type(of: property.value))"] else{
                throw NSError(domain: "Orz Invalid Column Type", code: 7, userInfo: nil)
            }
            return "`\(column)` \(columnType) \(opts[column] ?? "")"
            }.joined(separator: ",")
        let sql = "CREATE TABLE IF NOT EXISTS `\(type(of: self))` (\(settings));"
        print(sql)
        return sql
    }
    func reflect()throws -> (Mirror.Children, [String], [Any]) {
        let info = Mirror(reflecting: self).children
        let cols:[String] = try info.map{ property in
            guard let column = property.label else{
                throw NSError(domain: "", code: 0, userInfo: nil)
            }
            return column
        }
        let vals:[Any] = info.map{ property in
            let m = Mirror(reflecting: property.value)
            if m.displayStyle == .optional{
                if let v = m.children.first?.value{
                    return v
                }
                return NSNull()
            }
            return property.value
        }
        return (info, cols, vals)
    }
    func toInsert()throws -> (String, [Any]) {
        var (info, cols, vals) = try reflect()
        let count = Int(info.count)
        let (pk, dec) = primaryKey()
        if dec == .autoIncrement{
            cols = cols.filter{ $0 != pk }
            _ = vals.remove(at: cols.index(of:pk)!)
        }
        let sql = "INSERT OR REPLACE INTO `\(type(of: self))` (\(cols.joined(separator: ","))) VALUES (\([String](repeating: "?", count: count - 1).joined(separator: ",")));"
        return (sql, vals)
    }
    func toUpdate()throws -> (String, [Any])  {
        var  (_, cols, vals) = try reflect()
        let (pkey, _) = primaryKey()
        let pk = vals.remove(at: cols.index(of:pkey)!)
        vals.append(pk)
        let sql = "UPDATE `\(type(of: self))` SET \(cols.filter{ $0 != pkey }.map{ "`\($0)` = ?"}.joined(separator: ",")) WHERE `\(pkey)` = ?;"
        return (sql, vals)
    }
    func toDelete()throws -> (String, [Any])  {
        let  (_, cols, vals) = try reflect()
        let (pkey, _) = primaryKey()
        let pk = vals[cols.index(of:pkey)!]
        let sql = "DELETE FROM `\(type(of: self))` WHERE `\(pkey)` = ?;"
        return (sql, [pk])
    }
    
}
