import Foundation

final class ConfigurationGenerator {

	private static func useRedis() -> String {
		// TODO: Add Redis as an import, include use Redis
		return ""
	}
	
	private static func useJWT() -> String {
		// TODO: Load Keys from environment, add JWT as an import
		return ""
	}
	
	private static func useSessions() -> String {
		// TODO: Add session middleware 
		return ""
	}
	
	static func generateBaseConfiguration() -> String {
		return """
		import Fluent
		import FluentPostgresDriver
		import Leaf
		import Vapor
		import AutoMigrator
		
		public func configure(_ app: Application) throws {
			app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
		
			app.databases.use(.postgres(
				hostname: Environment.get("DATABASE_HOST") ?? "localhost",
				port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
				username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
				password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
				database: Environment.get("DATABASE_NAME") ?? "vapor_database"
			), as: .psql)
		
			app.views.use(.leaf)

			app.loadAutoMigrations()
		
			try routes(app)
		}
		"""
	}
	
	static func generateRedisConfiguration() -> String {
		return """
		import Fluent
		import FluentPostgresDriver
		import Leaf
		import Vapor
		import Redis
		import AutoMigrator
		
		public func configure(_ app: Application) throws {
			app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
		
			app.databases.use(.postgres(
				hostname: Environment.get("DATABASE_HOST") ?? "localhost",
				port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
				username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
				password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
				database: Environment.get("DATABASE_NAME") ?? "vapor_database"
			), as: .psql)
		
			app.views.use(.leaf)
			
			app.redis.configuration = try RedisConfiguration(hostname: "localhost")
		
			app.loadAutoMigrations()

			try routes(app)
		}
		"""
	}
}