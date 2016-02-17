//
//  ConectionManager.swift
//  WatchQ
//
//  Created by H1-157 on 2015/10/09.
//  Copyright © 2015年 Ninja Egg. All rights reserved.
//

import Foundation
import WatchConnectivity

class ConnectionManager:NSObject, WCSessionDelegate
{
    static let sharedManager = ConnectionManager()
    var session : WCSession!
    
    override init()
    {
        if WCSession.isSupported() { session =  WCSession.defaultSession() }
        else { session = nil }
        
        super.init()
    }
    
    func startSession() {
        session.delegate = self
        session.activateSession()
    }
    
    func exchangeDataWithIphone(name: String, action: String, veriable: String, value1: AnyObject, value2: AnyObject)
    {
        //name: coreDataWords, coreDataItems, userInfoInt, userInfoBool, userInfoString, userInfoObject
        //action : getWord, updateWord, fetchItemByConsume, fetchItemById, updateSavedData, checkAboutItem, getAmountofItem, deleteItemByID, createItem
        
        if WCSession.isSupported()
        {
            let message = makeInfoForSend(name, action: action, veriable: veriable, value1: value1, value2: value2)
            
            session.sendMessage(message, replyHandler: { (content:[String : AnyObject]) -> Void in
                
                self.getDataFromIphone(content)
                
                }, errorHandler: {  (error ) -> Void in
                    
                    self.errorOnGettingData(error)
            })
        }
    }
    
    //**** override function to use in each class ****//
    
    //use function to add
    func makeInfoForSend(name: String, action: String, veriable: String, value1: AnyObject, value2: AnyObject) -> [String:AnyObject]
    {
        return ["name" : name, "action": action, "veriable": veriable, "value1": value1, "value2": value2]
    }
    
    //write proceeger after you get data from iphone on here
    func getDataFromIphone(content:AnyObject)
    {
        print("succes to get info from iphone")
        print(content)
    }
    
    //write error on here
    func errorOnGettingData(error:NSError)
    {
        print("We got an error from our paired device : \(error)")
    }
    
    //**** override function to use in each class ****//
}
