//
//  ComposeTweetViewController.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-28.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Compose or reply to a tweet
//

import UIKit

class ComposeTweetViewController: UIViewController {
	@IBOutlet weak var tweetButton: UIBarButtonItem!
	@IBOutlet weak var characterCountingLabel: UILabel!
	@IBOutlet weak var tweetTextView: UITextView!
	
	var replyTo: Tweet?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Avoid vertical spacing in text view
		automaticallyAdjustsScrollViewInsets = false
		
		// Listen to keyboard events
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: UITextViewTextDidChangeNotification, object: tweetTextView)
		
		// Add username to tweet if it's a reply
		if (replyTo != nil) {
			tweetTextView.text = replyTo!.user.username + " "
		}
		
		updateCharacterCounter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		tweetTextView.becomeFirstResponder()
	}
	
	func textDidChange(notification: NSNotification) {
		updateCharacterCounter()
	}
	
	func updateCharacterCounter() {
		let charactersLeft = 140 - tweetTextView.text.characters.count
		
		// Update counter and enable/disable tweet
		characterCountingLabel.text = String(charactersLeft)
		if (charactersLeft < 0) {
			characterCountingLabel.textColor = UIColor.redColor()
			tweetButton.enabled = false
		}
		else {
			characterCountingLabel.textColor = UIColor.blackColor()
			
			// Tweet must have at least one character
			if tweetTextView.text.characters.count > 0 {
				tweetButton.enabled = true
			}
			else {
				tweetButton.enabled = false
			}
			
		}
	}
}
