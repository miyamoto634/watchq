//
//  ExtensionDelegate.swift
//  WatchQ WatchKit Extension
//
//  Created by H1-2 on 24/09/2015.
//  Copyright © 2015 Ninja Egg. All rights reserved.
//

import WatchKit
//import DataSaverKit

class ExtensionDelegate: NSObject, WKExtensionDelegate
{
    let defaults = NSUserDefaults.standardUserDefaults();
    //コネクションマネージャー
    var connectionManager = ConnectionManager()
    //ステータスマネージャー
    var statusManager = StatusManager()
    
    
    
    func applicationDidFinishLaunching()
    {
        // Perform any final initialization of your application.
        ConnectionManager.sharedManager.startSession()
        
        
        //get error and save it to send it to iphone 
        /*
        NSSetUncaughtExceptionHandler { exception in
            var exceptionStr : String = String(exception);
            let exceptionCallStackSymbolsStr : String = String(exception.callStackSymbols);
            exceptionStr  = exceptionStr + "\n" + exceptionCallStackSymbolsStr;
            
            let defaults1 = NSUserDefaults.standardUserDefaults();
            defaults1.setValue(exceptionStr, forKey: "exceptionStr")
        }*/
    }

    func applicationDidBecomeActive()
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive()
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        var foodPeriod = 0
        var staminaPeriod = 0
        
        let statusDict = statusManager.loadStatus(false)
        
        foodPeriod = Int(statusDict["feedingV"]!)
        staminaPeriod = Int(statusDict["staminaMaxV"]! - statusDict["staminaV"]!)
        
        connectionManager.exchangeDataWithIphone("sendNotificationInfo", action: "updateValue", veriable: "", value1: [String(foodPeriod),String(staminaPeriod)], value2: "")
    }

}
