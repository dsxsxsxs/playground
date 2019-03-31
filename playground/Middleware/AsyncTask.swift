//
//  AsyncTask.swift
//  playground
//
//  Created by dsxs on 2018/05/17.
//  Copyright © 2018年 dsxs. All rights reserved.
//

import Foundation

enum Result <T> {
    case success(T)
    case failure(Error)
}
struct Async<T> {
    
    
    let body:((Result<T>)->Void)->Void
    
    init(fn:@escaping ((Result<T>)->Void)->Void) {
        body = fn
    }
    
    func go(_ cb:(Result<T>)->Void) {
        body(cb)
    }
}
extension Result{
    
    func flatMap<U>(f: @escaping (T) throws-> Result<U>) -> Result<U> {
        switch self{
        case .success(let value):
            do{
                return try f(value)
            }catch let e{
                return .failure(e)
            }
        case .failure(let e):
            return .failure(e)
        }
    }
}
extension Async{

    static func unit(_ x:T) -> Async<T> {
        return Async{ $0(.success(x)) }
    }
    
    func map<U>(f: @escaping (T) throws-> U) -> Async<U> {
        return flatMap{ .unit(try f($0)) }
    }
    
    func flatMap<U>(_ f:@escaping (T) throws-> Async<U>) -> Async<U> {
        return Async<U>{ cont in
            self.go{ _ in
//                switch $0.map(f){
//                case .success(let async):
//                    async.go(cont)
//                case .failure(let error):
//                    cont(.failure(error))
//                }
            }
        }
    }
    
    func apply<U>(af:Async<(T) throws-> U>) -> Async<U> {
        return af.flatMap(map)
    }
}
