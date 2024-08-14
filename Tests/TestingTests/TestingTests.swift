@testable import Testing
import XCTVapor

final class TestingTests: XCTestCase {
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "/", headers: ["accept": "text/html"], afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContains(res.body.string, "Simmer")
            XCTAssertContains(res.body.string, "Vapor")
        })
    }
}
