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
    
    //消費アイテム使用
    func useConsumeItem(itemDict: [String:String])
    {
        let itemID = Int(itemDict["ItemID"]!)!
        
        //存在しなかったらそのまま返す
        if !ItemsManager.checkAboutItem(Int16(itemID)) { return }
        
        let itemQuery = ItemsManager.fetchItemById(Int16(itemID))
        
        //効用
        if itemID != 901 && itemID != 1001
        {
            effectItem(itemDict)
        }
        
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
            for key in ["AddStamina", "AddHealth", "AddFun", "AddFood", "AddSleep", "AddRelation", "AddLevel", "AddExp", "AddGold", "AddDiamond"]
            {
                let diff_keyValue = Int(itemDict[key]!)!
                if diff_keyValue != 0 { addValueFromKey(key,diff_value: diff_keyValue) }
            }
            
            return
        }
        
        print("type:"+itemType+"の処理が存在しません。")
    }
    
    func addValueFromKey(key:String, diff_value:Int)
    {
        switch key
        {
        case "AddStamina":
            var returnValue = statusManager.loadValue("staminaV")
            returnValue += diff_value*900
            statusManager.updateValue("staminaV", target_value: returnValue)
            break
        case "AddHealth":
            print("Health!")
            break
        case "AddFun":
            var returnValue = statusManager.loadValue("funV")
            returnValue += diff_value*720
            statusManager.updateValue("funV", target_value: returnValue)
            break
        case "AddFood":
            var returnValue = statusManager.loadValue("feedingV")
            returnValue += diff_value*864
            statusManager.updateValue("feedingV", target_value: returnValue)
            break
        case "AddSleep":
            var returnValue = statusManager.loadValue("sleepingV")
            returnValue += diff_value*720
            statusManager.updateValue("sleepingV", target_value: returnValue)
            break
        case "AddRelation":
            var returnValue = statusManager.loadValue("frendshipV")
            returnValue += diff_value
            statusManager.updateValue("frendshipV", target_value: returnValue)
            break
        case "AddLevel":
            var returnValue = statusManager.loadValue("levelV")
            returnValue += diff_value
            statusManager.updateValue("levelV", target_value: returnValue)
            break
        case "AddExp":
            var returnValue = statusManager.loadValue("experienceV")
            returnValue += diff_value
            statusManager.updateValue("experienceV", target_value: returnValue)
            break
        case "AddGold":
            var returnValue = statusManager.loadValue("goldenAmount")
            returnValue += diff_value
            statusManager.updateValue("goldenAmount", target_value: returnValue)
            break
        case "AddDiamond":
            ConnectionManager.sharedManager.exchangeDataWithIphone("userInfoInt", action: "addValue", veriable: "diamondAmount", value1: String(diff_value), value2: "")
            break
        default:
            break
        }
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
            print("add item ID "+String(itemId))
            ItemsManager.createActivity(itemId, consume: consume, amount: amount_diff)
        }
    }
    
    //retrun item list that are unlocked
    func filterItemList(shopType:String) -> [[String:String]]
    {
        var allItemDictArray = [[String:String]]()
        var itemDictArray = [[String:String]]()
        var conditionNumDict = [String:Int]()
        //let dummyDict = ["ItemID":"0","Itemtype":"100","Consume":"100","ItemName":"？？？？","ItemSummary":"？？？？","How2Buy":"1","Gold":"？？","Diamonds":"？？"]
        var dummyDict = ["ItemID":"0","Itemtype":"0","Consume":"100","ItemName":"？？？？","ItemSummary":"？？？？","How2Buy":"1","Gold":"？？","Diamonds":"？？"]
        
         //get all item dict
        let tmpItemDictArray = perthCsv.getAll("items")
        
        //filter by shopType
        switch shopType
        {
        case "goldEquip":
            for element in tmpItemDictArray
            {
                if element["How2Buy"]! == "1" || element["How2Buy"]! == "2"
                {
                    if element["Consume"]! == "1"
                    { allItemDictArray += [element] }
                }
            }
            break
        case "goldConsume":
            for element in tmpItemDictArray
            {
                if element["How2Buy"]! == "1" || element["How2Buy"]! == "2"
                {
                    if element["Consume"]! == "2"
                    { allItemDictArray += [element] }
                }
            }
            break
        case "diaEquip":
            for element in tmpItemDictArray
            {
                if element["How2Buy"]! == "1" || element["How2Buy"]! == "3"
                {
                    if element["Consume"]! == "1"
                    { allItemDictArray += [element] }
                }
            }
            break
        case "diaConsume":
            for element in tmpItemDictArray
            {
                if element["How2Buy"]! == "1" || element["How2Buy"]! == "3"
                {
                    if element["Consume"]! == "2"
                    { allItemDictArray += [element] }
                }
            }
            break
        default:
            break
        }
        
        //get all status num use for condition
        conditionNumDict = getConditionDict()
        
        //get item list which player have
        let allItemList = ItemsManager.fetchAllItems()
        
        //filter some item from condition
        for itemDict in allItemDictArray
        {
            let threshold = Int(itemDict["UnlockThreshold"]!)
            let keyString = returnStringKey(itemDict["Unlock"]!)
            
            //check if it can add to item list
            var isExist = false
            if itemDict["Consume"] == "1"
            {
                for item in allItemList
                {
                    if itemDict["ItemID"] == String(item.itemId)
                    {
                        isExist = true
                        break
                    }
                }
            }
            
            if !isExist//装備アイテムですでに購入済みか
            {
                if itemDict["Unlock"]!  != "18"//18なら非表示
                {
                    if keyString != ""//空なら追加・条件ありなら判定
                    {
                        if conditionNumDict[keyString] >= threshold//判定
                        {
                            itemDictArray += [itemDict]
                        }
                        else
                        {
                            dummyDict["ItemID"] = itemDict["ItemID"]!
                            //dummyDict["ItemName"] = itemDict["ItemName"]!
                            itemDictArray += [dummyDict]
                        }
                    }
                    else
                    {
                        itemDictArray += [itemDict]
                    }
                }
            }
        }
        
        return itemDictArray
    }
    
    //get all status num use for condition
    func getConditionDict() -> [String:Int]
    {
        var conditionNumDict = [String:Int]()
        
        conditionNumDict["level"] = statusManager.loadValue("levelV")
        conditionNumDict["relationship"] = statusManager.loadValue("frendshipV")
        
        conditionNumDict["quizCorrectAnswers"] = statusManager.loadValue("quizCorrectAnswers")
        conditionNumDict["historyCorrectAnswers"] = statusManager.loadValue("historyCorrectAnswers")
        conditionNumDict["geographyCorrectAnswers"] = statusManager.loadValue("geographyCorrectAnswers")
        conditionNumDict["artCorrectAnswers"] = statusManager.loadValue("artCorrectAnswers")
        conditionNumDict["sportCorrectAnswers"] = statusManager.loadValue("sportCorrectAnswers")
        conditionNumDict["scienceCorrectAnswers"] = statusManager.loadValue("scienceCorrectAnswers")
        conditionNumDict["zatugakuCorrectAnswers"] = statusManager.loadValue("zatugakuCorrectAnswers")
        
        conditionNumDict["spillGridCorrectAnswers"] = statusManager.loadValue("spillGridCorrectAnswers")
        conditionNumDict["ticTacToeWins"] = statusManager.loadValue("ticTacToeWins")
        conditionNumDict["gold"] = statusManager.loadValue("maxGoldenAmount")
        let timeDiffDict = statusManager.calcSpendTimeDiff()
        conditionNumDict["spendTime"] = timeDiffDict["hour"]!*60+timeDiffDict["min"]!
        
        return conditionNumDict
    }
    
    //return key which use for comparision
    func returnStringKey(Unlock:String) -> String
    {
        var keyString = ""
        
        switch Unlock
        {
        case "1"://no condition
            break
        case "2"://level
            keyString = "level"
            break
        case "3"://revive
            print("reveive is not ready yet")
            break
        case "4"://total play time
            keyString = "spendTime"
            break
        case "5"://relationship
            keyString = "relationship"
            break
        case "6"://learned word
            print("learn word amount is not ready yet")
            break
        case "7"://correct answer of all quiz
            keyString = "quizCorrectAnswers"
            break
        case "8"://correct answer of history quiz
            keyString = "historyCorrectAnswers"
            break
        case "9"://correct answer of geography quiz
            keyString = "geographyCorrectAnswers"
            break
        case "10"://correct answer of art quiz
            keyString = "artCorrectAnswers"
            break
        case "11"://correct answer of sport quiz
            keyString = "sportCorrectAnswers"
            break
        case "12"://correct answer of science quiz
            keyString = "scienceCorrectAnswers"
            break
        case "13"://correct answer of zatugaku quiz
            keyString = "zatugakuCorrectAnswers"
            break
        case "14"://tictactoe win
            keyString = "ticTacToeWins"
            break
        case "15"://spellgrid correct
            keyString = "spillGridCorrectAnswers"
            break
        case "16"://gold
            keyString = "gold"
            break
        case "17"://play time
            keyString = "spendTime"
            break
        default:
            break
        }
        
        return keyString
    }
    
    //pet change random
    func changePetImage(usedStamina:Int, newLog:[String]) -> Bool
    {
        var logArray = statusManager.loadArray("playLog")
        
        //add new record, delete old record
        if newLog[0] != "test"
        {
            logArray += newLog
            while logArray.count > 300
            {
                logArray.removeAtIndex(0)
            }
            print("array length:"+String(logArray.count))
            statusManager.updateArray("playLog", target_array: logArray)
        }
        
        if logArray == [String]() { return false }
        
        let rand = Int(arc4random_uniform(100))
        if rand > usedStamina { return false }
        
        //count the number of each type
        var typeCountDict =
        [
            "history":0,
            "geography":0,
            "art":0,
            "sport":0,
            "zatugaku":0,
            "science":0,
            "default":0
        ]
        
        for item in logArray
        {
            switch item
            {
            case "history":
                typeCountDict["history"]! += 1
                break
            case "geography":
                typeCountDict["geography"]! += 1
                break
            case "art":
                typeCountDict["art"]! += 1
                break
            case "sport":
                typeCountDict["sport"]! += 1
                break
            case "zatugaku":
                typeCountDict["zatugaku"]! += 1
                break
            case "science":
                typeCountDict["science"]! += 1
                break
            case "default":
                typeCountDict["default"]! += 1
                break
            default:
                break
            }
        }
        
        print("history:"+String(typeCountDict["history"]!))
        print("geography:"+String(typeCountDict["geography"]!))
        print("art:"+String(typeCountDict["art"]!))
        print("sport:"+String(typeCountDict["sport"]!))
        print("zatugaku:"+String(typeCountDict["zatugaku"]!))
        print("science:"+String(typeCountDict["science"]!))
        
        //select which one
        let randNum = Int(arc4random_uniform(UInt32(logArray.count)))
        
        //get pet image dict 
        var petImageDict = statusManager.getPetImageDict()
        
        //history
        if typeCountDict["history"]! > randNum
        {
            print("pet face change to history")
            petImageDict["petBodyType"] = "Pet_history_rand"
            petImageDict["petEye"]! = "Pet_history_rand_petEye"
            petImageDict["petMouth"]! = "Pet_history_rand_petMouth"
            petImageDict["petSkin"]! = "Pet_history_rand_petSkin"
            
            var recordDict = statusManager.loadStringIntDict("recordDict")
            if recordDict["petPartHistory"]! == 0
            {
                recordDict["petPartHistory"]! = 1
                statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
            }
            
            statusManager.upadatePetImageName(petImageDict)
            return true
        }
        
        //geography
        if typeCountDict["geography"]! + typeCountDict["history"]! > randNum
        {
            petImageDict["petBodyType"] = "Pet_geography_rand"
            petImageDict["petEye"]! = "Pet_geography_rand_petEye"
            petImageDict["petMouth"]! = "Pet_geography_rand_petMouth"
            petImageDict["petSkin"]! = "Pet_geography_rand_petSkin"
            
            var recordDict = statusManager.loadStringIntDict("recordDict")
            if recordDict["petPartGeograpy"]! == 0
            {
                recordDict["petPartGeograpy"]! = 1
                statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
            }
            
            print("pet face change to geography")
            statusManager.upadatePetImageName(petImageDict)
            return true
        }
        
        //art
        if typeCountDict["art"]! + typeCountDict["geography"]! + typeCountDict["history"]! > randNum
        {
            petImageDict["petBodyType"] = "Pet_art_rand"
            petImageDict["petEye"]! = "Pet_art_rand_petEye"
            petImageDict["petMouth"]! = "Pet_art_rand_petMouth"
            petImageDict["petSkin"]! = "Pet_art_rand_petSkin"
            
            var recordDict = statusManager.loadStringIntDict("recordDict")
            if recordDict["petPartArt"]! == 0
            {
                recordDict["petPartArt"]! = 1
                statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
            }
            
            print("pet face change to art")
            statusManager.upadatePetImageName(petImageDict)
            return true
        }
        
        //sport
        if typeCountDict["sport"]! + typeCountDict["art"]! + typeCountDict["geography"]! + typeCountDict["history"]! > randNum
        {
            petImageDict["petBodyType"] = "Pet_sport_rand"
            petImageDict["petEye"]! = "Pet_sport_rand_petEye"
            petImageDict["petMouth"]! = "Pet_sport_rand_petMouth"
            petImageDict["petSkin"]! = "Pet_sport_rand_petSkin"
            
            var recordDict = statusManager.loadStringIntDict("recordDict")
            if recordDict["petPartSports"]! == 0
            {
                recordDict["petPartSports"]! = 1
                statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
            }
            
            print("pet face change to sport")
            statusManager.upadatePetImageName(petImageDict)
            return true
        }
        
        //zatugaku
        if typeCountDict["zatugaku"]! + typeCountDict["sport"]! + typeCountDict["art"]! + typeCountDict["geography"]! + typeCountDict["history"]! > randNum
        {
            petImageDict["petBodyType"] = "Pet_zatugaku_rand"
            petImageDict["petEye"]! = "Pet_zatugaku_rand_petEye"
            petImageDict["petMouth"]! = "Pet_zatugaku_rand_petMouth"
            petImageDict["petSkin"]! = ""
            
            var recordDict = statusManager.loadStringIntDict("recordDict")
            if recordDict["petPartZatugaku"]! == 0
            {
                recordDict["petPartZatugaku"]! = 1
                statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
            }
            
            print("pet face change to zatugaku")
            statusManager.upadatePetImageName(petImageDict)
            return true
        }
        
        //science
        if typeCountDict["science"]! + typeCountDict["zatugaku"]! + typeCountDict["sport"]! + typeCountDict["art"]! + typeCountDict["geography"]! + typeCountDict["history"]! > randNum
        {
            petImageDict["petBodyType"] = "Pet_science_rand"
            petImageDict["petEye"]! = "Pet_science_rand_petEye"
            petImageDict["petMouth"]! = "Pet_science_rand_petMouth"
            petImageDict["petSkin"]! = ""
            
            var recordDict = statusManager.loadStringIntDict("recordDict")
            if recordDict["petPartScience"]! == 0
            {
                recordDict["petPartScience"]! = 1
                statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
            }
            
            print("pet face change to science")
            statusManager.upadatePetImageName(petImageDict)
            return true
        }
        
        //default
        var petGender = "man"
        
        if statusManager.loadValue("petgender") == 1 { petGender = "man" }
        else { petGender = "woman" }
        
        print("pet face change to default")
        petImageDict["petBodyType"] = "Pet_default_"+petGender
        petImageDict["petEye"]! = "Pet_default_"+petGender+"_petEye"
        petImageDict["petMouth"]! = "Pet_default_"+petGender+"_petMouth"
        petImageDict["petSkin"]! = "Pet_default_"+petGender+"_petSkin"
        statusManager.upadatePetImageName(petImageDict)
        
        return true
    }
}