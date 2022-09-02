//
//  File.swift
//  
//
//  Created by Brian Hasenstab on 9/1/22.
//

import Foundation

final class SwiftPackageLoader {
    struct Packages {
        var postgres = false
        var mysql = false
        var mongodb = false
        var sqlite = false
        
        var redis = false
        
        var leaf = false
        
        var jwt = false
        
        var autoMigrator = true
        
    }
    static func load(name: String, packageData: Packages = Packages()) {
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

        
        
        
        
        packageManager = packageManager.replacingOccurrences(of: "::packages::", with: packages.joined(separator: "\n"))
        packageManager = packageManager.replacingOccurrences(of: "::dependencies::", with: dependencies.joined(separator: "\n"))
        print(packageManager)
        FileHandler.createFileWithContents(packageManager, fileName: "Package.swift", path: .RootPath)
    }
}
