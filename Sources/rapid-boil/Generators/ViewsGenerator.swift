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
                            <th>\(fieldName.capitalized)</th>

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

    static func generateIndexView(for model: String, fields: [String], hasTimestamps: Bool = true) -> String {
        let header = ViewsGenerator.getHeaderRow(fields: fields)
        let rows = ViewsGenerator.getFieldsForIndex(model: model, fields: fields)
        return """
        #extend(\"main\"):
            #export(\"title\"):
                \(model.capitalized)
            #endexport
        
            #export(\"body\"):
                <h1>\(model)</h1>
        
                <table>
                    \(header)
                    #for(item in items) {
                        \(rows)
                    }
                </table>
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
                        <p>model.\(fieldname)</p>

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
        extend(\"main\"):
            #export(\"title\"):
                \(model.capitalized) - Show
            #endexport
        
            #export(\"body\"):
                \(fields)
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
