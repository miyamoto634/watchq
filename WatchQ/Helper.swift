//
//  Helper.swift
//  WatchQ
//
//  Created by H1-2 on 25/08/2015.
//  Copyright (c) 2015 DaisukeMiyamoto. All rights reserved.
//

import Foundation
import UIKit

public class Helper : NSObject, BWWalkthroughViewControllerDelegate{
    
    let defaults = NSUserDefaults.standardUserDefaults()//NSUserDefaults(suiteName:"group.com.platinum-egg.WatchQ.userdefaults")// to save data in user file
    //let defaults1 = NSUserDefaults.standardUserDefaults();// not shared with watch
    
    //csvパースクラス
    let perthCsv = PerthCsv()
    //ステータスマネージャークラス
    
    override init()
    {
        //初期化
    }
    
    //（本当は購入処理をここでやりたい）
    //消費アイテム使用
    func useConsumeItem(itemDict: [String:String])
    {
        let itemID = Int(itemDict["ItemID"]!)!
        let itemQuery = ItemsManager.fetchItemById(Int16(itemID))
        
        //効用
        effectItem(itemDict)
        
        //消費
        if itemQuery.amount <= 1
        {
            ItemsManager.deleteItemByID(Int16(itemQuery.itemId))
        }
        else
        {
            updateItem(Int16(itemQuery.itemId), consume: itemQuery.consume, amount_diff: -1)
        }
    }
    
    //装備アイテム装備
    func equipItem(itemDict: [String:String], type: Int)
    {
        if (type == 0)
        {
          //  statusManager.releaseItem(itemDict)//解除
        }
        else
        {
         //   statusManager.equipItem(itemDict)//装備
        }
    }
    
    //typeから効用を選択・反映
    func effectItem(itemDict: [String:String])
    {
        let itemType = itemDict["ItemType"]!
        
        if itemType == "6"
        {
            let diff_stamina = Int(itemDict["AddStamina"]!)!
            var stamina = defaults.integerForKey("staminaV");
            
            stamina += diff_stamina
            
            defaults.setInteger(stamina , forKey: "staminaV");
            
            return
        }
        
        print("type:"+itemType+"の処理が存在しません。")
    }
    
    //アイテム情報更新
    func updateItem(itemId: Int16, consume: Int16, amount_diff: Int16)
    {
        let itemExist =  ItemsManager.checkAboutItem(itemId)
        var amount = ItemsManager.getAmountofItem(itemId)
        
        if itemExist
        {
            amount += amount_diff
            print("update:"+String(amount))
            
            //update
            ItemsManager.updateSavedData(itemId, amount: amount)
        }
        else
        {
            // add it
            ItemsManager.createActivity(itemId, consume: consume, amount: amount_diff)
        }
    }
    
    let defaults1 = NSUserDefaults.standardUserDefaults();
    
    func goToPetView() -> BWWalkthroughViewController
    {
      //  defaults1.setInteger(0, forKey: "pageNo");
        
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Pet", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("walk") as! BWWalkthroughViewController
        let petView = stb.instantiateViewControllerWithIdentifier("petView") as UIViewController;
        
        walkthrough.delegate = self
        walkthrough.addViewController(petView)
        
        // this to add views to scroll view
       if(defaults1.stringForKey("swichDeviceV") == nil || defaults1.stringForKey("swichDeviceV")! == "watch")
        {
            let generalResultV = stb.instantiateViewControllerWithIdentifier("GeneralResult") as UIViewController
            let generalResultV2 = stb.instantiateViewControllerWithIdentifier("GeneralResult2") as UIViewController
            walkthrough.addViewController(generalResultV);
            walkthrough.addViewController(generalResultV2);
        }
        return walkthrough;
    }
    
    func randomInt(min: Int, max:Int) -> Int
    {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}