//
//  MessageReplace.swift
//  WatchQ
//
//  Created by H1-157 on 2015/09/01.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import Foundation

public class MessageReplace:NSObject
{
    //ステータスクラスマネージャー
    var statusManager = StatusManager()
    
    //csvパーサー
    let perthCsv = PerthCsv()
    
    let enCharacters:[Character] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    let jaCharacters:[Character] = ["あ","い","う","え","お","か","き","く","け","こ","さ","し","す","せ","そ","た","ち","つ","て","と","な","に","ぬ","ね","の","は","ひ","ふ","へ","ほ","ま","み","む","め","も","や","ゆ","よ","ら","り","る","れ","ろ","わ","を","ん","が","ぎ","ぐ","げ","ご","ざ","じ","ず","ぜ","ぞ","だ","ぢ","づ","で","ど","ば","び","ぶ","べ","ぼ","ぱ","ぴ","ぷ","ぺ","ぽ","ゃ","ゅ","ょ","っ"]
   let kanaCharacters:[Character] = ["ア","イ","ウ","エ","オ","カ","キ","ク","ケ","コ","サ","シ","ス","セ","ソ","タ","チ","ツ","ツ","ト","ナ","ニ","ヌ","ネ","ノ","ハ","ヒ","フ","ヘ","ホ","マ","ミ","ム","メ","モ","ヤ","ユ","ヨ","ラ","リ","ル","レ","ロ","ワ","ヲ","ン","ガ","ギ","グ","グ","ゲ","ゴ","ザ","ジ","ズ","ゼ","ゾ","ダ","ヂ","ヅ","デ","ド","パ","ピ","プ","ペ","ポ","ャ","ュ","ョ","ッ"]
    
    
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
        case "%＜地名＞":
            let placeWordList = WordsManager.fetchWordByProperty("place")
            let randNum = Int(arc4random_uniform(UInt32(placeWordList.count)))
            let placeName = placeWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = placeName
            return sentence.stringByReplacingOccurrencesOfString("%＜地名＞", withString: placeName, options: [], range: nil)
        case "%＜おやつ＞":
            let snackWordList = WordsManager.fetchWordByProperty("snack")
            let randNum = Int(arc4random_uniform(UInt32(snackWordList.count)))
            let snackName = snackWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = snackName
            return sentence.stringByReplacingOccurrencesOfString("%＜おやつ＞", withString: snackName, options: [], range: nil)
        case "%＜時間＞":
            let timeWordList = WordsManager.fetchWordByProperty("time")
            let randNum = Int(arc4random_uniform(UInt32(timeWordList.count)))
            let timeName = timeWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = timeName
            return sentence.stringByReplacingOccurrencesOfString("%＜時間＞", withString: timeName, options: [], range: nil)
        case "%＜国＞":
            let countryWordList = WordsManager.fetchWordByProperty("country")
            let randNum = Int(arc4random_uniform(UInt32(countryWordList.count)))
            let countryName = countryWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = countryName
            return sentence.stringByReplacingOccurrencesOfString("%＜国＞", withString: countryName, options: [], range: nil)
        case "%＜場所＞":
            let locationWordList = WordsManager.fetchWordByProperty("location")
            let randNum = Int(arc4random_uniform(UInt32(locationWordList.count)))
            let locationName = locationWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = locationName
            return sentence.stringByReplacingOccurrencesOfString("%＜場所＞", withString: locationName, options: [], range: nil)
        case "%＜アーティスト＞":
            let artistWordList = WordsManager.fetchWordByProperty("artist")
            let randNum = Int(arc4random_uniform(UInt32(artistWordList.count)))
            let artistName = artistWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = artistName
            return sentence.stringByReplacingOccurrencesOfString("%＜アーティスト＞", withString: artistName, options: [], range: nil)
        case "%＜ジャンル＞":
            let genruWordList = WordsManager.fetchWordByProperty("genru")
            let randNum = Int(arc4random_uniform(UInt32(genruWordList.count)))
            let genruName = genruWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = genruName
            return sentence.stringByReplacingOccurrencesOfString("%＜ジャンル＞", withString: genruName, options: [], range: nil)
        case "%＜遊び＞":
            let gameWordList = WordsManager.fetchWordByProperty("game")
            let randNum = Int(arc4random_uniform(UInt32(gameWordList.count)))
            let gameName = gameWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = gameName
            return sentence.stringByReplacingOccurrencesOfString("%＜遊び＞", withString: gameName, options: [], range: nil)
        case "%＜癒やし＞":
            let healingWordList = WordsManager.fetchWordByProperty("healing")
            let randNum = Int(arc4random_uniform(UInt32(healingWordList.count)))
            let healingName = healingWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = healingName
            return sentence.stringByReplacingOccurrencesOfString("%＜癒やし＞", withString: healingName, options: [], range: nil)
        case "%＜ジュース＞":
            let juiceWordList = WordsManager.fetchWordByProperty("juice")
            let randNum = Int(arc4random_uniform(UInt32(juiceWordList.count)))
            let juiceName = juiceWordList[randNum].word
            let usedWordNum = usedWordDict.count + 1
            usedWordDict["%＜索引["+String(usedWordNum)+"]＞"] = juiceName
            return sentence.stringByReplacingOccurrencesOfString("%＜ジュース＞", withString: juiceName, options: [], range: nil)
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
    
    func selectPhrase(foodStateValue: Int, sleepStateValue: Int, funStateValue: Int, relationshipStateValue: Int, isSleeping: Bool, balloonConverSession:[[String:String]]) -> [String:String]
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
                relationshipStateValue: relationshipStateValue,
                isSleeping: isSleeping)
            
            flag += cheackCondition(elementDict,
                conditionName:"condition2",
                foodStateValue: foodStateValue,
                sleepStateValue: sleepStateValue,
                funStateValue: funStateValue,
                relationshipStateValue: relationshipStateValue,
                isSleeping: isSleeping)
            
            if flag == 0
            {
                if elementDict["condition1"]! == "11"
                {
                    print("uid:"+elementDict["uid"]!)
                    print("cond2:"+elementDict["condition2"]!)
                    print("cond2para1:"+elementDict["condition2para1"]!)
                    print("cond2para2:"+elementDict["condition2para2"]!)
                    print("----------------")
                }
                //candidateArray.append(elementDict)
                let elementDictsArray = [[String:String]](count: Int(elementDict["weight"]!)!, repeatedValue: elementDict)
                candidateArray += elementDictsArray
            }
        }
        
        //そこからランダムに選択
        let arrayLength:Int = Int(candidateArray.count)
        let randNum = Int(arc4random_uniform(UInt32(arrayLength)))
        let tmpDict = candidateArray[randNum]
        if tmpDict["condition2"]! == "13"
        {
            print(candidateArray[randNum])
        }
        
        return candidateArray[randNum]
    }
    
    //条件合えば0、そうでなければ1
    func cheackCondition(targetDict:[String:String], conditionName:String,foodStateValue: Int, sleepStateValue: Int, funStateValue: Int, relationshipStateValue: Int, isSleeping: Bool) -> Int
    {
        if targetDict[conditionName]! == "11"
        {
            //get all pet image dict?
            let petImageDict = statusManager.getPetImageDict()
            //return 0 if image name is X
            for (_, value) in petImageDict
            {
                let paraX = targetDict[conditionName+"para1"]!
                if value == paraX { return 0 }
            }
            return 1
        }
        else
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
                print("health is not used now")
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
                let now = NSDate() // 現在日時の取得
                let dateFormatter = NSDateFormatter()
                
                // ロケールの設定
                dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
                // スタイルの設定
                dateFormatter.timeStyle = .ShortStyle
                dateFormatter.dateStyle = .NoStyle
                
                let timeString = String(dateFormatter.stringFromDate(now))
                let timeArray = timeString.componentsSeparatedByString(":")
                if checkNumIsInside(Int(timeArray[0])!, minNum: paraX, maxNum: paraY) { return 0 }
                else { return 1 }
            case "14":// day is in X ~ Y
                break
            case "15":// heartrate is in X ~ Y
                break
            case "16":// walktime is in X ~ Y
                break
            case "17":// bodytempurture is in X ~ Y
                break
            case "18":// face type is X
                break
            default:
                break
            }

        }
        
        
        return 0
    }
    
    func checkNumIsInside(targetNum:Int, minNum:Int, maxNum:Int) -> Bool
    {
        if minNum <= targetNum && targetNum <= maxNum
        {
            return true
        }
        return false
    }
    
    /////////////////// use for pet balloon end ///////////////////
    
    /////////////////// use for pet talking part ///////////////////
    
    //何かないかなー
    func filterByStatus(foodStateValue: Int, sleepStateValue: Int, funStateValue: Int, relationshipStateValue: Int, isSleeping: Bool, converSession:[[String:String]]) -> [[String:String]]
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
                relationshipStateValue: relationshipStateValue,
                isSleeping: isSleeping)
            
            flag += cheackCondition(elementDict,
                conditionName:"condition2",
                foodStateValue: foodStateValue,
                sleepStateValue: sleepStateValue,
                funStateValue: funStateValue,
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