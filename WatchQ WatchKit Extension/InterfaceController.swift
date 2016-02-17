//
//  InterfaceController.swift
//  WatchQ WatchKit Extension
//
//  Created by H1-2 on 24/09/2015.
//  Copyright © 2015 Ninja Egg. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
         WordsManager.fillFoodListForFirstLunchApp();
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
