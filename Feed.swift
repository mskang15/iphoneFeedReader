//
//  Feed.swift
//  FeedReader
//
//  Created by Moon-Seok Kang on 6/2/15.
//  Copyright (c) 2015 Moon Kang. All rights reserved.
//

import Foundation
import CoreData

class Feed: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var articles: NSSet

}
