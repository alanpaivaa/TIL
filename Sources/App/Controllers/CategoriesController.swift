//
//  File.swift
//  
//
//  Created by Alan Paiva on 1/2/22.
//

import Vapor

struct CategoriesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categoriesRoutes = routes.grouped("api", "categories")

        // GET
        categoriesRoutes.get(use: getAllHandler)
        categoriesRoutes.get(":categoryID", use: getOneHandler)
        categoriesRoutes.get(":categoryID", "acronyms", use: getAcronymsHandler)

        // POST
        categoriesRoutes.post(use: createHandler)
    }

    // MARK: - GET

    private func getAllHandler(_ req: Request) -> EventLoopFuture<[Category]> {
        Category
            .query(on: req.db)
            .all()
    }

    private func getAcronymsHandler(_ req: Request) -> EventLoopFuture<[Acronym]> {
        Category
            .find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                category
                    .$acronyms
                    .get(on: req.db)
            }
    }

    private func getOneHandler(_ req: Request) -> EventLoopFuture<Category> {
        let id = req.parameters.get("categoryID", as: UUID.self)
        return Category
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    // MARK: - POST

    private func createHandler(_ req: Request) throws -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category
            .save(on: req.db)
            .map { category }
    }
}
