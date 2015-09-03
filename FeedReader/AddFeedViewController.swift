//
//  AddFeedViewController.swift
//  FeedReader
//
//  Created by Moon-Seok Kang on 6/2/15.
//  Copyright (c) 2015 Moon Kang. All rights reserved.
//

import UIKit

class AddFeedViewController: UIViewController {

    @IBOutlet weak var feedUrl: UITextField!
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController: FeedsTableViewController = segue.destinationViewController as! FeedsTableViewController
        viewController.AddNewFeed(feedUrl.text)
        
    }
    
}
