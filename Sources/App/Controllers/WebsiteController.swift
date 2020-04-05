//
//  WebsiteController.swift
//  App
//
//  Created by Artem Panasenko on 01.04.2020.
//

import Vapor
import Authentication


struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionsRoutes = router.grouped(User.authSessionsMiddleware())
        authSessionsRoutes.get(use: indexHandler)
        authSessionsRoutes.get("acronyms", Acronym.parameter, use:acronumHandler)
        authSessionsRoutes.get("users", User.parameter, use:userHandler)
        authSessionsRoutes.get("users", use: allUsersHandler)
        authSessionsRoutes.get("categories", Category.parameter, use:categoryHandler)
        authSessionsRoutes.get("categories", use: allCategoriesHandler)
        authSessionsRoutes.get("login", use: loginHandler)
        authSessionsRoutes.post("login", use: loginPostHandler)


        let protectedRoutes = authSessionsRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
        protectedRoutes.get("acronyms", "create",use: createAcronymHandler)
        protectedRoutes.post(CreateAcronymData.self, at: "acronyms", "create", use: createAcronumPostHandler)
        protectedRoutes.get("acronyms", Acronym.parameter, "edit", use: editAcronymHandler)
        protectedRoutes.post("acronyms", Acronym.parameter, "edit", use: editAcronymPostHandler)
        protectedRoutes.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            let context = IndexContext(title: "Homepage", acronyms: acronyms)
            return try req.view().render("index", context)
        }
    }
    
    func acronumHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            return acronym.user.get(on: req).flatMap(to: View.self) { user in
                let context = try AcronymContext(title: acronym.long, acronym: acronym, user: user, categories: acronym.categories.query(on: req).all())
                return try req.view().render("acronym", context)
            }
        }
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            print("--- userHandler --- user: \(user)")
            let context = try UserContext(title: user.name, user: user, acronyms: user.acronyms.query(on: req).all())
            print("--- userHandler --- context: \(context)")
            print("--- userHandler --- acronyms: \(user.acronyms)")
            return try req.view().render("user", context)
        }
    }
    
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        let context = AllUsersContext(users: User.query(on: req).all())
        return try req.view().render("allUsers", context)
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self).flatMap(to: View.self) { category in
            let context = try CategoryContext(title: category.name, category: category, acronyms: category.acronyms.query(on: req).all())
            return try req.view().render("category", context)
        }
    }
    
    func allCategoriesHandler(_ req: Request) throws -> Future<View> {
        let context = AllCategoriesContext(categories: Category.query(on: req).all())
        return try req.view().render("allCategories", context)
    }
    
    func createAcronymHandler(_ req: Request) throws -> Future<View> {
        let context = CreateAcronymContext()
        return try req.view().render("createAcronym", context)
    }
    
    func createAcronumPostHandler(_ req: Request, acronymData: CreateAcronymData) throws -> Future<Response> {
        let user = try req.requireAuthenticated(User.self)
        let acronym = try Acronym(short: acronymData.short, long: acronymData.long, userID: user.requireID())
        return acronym.save(on: req).map(to: Response.self) { acronym in
            guard let id = acronym.id else {
                return req.redirect(to: "/")
            }
            return req.redirect(to: "/acronyms/\(id)")
        }
    }
    
    func editAcronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            let context = EditAcronymContext(title: "Edit Acronym", acronym: acronym)
            return try req.view().render("createAcronym", context)
        }
    }
    
    func editAcronymPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Acronym.self).flatMap(to: Response.self) { acronym in
            let updatedAcronum = try req.content.syncDecode(CreateAcronymData.self)
            acronym.short = updatedAcronum.short
            acronym.long = updatedAcronum.long
            let user = try req.requireAuthenticated(User.self)
            acronym.userID = try user.requireID()
            
            return acronym.save(on: req).map(to: Response.self) { savedAcronym in
                guard let id = savedAcronym.id else {
                    return req.redirect(to: "/")
                }
                return req.redirect(to: "/acronyms/\(id)")
            }
        }
    }
    
    func deleteAcronymHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Acronym.self).flatMap(to: Response.self) { acronym in
            acronym.delete(on: req).transform(to: req.redirect(to: "/"))
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context = LoginContext()
        return try req.view().render("login", context)
    }
    
    func loginPostHandler(_ req: Request) throws -> Future<Response> {
        let loginData = try req.content.syncDecode(LoginPostData.self)
        return User.authenticate(username: loginData.userName, password: loginData.password, using: BCryptDigest(), on: req).map(to: Response.self) {user in
            guard let user = user else {
                return req.redirect(to: "/login")
            }
            try req.authenticateSession(user)
            return req.redirect(to: "/")
        }
    }
    
    
}


struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let user: User
    let categories: Future<[Category]>
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let acronyms: Future<[Acronym]>
}

struct AllUsersContext: Encodable {
    let title = "All Users"
    let users: Future<[User]>
}

struct CategoryContext: Encodable {
    let title: String
    let category: Category
    let acronyms: Future<[Acronym]>
}

struct AllCategoriesContext: Encodable {
    let title = "All Categories"
    let categories: Future<[Category]>
}

struct CreateAcronymContext: Encodable {
    let title = "Create An Acronym"
}

struct EditAcronymContext: Encodable {
    let title: String
    let acronym: Acronym
    let editing = true
}

struct CreateAcronymData: Content {
    let short: String
    let long: String
}

struct LoginContext: Encodable {
    let title = "Log in"
}

struct LoginPostData: Content {
    let userName: String
    let password: String
}
