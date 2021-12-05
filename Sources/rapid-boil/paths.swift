import Foundation

#if DEBUG
enum PathConstants: String {
    case BasePath = "Source"
    case ApplicationPath = "Source/App"

    case ModelPath = "Source/App/Models"

    case ResourcePath = "Source/App/Resources"

    case ControllerPath = "Source/App/Controllers"

    case MigrationPath = "Source/App/Migrations"

    case FormPath = "Source/App/Forms"

    case ProtocolPath = "Source/App/Protocols"
    case APIProtocolPath = "Source/App/Protocols/APIProtocols"
    case WebProtocolPath = "Source/App/Protocols/WebProtocols"
}
#else
enum PathConstants: String {
    case BasePath = "Sources"
    case ApplicationPath = "Sources/App"
    
    case ModelPath = "Sources/App/Models"
    
    case ResourcePath = "Sources/App/Resources"
    
    case ControllerPath = "Sources/App/Controllers"
    
    case MigrationPath = "Sources/App/Migrations"
    
    case FormPath = "Sources/App/Forms"
    
    case ProtocolPath = "Sources/App/Protocols"
    case APIProtocolPath = "Sources/App/Protocols/APIProtocols"
    case WebProtocolPath = "Sources/App/Protocols/WebProtocols"
}
#endif
