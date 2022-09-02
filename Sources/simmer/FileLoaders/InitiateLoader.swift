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
}

final class InitiateLoader {
    static func loadAll(for name: String, packageData: InitialPackageData) {
        loadApp(name)
        loadPackageSwift(name, packageData: packageData)
        loadAppConfiguration(name)
        loadErsatzConfiguration(name, packageData: packageData)
    }
    static func loadApp(_ name: String) {
        var defaultAppState = FileHandler.fetchDefaultFile("DefaultApp")
        defaultAppState = defaultAppState.replacingOccurrences(of: "::name::", with: name)
        
        FileHandler.createFileWithContents(defaultAppState, fileName: "main.swift", path: .RunPath)
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
            "\t\t\t\t.product(name: \"FormattedResponse\", package: \"FormattedResponse\")",
        ]

        if packageData.postgres || packageData.mysql || packageData.mongodb || packageData.sqlite {
            packages.append("\t\t.package(url: \"https://github.com/vapor/fluent.git\", from: \"4.0.0\")")
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

        FileHandler.createFileWithContents(packageManager, fileName: "Package.swift", path: .RootPath)
    }
    
    static func loadErsatzConfiguration(_ name: String, packageData: InitialPackageData) {
        var ersatzConfig = FileHandler.fetchDefaultFile("ErsatzConfiguration")
        ersatzConfig = ersatzConfig.replacingOccurrences(of: "::name::", with: name)
        ersatzConfig = ersatzConfig.replacingOccurrences(of: "::autoMigrate::", with: packageData.autoMigrator.description)
        
        
        FileHandler.createFileWithContents(
            ersatzConfig,
            fileName: "ersatz.json",
            path: .RootPath
        )
    }
    
    static func loadAppConfiguration(_ name: String) {
        
    }
}
