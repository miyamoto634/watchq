//
//  ItemEquipmentInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/18.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class EquipmentItemInterfaceController: WKInterfaceController
{
    //csvパース
    let perthCsv = PerthCsv()
    //ステータスマネージャー
    let statusManager = StatusManager()
    
    @IBOutlet weak var itemTable: WKInterfaceTable!
    
    //アイテムidを保存
    var itemIdArray = [Int16]()
    var allItemsDict = [[String:String]]()
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //csvをパースする
        allItemsDict = perthCsv.getAll("items")
    }
    
    //テーブルのデータを読み込む
    func loadTableData()
    {
        let equipList = statusManager.getPetImageDict()
        
        var itemQuery = ItemsManager.fetchItemByConsume(1 as Int16)
        
        //sort itemQuery by id
        for var i = 0; i < itemQuery.count-2; i++
        {
            for var j = itemQuery.count-1; j > i+1; j--
            {
                if itemQuery[j].itemId < itemQuery[j-1].itemId
                {
                    let tmp_item = itemQuery[j]
                    itemQuery[j] = itemQuery[j-1]
                    itemQuery[j-1] = tmp_item
                }
            }
        }
        
        if itemQuery.isEmpty { return }
        
        itemTable.setNumberOfRows(itemQuery.count, withRowType: "EquipmentTableRowController")
        
        for (index, value) in itemQuery.enumerate()
        {
            let row = itemTable.rowControllerAtIndex(index) as! EquipmentTableRowController
            
            itemIdArray.insert(value.itemId, atIndex: index)
            
            let targetItem = searchItemById(String(value.itemId))
            
            let menloFont = UIFont(name: "HiraKakuProN-W6", size: 12.0)!
            let fontAttrs = [NSFontAttributeName : menloFont]
            let attrString = NSAttributedString(string: targetItem["ItemName"]!, attributes: fontAttrs)
            row.itemNameLabel.setAttributedText(attrString)
            //row.itemNameLabel.setText(targetItem["ItemName"])
            
            let itemFileName = targetItem["FileName"]!
            for (_, name) in equipList
            {
                if itemFileName == name
                {
                    row.equipLabel.setText("E")
                    break
                }
                
                row.equipLabel.setText("")
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
    
    //詳細を押した時の反応
    override func contextForSegueWithIdentifier(
        segueIdentifier: String,
        inTable table: WKInterfaceTable,
        rowIndex: Int) -> AnyObject?
    {
        let itemId = itemIdArray[rowIndex]
        return Int(itemId)
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        let petImageDict = statusManager.getPetImageDict()
        print(petImageDict)
        
        //テーブルの設置
        loadTableData()
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
    }
}
