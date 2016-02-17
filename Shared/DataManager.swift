//
//  DataManager.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import CoreData

public class DataManager: NSObject {
    
    public class func getContext() -> NSManagedObjectContext
    {
        return DataSaver.sharedInstance.managedObjectContext
    }
    
    public class func deleteManagedObject(object:NSManagedObject)
    {
        getContext().deleteObject(object)
        saveManagedContext()
    }
    
    public class func saveManagedContext()
    {
        var error : NSError? = nil
        do {
            try getContext().save()
        } catch let error1 as NSError {
            error = error1
            NSLog("Unresolved error saving context \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    

    
  

}
