//
//  SwipeView.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-28.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Swipeable view for replying or retweeting via swipe gestures (left and right)
//	Might be useful within a table or collection view cell.
//

import UIKit

// Enumeration of tweet actions to be used within the swipe view
private enum TweetAction {
	case NoAction, Reply, Retweet
}

// Delegate protocol for triggering retweet and reply from the swipe view
protocol SwipeViewDelegate {
	func retweet(sender: AnyObject?)
	func reply(sender: AnyObject?)
}

class SwipeView: UIView, UIGestureRecognizerDelegate {
	var delegate: SwipeViewDelegate!
	var recognizer: UIPanGestureRecognizer!
	var retweeted: Bool = false
	
	private var panCenter: CGPoint?
	private var cellFrame: CGRect?
	private var tweetAction = TweetAction.NoAction
	
	private let retweetView = UIView(frame: CGRectNull)
	private let retweetIconView = UIImageView(frame: CGRectNull)
	private let replyView = UIView(frame: CGRectNull)
	private let replyIconView = UIImageView(frame: CGRectNull)
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// Initialize gestures
		recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
		self.addGestureRecognizer(recognizer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Configure retweet cue
		retweetView.backgroundColor = Resources.SwipeViewResources.retweetBackgroundColor
		self.addSubview(retweetView)
		retweetView.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)
		
		retweetIconView.image = Resources.SwipeViewResources.retweetImage
		retweetIconView.contentMode = UIViewContentMode.Center
		retweetIconView.frame = CGRectMake(self.bounds.size.width, 0, 80, self.bounds.size.height)
		self.addSubview(retweetIconView)
		
		
		// Configure reply cue
		replyView.backgroundColor = Resources.SwipeViewResources.replyBackgroundColor
		self.addSubview(replyView)
		replyView.frame = CGRectMake(-self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)
		
		replyIconView.image = Resources.SwipeViewResources.replyImage
		replyIconView.contentMode = UIViewContentMode.Center
		replyIconView.frame = CGRectMake(-80, 0, 80, self.bounds.size.height)
		self.addSubview(replyIconView)
	}
	
	// Handle panning/swiping gestures
	func handlePan(recognizer: UIPanGestureRecognizer) {
		// Save original position
		if recognizer.state == UIGestureRecognizerState.Began {
			panCenter = self.center
			cellFrame = self.frame
			
			// Reset
			if retweeted {
				retweetIconView.tintColor = Resources.SwipeViewResources.retweetActiveColor
			}
			else {
				retweetIconView.tintColor = Resources.SwipeViewResources.retweetInactiveColor
			}
			replyIconView.tintColor = Resources.SwipeViewResources.replyInactiveColor
		}
		
		// Pan tweet
		if recognizer.state == UIGestureRecognizerState.Changed {
			// Point in the swipe gesture where the action should be activated
			let activationPoint = cellFrame!.size.width / 2
			
			// Calculate offset and animate (block gesture too far past the activation point)
			let translation = recognizer.translationInView(self)
			if abs(translation.x) <= activationPoint * 1.2 {
				self.center = CGPointMake(panCenter!.x + translation.x, panCenter!.y)
			}
			
			// Should we reply or retweet?
			if frame.origin.x <= cellFrame!.origin.x - activationPoint {
				// Retweet to the left
				tweetAction = TweetAction.Retweet
				
				// Animate to active/selected state
				UIView.animateWithDuration(0.2, animations: {
					if self.retweeted {
						self.retweetIconView.tintColor = Resources.SwipeViewResources.retweetInactiveColor
					}
					else {
						self.retweetIconView.tintColor = Resources.SwipeViewResources.retweetActiveColor
					}
				})
			}
			else if frame.origin.x >= cellFrame!.origin.x + activationPoint {
				// Reply to the right
				tweetAction = TweetAction.Reply
				
				// Animate to active/selected state
				UIView.animateWithDuration(0.2, animations: {
					self.replyIconView.tintColor = Resources.SwipeViewResources.replyActiveColor
				})
				
			}
			else {
				// Not far enough for an action
				tweetAction = TweetAction.NoAction
				
				// Animate back to original state
				UIView.animateWithDuration(0.2, animations: {
					if self.retweeted {
						self.retweetIconView.tintColor = Resources.SwipeViewResources.retweetActiveColor
					}
					else {
						self.retweetIconView.tintColor = Resources.SwipeViewResources.retweetInactiveColor
					}
				})
				
				UIView.animateWithDuration(0.2, animations: {
					self.replyIconView.tintColor = Resources.SwipeViewResources.replyInactiveColor
				})
			}
		}
		
		// Tweet released
		if recognizer.state == UIGestureRecognizerState.Ended {
			// Bounce back to original position
			let originalFrame = CGRectMake(cellFrame!.origin.x, cellFrame!.origin.y, cellFrame!.size.width, cellFrame!.size.height)
			UIView.animateWithDuration(0.2, animations: { () -> Void in
				self.frame = originalFrame
			})
			
			if tweetAction == TweetAction.Retweet {
				// Invert retweeted cue
				retweeted = !retweeted
				// Retweet
				delegate.retweet(nil)
			}
			else if tweetAction == TweetAction.Reply {
				// Reply
				delegate.reply(nil)
			}
		}
	}
}



