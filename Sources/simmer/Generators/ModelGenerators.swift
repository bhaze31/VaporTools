import Foundation

final class ModelGenerator {
    public static func generateModel(name: String, fields: [String], hasTimestamps: Bool = true) -> String {
        print("Generating model \(name.toModelCase())")
        
        let fs = extractFieldsData(fields: fields)

        let initializer = generateModelInitializer(fields: fs)

        let fieldKeys = generateFieldKeys(fields: fs, hasTimestamps: hasTimestamps)

        // TODO: Implement check for Int id flag
        let modelFields = generateFields(fields: fs, hasTimestamps: hasTimestamps)
        
        let model = """
        import Vapor
        import Fluent
        
        final class \(name.toModelCase()): ControllerModel {
            static let schema = \"\(name.lowercased())\"
        
            struct FieldKeys {
                \(fieldKeys)
            }
        
            \(modelFields)
        
            init() {}
        
            \(initializer)
        }
        """
        
        return model
    }
}
