import Foundation

final class FormProtocols {
    public static func mainProtocol() -> String {
        return """
        import Vapor
        import Fluent
        
        protocol Form: Encodable {
            associatedtype Model: Fluent.Model
        
            var id: String? { get set }
        
            init()
            init(req: Request) throws
        
            func write(to: Model)
            func read(from: Model)
            func validate(req: Request) -> EventLoopFuture<Bool>
        }
        """
    }
    
    public static func basicForm() -> String {
        return """
        import Foundation

        struct BasicFormField: Encodable {
            var value: String = ""
            var error: String?
        }
        """
    }
    
    public static func arrayForm() -> String {
        return """
        import Foundation

        struct ArrayFormField<T: Encodable>: Encodable {
            var value: Array<T> = []
            var error: String?
        }
        """
    }
    
    public static func optionalForm() -> String {
        return """
        import Foundation

        struct OptionalFormField: Encodable {
            var value: String?
            var error: String?
        }
        """
    }
    
    public static func checkBoxForm() -> String {
        return """
        import Foundation

        struct CheckBoxFormField: Encodable {
            var value: Bool = false
        }
        """
    }
}
