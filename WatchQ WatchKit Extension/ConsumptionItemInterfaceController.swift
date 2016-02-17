//
//  ConsumptionItemInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/18.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class ConsumptionItemInterfaceController: WKInterfaceController
{
    //csvパースクラス
    let perthCsv = PerthCsv()
    
    //アウトレット
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
        let itemQuery = ItemsManager.fetchItemByConsume(2 as Int16)
        if itemQuery.isEmpty
        {
            itemTable.setNumberOfRows(0, withRowType: "ConsumptionTableRowController")
            return
        }
        
        itemTable.setNumberOfRows(itemQuery.count, withRowType: "ConsumptionTableRowController")
        
        for (index, value) in itemQuery.enumerate()
        {
            let row = itemTable.rowControllerAtIndex(index) as! ConsumptionTableRowController
            
            print("itemid:"+String(value.itemId))
            print("amount:"+String(value.amount))
            itemIdArray.insert(value.itemId, atIndex: index)
            let targetItem = searchItemById(String(value.itemId))
            
            let menloFont = UIFont(name: "HiraKakuProN-W6", size: 12.0)!
            let fontAttrs = [NSFontAttributeName : menloFont]
            let attrString = NSAttributedString(string: targetItem["ItemName"]!, attributes: fontAttrs)
            row.itemNameLabel.setAttributedText(attrString)
            
            row.itemAmountLabel.setText(String(value.amount)+"個")
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
        
        loadTableData()
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
    }
}