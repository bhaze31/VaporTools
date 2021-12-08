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
}
