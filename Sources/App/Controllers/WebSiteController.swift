//
//  Created by Alan Paiva on 1/11/22.
//

import Foundation
import Vapor

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.get("acronyms", ":acronymID", use: acronymHandler)
        routes.get("acronyms/:acronymID", use: acronymHandler)
    }

    private func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Acronym.query(on: req.db).all().flatMap { acronyms -> EventLoopFuture<View> in
            let context = IndexContext(
                title: "Home Page",
                acronyms: acronyms.isEmpty ? nil : acronyms
            )
            return req.view.render("index", context)
        }
    }

    private func acronymHandler(_ req: Request) throws -> EventLoopFuture<View> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db).flatMap { user in
                    let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                    return req.view.render("acronym", context)
                }
        }
    }
}

struct IndexContext: Codable {
    let title: String
    let acronyms: [Acronym]?
}

struct AcronymContext: Codable {
    let title: String
    let acronym: Acronym
    let user: User
}
