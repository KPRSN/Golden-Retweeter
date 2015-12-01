//
//  TweetCollectionViewCell.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-27.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Collection view cell representing a tweet
//

import UIKit

class TweetCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var tweetLabel: UILabel!
	@IBOutlet weak var swipeView: SwipeView!
	
	var delegate: SwipeViewDelegate!
	
	var tweet: Tweet? {
		didSet {
			nameLabel.text = tweet?.user.name
			usernameLabel.text = tweet?.user.username
			tweetLabel.text = tweet?.text
			tweetLabel.sizeToFit()
			
			swipeView.retweeted = tweet!.retweeted
			swipeView.delegate = self
			swipeView.recognizer.delegate = self
		}
	}
	
	// Make sure not to hijack the pan gestures of an eventual scroll view (collection or table)
	override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
		if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
			let translation = gestureRecognizer.translationInView(self.superview)
			
			// Only allow horizontal gestures in the swipeView
			if fabs(translation.x) > fabs(translation.y) {
				return true
			}
		}
		return false
	}
}

extension TweetCollectionViewCell: SwipeViewDelegate {
	func reply(sender: AnyObject?) {
		// Segue from view controller delegate
		delegate.reply(self)
	}
	
	func retweet(sender: AnyObject?) {
		delegate.retweet(self)
	}
}