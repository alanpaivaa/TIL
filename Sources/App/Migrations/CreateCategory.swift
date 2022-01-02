//
//  File.swift
//  
//
//  Created by Alan Paiva on 1/2/22.
//

import Fluent

struct CreateCategory: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("categories")
            .delete()
    }
}
