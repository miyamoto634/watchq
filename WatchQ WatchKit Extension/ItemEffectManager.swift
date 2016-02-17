//
//  ItemUse.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/24.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import Foundation

class ItemEffectManager: NSObject
{
    //csvパースクラス
    let perthCsv = PerthCsv()
    //ステータスマネージャークラス
    let statusManager = StatusManager()
    
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
        if type == 0 { statusManager.releaseItem(itemDict) }//解除
        else { statusManager.equipItem(itemDict) }//装備
    }
    
    //typeから効用を選択・反映
    func effectItem(itemDict: [String:String])
    {
        let itemType = itemDict["ItemType"]!
        
        if itemType == "6"
        {
            let diff_stamina = Int(itemDict["AddStamina"]!)!
            var stamina = statusManager.loadValue("staminaV")
            
            stamina += diff_stamina
            
            statusManager.updateValue("staminaV", target_value: stamina
            )
            
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
}