//
//  ItemManager.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import CoreData

public class ItemsManager: NSObject {
    
    public static let entityName = "Items"
    
    //This approach supports lazy initialization because Swift lazily initializes class constants (and variables), and is thread safe by the definition of let.
    static let sharedInstance = ItemsManager()
    
    
    
    public class func updateSavedData(itemId: Int16, amount: Int16)//
    {
        let itemExist =  ItemsManager.checkAboutItem(itemId)
        if !itemExist { return  }
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        let resultPredicate = NSPredicate(format: "itemId = %i", itemId)
        
        //let compound = NSCompoundPredicate.andPredicateWithSubpredicates([resultPredicate])
        fetchRequest.predicate = resultPredicate //compound
        
        if let fetchResults = (try? DataSaver.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Items]
        {
            if fetchResults.count != 0
            {
                let managedObject = fetchResults[0]
                managedObject.amount = amount
                do {
                    //.setValue(likeNewValue, forKey: "like")
                
                    try DataSaver.sharedInstance.managedObjectContext.save()
                } catch _ {
                }
            }
        }
    }
    
    
    
    public class func checkAboutItem(itemId: Int16) -> Bool//
    {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        let resultPredicate = NSPredicate(format: "itemId = %i", itemId)
        
        fetchRequest.predicate = resultPredicate //compound;
        
        
        if let fetchResults = (try? DataSaver.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Items]
        {
            if fetchResults.count != 0
            {
                return true//Int(activity.like);
            }
        }
        return false // not exist
    }
    
    public class func getAmountofItem(itemId: Int16) -> Int16//
    {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let resultPredicate = NSPredicate(format: "itemId = %i", itemId)
        
        //let compound = NSCompoundPredicate.andPredicateWithSubpredicates([resultPredicate])
        fetchRequest.predicate = resultPredicate //compound
        
        if let fetchResults = (try? DataSaver.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Items]
        {
            if fetchResults.count != 0
            {
                let managedObject = fetchResults[0]
                let amount =  Int16(managedObject.amount)
                
                return amount//Int(activity.amount)
            }
        }
        return 0 // not exist
    }
    
    
    public class func createItem(itemId: Int16, consume: Int16, amount: Int16)//
    {
        let itemExist =  ItemsManager.checkAboutItem(itemId)
        if itemExist { return  }
        
        createActivity( itemId, consume: consume, amount: amount)
    }
    
    public class func createActivity(itemId: Int16, consume: Int16, amount: Int16) -> Items
    {
        
        let newActivity: Items = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: DataManager.getContext()) as! Items
        
        newActivity.itemId = itemId
        newActivity.amount = amount
        newActivity.consume = consume
        
        DataManager.saveManagedContext()
        
        return newActivity
    }
    
    public class func fetchItemByConsume(consume: Int16) -> [Items]//
    {
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        
        let resultPredicate = NSPredicate(format: "consume = %i", consume)
        request.predicate = resultPredicate
        
        
        if let results:NSArray = (try! DataManager.getContext().executeFetchRequest(request)) as? [Items]
        {
            return results as! [Items]
        }
        else
        {
            return [Items]()
        }
    }
    
    public class func fetchItemById(itemId: Int16) -> Items//
    {
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        
        let resultPredicate = NSPredicate(format: "itemId = %i", itemId)
        request.predicate = resultPredicate
        
        
        if let results:NSArray = (try! DataManager.getContext().executeFetchRequest(request)) as? [Items]
        {
            return results[0] as! Items
        }
        else
        {
            return Items()//atention:これ怖い。ここまでこないようにしよう
        }
    }
    
    public class func fetchAllItems() -> [Items]
    {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        // Create a sort descriptor object that sorts on the "name"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "itemId", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        do
        {
            if let activities:[Items] = try DataManager.getContext().executeFetchRequest(fetchRequest) as? [Items]
            {
                return activities
            }
        }
        catch
        {
            return [Items]()
        }
        
        return [Items]()
    }
    
    public class func deleteItemByID(itemId:Int16)//
    {
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        
        let resultPredicate = NSPredicate(format: "itemId = %i", itemId)
        request.predicate = resultPredicate
        
        if let results:NSArray = (try! DataManager.getContext().executeFetchRequest(request)) as? [Items]
        {
            //return results[0] as! Items
            DataManager.deleteManagedObject(results[0] as! Items)
        }
    }
    
}

