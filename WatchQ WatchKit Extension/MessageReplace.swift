//
//  MessageReplace.swift
//  WatchQ
//
//  Created by H1-157 on 2015/09/01.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import Foundation

class MessageReplace:NSObject
{
    //ステータスクラスマネージャー
    var statusManager = StatusManager()
    
    //csvパーサー
    var perthCsv = PerthCsv()
    
    /////////////////// use for replaceing the word ///////////////////
    
    //索引文字記録
    var usedWordDict = [String:String]()
    //プレイヤー入力
    var playerInput = ""
    
    override init()
    {
        //初期化
        usedWordDict = [String:String]()
    }
    
    //文章の＜＞の中身を探し出す
    func replaceSentence(sentence:String)->String
    {
        var getChara = false
        var getText:String = ""
        var returnSentence = sentence
        
        for ch in sentence.characters
        {
            if ch == "%"{ getChara = true }
            else if ch == "＞"{
                getChara = false
                getText += "＞"
                returnSentence = replaceWord(returnSentence, text: getText)
                getText = ""
            }
            
            if getChara == true
            {
                let str = String(ch)
                getText += str
            }
        }
        
        return returnSentence
    }
    
    //＜＞の中身を置換
    func replaceWord(sentence:String, text:String)->String
    {
        let usedWordNum = usedWordDict.count + 1
        
        switch text
        {
        case "%＜飼い主＞":
            let playerName = statusManager.loadString("playerName")
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = playerName
            return sentence.stringByReplacingOccurrencesOfString("%＜飼い主＞", withString: playerName, options: [], range: nil)
        case "%＜ペット名＞":
            let petName = statusManager.loadString("petName")
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = petName
            return sentence.stringByReplacingOccurrencesOfString("%＜ペット名＞", withString: petName, options: [], range: nil)
        case "%＜プレイヤー入力＞":
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = playerInput
            return sentence.stringByReplacingOccurrencesOfString("%＜プレイヤー入力＞", withString: playerInput, options: [], range: nil)
        case "%＜現在時刻＞":
            let time = timeNow()
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = time
            return sentence.stringByReplacingOccurrencesOfString("%＜現在時刻＞", withString: time, options: [], range: nil)
        //ここ以降置き換える単語をペットの辞書から取得
        case "%＜食べ物＞":
            let foodWordList = WordsManager.fetchWordByProperty("food")
            let randNum = Int(arc4random_uniform(UInt32(foodWordList.count)))
            let foodName = foodWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = foodName
            return sentence.stringByReplacingOccurrencesOfString("%＜食べ物＞", withString: foodName, options: [], range: nil)
        default:
            break
        }
        
        //記録されている文字がなければそのまま返す
        if usedWordDict.count == 0 { return ""}
        
        //索引の置き換え
        for indexNum in 1...usedWordDict.count
        {
            let dictKey = "%＜索引["+String(indexNum)+"]＞"
            if text == dictKey
            {
                return sentence.stringByReplacingOccurrencesOfString(dictKey, withString: usedWordDict[dictKey]!, options: [], range: nil)
            }
        }
        
        return sentence
    }
    
    //現在時刻を返す
    func timeNow() -> String
    {
        let now = NSDate() // 現在日時の取得
        let dateFormatter = NSDateFormatter()
        
        // ロケールの設定
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        // スタイルの設定
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.dateStyle = .NoStyle
        
        let timeString = String(dateFormatter.stringFromDate(now))
        
        var timeFullString = ""
        for item in timeString.characters
        {
            timeFullString += convertHalf2Full(item)
        }
        
        return String(timeFullString)+"分"
    }
    
    //もっといい方法があればそれに置き換える
    func convertHalf2Full(chra: Character) -> String
    {
        switch chra{
        case "1":
            return "１"
        case "2":
            return "２"
        case "3":
            return "３"
        case "4":
            return "４"
        case "5":
            return "５"
        case "6":
            return "６"
        case "7":
            return "７"
        case "8":
            return "８"
        case "9":
            return "９"
        case "0":
            return "０"
        case ":":
            return "時"
        default:
            return String(chra)
        }
    }
    
    /////////////////// use for replaceing the word end ///////////////////
    
    /////////////////// use for pet balloon ///////////////////
    
    func selectPhrase(foodStateValue: Int, sleepStateValue: Int, funStateValue: Int, healthStateValue: Int, relationshipStateValue: Int, isSleeping: Bool, balloonConverSession:[[String:String]]) -> [String:String]
    {
        //候補配列
        var candidateArray = [[String:String]]()
        
        if isSleeping
        {
            candidateArray.append(balloonConverSession[5])
            candidateArray.append(balloonConverSession[6])
            
            //そこからランダムに選択
            let arrayLength:Int = Int(candidateArray.count)
            let randNum = Int(arc4random_uniform(UInt32(arrayLength)))
            
            return candidateArray[randNum]
        }
        
        //balloonConverSessionから条件に入るもののみを候補配列にappendする
        for elementDict in balloonConverSession
        {
            var flag = 0
            flag += cheackCondition(elementDict,
                conditionName:"condition1",
                foodStateValue: foodStateValue,
                sleepStateValue: sleepStateValue,
                funStateValue: funStateValue,
                healthStateValue: healthStateValue,
                relationshipStateValue: relationshipStateValue,
                isSleeping: isSleeping)
            
            flag += cheackCondition(elementDict,
                conditionName:"condition2",
                foodStateValue: foodStateValue,
                sleepStateValue: sleepStateValue,
                funStateValue: funStateValue,
                healthStateValue: healthStateValue,
                relationshipStateValue: relationshipStateValue,
                isSleeping: isSleeping)
            
            if flag == 0
            {
                candidateArray.append(elementDict)
            }
        }
        
        //そこからランダムに選択
        let arrayLength:Int = Int(candidateArray.count)
        let randNum = Int(arc4random_uniform(UInt32(arrayLength)))
        
        return candidateArray[randNum]
    }
    
    func cheackCondition(targetDict:[String:String], conditionName:String,foodStateValue: Int, sleepStateValue: Int, funStateValue: Int, healthStateValue: Int, relationshipStateValue: Int, isSleeping: Bool) -> Int
    {
        let paraX = Int(targetDict[conditionName+"para1"]!)!
        let paraY = Int(targetDict[conditionName+"para2"]!)!
        
        switch targetDict[conditionName]!
        {
        case "1"://no condition
            return 0
        case "2":// food is in X ~ Y
            if checkNumIsInside(foodStateValue, minNum: paraX, maxNum: paraY) { return 0 }
            return 1
        case "3":// fun is in X ~ Y
            if checkNumIsInside(funStateValue, minNum: paraX, maxNum: paraY) { return 0 }
            return 1
        case "4":// sleep is in X ~ Y
            if checkNumIsInside(sleepStateValue, minNum: paraX, maxNum: paraY) { return 0 }
            return 1
        case "5":// health is in X ~ Y
            if checkNumIsInside(healthStateValue, minNum: paraX, maxNum: paraY) { return 0 }
            return 1
        case "6":// relationship is in X ~ Y
            if checkNumIsInside(foodStateValue, minNum: paraX, maxNum: paraY) { return 0 }
            return 1
        case "7":// quiz correct number is X
            break
        case "8":// minigame win
            break
        case "9":// minigame draw
            break
        case "10":// minigame lose
            break
        case "11":// equip item number X
            //ここの処理大変そう
            break
        case "12":// is sleeping
            return 1
        case "13":// time is in X ~ Y
            break
        case "14":// day is in X ~ Y
            break
        case "15":// heartrate is in X ~ Y
            break
        case "16":// walktime is in X ~ Y
            break
        case "17":// bodytempurture is in X ~ Y
            break
        default:
            break
        }
        
        return 0
    }
    
    func checkNumIsInside(targetNum:Int, minNum:Int, maxNum:Int) -> Bool
    {
        if minNum <= targetNum || targetNum <= maxNum
        {
            return true
        }
        return false
    }
    
    /////////////////// use for pet balloon end ///////////////////
    
    /////////////////// use for pet talking part ///////////////////
    
    //何かないかなー
    func filterByStatus(foodStateValue: Int, sleepStateValue: Int, funStateValue: Int, healthStateValue: Int, relationshipStateValue: Int, isSleeping: Bool, converSession:[[String:String]]) -> [[String:String]]
    {
        //候補配列
        var candidateArray = [[String:String]]()
        
        //balloonConverSessionから条件に入るもののみを候補配列にappendする
        for elementDict in converSession
        {
            var flag = 0
            flag += cheackCondition(elementDict,
                conditionName:"condition1",
                foodStateValue: foodStateValue,
                sleepStateValue: sleepStateValue,
                funStateValue: funStateValue,
                healthStateValue: healthStateValue,
                relationshipStateValue: relationshipStateValue,
                isSleeping: isSleeping)
            
            flag += cheackCondition(elementDict,
                conditionName:"condition2",
                foodStateValue: foodStateValue,
                sleepStateValue: sleepStateValue,
                funStateValue: funStateValue,
                healthStateValue: healthStateValue,
                relationshipStateValue: relationshipStateValue,
                isSleeping: isSleeping)
            
            if flag == 0
            {
                candidateArray.append(elementDict)
            }
        }
        
        return candidateArray
    }
    
    /////////////////// use for pet talking part end ///////////////////
}