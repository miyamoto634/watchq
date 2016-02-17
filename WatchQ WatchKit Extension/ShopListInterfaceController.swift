//
//  ShopListInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/07/31.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation

class ShopListInterfaceController: ConnectionInterfaceController
{
    //csvパース
    let perthCsv = PerthCsv()
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    //ステータスマネージャー
    let statusManager = StatusManager()
    
    @IBOutlet weak var itemTable: WKInterfaceTable!
    @IBOutlet weak var goldLabel: WKInterfaceLabel!
    
    var goldAmount = 0//goldの値
    var shoptype = "gold"//ショップの種類（gold、dia）
    var shopName = "ゴールド"//ショップの種類（日本語）
    var allItemsDict = [[String:String]]()
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //ショップタイプを受け取る
        let getType = (context as? String)!
        if getType == "goldEquip" || getType == "goldConsume"
        {
            shoptype = "gold"
            shopName = "ゴールド"
        }
        else if getType == "diaEquip" || getType == "diaConsume"
        {
            shoptype = "dia"
            shopName = "ダイヤ"
        }
        
        allItemsDict = itemEffectManager.filterItemList(getType)
        
        //テーブルをセット
        loadTableData()
    }
    
    //テーブルのデータを読み込む
    func loadTableData()
    {
        itemTable.setNumberOfRows(allItemsDict.count, withRowType: "ItemTableRowController")
        
        for (index, value) in allItemsDict.enumerate()
        {
            let row = itemTable.rowControllerAtIndex(index) as! ItemTableRowController
            
            let menloFont = UIFont(name: "HiraKakuProN-W6", size: 12.0)!
            let menloFont2 = UIFont(name: "HiraKakuProN-W6", size: 14.0)!
            
            let fontAttrs = [NSFontAttributeName : menloFont]
            let fontAttrs2 = [NSFontAttributeName : menloFont2]
            
            let attrString = NSAttributedString(string: value["ItemName"]!, attributes: fontAttrs)
            row.itemNameLabel.setAttributedText(attrString)
            //row.itemNameLabel.setText(value["ItemName"])
            
            var costString = ""
            if shoptype == "gold" { costString = value["Gold"]! }
            else { costString = value["Diamonds"]! }
            let attrString2 = NSAttributedString(string: costString, attributes: fontAttrs2)
            row.itemCost.setAttributedText(attrString2)
        }
    }
    
    //詳細を押した時の反応
    override func contextForSegueWithIdentifier(
        segueIdentifier: String,
        inTable table: WKInterfaceTable,
        rowIndex: Int) -> AnyObject?
    {
        var sendDict = allItemsDict[rowIndex]
        sendDict["shoptype"] = shoptype
        return sendDict
    }
    
    //Goldの値をセットする
    func setGoldAmount()
    {
        if shoptype == "gold"
        {
            goldAmount = statusManager.loadValue("goldenAmount")
            goldLabel.setText("所持"+shopName+":"+String(goldAmount))
        }
        else if shoptype == "dia"
        {
            goldAmount = statusManager.loadValue("diamondAmount")
            exchangeDataWithIphone("userInfoInt", action: "getValue", veriable: "diamondAmount", value1: "", value2: "")
            goldLabel.setText("所持"+shopName+":"+String(goldAmount))
        }
    }
    
    override func getDataFromIphone(content:AnyObject)
    {
        super.getDataFromIphone(content)
        
        let reciveArray = content as! [String:AnyObject]
        
        goldAmount = reciveArray["result"]! as! Int
        statusManager.updateValue("diamondAmount", target_value: goldAmount)
        
        goldLabel.setText("所持"+shopName+":"+String(goldAmount))
    }
    
    override func willActivate()
    {
        super.willActivate()
        setGoldAmount()
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
    }
}
