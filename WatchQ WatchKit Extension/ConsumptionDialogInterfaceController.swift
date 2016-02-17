//
//  ConsumptionDialogInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/18.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class ConsumptionDialogInterfaceController: WKInterfaceController
{
    //csvパース
    let perthCsv = PerthCsv()
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    //ステータスマネージャー
    let statusManager = StatusManager()
    
    //アウトレット
    @IBOutlet weak var dialogMessageLabel: WKInterfaceLabel!
    @IBOutlet weak var itemSummaryLabel: WKInterfaceLabel!
    @IBOutlet weak var yesButton: WKInterfaceButton!
    @IBOutlet weak var noButton: WKInterfaceButton!
    
    var itemIdNum:Int = 1
    var allItemsDict = [[String:String]]()
    var itemDict = [String:String]()
    
    //テスト用
    let messageDict = ["スタミナが最大です。", "機嫌は最大です。", "睡眠が最大です。"]
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //csvをパースする
        allItemsDict = perthCsv.getAll("items")
        
        //前のシーンから受け取ったもの
        if let itemId = context as? Int
        {
            let itemQuery = ItemsManager.fetchItemById(Int16(itemId))
            itemIdNum = itemId
            itemDict = searchItemById(String(itemQuery.itemId))
            
            let canUse = checkItemCanUse()
            if canUse == -1
            {
                dialogMessageLabel.setText(itemDict["ItemName"]!+"を消費しますか？")
                itemSummaryLabel.setText(itemDict["ItemSummary"]!)
            }
            else
            {
                
                dialogMessageLabel.setText("アイテムを使うことができません。")
                itemSummaryLabel.setText(messageDict[canUse])
                yesButton.setHidden(true)
                noButton.setTitle("もどる")
            }
        }
    }
    
    func searchItemById(idNum: String) -> [String:String]
    {
        for item in allItemsDict
        {
            if item["ItemID"] == idNum { return item }
        }
        return [String:String]()
    }
    
    @IBAction func selectYes()
    {
        print("select Yes")
        print("item decrease")
        
        if itemIdNum == 901
        {
            presentControllerWithName("specialItem", context: "7")
        }
        else if itemIdNum == 1001
        {
            presentControllerWithName("specialItem", context: "8")
        }
        else
        {
            itemEffectManager.useConsumeItem(itemDict)
            dismissController()
        }
    }
    
    @IBAction func selectNo()
    {
        dismissController()
    }
    
    //アイテムが使用できるか確認
    func checkItemCanUse() -> Int
    {
        for keyName in ["AddStamina", "AddFun", "AddSleep"]
        {
            let keyAmount = Int(itemDict[keyName]!)
            
            print(keyName+":"+String(keyAmount))
            
            if keyAmount != 0
            {
                switch keyName
                {
                case "AddStamina":
                    
                    let maxStamina = statusManager.loadValue("staminaMaxV")
                    let stamina = statusManager.loadValue("staminaV")
                    
                    print("stamina:"+String(stamina))
                    
                    if stamina >= maxStamina { return 0 }
                    else { return -1 }
                    
                case "AddFun":
                    
                    let petFun = Int(statusManager.loadValue("funV")/720)
                    
                    print("fun:"+String(petFun))
                    
                    if petFun >= 100 { return 1 }
                    else { return -1 }
                    
                case "AddSleep":
                    
                    let petSleep = Int(statusManager.loadValue("sleepingV")/720)
                    
                    print("sleep:"+String(petSleep))
                    
                    if petSleep >= 100 { return 2 }
                    else { return -1 }
                    
                default:
                    break
                }
            }
        }
        
        return -1
    }
    
    override func willActivate()
    {
        super.willActivate()
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
    }
}
