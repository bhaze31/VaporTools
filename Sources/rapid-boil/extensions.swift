import Foundation

extension String {
    func toCamelCase() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0 == "" {
                    return $0 + String($1).lowercased()
                }
                
                return $0 + "_" + String($1).lowercased()
            }
            
            return $0 + String($1)
        }
    }
    
    func toTrainCase() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0 == "" { return $0 + "-" + String($1).lowercased() }
                
                return $0 + String($1).lowercased()
            }
            
            return $0 + String($1)
        }
    }
    
    func pluralize() -> String {
        // TODO: Better pluralizing ie candy -> candies
        if last == "s" {
            return self
        }
        
        return self + "s"
    }
}
