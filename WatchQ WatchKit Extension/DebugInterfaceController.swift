//
//  InterfaceController.swift
//  WatchQ WatchKit Extension
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class DebugInterfaceController: ConnectionInterfaceController
{
    //ステータスマネージャー
    var statusManager = StatusManager()
    //アイテムエフェクトマネージャー
    var itemEffectManager = ItemEffectManager()
    //csvパース
    var perthCsv = PerthCsv()
    
    @IBAction func levelIncreace()
    {
        let level = statusManager.loadValue("levelV")
        let maxStamina = statusManager.loadValue("staminaMaxV")
        statusManager.updateValue("levelV", target_value: level+1)
        statusManager.updateValue("staminaMaxV", target_value: maxStamina+900)
    }
    
    @IBAction func expIncreace()
    {
        let exppoint = statusManager.loadValue("experienceV")
        statusManager.updateValue("experienceV", target_value: exppoint+1000)
    }
    
    @IBAction func getAllItemParts()
    {
        //全アイテムのリストを取得
        let itemDictArray = perthCsv.filterType("items",type:"Consume",typeNum:"1")
        //全アイテムを追加
        for itemDict in itemDictArray
        {
            let itemID:Int16 = Int16(Int(itemDict["ItemID"]!)!)
            updateItem(itemID, consume: 1, amount_diff: 1)
        }
    }
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
            print("add item ID "+String(itemId))
            ItemsManager.createActivity(itemId, consume: consume, amount: amount_diff)
        }
    }
    
    @IBAction func zatugakuReleace()
    {
        statusManager.updateValue("zatugakuCorrectAnswers", target_value: 100)
        let all = statusManager.loadValue("quizCorrectAnswers")
        statusManager.updateValue("quizCorrectAnswers", target_value: all+100)
    }
    
    @IBAction func historyReleace()
    {
        statusManager.updateValue("historyCorrectAnswers", target_value: 100)
        let all = statusManager.loadValue("quizCorrectAnswers")
        statusManager.updateValue("quizCorrectAnswers", target_value: all+100)
    }
    
    @IBAction func sprotReleace()
    {
        statusManager.updateValue("sportCorrectAnswers", target_value: 100)
        let all = statusManager.loadValue("quizCorrectAnswers")
        statusManager.updateValue("quizCorrectAnswers", target_value: all+100)
    }
    
    @IBAction func geograohicReleace()
    {
        statusManager.updateValue("geographyCorrectAnswers", target_value: 100)
        let all = statusManager.loadValue("quizCorrectAnswers")
        statusManager.updateValue("quizCorrectAnswers", target_value: all+100)
    }
    
    @IBAction func artRelease()
    {
        statusManager.updateValue("artCorrectAnswers", target_value: 100)
        let all = statusManager.loadValue("quizCorrectAnswers")
        statusManager.updateValue("quizCorrectAnswers", target_value: all+100)
    }
    
    @IBAction func scienceRelease()
    {
        statusManager.updateValue("scienceCorrectAnswers", target_value: 100)
        let all = statusManager.loadValue("quizCorrectAnswers")
        statusManager.updateValue("quizCorrectAnswers", target_value: all+100)
    }
    
    @IBAction func ticRelease()
    {
        statusManager.updateValue("ticTacToeWins", target_value: 100)
    }
    
    @IBAction func spellRelease()
    {
        statusManager.updateValue("spillGridCorrectAnswers", target_value: 100)
    }
    
    @IBAction func coredataTest()
    {
        let tmp_dict = WordsManager.fetchAllWords()
        for word in tmp_dict
        {
            print("WORD:"+String(word.word))
            print("PROPERTY:"+String(word.property))
            print("LIKE:"+String(word.like))
        }
        print(tmp_dict)
    }
    
    @IBAction func getInfo()
    {
        exchangeDataWithIphone("userInfoInt", action: "getValue", veriable: "funV", value1: "", value2: "")
    }
    
    @IBOutlet var changePetButton: WKInterfaceButton!
    
    @IBAction func changePetRandom()
    {
        itemEffectManager.changePetImage(100, newLog: ["test"])
        
        let tmp_dict = statusManager.getPetImageDict()
        changePetButton.setTitle(tmp_dict["petBodyType"]!)
    }
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
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
