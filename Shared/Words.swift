//
//  Words.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//
import Foundation
import CoreData


public class Words: NSManagedObject {

    @NSManaged public var like: Int16
    @NSManaged public var property: String
    @NSManaged public var word: String
    
    public func stepsSortedByNumber() //-> [Step]
    {
        //if steps != nil {
        //    return self.steps!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "number", ascending: true)]) as! [Step]
            
       // }
      //  return []
    }

}
