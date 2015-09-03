//
//  ArticlesTableController.swift
//  FeedReader
//
//  Created by Moon-Seok Kang on 6/1/15.
//  Copyright (c) 2015 Moon Kang. All rights reserved.
//

import UIKit

class ArticlesTableController: UITableViewController {
    
    var articles :[ArticleModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell", forIndexPath: indexPath) as? UITableViewCell
        
        let article: ArticleModel = articles[indexPath.row]
        
        
        cell!.textLabel!.text = article.title
        
        
        cell!.detailTextLabel!.text = article.pubDate
        
        
        return cell!
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "showWebView") {
            let viewController: WebViewController = segue.destinationViewController as! WebViewController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let article = articles[indexPath.row]
            
            viewController.article = article
        }
    }
    

    

}
