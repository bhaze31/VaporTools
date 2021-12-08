import XCTest
@testable import rapid_boil

final class ViewTests: XCTestCase {
    func testIndexView() throws {
        let fields = [
            "name:string",
            "email:string",
            "created_at:date",
        ]
        
        let model = "user"
        
        let view = ViewsGenerator.generateIndexView(for: model, fields: fields)
        
        XCTAssertEqual(view, """
        #extend(\"main\"):
            #export(\"title\"):
                User
            #endexport

            #export(\"body\"):
                <h1>user</h1>

                <table>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Created_At</th>
                    </tr>

                    #for(item in items) {
                        <tr>
                            <td>#(item.name)</td>
                            <td>#(item.email)</td>
                            <td>#(item.created_at)</td>
                            <td><a href="/users/{{ item.id }}/edit">Edit</a></td>
                        </tr>
                    }
                </table>
            #endexport
        #endextend
        """)
    }
}
