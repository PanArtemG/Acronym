//
//  WebsiteController.swift
//  App
//
//  Created by Artem Panasenko on 01.04.2020.
//

import Vapor


struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: indexHandler)
    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            let context = IndexContext(title: "Homepage", acronyms: acronyms.isEmpty ? nil : acronyms)
            return try req.view().render("index", context)
        }
        
    }
    
//    func acronumHandler(_ req: Request) throws -> Future<View> {
//        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
//            return acronym.user.get(on: req).flatMap(to: View.self) { user in
//                return user.
//            }
//        }
//    }
    
    
}

struct IndexContext: Encodable {
    let title: String
    let acronyms: [Acronym]?
}

//struct <#name#> {
//    <#fields#>
//}
