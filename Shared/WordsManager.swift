//
//  WordsManager.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import CoreData

public class WordsManager: NSObject {
    
    public static let entityName = "Words"
    
    //This approach supports lazy initialization because Swift lazily initializes class constants (and variables), and is thread safe by the definition of let.
    static let sharedInstance = WordsManager()
    
    //データベースに単語を登録・更新
    public class func updateWord(word : String, property : String, likediff : Int16!)
    {
        //ステータスマネージャー
        let statusManager = StatusManager()
        
        var like =  Int16(WordsManager.checkAboutWord(word, property: property))
        print("like:"+String(like))
        
        if( like != -1)
        {
            like += likediff
            //update
            WordsManager.updateSavedData(word, property: property, likeNewValue: like)
        }
        else
        {
            // add it
            statusManager.addValue("feedingV", add_value: 10*864)
            WordsManager.createActivity(word, property: property, like: 50);
        }
    }
    
    //プロパティ選択
    public class func selectProperty(propertyNum:String)->String
    {
        switch propertyNum{
        case "0":
            break
        case "1":
            return "pet"
        case "2":
            return "user"
        case "3":
            return "people"
        case "4":
            return "place"
        case "5":
            return "modifier"
        case "6":
            return "verd"
        case "7":
            return "food"
        default:
            break
        }
        return "all"
    }
    
    
    public class func fillFoodListForFirstLunchApp()
    {
        let foodWordList = WordsManager.fetchAllWords()
        if foodWordList.isEmpty
        {
            updateWord("ガリレオ", property: "people", likediff: 0)
            
            updateWord("富士山", property: "place", likediff: 0)
            updateWord("愛媛", property: "place", likediff: 0)
            
            updateWord("きれいな", property: "modifier", likediff: 0)
            updateWord("かっこいい", property: "modifier", likediff: 0)
            
            updateWord("ラーメン", property: "food", likediff: 0)
            updateWord("サバの味噌煮", property: "food", likediff: 0)
            updateWord("おでん", property: "food", likediff: 0)
            updateWord("カレー", property: "food", likediff: 0)
            
            updateWord("かりんとう", property: "snack", likediff: 0)
            updateWord("おせんべい", property: "snack", likediff: 0)
            updateWord("クッキー", property: "snack", likediff: 0)
            
            updateWord("夜明け", property: "time", likediff: 0)
            updateWord("お昼", property: "time", likediff: 0)
            
            updateWord("アメリカ", property: "country", likediff: 0)
            updateWord("イタリア", property: "country", likediff: 0)
            
            updateWord("たき", property: "location", likediff: 0)
            updateWord("遊園地", property: "location", likediff: 0)
            
            updateWord("バッハ", property: "artist", likediff: 0)
            updateWord("ピカソ", property: "artist", likediff: 0)
            
            updateWord("クラシック", property: "genre", likediff: 0)
            
            updateWord("クイズ", property: "game", likediff: 0)
            updateWord("じゃんけん", property: "game", likediff: 0)
            
            updateWord("うたたね", property: "healing", likediff: 0)
            
            updateWord("ぶどうジュース", property: "juice", likediff: 0)
            updateWord("オレンジュース", property: "juice", likediff: 0)
            print("first open")
        }
    }
    
    public class func newWord(word : String, property : String, like : Int16)
    {
        let newlike =  Int16(WordsManager.checkAboutWord(word, property: property));
        
        if( newlike != -1)
        {
            // do calculation for like
            // ....
            //....
            //....
            
            //update
            WordsManager.updateSavedData(word, property: property, likeNewValue: like)
        }
        else
        {
            // add it
            WordsManager.createActivity(word, property: property, like: like);
        }
    }
    
    
    public class func updateSavedData(word: String, property: String, likeNewValue: Int16)
    {
        let like =  Int16(WordsManager.checkAboutWord(word, property: property));
        if( like == -1) { return }
        
        
        let fetchRequest = NSFetchRequest(entityName: "Words")
        
        let resultPredicate1 = NSPredicate(format: "word = %@", word);
        let resultPredicate2 = NSPredicate(format: "property = %@", property)
        
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [resultPredicate1, resultPredicate2])
        fetchRequest.predicate = compound
        
        
        if let fetchResults = (try? DataSaver.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Words]
        {
            if fetchResults.count != 0
            {
                let managedObject = fetchResults[0]
                managedObject.like = likeNewValue;
                do {
                    //.setValue(likeNewValue, forKey: "like")
                
                    try DataSaver.sharedInstance.managedObjectContext.save()
                } catch _ {
                }
            }
        }
    }
    
    
    
    public class func checkAboutWord(word: String, property: String) -> Int
    {
        let fetchRequest = NSFetchRequest(entityName: "Words")
        
        let resultPredicate1 = NSPredicate(format: "word = %@", word);
        let resultPredicate2 = NSPredicate(format: "property = %@", property)
        
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [resultPredicate1, resultPredicate2])
        fetchRequest.predicate = compound;
        
        if let fetchResults = (try? DataSaver.sharedInstance.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Words]
        {
            if fetchResults.count != 0
            {
                let managedObject = fetchResults[0];
                let like =  Int(managedObject.like);
                
                return like//Int(activity.like);
            }
        }
        
        return -1; // not exist
    }
    
    
    public class func createWord(word: String, property: String, like: Int16) 
    {
        let getlike =  WordsManager.checkAboutWord(word, property: property);
        if( getlike != -1) { return  }
        
        createActivity( word, property: property, like: like)
    }
    
     public class func createActivity(word: String, property: String, like: Int16) -> Words
    {
        let newActivity: Words = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: DataManager.getContext()) as! Words
        
        newActivity.word = word
        newActivity.property = property
        newActivity.like = like
        
        DataManager.saveManagedContext()
        
        return newActivity
    }
    
    public class func fetchWordByProperty(property: String) -> [Words]
    {
        let request = NSFetchRequest(entityName: entityName)
        request.returnsObjectsAsFaults = false;
        
        let resultPredicate = NSPredicate(format: "property = %@", property)
        request.predicate = resultPredicate
        

        if let results:NSArray = (try! DataManager.getContext().executeFetchRequest(request)) as? [Words]
        {
            return results as! [Words]
        }
        else
        {
            return [Words]()
        }
    }
    
    public class func fetchAllWords() -> [Words]
    {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        // Create a sort descriptor object that sorts on the "name"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do
        {
            if let activities:[Words] = try DataManager.getContext().executeFetchRequest(fetchRequest) as? [Words] {
                return activities }
        }
        catch
        {
            return [Words]()
        }
        
        return [Words]()
    }
    
    public class func deleteAllActivities()
    {
    
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do
        {
            if let activities:[Words] = try DataManager.getContext().executeFetchRequest(fetchRequest) as? [Words]
            {
                for bas: AnyObject in activities
                {
                    DataManager.deleteManagedObject(bas as! NSManagedObject)
                }
            }
        }
        catch
        {
        
        }
    }
    
    public class func deleteActivity(activity:Words) {
        DataManager.deleteManagedObject(activity)
    }

}
