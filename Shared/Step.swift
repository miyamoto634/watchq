//
//  Step.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import CoreData


public class Step: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var detail: String
    @NSManaged public var status: String
    @NSManaged public var activity: Words
    @NSManaged public var number: Int16

}
