//
//  File.swift
//  
//
//  Created by Alan Paiva on 12/30/21.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("users")
            .delete()
    }
}
