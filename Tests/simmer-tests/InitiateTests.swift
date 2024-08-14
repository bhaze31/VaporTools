import XCTest
@testable import simmer

final class InitiateTests: XCTestCase {

  func testDefaultConfiguration() throws {
    // By default, we have a configuration that contains Redis, Leaf, JWT,
    // and SQLite. It should create an environment
    let appName = "Testing"

    try? FileHandler.cleanup(app: PathGenerator.load(path: .App, name: appName))

    let config = InitialPackageData(
      database: .SQLite,
      redis: true,
      port: 3100
    )

    InitiateLoader.loadAll(for: appName, packageData: config)

    let appPath = PathGenerator.load(path: .App, name: appName)

    // The entrypoint is a static file. If it exists then we
    // are okay to proceed
    XCTAssertEqual(
      FileManager.default.fileExists(
        atPath: "\(appPath)/entrypoint.swift"
      ),
      true,
      "entrypoint.swift file should exist at path \(appPath)"
    )

    XCTAssertEqual(
      FileManager.default.fileExists(
        atPath: "\(appPath)/configure.swift"
      ),
      true,
      "configure.swift file should exist at path \(appPath)"
    )

    if let file = try? String(contentsOfFile: "\(appPath)/configure.swift") {
      ["Vapor",
      "AutoMigrator",
      "Fluent",
      "Leaf",
      "FluentSQLiteDriver"].forEach { package in
        XCTAssert(
          file.contains("import \(package)"),
          "\(package) should be imported by default")
      }

      XCTAssert(
        file.contains("app.http.server.configuration.port = 3100"),
        "Defined port should be respected"
      )

      // Leaf configurations
      XCTAssert(
        file.contains("app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))"),
        "Leaf file middleware should be used"
      )

      XCTAssert(
        file.contains("app.views.use(.leaf)"),
        "Views should load Leaf"
      )

      // Database info
      XCTAssert(
        file.contains("app.databases.use(.sqlite(.file(\"db.sqlite\")), as: .sqlite)"),
        "Should be using the SQLite database"
      )

      // Redis info
      XCTAssert(
        file.contains("app.redis.configuration = try RedisConfiguration(url: Environment.redisUrl)"),
        "Should load a Redis connection"
      )

      XCTAssert(
        file.contains("app.sessions.use(.redis)"),
        "Sessions should use Redis"
      )

      // Session data
      XCTAssert(
        file.contains("app.middleware.use(app.sessions.middleware)"),
        "Should use sessions for the middleware"
      )

      // Auto-Migration content
      XCTAssert(
        file.contains("app.loadAutoMigrations(migrationsPath: \"Sources/\(appName)/Migrations\", namespace: \"\(appName)\", fatalErrorOnInvalidClass: true)"),
        "Auto migrations should be loaded for the correct app name"
      )
    } else {
      XCTFail("Could not load the string contents of the configure.swift file, loader failed")
    }

    // Check proper folders were created
    var directory: ObjCBool = true
    XCTAssert(
      FileManager.default.fileExists(atPath: PathGenerator.load(path: .Controller, name: appName), isDirectory: &directory),
      "Controllers path should exist: \(PathGenerator.load(path: .Controller))"
    )

    XCTAssert(
      FileManager.default.fileExists(atPath: PathGenerator.load(path: .Extensions, name: appName), isDirectory: &directory),
      "Extensions path should exist: \(PathGenerator.load(path: .Extensions))"
    )

    XCTAssert(
      FileManager.default.fileExists(atPath: PathGenerator.load(path: .Middleware, name: appName), isDirectory: &directory),
      "Middleware path should exist: \(PathGenerator.load(path: .Middleware))"
    )

    XCTAssert(
      FileManager.default.fileExists(atPath: PathGenerator.load(path: .Migrations, name: appName), isDirectory: &directory),
      "Migrations path should exist: \(PathGenerator.load(path: .Migrations))"
    )

    XCTAssert(
      FileManager.default.fileExists(atPath: PathGenerator.load(path: .Model, name: appName), isDirectory: &directory),
      "Models path should exist: \(PathGenerator.load(path: .Model))"
    )

    try? FileHandler.cleanup(app: PathGenerator.load(path: .App, name: appName))
  }

  func testMySQLConfiguration() {

  }

  func testPostgreSQLConfiguration() {

  }

  func testMongoDBConfiguration() {

  }
}