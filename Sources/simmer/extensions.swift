import Foundation

extension String {
    func toCamelCase() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0 == "" {
                    return $0 + String($1).lowercased()
                }
            }
            
            return $0 + String($1)
        }
    }
    
    func toTrainCase() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0 == "" { return $0 + String($1).lowercased() }
                
                return $0 + "_" + String($1).lowercased()
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

    func toModelCase(addSpace: Bool = false) -> String {
        let train = self.toTrainCase()
        var shouldUppercase = false
        return train.unicodeScalars.reduce("") {
            if $0 == "" { return String($1).uppercased() }
            
            if $1 == "_" {
                shouldUppercase = true
                return $0
            }
            
            
            if shouldUppercase {
                shouldUppercase = false
                
                if addSpace { return $0 + " " + String($1).uppercased() }

                return $0 + String($1).uppercased()
                
            }
            
            return $0 + String($1).lowercased()
        }
    }
    
    func swap(from: String, to: String) -> String {
        self.replacingOccurrences(of: from, with: to)
    }
}
