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
    class RollbackBool{
        weak var db:FMDatabase?
        var isRollbacked = false
        var should = false{
            didSet{
                guard should, !isRollbacked else{
                    return
                }
                if let rb = rollback{
                    rb.pointee = true
                }else{
                    db?.rollback()
                }
                isRollbacked = true
            }
        }
        var rollback:UnsafeMutablePointer<ObjCBool>?
        init(_ db:FMDatabase){
            self.db = db
        }
        init(_ ptr:UnsafeMutablePointer<ObjCBool>) {
            rollback = ptr
        }
    }
    
    var db:FMDatabase?
    let queue:DispatchQueue
    let dbQueue:FMDatabaseQueue
    let group:DispatchGroup
    
    init?(name:String, use q:DispatchQueue? = nil) {
        guard
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path,
            let dbq = FMDatabaseQueue(path: "\(path)/\(name).db") else{
            return nil
        }
        queue = q ?? DispatchQueue(label: "me.dsxs.orz.dispatch", attributes: .concurrent)
        dbQueue = dbq
        group = DispatchGroup()
    }
    
    func write(_ fn: @escaping (Orz, RollbackBool)->Void)  {
        queue.async(group:group) { [dbQueue] in
            dbQueue.inTransaction{ (db, rollback) in
                let wrap = RollbackBool(rollback)
                self.db = db
                fn(self, wrap)
                self.db = nil
            }
        }
    }
    
    func transaction(_ fn:@escaping (FMDatabase, RollbackBool)->Void) {
        guard let db = self.db else{
            queue.async(group:group) { [dbQueue] in
                dbQueue.inTransaction{ db, rollback in
                    let wrap = RollbackBool(rollback)
                    fn(db, wrap)
                }
            }
            return
        }
        fn(db, RollbackBool(db))
    }
    func database(_ fn:@escaping (FMDatabase)->Void) {
        guard let db = self.db else{
            queue.async { [dbQueue] in
                dbQueue.inDatabase(fn)
            }
            return
        }
        fn(db)
    }
    func execute<M:OrzModel>(update sqls:[String], values:[[Any]], cb:Callback<M>?=nil) {
        transaction{ db, rollback in
            do{
                for (sql, val) in zip(sqls, values){
                    try db.executeUpdate(sql, values: val)
                }
                cb?(.done)
            }catch let err{
                rollback.should = true
                cb?(.failed(with: err))
            }
        }
    }
    func execute<M:OrzModel>(query sql:String, proto:M.Type, cb:Callback<M>?) {
        database{ db in
            do{
                let rs = try db.executeQuery(sql, values: nil)
                var set:[M] = []
                while rs.next(){
                    if let d = rs.resultDictionary as? [String:Any]{
                        if let m = proto.init(from: d){
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
                var sqls:[String] = [], vals:[[Any]] = []
                for model in models{
                    switch action {
                    case .create:
                        let sql = try model.toSchema()
                        sqls.append(sql)
                        vals.append([])
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
                        vals.append([])
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
    func select<M:OrzModel>(from model:M.Type, `where` query:String="1", orderBy:String?=nil, cb:Callback<M>?) {
        let sql = "SELECT * FROM `\(String(describing: model))` WHERE \(query) \(orderBy == nil ? "":"ORDER BY \(orderBy!)");"
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
    init()
    init?(from dictionary:[String:Any])
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
        let settings = try mirror.children.map{ property in
            let column = property.label ?? ""
            guard let columnType = toSqlType["\(type(of: property.value))"] else{
                throw NSError(domain: "Orz Invalid Column Type", code: 7, userInfo: nil)
            }
            return "`\(column)` \(columnType) \(opts[column] ?? "")"
            }.joined(separator: ",")
        let sql = "CREATE TABLE IF NOT EXISTS `\(type(of: self))` (\(settings));"
        return sql
    }
    func reflect()throws -> (Mirror.Children, [String], [Any]) {
        let info = Mirror(reflecting: self).children
        let (pk, decorator) = primaryKey()
        var cols:[String] = try info.map{ property in
            guard let column = property.label else{
                throw NSError(domain: "", code: 0, userInfo: nil)
            }
            return column
        }
//        var pkIdx:Int?
//        if case .autoIncrement = decorator{
//            pkIdx = cols.index{ $0 == pk }
//            cols = cols.filter{ $0 != pk }
//        }
        var vals:[Any] = info.map{ property in
            let m = Mirror(reflecting: property.value)
            if m.displayStyle == .optional{
                if let v = m.children.first?.value{
                    return v
                }
                return NSNull()
            }
            return property.value
        }
//        if let i = pkIdx{
//            vals.remove(at: i)
//        }
        return (info, cols, vals)
    }
    func toInsert()throws -> (String, [Any]) {
        let (info, cols, vals) = try reflect()
        let count = Int(info.count)
        let sql = "INSERT OR REPLACE INTO `\(type(of: self))` (\(cols.joined(separator: ","))) VALUES (\([String](repeating: "?", count: count).joined(separator: ",")));"
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
