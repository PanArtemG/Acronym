//
//  CategoriesController.swift
//  App
//
//  Created by Artem Panasenko on 01.04.2020.
//

import Vapor

struct CategoriesController: RouteCollection {
    func boot(router: Router) throws {
        let categoriesRoute = router.grouped("api", "categories")
        categoriesRoute.post(use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(Category.parameter, use: getCategoryHandler)
        categoriesRoute.get(Category.parameter, "acronyms", use: getAcronymsHandlers)
        
        
        
    }
    
    func createHandler(_ req: Request) throws -> Future<Category> {
        print("----- createHandler: \(try req.content.decode(Category.self))")
        return try req.content.decode(Category.self).save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        print("----- getAllHendlers: \(Category.query(on: req).all())")
        return Category.query(on: req).all()
    }
    
    func getCategoryHandler(_ req: Request) throws -> Future<Category> {
        print("----- getCategoryHandler: \(try req.parameters.next(Category.self))")
        return try req.parameters.next(Category.self)
    }
    
    func getAcronymsHandlers(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Category.self).flatMap(to: [Acronym].self) { category in
            return try category.acronyms.query(on: req).all()
            
        }
    }
}
