import Foundation
import ArgumentParser

final class AuthenticationCommand: ParsableCommand {
	static let _commandName: String = "authentication"
	
	static let configuration = CommandConfiguration(
		abstract: """
		Generate authentication middleware.
		By default, it generates both a web middleware that uses session storage and a
		token middleware that uses JWT, along with a generic Token model to use with
		JWT. However, the actual implementations are left up to you to determine what is
		a valid session, how you store it, and what consists of a valid token.
		""",
		discussion: ""
	)
	
	@Flag(name: .shortAndLong, help: "Use only JWT tokens")
	private var jwtOnly = false
	
	@Flag(name: .shortAndLong, help: "Use web authentication only")
	private var webOnly = false
	
	func run() throws {
		let jwtMiddleware = AuthenticationGenerator.generateJWTMiddleware()
		let jwtToken = AuthenticationGenerator.generateToken()
		let webMiddleware = AuthenticationGenerator.generateWebMiddleware()
		
		if jwtOnly {
			FileHandler.createFileWithContents(
				jwtMiddleware,
				fileName: "APIMiddleware.swift",
				path: PathGenerator.load(path: .Middleware, name: "MISSING_NAME"),
				displayIfConflicting: true
			)
			
			FileHandler.createFileWithContents(
				jwtToken,
				fileName: "Token.swift",
				path: PathGenerator.load(path: .Model, name: "MISSING_NAME"),
				displayIfConflicting: true
			)
		} else if webOnly {
			FileHandler.createFileWithContents(
				webMiddleware,
				fileName: "WebMiddleware.swift",
				path: PathGenerator.load(path: .Middleware, name: "MISSING_NAME"),
				displayIfConflicting: true
			)
		} else {
			FileHandler.createFileWithContents(
				jwtMiddleware,
				fileName: "APIMiddleware.swift",
				path: PathGenerator.load(path: .Middleware, name: "MISSING_NAME"),
				displayIfConflicting: true
			)
			
			FileHandler.createFileWithContents(
				jwtToken,
				fileName: "Token.swift",
				path: PathGenerator.load(path: .Model, name: "MISSING_NAME"),
				displayIfConflicting: true
			)
			
			FileHandler.createFileWithContents(
				webMiddleware,
				fileName: "WebMiddleware.swift",
				path: PathGenerator.load(path: .Middleware, name: "MISSING_NAME"),
				displayIfConflicting: true
			)
		}
		
		print("""
		[!!] REMINDER:
		These are generic authenticators that are not added to any routes. They also
		do not actually do any authentication, you need to determine what a valid token,
		valid session, and what model uses these middlewares.
		""")
	}
}
