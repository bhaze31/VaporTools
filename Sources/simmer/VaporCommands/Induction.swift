//
//  Induction.swift
//  
//
//  Created by Brian Hasenstab on 4/1/23.
//

import Foundation
import ConsoleKit

final class InductionGroup: CommandGroup {
    static var name = "induction"
    
    let help: String = "Induction is a set of vapor commands to help quickly generate models/migrations/controllers"
    
    let commands: [String: AnyCommand]
    
    init() {
        self.commands = [
            VaporMigrationCommand.name: VaporMigrationCommand()
        ]
    }
}
