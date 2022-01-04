//
//  File.swift
//  
//
//  Created by Alan Paiva on 1/3/22.
//

@testable import App
import Vapor

extension Application {
    static func testable() throws -> Application {
        let app = Application(.testing)
        try configure(app)
        return app
    }
}
