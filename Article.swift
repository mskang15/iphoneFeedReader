//
//  Article.swift
//  FeedReader
//
//  Created by Moon-Seok Kang on 6/2/15.
//  Copyright (c) 2015 Moon Kang. All rights reserved.
//

import Foundation
import CoreData

class Article: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var link: String
    @NSManaged var pubDate: String

}
