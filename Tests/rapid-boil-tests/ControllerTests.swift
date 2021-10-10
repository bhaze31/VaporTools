import XCTest
@testable import rapid_boil

final class ControllerTests: XCTestCase {
    func testAPIControllerGenerator() {
        let controller = ControllerGenerator.generateAPIController(for: "Test")
        
        XCTAssertEqual(controller, """
        import Vapor

        final class TestAPIController: APIControllerProtocol {
            typealias Model = Test
            
        }
        """)
    }
    
    func testWebControllerGenerator() {
        let controller = ControllerGenerator.generateWebController(for: "Test")
        
        XCTAssertEqual(controller, """
        import Vapor

        final class TestWebController: WebControllerProtocol {
            typealias EditForm = TestForm
            
            typealias Model = Test
        }
        """)
    }
}
