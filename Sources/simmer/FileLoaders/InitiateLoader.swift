//
//  InitiateLoader.swift
//
//
//  Created by Brian Hasenstab on 9/2/22.
//

import Foundation

func padding(_ tabCount: Int = 2, tabSize: Int = 4) -> String {
    let padding = String(repeating: " ", count: tabSize)
    return String(repeating: padding, count: tabCount)
}

enum DatabasePackage: String {
    case SQLite = "sqlite"
    case PostgreSQL = "postgres"
    case MySQL = "mysql"
    case MongoDB = "mongodb"

    var baseVersion: String {
        self == .MongoDB ? "1.0.0" : "4.0.0"
    }

    var driverVersion: String {
        switch self {
        case .SQLite:
            return "FluentSQLiteDriver"
        case .PostgreSQL:
            return "FluentPostgresDriver"
        case .MySQL:
            return "FluentMySQLDriver"
        case .MongoDB:
            return "FluentMongoDriver"
        }
    }
}

struct InitialPackageData {
    var database: DatabasePackage

    var redis = false

    var jwt = false

    var port: Int?
}

final class InitiateLoader {
    static func loadAll(for name: String, packageData: InitialPackageData) {
        loadApp(name)
        loadPackageSwift(name, packageData: packageData)
        loadAppConfiguration(name, packageData: packageData)
        loadDotEnv(name, packageData: packageData)
        loadTestConfiguration(name: name)
        loadEnvironmentExtensions(name: name)
        loadDefaultRouter(name: name)
        loadDefaultFolders(name: name)
    }

    static func loadApp(_ name: String) {
        FileHandler.createFileWithContents(FileHandler.fetchDefaultFile("Entrypoint"), fileName: "entrypoint.swift", path: PathGenerator.load(path: .App, name: name))
    }

    static func loadPackageSwift(_ name: String, packageData: InitialPackageData) {
        var packageManager = FileHandler.fetchDefaultFile("Package")
        packageManager = packageManager.replacingOccurrences(of: "::name::", with: name)
        var packages: [String] = []
        var dependencies: [String] = []

        let db = packageData.database
        packages.append("\(padding()).package(url: \"https://github.com/vapor/fluent-\(db.rawValue)-driver.git\", from: \"\(db.baseVersion)\"),")

        dependencies.append("\(padding(4)).product(name: \"FluentSQLiteDriver\", package: \"fluent-\(packageData.database)-driver\"),")

        if packageData.jwt {
            packages.append("\(padding()).package(url: \"https://github.com/vapor/jwt.git\", from: \"4.0.0\"),")
            dependencies.append("\(padding(4)).product(name: \"JWT\", package: \"jwt\"),")
        }

        if packageData.redis {
            packages.append("\(padding()).package(url: \"https://github.com/vapor/redis.git\", from: \"4.0.0\"),")
            dependencies.append("\(padding(4)).product(name: \"Redis\", package: \"redis\"),")
        }

        packageManager = packageManager.replacingOccurrences(of: "::packages::", with: packages.joined(separator: "\n"))
        packageManager = packageManager.replacingOccurrences(of: "::dependencies::", with: dependencies.joined(separator: "\n"))

        FileHandler.createFileWithContents(packageManager, fileName: "Package.swift", path: PathGenerator.load(path: .Root, name: name))
    }

    static func loadAppConfiguration(_ name: String, packageData: InitialPackageData) {
        var appConfiguration = FileHandler.fetchDefaultFile("AppConfiguration")

        appConfiguration = appConfiguration.replacingOccurrences(of: "::port::", with: "\(packageData.port ?? 3162)")

        var imports: [String] = ["import \(packageData.database.driverVersion)"]

        switch packageData.database {
        case .SQLite:
            appConfiguration = appConfiguration.replacingOccurrences(of: "::fluent::", with: "app.databases.use(.sqlite(.file(\"db.sqlite\")), as: .sqlite)")
        case .MongoDB:
            appConfiguration = appConfiguration.replacingOccurrences(of: "::fluent::", with: """
            try app.databases.use(.mongo(connectionString: Environment.databaseUrl), as: .mongo)
            """)
        case .MySQL:
            appConfiguration = appConfiguration.replacingOccurrences(of: "::fluent::", with: """
            var tls = TLSConfiguration.makeClientConfiguration()
            tls.certificateVerification = .none

            app.databases.use(
                .mysql(
                    hostname: Environment.dbHost,
                    username: Environment.dbUsername,
                    password: Environment.dbPassword,
                    database: Environment.dbName,
                    tlsConfiguration: tls
                ),
                as: .mysql
            )
            """)
        case .PostgreSQL:
            appConfiguration = appConfiguration.replacingOccurrences(of: "::fluent::", with: """
            app.databases.use(
                .postgres(
                    configuration: .init(
                        hostname: Environment.dbHost,
                        username: Environment.dbUsername,
                        password: Environment.dbPassword,
                        database: Environment.dbName,
                        tls: .disable
                    )
                ),
                as: .psql
            )
            """)

        }

        if packageData.jwt {
            imports.append("import JWT")

            appConfiguration = appConfiguration.replacingOccurrences(of: "::jwt::", with: """
            try app.jwt.signers.use(.rs256(key: .private(pem: Environment.privateKey)), kid: \"private\")
            try app.jwt.signers.use(.rs256(key: .public(pem: Environment.publicKey)), kid: \"public\")
            """)
        } else {
            appConfiguration = appConfiguration.replacingOccurrences(of: "::jwt::", with: "")
        }

        if packageData.redis {
            imports.append("import Redis")

            appConfiguration = appConfiguration.replacingOccurrences(of: "::redis::", with: "app.redis.configuration = try RedisConfiguration(url: Environment.redisUrl)")

            appConfiguration = appConfiguration.replacingOccurrences(of: "::sessions::", with: "app.sessions.use(.redis)")
        } else {
            appConfiguration = appConfiguration.replacingOccurrences(of: "::redis::", with: "")

            appConfiguration = appConfiguration.replacingOccurrences(of: "::sessions::", with: "")
        }

        let autoMigrationConfiguration = "app.loadAutoMigrations(migrationsPath: \"Sources/\(name)/Migrations\", namespace: \"\(name)\", fatalErrorOnInvalidClass: true)"
        appConfiguration = appConfiguration.replacingOccurrences(of: "::migrations::", with: autoMigrationConfiguration)

        appConfiguration = appConfiguration.replacingOccurrences(of: "::imports::", with: imports.joined(separator: "\n"))

        FileHandler.createFileWithContents(appConfiguration, fileName: "configure.swift", path: PathGenerator.load(path: .App, name: name))
    }

    static func loadDotEnv(_ name: String, packageData: InitialPackageData) {
        var dotEnv = FileHandler.fetchDefaultFile("DotEnv")

        if packageData.database == .MongoDB {
            // We use a connection string here, as opposed to using host/user/pass
            dotEnv = dotEnv.replacingOccurrences(of: "::DB::", with: "DATABASE_URL=mongodb://vapor:vapor@localhost:27017/vapor")
        } else if packageData.database == .PostgreSQL || packageData.database == .MySQL {
            dotEnv = dotEnv.replacingOccurrences(of: "::DB::", with: """
            DATABASE_HOST=localhost
            DATABASE_NAME=vapor
            DATABASE_USER=vapor
            DATABASE_PASSWORD=password
            """)
        } else {
            // SQLite doesn't need the database configuration, so just remove it entirely
            dotEnv = dotEnv.replacingOccurrences(of: "::DB::", with: "")
        }

        if packageData.jwt {
            let signingKey = "SIGNING_KEY=LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBdXBlckl5OUlxb1hORWhqRjlXT0FGcUx4V3RXS2M1TnhvalZiR0VHMjZrS2VWcU1yCklNRWZhd2MybUJXKzVxNDE5cmZBc29IR3NhVXFTcVFyNThBVG5rOFM5TGxNUUVXOTBaejRjRmdaLzhZcENmZloKbEhTYmlLSlZpSGw1STdOSWlXdjRDazExS2xYRWN3cktzTmlMRWg1NHZRYjV4ZG95UjNtWFk3bnZPV1dYVWFWSQpmeERXRWRidndDMlNSTW9jNTFORDd4eVFvMWhPME5VNXREUUZubys0TThwUkN2Z1o0K0hBMDJ6em5aVEZBZXc4Cm9TNHd4ZDJ5VTUvd2g4R25TQm1zaXRtaTlyTDM2SzA2ZmNIbTMxUUhVQks0Q0FTc2FvMjRRYU9JWVltQzdUUkkKUjdkNVBvTE4vSkJRaVcxZy9ZcE5JK0VUTFMvbElzNDBxRXp4QXdJREFRQUJBb0lCQUFyV0VBeEZETFZLZS9SWApGL2YrUlV3TFBuVUYvYnBrajY3WjVtWnNPcEUwT1RuUzFBaGM3dFFxWVJOSUFBUXBqZHk4SXlhNnZxMUdhRVJaCmNHdFBEbFNkUnY2TFhGQkhQSlRWeHQvUFhnTXFvT3VCUjFPRnlocVBRdVJnR1pibkxJaytpZk1mT0hTeThtdXoKN3IyQ2RlRWhmK1dLYUNzRFZ2UXJyWTBQR1VOOTkzbUViV3ZWWlhOcmc3VnZRNVdOTnJVRHE1WEM1RHpacE11TwpLVEdTamZGZGFpa1VFTzQybm90VVlScEVEb2JaYVFPaFh0ZllVU3ZiN0hmb1RLNmJsNXB5OTVucWcxRktKMDBWClVZSzJ2TjhQV3dlZU11ZHBZUmlQaE9BblFpZmM0RWRHU2xSSVpPSVQ3a3h1TFV2QkNTbnRrTUlzdWNDb3lLbGIKblU2dWFBRUNnWUVBNDc5bjNtaDh2L1UzVmVjYlRlOEh2cDZ4SzVCWjE4ZVBZcmpTMktZRFBmYnN6UXU1YkZBagpyNVZTSDRYaC9GeFE0OWJ1cFRzZENOYy9LS3QvOEZrc2xMQTJlUDhLRDFuSmxZcHNWeHV4OEtzemVRSElnYlQwCmdnSnR5K2UrYlhKQS9keUJUQ3JTaE9ENEI0dEtkNGRvcmlOWkRFT3FSWnhHU2ZFQUpiM1h4Z0VDZ1lFQTBiMUwKVjRHYTNGaU9jTUVQZ2diZno4NllHWjUrUDgzTllxbm5iSUlJZElZdTJ4MXNYcGNUbHozUllpcmtYd3YvYW5LSQpIcVlGeVo1ZWUyaVQ2ODdJVCs4RlhmOFhNZllqRGpVTUhWeGxSek53ZFJXU2pSNXg3a2RDWmtDWVo4Nm9zZng3CmMrK0N6czBrZ3VNTWJKWDVFVnV3dklWeDNUWlhiSUZLVUdqTG53TUNnWUVBdG16bjkwZTh2VW5mWkNpMVAweTYKNkY1V3plMVhlYmI0ekh2OUw5cHllRnprdXkyci9lMkhXQ3FFV0ltMlJaMXdrYi9rOG1jU1Q3V1Nlckk4emJtdwpNdjJlOUhaZGlZUkRLMHh3a2FtMmMyKyswQ3UwZnVrQ2ZXMFNvNlRpYk9wNjBwMmcxL0RwSmRUSjk4a0VBaEJ0CnNpYlFPam10RndzaFpqTHNDazh4bWdFQ2dZQmxKOTdHZllPcThpc0F4cHdzSWhTZnJRdytqdXBrNjJVN1NLYU0KOXNvTktRcEFNNWlvcGtTVWxRUC9US0NJRnNsQkZhd0EzQ0crYzlzdHVlcGR1SVZ6eDl2VzBjam1GOGdnZWdVMQp3L0kwdk9Kb0ZkZHdxRlphalpQQXJUYlVHaC9TZCtzeXB6bDNkQWsvOXpGdXpZWXFrUVpVWmlmY2dQRDVMQUlqCmRlZCs4UUtCZ1FEZ3FPZ3RhdDJVa2Yya0pHOEdGZ21qR0xEbWlJeExNdHVoazdoNUtnYk14OXdpTG5ubEtod2EKSXNQOEdEOXVPQ1RkMXg2UXJwWTYxTTRFZHkyWVlDZUtPOEdMclBpejlnK0xObDlZc3Rrbld5b0FjWC9heW1kWApvdTRVSjl4WUhCUE1USDd2dnJzckVZU2FlMTljYXJtUmUxbmtuMUg0UjJzUjhRYzNQRzFXOUE9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="
            let publicKey = "PUBLIC_KEY=LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF1cGVySXk5SXFvWE5FaGpGOVdPQQpGcUx4V3RXS2M1TnhvalZiR0VHMjZrS2VWcU1ySU1FZmF3YzJtQlcrNXE0MTlyZkFzb0hHc2FVcVNxUXI1OEFUCm5rOFM5TGxNUUVXOTBaejRjRmdaLzhZcENmZlpsSFNiaUtKVmlIbDVJN05JaVd2NENrMTFLbFhFY3dyS3NOaUwKRWg1NHZRYjV4ZG95UjNtWFk3bnZPV1dYVWFWSWZ4RFdFZGJ2d0MyU1JNb2M1MU5EN3h5UW8xaE8wTlU1dERRRgpubys0TThwUkN2Z1o0K0hBMDJ6em5aVEZBZXc4b1M0d3hkMnlVNS93aDhHblNCbXNpdG1pOXJMMzZLMDZmY0htCjMxUUhVQks0Q0FTc2FvMjRRYU9JWVltQzdUUklSN2Q1UG9MTi9KQlFpVzFnL1lwTkkrRVRMUy9sSXM0MHFFengKQXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg=="
            dotEnv = dotEnv.replacingOccurrences(of: "::SIGNING::", with: signingKey)
            dotEnv = dotEnv.replacingOccurrences(of: "::PUBLIC::", with: publicKey)

            PrettyLogger.info("WARNING")
            PrettyLogger.info("WARNING")
            PrettyLogger.info("")
            PrettyLogger.info("")
            PrettyLogger.info("The keys in the .env file should NOT be copied to production, they are used to start the dev environment")
            PrettyLogger.info("")
            PrettyLogger.info("")
            PrettyLogger.info("WARNING")
            PrettyLogger.info("WARNING")
        } else {
            dotEnv = dotEnv.replacingOccurrences(of: "::SIGNING::", with: "")
            dotEnv = dotEnv.replacingOccurrences(of: "::PUBLIC::", with: "")
        }

        let redisConfig = packageData.redis ? "REDIS_URL=redis://localhost:6379" : ""
        dotEnv = dotEnv.replacingOccurrences(of: "::REDIS::", with: redisConfig)

        FileHandler.createFileWithContents(dotEnv, fileName: ".env", path: PathGenerator.load(path: .Root, name: name))
    }

    static func loadTestConfiguration(name: String) {
        var testConfiguration = FileHandler.fetchDefaultFile("BaseTest")
        testConfiguration = testConfiguration.replacingOccurrences(of: "::name::", with: name)

        FileHandler.createFileWithContents(testConfiguration, fileName: "\(name)Tests.swift", path: PathGenerator.load(path: .Test, name: name))
    }

    static func loadEnvironmentExtensions(name: String) {
        FileHandler.createFileWithContents(FileHandler.fetchDefaultFile("EnvExtensions"), fileName: "Enviroment+Extensions.swift", path: PathGenerator.load(path: .Extensions, name: name))
    }

    static func loadDefaultRouter(name: String) {
        FileHandler.createFileWithContents(FileHandler.fetchDefaultFile("BaseRouter"), fileName: "routes.swift", path: PathGenerator.load(path: .App, name: name))
    }

    static func loadDefaultFolders(name: String) {
        FileHandler.createFolderUnlessExists(PathGenerator.load(path: .Controller, name: name))
        FileHandler.createFolderUnlessExists(PathGenerator.load(path: .Migrations, name: name))
        FileHandler.createFolderUnlessExists(PathGenerator.load(path: .Middleware, name: name))
        FileHandler.createFileWithContents(FileHandler.fetchDefaultFile("HomeView"), fileName: "index.leaf", path: PathGenerator.load(path: .Views, name: name))
        FileHandler.createFolderUnlessExists(PathGenerator.load(path: .Model, name: name))
    }
}
