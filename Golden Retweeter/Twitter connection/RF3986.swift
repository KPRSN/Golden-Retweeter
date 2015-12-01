//
//  RF3986.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-26.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	RF3986 percent encoding http://tools.ietf.org/html/rfc3986#section-2.1
//

import Foundation

// RF3986 percent encoding string extension
extension String {
	var percentEncoded: String {
		let genDelims = ":/?#[]@"
		let subDelims = "!$&'()*+,;="
		
		let characterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
		characterSet.removeCharactersInString(genDelims + subDelims)
		
		return self.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
	}
}