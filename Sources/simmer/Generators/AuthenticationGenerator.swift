import Foundation

final class AuthenticationGenerator {
	static func generateToken() -> String {
		return """
		import JWT
		
		struct APIToken: JWTPayload {
		    enum CodingKeys: String, CodingKey {
			    case subject = "sub"
				case expiration = "exp"
				case audience = "aud"
				case issuer = "iss"
				
				case isAdmin = "admin"
				case email = "eml"
			}
			
			var subject: SubjectClaim
			var audience: AudienceClaim
			var issuer: IssuerClaim
			var expiration: ExpirationClaim
			
			var isAdmin: Bool
			var email: String
			
			func verify(using signer: JWTSigner) throws {
			    // Add verifications
			}
		}
		"""
	}
	
	static func generateJWTMiddleware() -> String {
		return """
		import Vapor
		
		final class APIMiddleware: Middleware {
		    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
			    guard let token = try? request.jwt.verify(as: APIToken.self) else {
					return request.eventLoop.future(error: Abort(.unauthorized))
			}
			
			// Do something with your token here if necessary
			
			return next.respond(to: request)
		}
		"""
	}
	
	static func generateWebMiddleware() -> String {
		return """
		import Vapor
		import Fluent
		
		
		struct Authenticator: CredentialsAuthenticator {
			struct Input: Content {
				let identifiable: String
				let password: String
			}
			
			typealias Credentials = Input
		
			func authenticate(credentials: Credentials, for request: Request) -> EventLoopFuture<Void> {
				return _Model.query(on: request.db)
					.filter(\\.$identifiableKeyPath == credentials.identifiable)
					.first()
					.map {
						guard let model = $0 else {
							return
						}
						
						do {
							if let model = $0, try Bcrypt.verify(credentials.password, created: model.password) {
								// MARK: Authenticate user
							}
						} catch {
							// MARK: Handle error or continue
						}
				}
			}
		}
		"""
	}
}