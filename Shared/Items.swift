//
//  Items.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import CoreData


public class Items: NSManagedObject
{
    @NSManaged public var itemId: Int16
    @NSManaged public var amount: Int16
    @NSManaged public var consume: Int16
}