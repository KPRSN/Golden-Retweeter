//
//  Tweet.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-25.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Tweet
//

import Foundation

// Tweet
class Tweet {
	let id: String
	let text: String
	let favorited: Bool
	let retweeted: Bool
	let user: User
	
	init(id: String, text: String, favorited: Bool, retweeted: Bool, user: User) {
		self.id = id
		self.text = text
		self.favorited = favorited
		self.retweeted = retweeted
		self.user = user
	}
}

