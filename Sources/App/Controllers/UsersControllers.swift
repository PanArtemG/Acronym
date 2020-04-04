//
//  UsersControllers.swift
//  App
//
//  Created by Artem Panasenko on 01.04.2020.
//

import Vapor
import Crypto

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoutes = router.grouped("api", "users")
        usersRoutes.post(User.self, use: createHandler)
        usersRoutes.get(use: getAllHandler)
        usersRoutes.get(User.parameter, use: getUserHandler)
        usersRoutes.get(User.parameter, "acronym", use: getAcronymsHandler)
        
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        print("----- createHandler: \(req)")
        return  user.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
        print("----- getAllHandler: \(req).all()")
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        print("----- getUserHandler: \(try req.parameters.next(User.self))")
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self) { user in
            return try user.acronyms.query(on: req).all()
        }
    }
    
}
