import XCTest
@testable import rapid_boil

final class FormHelpers: XCTestCase {
    func testFormProtocolGenerator() {
        let fields = [
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
                var test_1: String?
                var test_2: [Int]
                var test_3: [String]
            }

            var id: String? = nil
            var test_1 = BasicFormField()
            var test_2 = ArrayFormField()
            var test_3 = ArrayFormField()

            init() {}

            init(req: Request) throws {
                let context = try req.content.decode(Input.self)

                if !context.id.isEmpty {
                    self.id = context.id
                }

                self.test_1.value = context.test_1
                self.test_2.value = context.test_2
                self.test_3.value = context.test_3
            }

            func write(to user: User) {
                if let id = self.id {
                    user.id = UUID(uuidString: id)
                }

                user.test_1 = self.test_1.value
                user.test_2 = self.test_2.value
                user.test_3 = self.test_3.value

            }
            
            func read(from user: User) {
                self.id = user.id?.uuidString
                self.test_1.value = user.test_1
                self.test_2.value = user.test_2
                self.test_3.value = user.test_3

            }

            func validate(req: Request) -> EventLoopFuture<Bool> {
                var valid = true

                // Add validations

                return req.eventLoop.future(valid)
            }
        }
        """
        )
    }
}
