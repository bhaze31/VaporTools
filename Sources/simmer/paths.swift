import Foundation

let SOURCE_BASE = "Sources"
let TEST_BASE = "Tests"


final class PathGenerator {
    enum Pathname: String {
        case Base
        case Root
        case App
        case Run
        case Test
        case Controller
        case Extensions
        case Middleware
        case Migrations
        case Model
        case Views
    }

    static func load(path: Pathname, name: String = "") -> String {
        switch (path) {
            case .Base:
                return SOURCE_BASE
            case .Root:
                return "./"
            case .App:
                return "\(SOURCE_BASE)/\(name)"
            case .Run:
                return "\(SOURCE_BASE)/Run"
            case .Test:
                return "\(TEST_BASE)/\(name)Tests"
            case .Controller:
                return "\(SOURCE_BASE)/\(name)/Controllers"
            case .Extensions:
                return "\(SOURCE_BASE)/\(name)/Extensions"
            case .Middleware:
                return "\(SOURCE_BASE)/\(name)/Middleware"
            case .Migrations:
                return "\(SOURCE_BASE)/\(name)/Migrations"
            case .Model:
                return "\(SOURCE_BASE)/\(name)/Models"
            case .Views:
                return "Resources/Views"
        }
    }
}
