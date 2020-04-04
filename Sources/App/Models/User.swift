//
//  User.swift
//  App
//
//  Created by Artem Panasenko on 01.04.2020.
//

import Foundation
import FluentMySQL
import Vapor

final class User: Codable {
    var id: UUID?
    var name: String
    var userName: String
    var password: String
    
    init(name: String, userName: String, password: String) {
        self.name = name
        self.userName = userName
        self.password = password
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var userName: String
        
        
        init(id: UUID?, name: String, userName: String) {
            self.id = id
            self.name = name
            self.userName = userName
        }
    }
}

extension User: MySQLUUIDModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}

extension User.Public: Content {}

extension User {
    func convertToPublic() -> User.Public {
        print("--- User (convertToPublic) ---")
        return User.Public(id: self.id, name: self.name, userName: self.userName)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        print("--- Future (convertToPublic) ---")
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}
