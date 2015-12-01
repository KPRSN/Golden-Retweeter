//
//  Twitter.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-25.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Methods for handling data to an from Twitter.
//

import Foundation

struct Twitter {
	// Get the twitter feed of a user
	static func feed(count: Int = 25, completionHandler: (([Tweet], NSURLResponse?, ErrorType?) -> Void)) {
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let baseurl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
		let url = baseurl + "?count=\(count)"
		
		// Initialize object for OAuth authorization
		let oauth = OAuthObject(httpMethod: "get", baseURL: baseurl, requestParameters: ["count":String(count)])
		
		// Configure request for OAuth
		sessionConfig.HTTPAdditionalHeaders = oauth.header
		let session = NSURLSession(configuration: sessionConfig)
		let task = session.dataTaskWithURL(NSURL(string: url)!) { (data, response, error) -> Void in
			var tweets: [Tweet] = []
			
			// Handle results
			if error == nil {
				do {
					if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [Dictionary<String, AnyObject>] {
						tweets = TwitterJSON.parseFeed(json)
					}
				}
				catch { }
			}
			
			// Return parsed result to completion handler
			completionHandler(tweets, response, error)
		}
		task.resume()
	}
	
	// Post a status update (tweet or reply)
	// Returns the posted tweet to the completion handler
	static func post(text: String, id: String?, completionHandler: ((Tweet?, NSURLResponse?, ErrorType?) -> Void)) {
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let baseurl = "https://api.twitter.com/1.1/statuses/update.json"
		var url = baseurl + "?status=\(text.percentEncoded)"
		var parameters = ["status":text]
		
		// Add reply id if provided
		if (id != nil) {
			url += "&in_reply_to_status_id=\(id!)"
			parameters["in_reply_to_status_id"] = id!
		}
		
		// Initialize object for OAuth authorization
		let oauth = OAuthObject(httpMethod: "post", baseURL: baseurl, requestParameters: parameters)
		
		// Configure request for OAuth
		sessionConfig.HTTPAdditionalHeaders = oauth.header
		let session = NSURLSession(configuration: sessionConfig)
		let request = NSMutableURLRequest(URL: NSURL(string: url)!)
		request.HTTPMethod = "POST"
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			var tweet: Tweet?
			
			// Handle results
			if error == nil {
				do {
					// Parse json object
					if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject] {
						tweet = TwitterJSON.parseTweet(json)
					}
				}
				catch { }
			}
			
			// Return parsed result to completion handler
			completionHandler(tweet, response, error)
		}
		task.resume()
	}
	
	// Post retweet
	// Returns the posted tweet to the completion handler
	static func retweet(id: String, completionHandler: ((Tweet?, NSURLResponse?, ErrorType?) -> Void)) {
		// Retweet POST will return the original tweet with retweet details embedded
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let url = "https://api.twitter.com/1.1/statuses/retweet/\(id).json"
		
		// Initialize object for OAuth authorization
		let oauth = OAuthObject(httpMethod: "post", baseURL: url, requestParameters: [:])
		
		// Configure request for OAuth
		sessionConfig.HTTPAdditionalHeaders = oauth.header
		let session = NSURLSession(configuration: sessionConfig)
		let request = NSMutableURLRequest(URL: NSURL(string: url)!)
		request.HTTPMethod = "POST"
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			var tweet: Tweet?
			
			// Handle results
			if error == nil {
				do {
					// Parse json object
					if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject] {
						tweet = TwitterJSON.parseTweet(json)
					}
				}
				catch { }
			}
			
			// Return parsed result to completion handler
			completionHandler(tweet, response, error)
		}
		task.resume()
	}
	
	// Destroy a tweet or retweet (returns the destroyed tweet)
	static func destroy(id: String, completionHandler: ((Tweet?, NSURLResponse?, ErrorType?) -> Void)) {
		// Retweet POST will return the original tweet with retweet details embedded
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let url = "https://api.twitter.com/1.1/statuses/destroy/\(id).json"
		
		// Initialize object for OAuth authorization
		let oauth = OAuthObject(httpMethod: "post", baseURL: url, requestParameters: [:])
		
		// Configure request for OAuth
		sessionConfig.HTTPAdditionalHeaders = oauth.header
		let session = NSURLSession(configuration: sessionConfig)
		let request = NSMutableURLRequest(URL: NSURL(string: url)!)
		request.HTTPMethod = "POST"
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			var tweet: Tweet?
			
			// Handle results
			if error == nil {
				do {
					// Parse json object
					if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject] {
						tweet = TwitterJSON.parseTweet(json)
					}
				}
				catch { }
			}
			
			// Return parsed result to completion handler
			completionHandler(tweet, response, error)
		}
		task.resume()
	}
	
	// Get id for a retweet by the authenticated user
	static func retweetID(id: String, completionHandler: ((String?, NSURLResponse?, ErrorType?) -> Void)) {
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		let baseurl = "https://api.twitter.com/1.1/statuses/show.json"
		let url = baseurl + "?id=\(id)&include_my_retweet=1"
		
		// Initialize object for OAuth authorization
		let oauth = OAuthObject(httpMethod: "get", baseURL: baseurl, requestParameters: ["id":id, "include_my_retweet":"1"])
		
		// Configure request for OAuth
		sessionConfig.HTTPAdditionalHeaders = oauth.header
		let session = NSURLSession(configuration: sessionConfig)
		let task = session.dataTaskWithURL(NSURL(string: url)!) { (data, response, error) -> Void in
			var retweetID: String?
			
			// Handle results
			if error == nil {
				do {
					if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String: AnyObject] {
						retweetID = TwitterJSON.parseRetweetID(json)
					}
				}
				catch { }
			}
			
			// Return parsed result to completion handler
			completionHandler(retweetID, response, error)
		}
		task.resume()
	}
}
