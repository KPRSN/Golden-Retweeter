//
//  User.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-30.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Twitter user
//

import Foundation

class User {
	let id: String
	let name: String
	let username: String
	
	init(id: String, name: String, username: String) {
		self.id = id
		self.name = name
		self.username = "@" + username
	}
}