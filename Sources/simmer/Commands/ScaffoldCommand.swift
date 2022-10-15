//
//  File.swift
//  
//
//  Created by Brian Hasenstab on 10/15/22.
//

import ArgumentParser
import Foundation

final class ScaffoldCommand: ParsableCommand {
    static let _commandName: String = "scaffold"
    
    static let configuration = CommandConfiguration(abstract: "Generate a full suite of items for a model", usage: "How to use it", discussion: "How things work entirely")
    
    @Argument(help: "The name of the model to generate")
    private var name: String
    
    func run() throws {
        
    }
}
