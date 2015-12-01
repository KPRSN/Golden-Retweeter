//
//  TwitterJSON.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-30.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Methods for parsing JSON data from twitter
//

import Foundation

struct TwitterJSON {
	// Parse JSON twitter feed
	static func parseFeed(jsonTweets: [Dictionary<String, AnyObject>]) -> [Tweet] {
		var tweets: [Tweet] = []
		
		// Parse tweets
		for jsonTweet in jsonTweets {
			if let tweet = parseTweet(jsonTweet) {
				tweets.append(tweet)
			}
		}
		
		return tweets
	}
	
	// Parse JSON tweet
	static func parseTweet(jsonTweet: [String: AnyObject]) -> Tweet? {
		// Parse user
		if let jsonUser = jsonTweet["user"] {
			if let name = jsonUser["name"] as? String {
				if let username = jsonUser["screen_name"] as? String {
					if let userid = jsonUser["id_str"] as? String {
						// Parse tweet
						if let tweetid = jsonTweet["id_str"] as? String {
							if let text = jsonTweet["text"] as? String {
								if let retweeted = jsonTweet["retweeted"] as? Bool {
									if let favorited = jsonTweet["favorited"] as? Bool {
										// Add successful tweet
										return Tweet(
											id: tweetid,
											text: text,
											favorited: favorited,
											retweeted: retweeted,
											user: User(
												id: userid,
												name: name,
												username: username))
									}
								}
							}
						}
					}
				}
			}
		}
		return nil
	}
	
	// Parse JSON retweet
	static func parseRetweetID(jsonTweet: [String: AnyObject]) -> String? {
		var id: String?
		
		// Get id of retweet (for the authenticated user)
		if let retweet = jsonTweet["current_user_retweet"] as? [String: AnyObject] {
			id = retweet["id_str"] as? String
		}
		
		return id
	}
}