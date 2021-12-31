//
//  File.swift
//  
//
//  Created by Alan Paiva on 12/28/21.
//

import Foundation
import Fluent

struct CreateAcronym: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("acronyms")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("userID", .uuid, .required, .references("users", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("acronyms")
            .delete()
    }
}
