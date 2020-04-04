//import FluentSQLite
import FluentMySQL
import Vapor
import Leaf
import Authentication


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())
//    try services.register(FluentSQLiteProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let databaseConfig = MySQLDatabaseConfig(hostname: "localhost", username: "artem", password: "password", database: "vapor")
    let database = MySQLDatabase(config: databaseConfig)
//    let sqlite = try SQLiteDatabase(storage: .memory)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: database, as: .mysql)
//    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Acronym.self, database: DatabaseIdentifier<Acronym.Database>.mysql)
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.mysql)
    migrations.add(model: Category.self, database: DatabaseIdentifier<Category.Database>.mysql)
    migrations.add(model: AcronymCategoryPivot.self, database: DatabaseIdentifier<AcronymCategoryPivot.Database>.mysql)
    migrations.add(model: Token.self, database: DatabaseIdentifier<Token.Database>.mysql)
    services.register(migrations)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
