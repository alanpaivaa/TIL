//
//  File.swift
//  
//
//  Created by Alan Paiva on 12/29/21.
//

import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let acronymRoutes = routes.grouped("api", "acronyms")

        // GET
        acronymRoutes.get(use: getAllHandler)
        acronymRoutes.get(":acronymID", use: getOneHandler)
        acronymRoutes.get("search", use: searchHandler)
        acronymRoutes.get("first", use: firstHandler)
        acronymRoutes.get("sorted", use: sortedHandler)
        acronymRoutes.get(":acronymID", "user", use: getUserHandler)

        // POST
        acronymRoutes.post(use: createHandler)

        // PUT
        acronymRoutes.put(":acronymID", use: updateHandler)

        // DELETE
        acronymRoutes.delete(":acronymID", use: deleteHandler)
    }

    // MARK: - GET

    private func getAllHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }

    private func getOneHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym
            .find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    private func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }

        return Acronym
            .query(on: req.db)
            .group(.or, { or in
                or.filter(\.$short == searchTerm)
                or.filter(\.$long == searchTerm)
            })
            .all()
    }

    private func firstHandler(_ req: Request) -> EventLoopFuture<Acronym> {
        Acronym
            .query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    private func sortedHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Acronym
            .query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }

    private func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
        let acronymID = req.parameters.get("acronymID", as: UUID.self)
        return Acronym
            .find(acronymID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }

    // MARK: - POST

    private func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let acronymData = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: acronymData.short, long: acronymData.long, userID: acronymData.userID)
        return acronym.save(on: req.db).map { acronym }
    }

    // MARK: - PUT

    private func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updateData = try req.content.decode(CreateAcronymData.self)
        let acronymID = req.parameters.get("acronymID", as: UUID.self)
        return Acronym
            .find(acronymID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym -> EventLoopFuture<Acronym> in
                acronym.short = updateData.short
                acronym.long = updateData.long
                acronym.$user.id = updateData.userID
                return acronym
                    .save(on: req.db)
                    .map { acronym }
            }
    }

    // MARK: - DELETE

    private func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let acronymID = req.parameters.get("acronymID", as: UUID.self)
        return Acronym
            .find(acronymID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym -> EventLoopFuture<HTTPStatus> in
                acronym
                    .delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}

// DTO
private struct CreateAcronymData: Content {
    let short: String
    let long: String
    let userID: UUID

}
