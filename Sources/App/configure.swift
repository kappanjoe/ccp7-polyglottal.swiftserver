import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

public func configure(_ app: Application) async throws {
	try app.databases.use(.postgres(url: ProcessInfo.processInfo.environment["POSTGRES_URL"] ?? ""), as: .psql)
	app.migrations.add(UserMigration())
	app.migrations.add(MessageLogMigration())
	app.migrations.add(MessageRecipientMigration())
	app.migrations.add(UniqueMessageRecipientMigration())
	
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
	app.views.use(.leaf)
	
	let connectionController = ConnectionController(eventLoop: app.eventLoopGroup.next())
	
	app.webSocket("channel") { req, ws in
		connectionController.connect(ws, db: app.db)
	}
	
    try routes(app)
}
