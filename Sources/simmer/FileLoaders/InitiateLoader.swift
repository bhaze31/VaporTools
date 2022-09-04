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
    }

    static func loadApp(_ name: String) {
        var defaultAppState = FileHandler.fetchDefaultFile("DefaultApp")
        defaultAppState = defaultAppState.replacingOccurrences(of: "::name::", with: name)
        
        FileHandler.createFileWithContents(defaultAppState, fileName: "main.swift", path: PathGenerator.load(path: .Run, name: name))
    }
    
    static func loadDotEnv(_ name: String, packageData: InitialPackageData) {
        var dotEnv = FileHandler.fetchDefaultFile("DotEnv")
        
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
        
        var imports = ["import Vapor"]
        
        if packageData.postgres || packageData.mysql || packageData.sqlite || packageData.mongodb {
            imports.append("import Fluent")
            
            var dbConfiguration: String = ""
            if packageData.postgres {
                dbConfiguration = """
                if var config = PostgresConfiguration(url: Environment.databaseURL),
                   ["development", "production"].contains(app.environment.name) {
                    if app.environment.isRelease {
                        config.tlsConfiguration = TLSConfiguration.makeClientConfiguration()
                    }
                    
                    app.databases.use(.postgres(configuration: config), as: .psql)
                } else {
                    if let config = PostgresConfiguration(url: Environment.databaseURL) {
                        app.databases.use(.postgres(configuration: config), as: .psql)
                    }
                }
                """
            }
            
            appConfiguration = appConfiguration.replacingOccurrences(of: "::fluent::", with: dbConfiguration)
        } else {
            appConfiguration = appConfiguration.replacingOccurrences(of: "::fluent::", with: "")
        }
        
        if packageData.leaf {
            let leafConfig = """
            app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
            
            \t\tapp.views.use(.leaf)
            """
            
            appConfiguration = appConfiguration.replacingOccurrences(of: "::leaf::", with: leafConfig)
            
            imports.append("import Leaf")
        } else {
            appConfiguration = appConfiguration.replacingOccurrences(of: "::leaf::", with: "")
        }
        
        FileHandler.createFileWithContents(appConfiguration, fileName: "configure.swift", path: PathGenerator.load(path: .App, name: name))
    }
}
