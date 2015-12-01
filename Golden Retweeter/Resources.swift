//
//  Resources.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-30.
//  Copyright © 2015 Karl Persson. All rights reserved.
//

import UIKit

struct Resources {
	// Static resources for the swipe view
	struct SwipeViewResources {
		static let retweetBackgroundColor = UIColor(red:0.10, green:0.81, blue:0.53, alpha:1.0)	// #1acf87
		static let retweetActiveColor = UIColor.yellowColor()
		static let retweetInactiveColor = UIColor.whiteColor()
		static let replyBackgroundColor = UIColor(red:0.09, green:0.64, blue:0.96, alpha:1.0)	// #17a3f5
		static let replyActiveColor = UIColor(red:0.64, green:0.85, blue:1.00, alpha:1.0)
		static let replyInactiveColor = UIColor.whiteColor()
		
		static let retweetImage = UIImage(named: "retweet-action")
		static let replyImage = UIImage(named: "reply-action")
	}
	
	// OAuth credentials
	struct OAuthCredentials {
		static let consumerKey = ""
		static let token = ""
		static let consumerSecret = ""
		static let tokenSecret = ""
	}
}
