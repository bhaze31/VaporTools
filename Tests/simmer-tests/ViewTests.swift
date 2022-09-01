import XCTest
@testable import simmer

final class ViewTests: XCTestCase {
    func testMainView() {
        let view = ViewsGenerator.generateMainView()
        
        XCTAssertEqual(view, """
        <!DOCTYPE htnl>
        <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
                <meta name="description" content="">
                <meta name="author" content="">
                
                <title>#import("title")</title>
            </head>
            <body>
                #import("body")
            </body>
        </html>
        """)
    }
    
    func testShowView() throws {
        let fields = [
            "name:string",
            "email:string"
        ]
        
        let view = ViewsGenerator.generateShowView(model: "User", fields: fields)
        
        XCTAssertEqual(view, """
        extend("main"):
            #export("title"):
                User - Show
            #endexport

            #export("body"):
                <div>
                    <p>#(model.name)</p>
                    <p>#(model.email)</p>
                </div>
        
                <a href="/users/#(model.id)/edit">Edit User</a>
            #endexport
        #endextend
        """)
    }
    
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
                <h1>User</h1>

                <table>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Created At</th>
                    </tr>

                    #for(item in items):
                        <tr>
                            <td>#(item.name)</td>
                            <td>#(item.email)</td>
                            <td>#(item.created_at)</td>
                            <td><a href="/users/{{ item.id }}/edit">Edit</a></td>
                        </tr>
                    #endfor
                </table>
        
                <a href="/users">Create User</a>
            #endexport
        #endextend
        """)
    }
    
//    func testEditView() {
//        let fields = [
//            "name:email"
//        ]
//    }
}
