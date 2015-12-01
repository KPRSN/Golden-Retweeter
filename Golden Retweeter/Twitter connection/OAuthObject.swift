//
//  OAuthObject.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-30.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Helper object for handling the OAuth authentication
//

import Foundation

class OAuthObject {
	let httpMethod: String
	let baseURL: String
	let requestParameters: [String: String]
	
	let consumerSecret = Resources.OAuthCredentials.consumerSecret
	let tokenSecret = Resources.OAuthCredentials.tokenSecret
	let consumerKey = Resources.OAuthCredentials.consumerKey
	let nonce: String
	let signature: String
	let signatureMethod = "HMAC-SHA1"
	let timestamp: String
	let token = Resources.OAuthCredentials.token
	let version = "1.0"
	
	var headerParameters: [String: String] {
		get {
			return [
				"oauth_consumer_key": consumerKey,
				"oauth_nonce": nonce,
				"oauth_signature": signature,
				"oauth_signature_method": signatureMethod,
				"oauth_timestamp": timestamp,
				"oauth_token": token,
				"oauth_version": version]
		}
	}
	
	// OAuth HTTP header
	var header: [String: String] {
		get {
			var header = "OAuth"
			
			// Encode and append parameters to the header string
			let keys = Array(headerParameters.keys).sort()
			for key in keys {
				header += " \(key.percentEncoded)=\"\(headerParameters[key]!.percentEncoded)\""
				if key != keys.last {
					header += ","
				}
			}
			
			return ["Authorization":header]
		}
		
	}
	
	init(httpMethod: String, baseURL: String, requestParameters: [String: String]) {
		self.httpMethod = httpMethod
		self.baseURL = baseURL
		self.requestParameters = requestParameters
		
		nonce = OAuthObject.generateNonce()
		timestamp = OAuthObject.generateTimestamp()
		
		// Append OAuth parameters to the request parameters and generate OAuth signature
		var signatureParameters = requestParameters
		signatureParameters["oauth_consumer_key"] = consumerKey
		signatureParameters["oauth_nonce"] = nonce
		signatureParameters["oauth_signature_method"] = signatureMethod
		signatureParameters["oauth_timestamp"] = timestamp
		signatureParameters["oauth_token"] = token
		signatureParameters["oauth_version"] = version
		signature = OAuthObject.generateSignature(httpMethod, baseURL: baseURL, parameters: signatureParameters, consumerSecret: consumerSecret, tokenSecret: tokenSecret)
	}
	
	// Generate 32 bytes of random base 64 data
	static func generateNonce() -> String {
		let data = NSMutableData(length: 32)
		SecRandomCopyBytes(kSecRandomDefault, data!.length, UnsafeMutablePointer<UInt8>(data!.mutableBytes))
		return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
	}
	
	// Generate Unix timestamp
	static func generateTimestamp() -> String {
		return String(Int(NSDate().timeIntervalSince1970))
	}
	
	// OAuth signature string for a specific twitter request (https://dev.twitter.com/oauth/overview/creating-signatures)
	static func generateSignature(httpMethod: String, baseURL: String, parameters: [String: String], consumerSecret: String, tokenSecret: String) -> String {
		// Generate parameter string used to create the signature base string
		var parameterString = ""
		let keys = Array(parameters.keys).sort()
		for key in keys {
			parameterString += "\(key.percentEncoded)=\(parameters[key]!.percentEncoded)"
			if key != keys.last {
				parameterString += "&"
			}
		}

		// Finalize base string and key
		let signatureBaseString = httpMethod.uppercaseString + "&" + baseURL.percentEncoded + "&" + parameterString.percentEncoded
		let signingKey = consumerSecret.percentEncoded + "&" + tokenSecret.percentEncoded

		// Return HMAC-SHA1 signature
		return signatureBaseString.hmac(HMACAlgorithm.SHA1, key: signingKey)
	}
}