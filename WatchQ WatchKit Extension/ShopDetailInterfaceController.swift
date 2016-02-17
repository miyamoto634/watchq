//
//  ShopDetailInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/07/31.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class ShopDetailInterfaceController: ConnectionInterfaceController
{
    //ステータスマネージャー
    let statusManager = StatusManager()
    //csvパース
    let perthCsv = PerthCsv()
    
    @IBOutlet weak var itemNameLabel: WKInterfaceLabel!
    @IBOutlet weak var itemSummaryLabel: WKInterfaceLabel!
    @IBOutlet weak var costLabel: WKInterfaceLabel!
    @IBOutlet weak var infoLabel: WKInterfaceLabel!
    
    @IBOutlet weak var buyButton: WKInterfaceButton!
    @IBOutlet weak var dismissButton: WKInterfaceButton!
    
    var unitAmount = 0
    var shoptype = "gold"
    var shopName = "ゴールド"
    var allItemsDict = [[String:String]]()
    var itemDict = [String:String]()
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //csvをパースする
        allItemsDict = perthCsv.getAll("items")
        
        //前のシーンから受け取ったものをセット
        if let contextDict = context as? [String:String]
        {
            itemDict = contextDict
            shoptype = contextDict["shoptype"]!
            
            if shoptype == "gold"
            {
                shopName = "ゴールド"
                unitAmount = statusManager.loadValue("goldenAmount")
                costLabel.setText(shopName+":"+itemDict["Gold"]!)
            }
            else if shoptype == "dia"
            {
                shopName = "ダイヤ"
                unitAmount = statusManager.loadValue("diamondAmount")
                exchangeDataWithIphone("userInfoInt", action: "getValue", veriable: "diamondAmount", value1: "", value2: "")
                costLabel.setText(shopName+":"+itemDict["Diamonds"]!)
            }
            
            //文字のセット
            itemNameLabel.setText(itemDict["ItemName"]!)
            itemSummaryLabel.setText(itemDict["ItemSummary"]!)
        }
    }
    
    override func getDataFromIphone(content:AnyObject)
    {
        super.getDataFromIphone(content)
        
        let reciveArray = content as! [String:AnyObject]
        
        unitAmount = reciveArray["result"]! as! Int
        statusManager.updateValue("diamondAmount", target_value: unitAmount)
        
        setAlert()
    }
    
    //注意を表記
    func setAlert()
    {
        var itemCost = 0
        let itemId = Int16(Int(itemDict["ItemID"]!)!)
        
        if itemDict["Itemtype"] == "0"
        {
            buyButton.setHidden(true)
            dismissButton.setHidden(true)
            infoLabel.setText("このアイテムはまだ解放されていません。")
            
            return
        }
        
        if shoptype == "gold"
        {
            unitAmount = statusManager.loadValue("goldenAmount")
            itemCost = Int(itemDict["Gold"]!)!
        }
        else if shoptype == "dia"
        {
            unitAmount = statusManager.loadValue("diamondAmount")
            itemCost = Int(itemDict["Diamonds"]!)!
        }
        
        if itemCost > unitAmount
        {
            buyButton.setHidden(true)
            dismissButton.setHidden(true)
            infoLabel.setText(shopName+"が不足しています。")
        }
        else
        {
            let itemExist =  ItemsManager.checkAboutItem(itemId)
            if itemExist
            {
                let itemQuery = ItemsManager.fetchItemById(itemId)
                
                if itemDict["Consume"] == "1" && itemQuery.amount >= 1
                {
                    buyButton.setHidden(true)
                    dismissButton.setHidden(true)
                    infoLabel.setText("すでに購入されています。")
                    return
                }
                else if itemDict["Consume"] == "2" && itemQuery.amount >= 99
                {
                    buyButton.setHidden(true)
                    dismissButton.setHidden(true)
                    infoLabel.setText("購入数が最大値(99)を超えています。")
                    return
                }
                
                infoLabel.setText("現在の所持数:"+String(itemQuery.amount))
            }
            else
            {
                infoLabel.setText("現在の所持数:0")
            }
        }
    }
    
    
    @IBAction func selectBuy()
    {
        var sendCost = ""
        if shoptype == "gold"
        {
            sendCost = itemDict["Gold"]!
        }
        else if shoptype == "dia"
        {
            sendCost = itemDict["Diamonds"]!
        }
         presentControllerWithName("buydialog", context: [itemDict["ItemID"]!, itemDict["ItemName"]!, itemDict["Consume"]!, sendCost, shoptype])
    }
    
    @IBAction func selectIgnore() { dismissController() }
    
    func searchItemById(idNum: String) -> [String:String]
    {
        for item in allItemsDict
        {
            if item["ItemID"] == idNum { return item }
        }
        return [String:String]()
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        setAlert()
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
    }
}
