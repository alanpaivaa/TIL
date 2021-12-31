//
//  File.swift
//  
//
//  Created by Alan Paiva on 12/30/21.
//

import Vapor

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")

        // GET
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userID", use: getOneHandler)
        usersRoute.get(":userID", "acronyms", use: getAcronymsHandler)

        // POST
        usersRoute.post(use: createHandler)
    }

    // MARK: - GET

    private func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }

    private func getOneHandler(_ req: Request) -> EventLoopFuture<User> {
        let userID = req.parameters.get("userID", as: UUID.self)
        return User
            .find(userID, on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    private func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        let userID = req.parameters.get("userID", as: UUID.self)
        return User
            .find(userID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$acronyms.get(on: req.db)
            }
    }

    // MARK: - POST

    private func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }
}
