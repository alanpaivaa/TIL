import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

//    let databaseName: String
//    let databasePort: Int
//
//    if app.environment == .testing {
//        databaseName = "vapor-test"
//        databasePort = 5433
//    } else {
//        databaseName = "vapor_database"
//        databasePort = 5432
//    }
//
//    app.databases.use(.postgres(
//        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
//        port: databasePort,
//        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
//        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
//        database: Environment.get("DATABASE_NAME") ?? databaseName
//    ), as: .psql)

    let database: DatabaseConfigurationFactory
    let databaseID: DatabaseID

    if app.environment == .testing {
        database = .sqlite(.memory)
        databaseID = .sqlite
    } else {
        database = .postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: 5432,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database"
        )
        databaseID = .psql
    }

    app.databases.use(database, as: databaseID)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())

    app.logger.logLevel = .debug

    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
