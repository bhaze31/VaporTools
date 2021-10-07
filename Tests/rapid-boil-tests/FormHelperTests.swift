import XCTest
@testable import rapid_boil

final class FormHelpers: XCTestCase {
    func testFormProtocolGenerator() {
        let fields = [
            "test:string",
            "test_1:string:o",
            "test_2:int.a",
            "test_3:string.a"
        ]
        
        let form = FormGenerator.generateForm(model: "User", fields: fields)
        
        XCTAssertEqual(form, """
        import Vapor
        import Fluent

        final class UserForm: Form {
            typealias Model = User

            struct Input: Content {
                var id: String?
                var test: String
                var test_1: String?
                var test_2: [Int]
                var test_3: [String]
            }

            var id: String? = nil
            var test = BasicFormField(type: String.self)
            var test_1 = OptionalFormField(type: String.self)
            var test_2 = ArrayFormField()
            var test_3 = ArrayFormField()

            init() {}

            init(_ req: Request) throws {
                let context = try req.content.decode(Input.self)

                if let id = context.id {
                    self.id = id
                }

                self.test.value = context.test
                self.test_1.value = context.test_1
                self.test_2.value = context.test_2
                self.test_3.value = context.test_3
            }

            func write(to user: User) {
                if let id = self.id {
                    user.id = UUID(uuidString: id)
                }

                user.test = self.test.value
                user.test_1 = self.test_1.value
                user.test_2 = self.test_2.value
                user.test_3 = self.test_3.value

            }
            
            func read(from user: User) {
                self.id = user.id?.uuidString
                self.test.value = user.test
                self.test_1.value = user.test_1
                self.test_2.value = user.test_2
                self.test_3.value = user.test_3

            }

            func validate(_ req: Request) -> EventLoopFuture<Bool> {
                var valid = true

                // Add validations

                return req.eventLoop.future(valid)
            }
        }
        """
        )
    }
}
