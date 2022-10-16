//
//  File.swift
//  
//
//  Created by Brian Hasenstab on 10/15/22.
//

import Foundation

final class ModelLoader {
    static func generateModel(options: ModelOptions) {
        var schema = options.name.toTrainCase()
        if let _schema = options.schemaName {
            schema = _schema
        }
        
        var id = "@ID(key: Keys.id) var id: UUID?"
        
        // TODO: Handle custom ID type
        if let customID = options.customIdName {
            id = "@ID(key: Keys.\(customID)) var id: UUID?"
        }
        
        var keys: [String]  = [getIDKey(options: options)]
        keys.append(contentsOf: options.fields.map(getFieldKey))
        keys.append(contentsOf: getTimestampKeys(options: options))
        let defaultModel = FileHandler.fetchDefaultFile("Model")
            .swap("::model_name::", to: options.name)
            .swap("::model_id::", to: id)
            .swap("::schema::", to: "\"\(schema)\"")
            .swap("::keys::", to: keys.joined(separator: "\n\t\t"))
            .swap("::model_fields::", to: options.fields.map(getField).joined(separator: "\n\t"))
            .swap("::timestamps::", to: getTimestampFields(options: options))
        
        print(defaultModel)
    }
    
    static func getIDKey(options: ModelOptions) -> String {
        if let idName = options.customIdName {
            return "static var \(idName.toCamelCase()): FieldKey { \"\(idName.toTrainCase())\" }"
        } else {
            return "statis var id: FieldKey { \"id\" }"
        }
    }
    
    static func getFieldKey(field: Field) -> String {
        return "static var \(field.name.toCamelCase()): FieldKey { \"\(field.name.toTrainCase())\" }"
    }
    
    static func getField(field: Field) -> String {
        return "@Field(key: Keys.\(field.name.toCamelCase())) var \(field.name): \(field.getSwiftType())"
    }
    
    static func getTimestampFields(options: ModelOptions) -> String {
        if options.skipTimestamps && !options.softDelete {
            return ""
        }
        
        var timestamps: [String] = []
        
        if !options.skipTimestamps {
            timestamps.append("@Timestamp(key: Keys.createdAt, on: .create) var createdAt: Date?")
            timestamps.append("@Timestamp(key: Keys.updatedAt, on: .update) var updatedAt: Date?")
        }
        
        if options.softDelete {
            timestamps.append("@Timestamp(key: Keys.deletedAt, on: .delete) var deletedAt: Date?")
        }
        
        return timestamps.joined(separator: "\n\t")
    }
    
    static func getTimestampKeys(options: ModelOptions) -> [String] {
        if options.skipTimestamps && !options.softDelete {
            return [""]
        }
        
        var timestampKeys: [String] = []
        
        if !options.skipTimestamps {
            timestampKeys.append("static var createdAt: FieldKey { \"created_at\" }")
            timestampKeys.append("static var updatedAt: FieldKey { \"updated_at\" }")
        }
        
        if options.softDelete {
            timestampKeys.append("static var deletedAt: FieldKey { \"deleted_at\" }")
        }
        
        return timestampKeys
    }
}
