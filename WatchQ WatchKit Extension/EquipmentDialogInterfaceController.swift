//
//  EquipmentDialogInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/18.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class EquipmentDialogInterfaceController: WKInterfaceController
{
    //csvパースクラス
    let perthCsv = PerthCsv()
    //アイテムマネージャークラス
    let itemEffectManager = ItemEffectManager()
    //ステマネ
    let statusManager = StatusManager()
    
    var itemDict = [String:String]()
    var isEquip = false
    
    //アウトレット
    @IBOutlet weak var dialogMessageLabel: WKInterfaceLabel!
    @IBOutlet weak var itemSummaryLabel: WKInterfaceLabel!
    @IBOutlet weak var yesButton: WKInterfaceButton!
    @IBOutlet weak var noButton: WKInterfaceButton!
    
    var allItemsDict = [[String:String]]()
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //csvをパースする
        allItemsDict = perthCsv.getAll("items")
        
        //前のシーンから受け取ったもの
        if let itemId = context as? Int
        {
            let itemQuery = ItemsManager.fetchItemById(Int16(itemId))
            itemDict = searchItemById(String(itemQuery.itemId))
            
            let equipList = statusManager.getPetImageDict()
            
            for (_, name) in equipList
            {
                dialogMessageLabel.setText(itemDict["ItemName"]!+"を装備しますか？")
                itemSummaryLabel.setText(itemDict["ItemSummary"]!)
                
                
                let itemFileName = itemDict["FileName"]!
                if itemFileName == name
                {
                    isEquip = true
                    dialogMessageLabel.setText(itemDict["ItemName"]!+"を外しますか？")
                    itemSummaryLabel.setHidden(true)
//                    yesButton.setTitle("外す")
//                    noButton.setTitle("もどる")
                    break
                }
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
        if isEquip { itemEffectManager.equipItem(itemDict, type: 0) }
        else { itemEffectManager.equipItem(itemDict, type: 1) }
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
