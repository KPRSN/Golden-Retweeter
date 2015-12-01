//
//  FeedCollectionViewController.swift
//  Golden Retweeter
//
//  Created by Karl Persson on 2015-11-27.
//  Copyright © 2015 Karl Persson. All rights reserved.
//
//	Display and handle the twitter feed

import UIKit

private let reuseIdentifier = "TweetCollectionViewCell"

class FeedCollectionViewController: UICollectionViewController {
	let refreshControl = UIRefreshControl()
	var tweets: [Tweet] = []
	var topCell: NSIndexPath?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Pull to refresh
		refreshControl.addTarget(self, action: "refreshFeed:", forControlEvents: .ValueChanged)
		collectionView?.addSubview(refreshControl)
		// Draw refresh control on top of background
		collectionView?.backgroundView?.layer.zPosition -= 1
		
		// Load tweets from the server
		refreshFeed(self)
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "ComposeTweetIdentifier" {
			// Send tweet to controller if we want to compose a reply
			if sender?.isKindOfClass(TweetCollectionViewCell) == true {
				let sender = sender as! TweetCollectionViewCell
				let composeController = (segue.destinationViewController as! UINavigationController).topViewController as! ComposeTweetViewController
				composeController.replyTo = sender.tweet
			}
		}
    }
	
	// Show alert view with http response
	func showHTTPResponseAlert(response: NSURLResponse) {
		// Show HTTP error code as an alert view (if any)
		if let httpresponse = response as? NSHTTPURLResponse {
			if httpresponse.statusCode != 200 {
				let alert = UIAlertController(title: "Error", message: "Something went bananas: \(httpresponse.statusCode)", preferredStyle: .Alert)
				alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
			}
			
		}
	}
	
	// MARK: - Rotation
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		// Update collection view on rotation
		collectionView?.collectionViewLayout.invalidateLayout()
		collectionView?.collectionViewLayout.finalizeCollectionViewUpdates()
	}
	
	override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		// Find current cell at rotation
		if tweets.count > 0 {
			// Top left
			var visiblePoint = CGPointMake(collectionView!.bounds.origin.x, collectionView!.bounds.origin.y + navigationController!.navigationBar.frame.size.height+navigationController!.navigationBar.frame.origin.y)
			
			// Find cell in the top left corner
			topCell = collectionView?.indexPathForItemAtPoint(visiblePoint)
			// Offset if no cell is found (collection view spacing)
			if topCell == nil {
				visiblePoint = CGPointMake(visiblePoint.x, visiblePoint.y + 2)
				topCell = collectionView?.indexPathForItemAtPoint(visiblePoint)
			}
		}
	}
	
	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		// Scroll to current cell after rotation
		if let topCell = topCell {
			collectionView?.scrollToItemAtIndexPath(topCell, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
		}
	}

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		// Number of sections
        return 1
    }
	
	
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// Number of items
        return tweets.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TweetCollectionViewCell
		
        // Configure the cell
		cell.tweet = tweets[indexPath.row]
		cell.delegate = self
		
        return cell
    }
	
	func refreshFeed(sender: AnyObject) {
		// Load tweets from the server
		Twitter.feed(50, completionHandler: {tweets, response, error -> Void in
			dispatch_async(dispatch_get_main_queue(), {
				self.refreshControl.endRefreshing()
				if (error == nil) {
					self.tweets = tweets
					self.collectionView?.reloadData()
					
					// Show HTTP error code (if any)
					if (response != nil) {
						self.showHTTPResponseAlert(response!)
					}
				}
				
			})
		})
	}
	
	// Post/reply to a tweet and add new tweet to the feed
	@IBAction func sendTweet(segue: UIStoryboardSegue) {
		if let controller = segue.sourceViewController as? ComposeTweetViewController {
			// Post tweet
			Twitter.post(controller.tweetTextView.text, id: controller.replyTo?.id, completionHandler: { tweet, response, error -> Void in
				dispatch_async(dispatch_get_main_queue(),  {
					if (error == nil) {
						if (tweet != nil) {
							// Add tweet to feed and reload view
							self.tweets.insert(tweet!, atIndex: 0)
							self.collectionView?.reloadData()
							
							// Scroll to tweet
							self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
						}
						
						// Show HTTP error code (if any)
						if (response != nil) {
							self.showHTTPResponseAlert(response!)
						}
					}
					
				})
			})
		}
	}
	
	@IBAction func cancelToFeedCollectionViewController(segue: UIStoryboardSegue) {
		// Cancel tweet
	}
}

extension FeedCollectionViewController: SwipeViewDelegate {
	// MARK: - Swipe view delegate
	func reply(sender: AnyObject?) {
		performSegueWithIdentifier("ComposeTweetIdentifier", sender: sender)
	}
	
	func retweet(sender: AnyObject?) {
		// Get cell and tweet
		if let cell = sender as? TweetCollectionViewCell {
			if let tweet = cell.tweet {
				
				// Post retweet and update table
				Twitter.retweet(tweet.id, completionHandler: { retweetedTweet, response, error -> Void in
					dispatch_async(dispatch_get_main_queue(), {
						if (error == nil) {
							if (retweetedTweet != nil) {
								
								// Update tweet
								for i in 0..<self.tweets.count {
									if tweet.id == self.tweets[i].id {
										self.tweets[i] = Tweet(id: tweet.id, text: tweet.text, favorited: tweet.favorited, retweeted: true, user: tweet.user)
									}
								}
							}
							
							// Show HTTP error code (if any)
							if (response != nil) {
								self.showHTTPResponseAlert(response!)
							}
							
							// Reload view
							self.collectionView?.reloadData()
						}
					})
				})
			}
		}
	}
}

extension FeedCollectionViewController: UICollectionViewDelegateFlowLayout {
	// MARK: - Flow layout
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		// Size based on rotation (two columns for lanscape, one for portrait)
		if collectionView.bounds.size.width > collectionView.bounds.size.height {
			return CGSize(width: (collectionView.bounds.size.width-1)/2.0, height: 240)
		}
		return CGSize(width: collectionView.bounds.size.width, height: 200)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 1
	}
}

