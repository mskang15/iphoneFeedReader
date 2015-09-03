//
//  FeedsTableViewController.swift
//  FeedReader
//
//  Created by Moon-Seok Kang on 6/1/15.
//  Copyright (c) 2015 Moon Kang. All rights reserved.
//

import UIKit
import CoreData

class FeedsTableViewController: UITableViewController, NSXMLParserDelegate {
    
    var parser: NSXMLParser = NSXMLParser()
    var feedUrl = String()
    
    var feedTitle = String()
    var articleTitle = String()
    var articleLink = String()
    var articlePubDate = String()
    var parsingChannel = false
    var eName = String()
    
    var feeds: [FeedModel] = []
    var articles: [ArticleModel] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feeds = GetFeeds()
    }
    
    
    @IBAction func retrieveNewFeed(segue: UIStoryboardSegue) {
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var feedModel = feeds[indexPath.row]
        
        DeleteFeed(feedModel.url)
        
        feeds.removeAtIndex(indexPath.row)
        
        tableView.reloadData()
        
    }
    
    func AddNewFeed(url: String) {
        var feedUrl = url
        let url: NSURL = NSURL(string: feedUrl)!
        
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    func SaveFeed(feedModel: FeedModel) {
        if(FeedExists(feedModel.url)) {
            NSLog("feed exists!")
            
            return
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Feed", inManagedObjectContext: managedContext)
        
        let feed = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as! Feed
        
        
        feed.title = feedModel.title
        feed.url = feedModel.url
        
        var articles: NSMutableSet = NSMutableSet()
        
        for articleModel in feedModel.articles {
            let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: managedContext)
            
            let article = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext) as! Article
            article.title = articleModel.title
            article.link = articleModel.link
            article.pubDate = articleModel.pubDate
            
            articles.addObject(article)
        }
        
        feed.articles = articles
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        feeds.append(feedModel)
        
    }
    
    func FeedExists(url: String) -> Bool  {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        fetchRequest.returnsObjectsAsFaults = false
        let predicate = NSPredicate(format: "url == %@", url)
        
        fetchRequest.predicate = predicate
        
        var error: NSError?
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if fetchResults!.count > 0 {
            return true
        }
        
        return false
    }
    
    func GetFeeds() -> [FeedModel] {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        fetchRequest.returnsObjectsAsFaults = false
        
        var error: NSError?
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        var feedModels: [FeedModel] = [FeedModel]()
        
        if let results = fetchResults {
            for feed in results as! [Feed] {
                var feedModel = FeedModel()
                feedModel.title = feed.title
                feedModel.url = feed.url
                
                var articleModels: [ArticleModel] = [ArticleModel]()
                for article in feed.articles {
                    var articleModel = ArticleModel()
                    articleModel.title = article.title!
                    articleModel.link = article.link!
                    articleModel.pubDate = article.pubDate!
                    
                    articleModels.append(articleModel)
                }
                
                feedModel.articles = articleModels
                
                feedModels.append(feedModel)
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        return feedModels
    }
    
    func DeleteFeed(url: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        let predicate = NSPredicate(format: "url == %@", url)
        
        fetchRequest.predicate = predicate
        
        var error: NSError?
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [Feed]?
        
        if(fetchResults?.count == 1) {
            var feed = fetchResults?.first!
            
            managedContext.deleteObject(feed!)
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
        }
        
    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        eName = elementName
        if elementName == "channel" {
            feedTitle = String()
            feedUrl = String()
            parsingChannel = true
            articles = []
        } else if elementName == "item" {
            articleTitle = String()
            articleLink = String()
            articlePubDate = String()
            parsingChannel = false
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        let data = string?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if(!data!.isEmpty) {
            if parsingChannel {
                if eName == "title" {
                    feedTitle += data!
                    
                } else if eName == "link" {
                    feedUrl += data!
                }
            } else {
                if eName == "title" {
                    articleTitle += data!
                } else if eName == "link" {
                    articleLink += data!
                } else if eName == "pubDate" {
                    articlePubDate += data!
                }
            }
        }
        
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "channel" {
            let feed: FeedModel = FeedModel()
            feed.title = feedTitle
            feed.url = feedUrl
            feed.articles = articles
            //feeds.append(feed)
            
            SaveFeed(feed)
            
            
        } else if elementName == "item" {
            let article = ArticleModel()
            article.title = articleTitle
            article.link = articleLink
            article.pubDate = articlePubDate
            articles.append(article)
        }
        self.tableView.reloadData();
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! UITableViewCell
        let feed: FeedModel = feeds[indexPath.row]
        cell.textLabel!.text = feed.title
        
        return cell
    }
    

    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "ShowArticles") {
            let viewController: ArticlesTableController = segue.destinationViewController as! ArticlesTableController
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let feed = feeds[indexPath.row]
            
            viewController.articles = feed.articles
        }
    }
    
}
