//: Playground - noun: a place where people can play

import UIKit
//import FMDB

struct strct{
    var x = 5
}

var sa = strct()
var oa:strct! = sa
sa.x = 8
oa.x = 2
print(sa)
protocol OrzModel{
    func primaryKey()->String
    func options()->[String:String]?

}
extension OrzModel{
    
    func toSchema()throws ->String {
        let mirror = Mirror(reflecting: self)
        var opts = self.options()
        let pk = primaryKey()
        if let pkopt = opts?[pk]{
            opts?[pk] = "PRIMARY KEY AUTOINCREMENT NOT NULL \(pkopt)"
        }else{
            opts?[pk] = "PRIMARY KEY AUTOINCREMENT NOT NULL"
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
            return "`\(column)` \(columnType) \(opts?[column] ?? "")"
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
        let count = Int(info.count), pk = primaryKey()
        _ = vals.remove(at: cols.index(of:pk)!)
        let sql = "INSERT INTO `\(type(of: self))` (\(cols.filter{ $0 != pk }.joined(separator: ","))) VALUES (\([String](repeating: "?", count: count - 1).joined(separator: ",")));"
        return (sql, vals)
    }
    func toUpdate()throws -> (String, [Any])  {
        var  (_, cols, vals) = try reflect()
        let pkey = primaryKey()
        let pk = vals.remove(at: cols.index(of:pkey)!)
        vals.append(pk)
        let sql = "UPDATE `\(type(of: self))` SET \(cols.filter{ $0 != pkey }.map{ "`\($0)` = ?"}.joined(separator: ",")) WHERE `\(pkey)` = ?"
        return (sql, vals)
    }
    func toDelete()throws -> (String, [Any])  {
        let  (_, cols, vals) = try reflect()
        let pkey = primaryKey()
        let pk = vals[cols.index(of:pkey)!]
        let sql = "DELETE FROM `\(type(of: self))` WHERE `\(pkey)` = ?"
        return (sql, [pk])
    }


}
let o:Int?=nil
let x:Any = o
let m = Mirror(reflecting: x)
if m.displayStyle == .optional{
    print(m.children.first?.value ?? "nfefefil")
}
struct Receipt:OrzModel{
    var id:Int = 0
    var date:Date? = nil
    var title:String =  ""
    func primaryKey() -> String {
        return "id"
    }
    func options() -> [String:String]? {
        return ["title":"NOT NULL"]
    }
}
func create(table: OrzModel){
    try? table.toSchema()
    try? table.toInsert()
    try? table.toUpdate()
    try? table.toDelete()
}

create(table: Receipt())

//let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//
//let db = FMDatabase(url: url)

