//
//  BuyCheckDialogInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/21.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class BuyCheckDialogInterfaceController: WKInterfaceController
{
    //ステータスマネージャー
    let statusManager = StatusManager()
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    
    var itemID:Int16 = 0
    var itemName = ""
    var consume:Int16 = 0
    var cost = 0
    var shoptype = "gold"
    var unitAmount = 0
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        if let contextArray = context as? [String]
        {
            itemID = Int16(Int(contextArray[0])!)
            itemName = contextArray[1]
            consume = Int16(Int(contextArray[2])!)
            cost = Int(contextArray[3])!
            shoptype = contextArray[4]
        }
        
        var typeName = ""
        if shoptype == "gold"
        {
            typeName = "ゴールド"
            unitAmount = statusManager.loadValue("goldenAmount")
        }
        else if shoptype == "dia"
        {
            typeName = "ダイヤ"
            unitAmount = statusManager.loadValue("diamondAmount")
        }
        
        var messageText = String(cost)+typeName+"で"+itemName
        messageText += "を購入してもよろしでしょうか？"
        messageLabel.setText(messageText)
    }
    
    @IBAction func selectYes()
    {
        itemEffectManager.updateItem(itemID, consume: consume, amount_diff: 1)

        unitAmount -= cost
        print("diff:"+String(cost))
        print("Gold"+String(unitAmount))
        if shoptype == "gold"
        {
            statusManager.updateValue("goldenAmount", target_value: unitAmount)
        }
        else
        {
            ConnectionManager.sharedManager.exchangeDataWithIphone("userInfoInt", action: "addValue", veriable: "diamondAmount", value1: String(-cost), value2: "")
        }
        
        dismissController()
    }
    
    @IBAction func selectNo()
    {
        dismissController()
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
