//
//  ViewsGenerator.swift
//  
//
//  Created by Brian Hasenstab on 12/5/21.
//

import Foundation

final class ViewsGenerator {
    private static func getHeaderRow(fields: [String]) -> String {
        var header = """
        <tr>

        """
        
        for field in fields {
            let fieldName = field.split(separator: ":")[0]
            header += """
                            <th>\(String(fieldName).toModelCase(addSpace: true))</th>

            """
        }
        
        header += """
                    </tr>

        """
        
        return header
        
    }

    private static func getFieldsForIndex(model: String, fields: [String]) -> String {
        var row = """
        <tr>
        
        """
        for field in fields {
            let fieldname = field.split(separator: ":")[0]
            row += """
                                <td>#(item.\(fieldname))</td>

            """
        }
        
        row += getActionsForRow(model: model)
        
        return row + """
                        </tr>
        """
    }
    
    private static func getActionsForRow(model: String) -> String {
        return """
                            <td><a href=\"/\(model.lowercased().pluralize())/{{ item.id }}/edit\">Edit</a></td>

        """
    }
    
    private static func getInputForRow(model: String, fields: [Field]) -> String {
        let row = """
        <form action="/\(model.lowercased().pluralize())", method="POST">
        """
        
//        for field in fields {
//            
//        }
        return row + """
        </form>
        """
    }

    static func generateIndexView(for model: String, fields: [String], hasTimestamps: Bool = true) -> String {
        let header = ViewsGenerator.getHeaderRow(fields: fields)
        let rows = ViewsGenerator.getFieldsForIndex(model: model, fields: fields)
        return """
        #extend(\"main\"):
            #export(\"title\"):
                \(model.toModelCase(addSpace: true))
            #endexport
        
            #export(\"body\"):
                <h1>\(model.toModelCase(addSpace: true))</h1>
        
                <table>
                    \(header)
                    #for(item in items):
                        \(rows)
                    #endfor
                </table>
        
                <a href=\"/\(model.lowercased().pluralize())\">Create \(model.toModelCase(addSpace: true))</a>
            #endexport
        #endextend
        """
    }
    
    static func getEditView(model: String, fields: [String]) -> String {
        return """
        #extend("main"):
            #export("title"):
                \(model.toModelCase(addSpace: true)) - Edit
            #endexport
        
            #export("body"):
                <h1>Edit \(model.toModelCase(addSpace: true))</h1>
            #endexport
        #endextend
        """
    }
    
    private static func getFieldsForShow(fields: [String]) -> String {
        var div = """
        <div>

        """
        
        for field in fields {
            let fieldname = field.split(separator: ":")[0]
            div += """
                        <p>#(model.\(fieldname))</p>

            """
        }
        
        div += """
                </div>
        """

        return div
    }
    
    static func generateShowView(model: String, fields: [String]) -> String {
        let fields = ViewsGenerator.getFieldsForShow(fields: fields)
        return """
        extend("main"):
            #export("title"):
                \(model.toModelCase(addSpace: true)) - Show
            #endexport
        
            #export("body"):
                \(fields)
        
                <a href="/\(model.lowercased().pluralize())/#(model.id)/edit">Edit \(model.toModelCase(addSpace: true))</a>
            #endexport
        #endextend
        """
    }
    
    static func generateMainView() -> String {
        return """
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
        """
    }
}
