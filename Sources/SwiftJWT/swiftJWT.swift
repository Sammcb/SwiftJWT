import Foundation
import CryptoKit
import ArgumentParser

extension Data {
	func base64EncodedURL() -> String {
		return base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
	}
}

struct Header: Encodable {
	let alg = "ES256"
	var kid: String
}

struct Payload: Encodable {
	var iss: String
	var iat: Int
	var exp: Int
	
	init(iss: String, iat: Date, exp: DateComponents) {
		let calendar = Calendar.current
		self.iss = iss
		self.iat = Int(iat.timeIntervalSince1970)
		self.exp = Int(calendar.date(byAdding: exp, to: iat)!.timeIntervalSince1970)
	}
}

@main
struct SwiftJWT: ParsableCommand {
	static let configuration = CommandConfiguration(abstract: "Generates a JWT token.", version: "1.0.0")
	
	@Argument(help: "Path to secret")
	var secretPath: String
	
	@Argument(help: "Key ID")
	var keyId: String
	
	@Argument(help: "Developer ID")
	var devId: String
	
	func validate() throws {
		let secretURL = URL(fileURLWithPath: secretPath, isDirectory: false)
		
		guard FileManager.default.fileExists(atPath: secretURL.path) else {
			throw ValidationError("'<secret-path>' must point to a valid file.")
		}
		
		guard (try? String(contentsOf: secretURL)) != nil else {
			throw ValidationError("'<secret-path>' must point to a valid file.")
		}
	}
	
	func run() throws {
		let secretURL = URL(fileURLWithPath: secretPath, isDirectory: false)
		let secret = try! String(contentsOf: secretURL)

		let calendar = Calendar.current
		let now = Date()
		let duration = DateComponents(calendar: calendar, month: 5)

		let privateKey = try! P256.Signing.PrivateKey(pemRepresentation: secret)

		let headerJSON = try! JSONEncoder().encode(Header(kid: keyId))
		let headerString = headerJSON.base64EncodedURL()

		let payloadJSON = try! JSONEncoder().encode(Payload(iss: devId, iat: now, exp: duration))
		let payloadString = payloadJSON.base64EncodedURL()

		let data = "\(headerString).\(payloadString)".data(using: .utf8)!

		let signature = try! privateKey.signature(for: data)
		let signatureString = signature.rawRepresentation.base64EncodedURL()

		let token = "\(headerString).\(payloadString).\(signatureString)"
		print(token)
	}
}
