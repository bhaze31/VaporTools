import Foundation

#if DEBUG
enum PathConstants: String {
    case RootPath = "./"
    
    case BasePath = "Source"

    case ApplicationPath = "Source/App"

    case ModelPath = "Source/App/Models"

    case ControllerPath = "Source/App/Controllers"

    case MigrationPath = "Source/App/Migrations"
    
    case MiddlewarePath = "Source/App/Middleware"

    case FormPath = "Source/App/Forms"
    
    case ViewsPath = "Resources/Views"

    case ProtocolPath = "Source/App/Protocols"
}
#else
enum PathConstants: String {
    case RootPath = "./"

    case BasePath = "Sources"

    case ApplicationPath = "Sources/App"
    
    case ModelPath = "Sources/App/Models"
    
    case ControllerPath = "Sources/App/Controllers"
    
    case MigrationPath = "Sources/App/Migrations"
    
    case MiddlewarePath = "Sources/App/Middleware"
    
    case FormPath = "Sources/App/Forms"
    
    case ViewsPath = "Resources/Views"

    case ProtocolPath = "Sources/App/Protocols"
}
#endif
