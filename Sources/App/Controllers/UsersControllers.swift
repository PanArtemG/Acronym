//
//  UsersControllers.swift
//  App
//
//  Created by Artem Panasenko on 01.04.2020.
//

import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoutes = router.grouped("api", "users")
        usersRoutes.post(User.self, use: createHandler)
        usersRoutes.get(use: getAllHandler)
        usersRoutes.get(User.parameter, use: getAllHandler)
        usersRoutes.get(User.parameter, "acronym", use: getAcronymsHandler)
        
    }
    
    func createHandler(_ req: Request, user: User) throws -> Future<User> {
        print("----- createHandler: \(req)")
        return  user.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        print("----- getAllHandler: \(req).all()")
        return User.query(on: req).all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User> {
        print("----- getUserHandler: \(try req.parameters.next(User.self))")
        return try req.parameters.next(User.self)
    }
    
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self) { user in
            return try user.acronyms.query(on: req).all()
        }
    }
    
}
