//
//  Tag.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 29.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData

extension Tag{
    
    
    class func getOrCreate(title:String?) -> Tag?{
        guard let title = title else {return nil}
        let request = NSFetchRequest<Tag>.init(entityName: "Tag")
        request.predicate = NSPredicate.init(format: "title == %@", title)
        if let tag = (try? managedContext.fetch(request))?.first{
            return tag
        }
        let tag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: managedContext) as? Tag
        tag?.title = title
        try? managedContext.save()
        return tag
    }
    class func getAll() -> [Tag]{
        let request = NSFetchRequest<Tag>.init(entityName: "Tag")
        let all = (try? managedContext.fetch(request)) ?? [Tag]()
        return all
    }
    
}
