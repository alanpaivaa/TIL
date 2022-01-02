//
//  File.swift
//  
//
//  Created by Alan Paiva on 1/2/22.
//

import Fluent

struct CreateAcronymCategoryPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(AcronymCategoryPivot.schema)
            .id()
            .field("acronymID", .uuid, .required, .references("acronyms", "id", onDelete: .cascade))
            .field("categoryID", .uuid, .required, .references("categories", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(AcronymCategoryPivot.schema)
            .create()
    }
}
