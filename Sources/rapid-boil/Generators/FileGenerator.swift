import Foundation

final class AppFiles {
  var appRouter: String {
    return """
    import Vapor

    final class AppRouter {
        var app: Application

        init(_ application: Application) {
            self.app = application
        }

        func loadResources() throws {

        }

        func loadRoutes() throws {

        }
    }
    """
  }
}
