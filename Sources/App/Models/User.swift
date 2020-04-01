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
    
    init(name: String, userName: String) {
        self.name = name
        self.userName = userName
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
