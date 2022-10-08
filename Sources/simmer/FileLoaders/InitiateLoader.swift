//
//  InitiateLoader.swift
//  
//
//  Created by Brian Hasenstab on 9/2/22.
//

import Foundation

struct InitialPackageData {
    var postgres = false
    var mysql = false
    var mongodb = false
    var sqlite = false
    
    var redis = false
    
    var leaf = false
    
    var jwt = false
    
    var autoMigrator = true
    
    var port: Int?
}

final class InitiateLoader {
    static func loadAll(for name: String, packageData: InitialPackageData) {
        loadApp(name)
        loadPackageSwift(name, packageData: packageData)
        loadAppConfiguration(name, packageData: packageData)
        loadErsatzConfiguration(name, packageData: packageData)
        loadDotEnv(name, packageData: packageData)
        loadTestConfiguration(name: name)
        loadEnvironmentExtensions(name: name)
        loadDefaultRouter(name: name)
        loadDefaultFolders(name: name)
    }

    static func loadApp(_ name: String) {
        var defaultAppState = FileHandler.fetchDefaultFile("DefaultApp")
        defaultAppState = defaultAppState.replacingOccurrences(of: "::name::", with: name)
        
        FileHandler.createFileWithContents(defaultAppState, fileName: "main.swift", path: PathGenerator.load(path: .Run, name: name))
    }
    
    static func loadDotEnv(_ name: String, packageData: InitialPackageData) {
        var dotEnv = FileHandler.fetchDefaultFile("DotEnv")
        
        let postgresConfig = packageData.postgres ? "DATABASE_URL=postgres://\(name.lowercased()):\(name.lowercased())@localhost:5432/\(name.lowercased())" : ""
        dotEnv = dotEnv.replacingOccurrences(of: "::PG::", with: postgresConfig)
        
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
            dotEnv = dotEnv.replacingOccurrences(of: "// NOTE: THESE KEYS ARE NOT TO BE USED ON PRODUCTION, THEY ARE HERE TO SIMPLY BE ABLE TO START A DEV ENV WITH JWT", with: "")
            dotEnv = dotEnv.replacingOccurrences(of: "::SIGNING::", with: "")
            dotEnv = dotEnv.replacingOccurrences(of: "::PUBLIC::", with: "")
        }
        
        let redisConfig = packageData.redis ? "REDIS_URL=redis://127.0.0.1:6379" : ""
        dotEnv = dotEnv.replacingOccurrences(of: "::REDIS::", with: redisConfig)
        
        FileHandler.createFileWithContents(dotEnv, fileName: ".env", path: PathGenerator.load(path: .Root, name: name))
    }
    
    static func loadPackageSwift(_ name: String, packageData: InitialPackageData) {
        var packageManager = FileHandler.fetchDefaultFile("Package")
        packageManager = packageManager.replacingOccurrences(of: "::name::", with: name)
        var packages = [
            ".package(url: \"https://github.com/vapor/vapor.git\", from: \"4.0.0\"),",
            "\t\t.package(url: \"https://github.com/bhaze31/FormattedResponse.git\", from: \"0.0.1\"),"
        ]
        var dependencies = [
            ".product(name: \"Vapor\", package: \"vapor\"),",
            "\t\t\t\t.product(name: \"FormattedResponse\", package: \"FormattedResponse\"),",
        ]

        if packageData.postgres || packageData.mysql || packageData.mongodb || packageData.sqlite {
            packages.append("\t\t.package(url: \"https://github.com/vapor/fluent.git\", from: \"4.0.0\"),")
            dependencies.append("\t\t\t\t.product(name: \"Fluent\", package: \"fluent\"),")
            
            if packageData.postgres {
                packages.append("\t\t.package(url: \"https://github.com/vapor/fluent-postgres-driver.git\", from: \"2.1.0\"),")
                dependencies.append("\t\t\t\t.product(name: \"FluentPostgresDriver\", package: \"fluent-postgres-driver\"),")
            }
            
            if packageData.mysql {
                packages.append("\t\t.package(url: \"https://github.com/vapor/fluent-mysql-driver.git\", from: \"4.0s.0\"),")
                dependencies.append("\t\t\t\t.product(name: \"FluentMySQLDriver\", package: \"fluent-mysql-driver\"),")
            }
            
            if packageData.mongodb {
                packages.append("\t\t.package(url: \"https://github.com/vapor/fluent-mongo-driver.git\", from: \"1.0.0\"),")
                dependencies.append("\t\t\t\t.product(name: \"FluentMongoDriver\", package: \"fluent-mongo-driver\"),")
            }
            
            if packageData.sqlite {
                packages.append("\t\t.package(url: \"https://github.com/vapor/fluent-sqlite-driver.git\", from: \"4.0.0\"),")
                dependencies.append("\t\t\t\t.product(name: \"FluentSQLiteDriver\", package: \"fluent-sqlite-driver\"),")
            }
        }
        
        if packageData.jwt {
            packages.append("\t\t.package(url: \"https://github.com/vapor/jwt.git\", from: \"4.0.0\"),")
            dependencies.append("\t\t\t\t.product(name: \"JWT\", package: \"jwt\"),")
        }
        
        if packageData.leaf {
            packages.append("\t\t.package(url: \"https://github.com/vapor/leaf.git\", from: \"4.0.0\"),")
            dependencies.append("\t\t\t\t.product(name: \"Leaf\", package: \"leaf\"),")
        }
        
        if packageData.autoMigrator {
            packages.append("\t\t.package(url: \"https://github.com/bhaze31/AutoMigrator.git\", from: \"0.0.4\"),")
            dependencies.append("\t\t\t\t.product(name: \"AutoMigrator\", package: \"AutoMigrator\"),")
        }

        if packageData.redis {
            packages.append("\t\t.package(url: \"https://github.com/vapor/redis.git\", from: \"4.0.0\"),")
            dependencies.append("\t\t\t\t.product(name: \"Redis\", package: \"redis\"),")
            
            packages.append("\t\t.package(url: \"https://github.com/vapor/queues-redis-driver.git\", from: \"1.0.0\"),")
            dependencies.append("\t\t\t\t.product(name: \"QueuesRedisDriver\", package: \"queues-redis-driver\"),")
        }
        
        packageManager = packageManager.replacingOccurrences(of: "::packages::", with: packages.joined(separator: "\n"))
        packageManager = packageManager.replacingOccurrences(of: "::dependencies::", with: dependencies.joined(separator: "\n"))

        FileHandler.createFileWithContents(packageManager, fileName: "Package.swift", path: PathGenerator.load(path: .Root, name: name))
    }
    
    static func loadErsatzConfiguration(_ name: String, packageData: InitialPackageData) {
        var ersatzConfig = FileHandler.fetchDefaultFile("ErsatzConfiguration")
        ersatzConfig = ersatzConfig.replacingOccurrences(of: "::name::", with: name)
        ersatzConfig = ersatzConfig.replacingOccurrences(of: "::autoMigrate::", with: packageData.autoMigrator.description)
        
        FileHandler.createFileWithContents(
            ersatzConfig,
            fileName: "ersatz.json",
            path: PathGenerator.load(path: .Root, name: name)
        )
    }
    
    static func loadAppConfiguration(_ name: String, packageData: InitialPackageData) {
        var appConfiguration = FileHandler.fetchDefaultFile("AppConfiguration")
        appConfiguration = appConfiguration.replacingOccurrences(of: "::port::", with: "\(packageData.port ?? 3162)")
        
        var imports = ["import Vapor", "import AutoMigrator"]
        
        if packageData.postgres || packageData.mysql || packageData.sqlite || packageData.mongodb {
            imports.append("import Fluent")
            
            var dbConfiguration: String = ""
            if packageData.postgres {
                imports.append("import FluentPostgresDriver")
                dbConfiguration = FileHandler.fetchDefaultFile("FluentPostgresConfiguration")
            }
            
            if packageData.sqlite {
                imports.append("import FluentSQLiteDriver")
            }
            
            if packageData.mongodb {
                imports.append("import FluentMongoDriver")
            }
            
            if packageData.mysql {
                imports.append("import FluentMySQLDriver")
            }
            
            appConfiguration = appConfiguration.replacingOccurrences(of: "::fluent::", with: dbConfiguration)
            appConfiguration = appConfiguration.replacingOccurrences(of: "::sessions::", with: "app.sessions.use(.fluent)\n\tapp.middleware.use(app.sessions.middleware)")
        } else {
            appConfiguration = appConfiguration.replacingOccurrences(of: "::fluent::", with: "")
            appConfiguration = appConfiguration.replacingOccurrences(of: "::sessions::", with: "app.middleware.use(app.sessions.middleware)")
        }
        
        if packageData.leaf {
            let leafConfig = """
            app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
            
            \tapp.views.use(.leaf)
            """
            
            appConfiguration = appConfiguration.replacingOccurrences(of: "::leaf::", with: leafConfig)
            
            imports.append("import Leaf")
        } else {
            appConfiguration = appConfiguration.replacingOccurrences(of: "::leaf::", with: "")
        }
        
        if packageData.jwt {
            imports.append("import JWT")
            
            appConfiguration = appConfiguration.replacingOccurrences(of: "::jwt::", with: "try app.jwt.signers.use(.rs256(key: .private(pem: Environment.privateKey)), kid: \"private\")\n\ttry app.jwt.signers.use(.rs256(key: .public(pem: Environment.publicKey)), kid: \"public\")")          
        } else {
            appConfiguration = appConfiguration.replacingOccurrences(of: "::jwt::", with: "")
        }
        
        let redisConfig = packageData.redis ? "try app.queues.use(.redis(url: Environment.redisURL))" : ""
        appConfiguration = appConfiguration.replacingOccurrences(of: "::redis::", with: redisConfig)
        
        let autoMigrationConfiguration = "app.loadAutoMigrations(migrationsPath: \"Sources/\(name)/Migrations\", namespace: \"\(name)\", fatalErrorOnInvalidClass: true)"
        appConfiguration = appConfiguration.replacingOccurrences(of: "::migrations::", with: autoMigrationConfiguration)
        
        appConfiguration = appConfiguration.replacingOccurrences(of: "::imports::", with: imports.joined(separator: "\n"))
        
        FileHandler.createFileWithContents(appConfiguration, fileName: "configure.swift", path: PathGenerator.load(path: .App, name: name))
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
