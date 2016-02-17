//
//  StatusManager.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/04.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import Foundation
import WatchKit

class StatusManager: NSObject
{
    let defaults = NSUserDefaults.standardUserDefaults()
    let userCalendar = NSCalendar.currentCalendar()
    
    //csvパース
    let perthCsv = PerthCsv()
    
    override init()
    {
        //
    }
    
    //各数値を読み込み
    internal func loadValue(target_name: String) -> Int
    {
        
        if target_name == "isSleeping"
        {
            if defaults.boolForKey("isSleeping") { return 1 }
            else { return 0 }
        }
        
        return defaults.integerForKey(target_name)
    }
    
    //文字を読み込む
    func loadString(target_name: String) -> String
    {
        return defaults.stringForKey(target_name)!
    }
    
    //配列を読み込む
    func loadArray(target_name: String) -> [String]
    {
        return defaults.objectForKey(target_name)! as! [String]
    }
    
    //各数値の更新
    func updateValue(target_name: String, target_value: Int)
    {
        print("update "+target_name+" to "+String(target_value))
        if target_name == "isSleeping"
        {
            //0/1をtrue/falseに変換
            if target_value == 0 { defaults.setBool(false, forKey: "isSleeping") }
            else if target_value == 1 { defaults.setBool(true, forKey: "isSleeping") }
            
            return
        }
        
        if target_name == "experienceV"
        {
            var new_exp_value = target_value
            var new_level = defaults.integerForKey("levelV")
            var new_max_stamina = defaults.integerForKey("staminaMaxV")
            
            var isLevelUp = false
            
            if new_level < 10
            {
                //level up
                var max_exp = Int(perthCsv.getMaxExp(new_level))
                while max_exp <= new_exp_value
                {
                    //初回ランクアップ
                    if new_level == 1
                    {
                        //アイテム付与
                        updateItem(503, consume: 2, amount_diff: 3)
                        //メッセージ
                        updateString("itemGrantMessage", target_string: "スタミナのかたまり×３")
                    }
                    new_exp_value -= max_exp
                    new_level += 1
                    new_max_stamina += 2*900
                    max_exp = Int(perthCsv.getMaxExp(new_level))
                    isLevelUp = true
                }
            }
            
            defaults.setInteger(new_exp_value, forKey: "experienceV")
            defaults.setInteger(new_level, forKey: "levelV")
            defaults.setInteger(new_max_stamina, forKey: "staminaMaxV")
            
            if isLevelUp { defaults.setInteger(new_max_stamina, forKey: "staminaV") }
            
            return
        }
        
        if target_name == "staminaV"
        {
            var new_stamina = target_value
            let maxStamina = defaults.integerForKey("staminaMaxV")
            
            if new_stamina > maxStamina { new_stamina = maxStamina }
            defaults.setInteger(new_stamina, forKey: "staminaV")
            return
        }
        
        if target_name == "goldenAmount"
        {
            defaults.setInteger(target_value, forKey: target_name)
            let maxGoldenAmount = defaults.integerForKey("maxGoldenAmount")
            if target_value >= maxGoldenAmount
            {
                defaults.setInteger(target_value, forKey: "maxGoldenAmount")
            }
        }
        
        defaults.setInteger(target_value, forKey: target_name)
        
    }
    
    //文字を更新
    func updateString(target_name: String, target_string: String)
    {
        defaults.setObject(target_string, forKey: target_name)
    }
    
    //配列更新
    func updateArray(target_name:String, target_array:[String])
    {
        defaults.setObject(target_array, forKey: target_name)
    }
    
    //追加
    func addValue(target_name:String, add_value:Int)
    {
        if target_name == "sleepingV"
        {
            var save_value = loadValue(target_name)
            save_value += add_value*60*12
            if save_value < 0
            {
                save_value = 0
                updateValue("isSleeping", target_value: 1)
            }
            updateValue(target_name, target_value: save_value)
        }
        
        var save_value = loadValue(target_name)
        save_value += add_value
        updateValue(target_name, target_value: save_value)
    }
    
    //ステータス画面の値を保存
    func saveStatus(foodStateValue: Int, sleepStateValue: Int, funStateValue: Int, isSleeping: Bool, staminaStateValue: Int, maxStaminaStateValue: Int)
    {
        //保存する時の時間
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Second, .Day, .Month, .Year] , fromDate: date)
        let timeOfCloseHour = components.hour
        let timeOfCloseMin = components.minute
        let timeOfCloseSecond = components.second
        let timeOfCloseDay = components.day
        let timeOfCloseMonth = components.month
        let timeOfCloseYear  = components.year
        
        //時間保存
        defaults.setInteger(timeOfCloseHour, forKey: "timeOfLastCloseHour")
        defaults.setInteger(timeOfCloseMin, forKey: "timeOfLastCloseMin")
        defaults.setInteger(timeOfCloseDay, forKey: "timeOfLastCloseDay")
        defaults.setInteger(timeOfCloseMonth, forKey: "timeOfLastCloseMonth")
        defaults.setInteger(timeOfCloseYear, forKey: "timeOfLastCloseYear")
        defaults.setInteger(timeOfCloseSecond, forKey: "timeOfCloseSecond")
        
        //各数値を保存
        defaults.setInteger(foodStateValue, forKey: "feedingV")
        defaults.setInteger(sleepStateValue, forKey: "sleepingV")
        defaults.setInteger(funStateValue, forKey: "funV")
        defaults.setBool(isSleeping, forKey: "isSleeping")
        print(String(stringInterpolationSegment: isSleeping))
        defaults.setInteger(staminaStateValue, forKey: "staminaV")
        defaults.setInteger(maxStaminaStateValue, forKey: "staminaMaxV")
    }
    
    //new load status
    func loadStatus(needSave:Bool) -> [String: Int]
    {
        var returnDict = [String: Int]()
        
        //保存した時の時間を取得
        let timeOfCloseSecond = defaults.integerForKey("timeOfCloseSecond")
        let timeOfLastCloseMin = defaults.integerForKey("timeOfLastCloseMin")
        let timeOfLastCloseHour = defaults.integerForKey("timeOfLastCloseHour")
        let timeOfLastCloseDay = defaults.integerForKey("timeOfLastCloseDay")
        let timeOfLastCloseMonth = defaults.integerForKey("timeOfLastCloseMonth")
        let timeOfLastCloseYear = defaults.integerForKey("timeOfLastCloseYear")
        
        //現在との時間差を求める
        var time_diff = 0
        time_diff = TimeDifference(timeOfLastCloseYear,month: timeOfLastCloseMonth,day: timeOfLastCloseDay,hour: timeOfLastCloseHour,minute: timeOfLastCloseMin,second: timeOfCloseSecond)
        if time_diff < 0 { time_diff = 0 }
        
        //保存時の全値を取得
        var food_saved = defaults.integerForKey("feedingV")
        var sleep_saved = defaults.integerForKey("sleepingV")
        var fun_saved = defaults.integerForKey("funV")
        var isSleeping_saved = defaults.boolForKey("isSleeping")
        var stamina_saved = defaults.integerForKey("staminaV")
        let maxStamina_saved = defaults.integerForKey("staminaMaxV")
        
        //food
        food_saved -= time_diff
        if food_saved < 0 { food_saved = 0 }
        
        //fun
        if fun_saved > 50*720
        {
            if fun_saved - 50*720 > time_diff { fun_saved -= time_diff }
            else { fun_saved = 50*720 }
        }
        else
        {
            if 50*720 - fun_saved > time_diff { fun_saved += time_diff }
            else { fun_saved = 50*720 }
        }
        
        if fun_saved >= 100*720 { fun_saved = 100*720 }
        else if fun_saved <= 0 { fun_saved = 0 }
        
        //sleep
        if isSleeping_saved { sleep_saved += time_diff*12 }
        else { sleep_saved += time_diff }
        if sleep_saved >= 100*60*12
        {
            isSleeping_saved = false
            sleep_saved = 100*60*12
        }
        
        //stamina
        stamina_saved += time_diff
        if stamina_saved > maxStamina_saved { stamina_saved = maxStamina_saved }
        
        if needSave == true
        {
            //save values
            saveStatus(
                food_saved,
                sleepStateValue: sleep_saved,
                funStateValue: fun_saved,
                isSleeping: isSleeping_saved,
                staminaStateValue: stamina_saved,
                maxStaminaStateValue: maxStamina_saved
            )
            
        }
        
        //register all values to dict and return
        returnDict["feedingV"] = food_saved
        returnDict["sleepingV"] = sleep_saved
        returnDict["funV"] = fun_saved
        if isSleeping_saved { returnDict["isSleeping"] = 1 }
        else { returnDict["isSleeping"] = 0 }
        returnDict["staminaV"] = stamina_saved
        returnDict["staminaMaxV"] = maxStamina_saved
        returnDict["levelV"] = defaults.integerForKey("levelV")
        returnDict["relationV"] = defaults.integerForKey("relationV")
        returnDict["goldenAmount"] = defaults.integerForKey("goldenAmount")
        returnDict["diamondAmount"] = defaults.integerForKey("diamondAmount")
        returnDict["experienceV"] = defaults.integerForKey("experienceV")
        
        return returnDict
    }
    
    func calculateDiscountForHealthValue(closecAppPeriod : Int ) ->Int
    {
        let health = defaults.integerForKey("healthV");
        var period = closecAppPeriod; //  5
        var discount = 0;
        
        let allAbove60 = defaults.integerForKey("allAbove60") * 3;// ++ 2
        if(period > 0)
        {
            if(period >= allAbove60)
            {
                discount += allAbove60 * 2
                period -= allAbove60;
            }
            else
            {
                discount += period * 2
                period = 0;
            }
            
            //this to prevent health value going up 100%
            if(discount > 100 - health)
            {
                discount = 100 - health;
            }
        }
        
        
        let oneLess60 = defaults.integerForKey("oneLess60");// -+0
        if(period > 0)
        {
            if(period >= oneLess60)
            {
                period -= oneLess60;
            }
            else
            {
                period = 0;
            }
        }
        
        let allLess60 = defaults.integerForKey("allLess60");// --2
        if(period > 0)
        {
            if(period >= allLess60)
            {
                discount -= allLess60 * 2;
                period -= allLess60;
            }
            else
            {
                discount -= period * 2;
                period = 0;
            }
        }
        
        // all is 0       // --3
        if(period > 0)
        {
            discount -= period * 3;
        }
        
        return discount;
    }
    
    //bring from StatsViewController.swift     // this to get period between two dates
    func TimeDifference( var year: Int, var month: Int , var day: Int, var hour: Int, var minute: Int ,var second : Int) -> Int
    {
        // get current datetime
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Second, .Day, .Month, .Year] , fromDate: date)
        let currenthour = components.hour
        let currentminute = components.minute
        let currentsecond = components.second
        let currentday = components.day
        let currentmonth = components.month
        let currentyear = components.year
        
        // first open
        if(year == 0)
        {
            print("first time open", terminator: "");
            year = currentyear
            month = currentmonth
            day = currentday
            hour = currenthour
            minute = currentminute
            second = currentsecond
            
            resetPlayerData()
            
            return 0
        }
        
        // Let's create an NSDate for St. Patrick's Day
        // using NSDateFormatter
        let dateMakerFormatter = NSDateFormatter()
        dateMakerFormatter.calendar = userCalendar
        
        
        // How many hours and minutes between two dates
        dateMakerFormatter.dateFormat = "yyyy/MM/dd kk:mm:ss"
        let startTime = dateMakerFormatter.dateFromString("\(year)/\(month)/\(day) \(hour):\(minute):\(second)")!
        let endTime = dateMakerFormatter.dateFromString("\(currentyear)/\(currentmonth)/\(currentday) \(currenthour):\(currentminute):\(currentsecond)")!
        let hourMinuteComponents: NSCalendarUnit = [.Hour, .Minute, .Second]
        let timeDifference = userCalendar.components( hourMinuteComponents, fromDate: startTime,toDate: endTime, options: [])
        
        print("hou_diff:"+String(timeDifference.hour))
        print("min_diff:"+String(timeDifference.minute))
        print("sec_diff:"+String(timeDifference.second))
        
        return timeDifference.hour * 3600 + timeDifference.minute * 60 + timeDifference.second
    }
    
    //過ごした時間リセット
    func resetSpendTime()
    {
        // get current datetime
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Day, .Month, .Year] , fromDate: date)
        let currenthour = components.hour
        let currentminute = components.minute
        let currentday = components.day
        let currentmonth = components.month
        let currentyear = components.year
        
        defaults.setInteger(currentyear, forKey: "spendYear")
        defaults.setInteger(currentmonth, forKey: "spendMonth")
        defaults.setInteger(currentday, forKey: "spendDay")
        defaults.setInteger(currenthour, forKey: "spendHour")
        defaults.setInteger(currentminute, forKey: "spendMinute")
    }
    
    //過ごした時間計算
    func calcSpendTimeDiff() -> [String:Int]
    {
        // get current datetime
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Day, .Month, .Year] , fromDate: date)
        let currenthour = components.hour
        let currentminute = components.minute
        let currentday = components.day
        let currentmonth = components.month
        let currentyear = components.year
        
        var savedYear = defaults.integerForKey("spendYear")
        var savedMonth = defaults.integerForKey("spendMonth")
        var savedDay = defaults.integerForKey("spendDay")
        var savedHour = defaults.integerForKey("spendHour")
        var savedMinute = defaults.integerForKey("spendMinute")
        
        if savedYear == 0
        {
            defaults.setInteger(currentyear, forKey: "spendYear")
            defaults.setInteger(currentmonth, forKey: "spendMonth")
            defaults.setInteger(currentday, forKey: "spendDay")
            defaults.setInteger(currenthour, forKey: "spendHour")
            defaults.setInteger(currentminute, forKey: "spendMinute")
            
            savedYear = currentyear
            savedMonth = currentmonth
            savedDay = currentday
            savedHour = currenthour
            savedMinute = currentminute
            
            return ["hour":0,"min":0]
        }

        
        //copy//
        // Let's create an NSDate for St. Patrick's Day
        // using NSDateFormatter
        let dateMakerFormatter = NSDateFormatter()
        dateMakerFormatter.calendar = userCalendar
        
        dateMakerFormatter.dateFormat = "yyyy/MM/dd kk:mm"
        let startTime = dateMakerFormatter.dateFromString("\(savedYear)/\(savedMonth)/\(savedDay) \(savedHour):\(savedMinute)")!
        let endTime = dateMakerFormatter.dateFromString("\(currentyear)/\(currentmonth)/\(currentday) \(currenthour):\(currentminute)")!
        //let startTime = dateMakerFormatter.dateFromString("2016/2/27 \(savedHour):\(savedMinute)")!
        //let endTime = dateMakerFormatter.dateFromString("2016/3/2 \(currenthour):\(currentminute)")!
        let hourMinuteComponents: NSCalendarUnit = [.Hour, .Minute]
        let timeDifference = userCalendar.components( hourMinuteComponents, fromDate: startTime,toDate: endTime, options: [])
        
        return ["hour":timeDifference.hour,"min":timeDifference.minute]
    }
    
    func calcSpendTime() -> String
    {
        let timeDiffDict = calcSpendTimeDiff()
        
        var returnString = ""
        returnString += String(timeDiffDict["hour"]!)+"時間"
        returnString += String(timeDiffDict["min"]!)+"分"
        
        if returnString == "" { returnString = "0時間0分" }
        
        return returnString
    }
    
    func changeMonth2Day(month:Int, year:Int) -> Int
    {
        switch month
        {
        case 1:
            return 31
        case 2:
            if (year%4 == 0 && year%10 != 0)||(year%400 == 0) { return 29 }
            else { return 28 }
        case 3:
            return 31
        case 4:
            return 30
        case 5:
            return 31
        case 6:
            return 30
        case 7:
            return 31
        case 8:
            return 31
        case 9:
            return 30
        case 10:
            return 31
        case 11:
            return 30
        case 12:
            return 31
        default:
            return 0
        }
    }
    
    
    func equipItem(itemDict:[String:String])
    {
        let itemType = itemDict["ItemType"]!
        let targetKey = SearchKeyFromItemType(itemType)
        
        var petImageDict = getPetImageDict()
        petImageDict[targetKey]! = itemDict["FileName"]!
        
        upadatePetImageName(petImageDict)
    }
    
    func releaseItem(itemDict:[String:String])
    {
        let itemType = itemDict["ItemType"]!
        let targetKey = SearchKeyFromItemType(itemType)
        
        var petImageDict = getPetImageDict()
        
        if targetKey == "petMouth" { petImageDict[targetKey]! = petImageDict["petBodyType"]! + "_petMouth" }
        else { petImageDict[targetKey]! = "" }
        
        upadatePetImageName(petImageDict)
    }
    
    //itemtypeから
    func SearchKeyFromItemType(itemType:String) -> String
    {
        switch itemType
        {
        case "1":
            return "petHair"
        case "2":
            return "petHairAcce"
        case "3":
            return "petCloth"
        case "4":
            return "petSkin"
        case "5":
            return "petBalloon"
        case "8":
            return "petMouth"
        case "9":
            return "petMakeup"
        case "10":
            return "petEyeAcce"
        default:
            return ""
        }
    }
    
    func avoidDeath()
    {
        defaults.setInteger(100*864, forKey: "feedingV")
        defaults.setInteger(100*60*12, forKey: "sleepingV")
        defaults.setInteger(100*720, forKey: "funV")
        defaults.setInteger(100*8640, forKey: "healthV")
        defaults.setInteger(0, forKey: "healthZeroPeriod")
    }
    
    //init pet image name string
    func initPetImageDict(petGender:String)
    {
        var saveDict = [String:String]()
        
        let defaultName = "Pet_default_"+petGender
        
        //pet gender
        saveDict["petGender"] = petGender//man,woman
        
        //pet type
        saveDict["petBodyType"] = defaultName
        
        //user can change
        saveDict["petHairAcce"] = defaultName + "_petHairAcce"
        saveDict["petEyeAcce"] = ""
        saveDict["petCloth"] = defaultName + "_petCloth"
        saveDict["petMakeup"] = ""
        saveDict["petBalloon"] = defaultName + "_petBalloon"
        //rendom change
        saveDict["petHair"] = defaultName + "_petHair"
        saveDict["petEye"] = defaultName + "_petEye"
        saveDict["petMouth"] = defaultName + "_petMouth"
        saveDict["petSkin"] = defaultName + "_petSkin"
        
        defaults.setObject(NSDictionary(dictionary: saveDict),forKey: "petImageDict")
    }
    
    //get pet image name string
    func getPetImageDict() -> [String:String]
    {
        var petImageDict : [String:String] = [String:String]()
        
        if defaults.objectForKey("petImageDict") != nil
        { petImageDict = (defaults.objectForKey("petImageDict") as? [String:String])! }
        
        return petImageDict
    }
    
    //update dict
    func upadatePetImageName(newDict: [String:String])
    {
        ConnectionManager.sharedManager.exchangeDataWithIphone("sendPetImageInfo", action: "updateValue", veriable: "", value1: newDict, value2: "")
        defaults.setObject(NSDictionary(dictionary: newDict),forKey: "petImageDict")
    }
    
    //use for iphone
    func upadatePetImageNameFromIphone(newDict: [String:String])
    {
        defaults.setObject(NSDictionary(dictionary: newDict),forKey: "petImageDict")
    }
    
    //init record dict
    func initRecodeDict(fromiPhone:Bool)
    {
        var saveDict = [String:Int]()
        
        //quiz played
        saveDict["quizPlayedHistory"]   =   0
        saveDict["quizPlayedGeograpy"]  =   0
        saveDict["quizPlayedScience"]   =   0
        saveDict["quizPlayedSports"]    =   0
        saveDict["quizPlayedArt"]       =   0
        saveDict["quizPlayedZatugaku"]  =   0
        
        //quiz correct
        saveDict["quizCorrectHistory"]  =   0
        saveDict["quizCorrectGeograpy"] =   0
        saveDict["quizCorrectScience"]  =   0
        saveDict["quizCorrectSports"]   =   0
        saveDict["quizCorrectArt"]      =   0
        saveDict["quizCorrectZatugaku"] =   0
        
        //TTT
        saveDict["TTTPlayed"]           =   0
        saveDict["TTTWin"]              =   0
        saveDict["TTTDraw"]             =   0
        
        //SpellGrid
        saveDict["spellGridPlayed"]     =   0
        saveDict["spellGridCorrect"]    =   0
        
        //item amount
        saveDict["equipItemAmount"]     =   0
        
        //random change
        saveDict["petPartHistory"]      =   0
        saveDict["petPartGeograpy"]     =   0
        saveDict["petPartScience"]      =   0
        saveDict["petPartSports"]       =   0
        saveDict["petPartArt"]          =   0
        saveDict["petPartZatugaku"]     =   0
        
        //talk time
        saveDict["petTalkTime"]         =   0
        
        if fromiPhone
        {
            defaults.setObject(NSDictionary(dictionary: saveDict),forKey: "recordDict1")
        }
        else
        {
            defaults.setObject(NSDictionary(dictionary: saveDict),forKey: "recordDict")
        }
    }
    
    //update string int dict
    func updateStringIntDict(keyName:String, var newDict:[String:Int], callFromWatch:Bool)
    {
        //watchならiphoneにデータ送信
        if callFromWatch
        {
            //データ送信
            let equipItemAmount = ItemsManager.fetchItemByConsume(1).count
            newDict["equipItemAmount"] = equipItemAmount
            ConnectionManager.sharedManager.exchangeDataWithIphone("sendStringIntDict", action: "updateValue", veriable: "recordDict", value1: newDict, value2: "")
        }
        
        defaults.setObject(NSDictionary(dictionary: newDict),forKey: keyName)
    }
    
    //get string int dict
    func loadStringIntDict(keyName:String) -> [String:Int]
    {
        var targetDict : [String:Int] = [String:Int]()
        
        if defaults.objectForKey(keyName) != nil
        { targetDict = (defaults.objectForKey(keyName) as? [String:Int])! }
        
        return targetDict
    }
    
    //increace correct answer number
    func increaceValue(targetString:String, increaceValue:Int)
    {
        if targetString == "ticTacToe"
        {
            let nowValue = loadValue("ticTacToeWins")
            updateValue("ticTacToeWins", target_value: nowValue+increaceValue)
            
            return
        }
        
        let nowValue = loadValue(targetString+"CorrectAnswers")
        updateValue(targetString+"CorrectAnswers", target_value: nowValue+increaceValue)
    }
    
    //calc exp and add to user default and retun exp
    func calcExpGoldPoint(gameName:String, expBase:Int, goldBase:Int, bounusPoint:Int) -> [Int]
    {
        //load each value
        let foodValue = Int(loadValue("feedingV")/864)
        let sleepingValue = Int(loadValue("sleepingV")/720)
        let funValue = Int(loadValue("funV")/720)
        let relationValue = loadValue("frendshipV")
        let playerRank = loadValue("levelV")
        
        print("baseexp:"+String(expBase))
        print("food:"+String(foodValue))
        print("sleep:"+String(sleepingValue))
        print("fun:"+String(funValue))
        print("relation:"+String(relationValue))
        print("rank:"+String(playerRank))
        
        var bounusRation = 1.0
        
        //sleep
        if sleepingValue < 30 { bounusRation -= 0.2 }
        
        //fun
        if funValue < 20 { bounusRation -= 0.5 }
        else if funValue > 80 { bounusRation += 0.5 }
        
        //relation
        bounusRation += Double(Int(relationValue/20))*0.1
        
        //rank
        bounusRation += (Double(playerRank)-1)*0.1
        
        if gameName == "quiz"
        {
            switch bounusPoint
            {
            case 0:
                bounusRation -= 0.5
                break
            case 2:
                bounusRation += 0.2
                break
            case 3:
                bounusRation += 0.5
                break
            default:
                break
            }
        }
        
        print("bounusRation:"+String(bounusRation))
        
        return [Int(Double(expBase)*bounusRation), Int(Double(goldBase)*bounusRation)]
    }
    
    //update falg dict array
    func updateFlagDictArray(targetArray:[[String:String]])
    {
        defaults.setObject(targetArray, forKey: "flagDictArray")
    }
    
    //load flag dict array
    func loadFlagDictArray() -> [[String:String]]
    {
        return defaults.objectForKey("flagDictArray")! as! [[String:String]]
    }
    
    //return pet text speed
    func getPetTalkTextSpeed() -> Double
    {
        switch loadValue("petTalkTextSpeed")
        {
        case 0://normal
            return 0.2
        case -1://slow
            return 0.28
        case 1://fast
            return 0.12
        default://normal
            return 0.2
        }
    }
    
    
    func resetPlayerData()
    {
        defaults.setInteger(1, forKey: "levelV")
        defaults.setInteger(0, forKey: "experienceV")
        defaults.setInteger(10*900, forKey: "staminaV")
        defaults.setInteger(10*900, forKey: "staminaMaxV")
        
        defaults.setInteger(100*864, forKey: "feedingV")
        defaults.setInteger(100*60*12, forKey: "sleepingV")
        defaults.setInteger(80*720, forKey: "funV")
        defaults.setInteger(100*8640, forKey: "healthV")
        defaults.setInteger(5, forKey: "frendshipV")
        
        defaults.setBool(false, forKey: "isSleeping")
        
        defaults.setInteger(0, forKey: "allAbove60")
        defaults.setInteger(0, forKey: "allLess60")
        defaults.setInteger(0, forKey: "oneLess60")
        defaults.setInteger(0, forKey: "healthZeroPeriod")
        
        defaults.setInteger(0, forKey: "spillGridCorrectAnswers")
        defaults.setInteger(0, forKey: "ticTacToeWins")
        defaults.setInteger(0, forKey: "quizCorrectAnswers")
        defaults.setInteger(0, forKey: "historyCorrectAnswers")
        defaults.setInteger(0, forKey: "geographyCorrectAnswers")
        defaults.setInteger(0, forKey: "artCorrectAnswers")
        defaults.setInteger(0, forKey: "sportCorrectAnswers")
        defaults.setInteger(0, forKey: "scienceCorrectAnswers")
        defaults.setInteger(0, forKey: "zatugakuCorrectAnswers")
        defaults.setObject("", forKey: "itemGrantMessage")
        
        //init record
        initRecodeDict(false)
        
        //make unlock flag list from items csv
        let itemDictArray = perthCsv.getAll("items")
        var flagDictArray = [[String:String]]()
        
        for elementDict in itemDictArray
        {
            var tmpFlagDict = [String:String]()
            tmpFlagDict["ItemID"] = elementDict["ItemID"]!
            tmpFlagDict["Unlock"] = elementDict["Unlock"]!
            tmpFlagDict["UnlockThreshold"] = elementDict["UnlockThreshold"]!
            tmpFlagDict["UnlockFlag"] = "0"
            tmpFlagDict["ItemName"] = elementDict["ItemName"]!
            flagDictArray += [tmpFlagDict]
        }
        updateFlagDictArray(flagDictArray)
    }
    
    
    
    func getStringUserDefaultInfo() -> [String]
    {
        var stringUserDefaultInfo : [String] = [];
        
        // arrange of these must be same as saveStringUserDefaultInfo()
        stringUserDefaultInfo.append(defaults.stringForKey("playerName")!);
        stringUserDefaultInfo.append(defaults.stringForKey("petName")!);
        
        return stringUserDefaultInfo
    }
    
    func saveStringUserDefaultInfo(let stringUserDefaultInfo : [String])
    {
        defaults.setValue(stringUserDefaultInfo[0], forKey: "playerName")
        defaults.setValue(stringUserDefaultInfo[1], forKey: "petName")
    }
    
    
    
    func getBoolUserDefaultInfo() -> [Bool]
    {
        var boolUserDefaultInfo : [Bool] = [];
        
        // arrange of these must be same as saveBoolUserDefaultInfo()
        boolUserDefaultInfo.append(defaults.boolForKey("isSleeping"))
    
        return boolUserDefaultInfo
    }
    
    func saveBoolUserDefaultInfo(let boolUserDefaultInfo : [Bool])
    {
        defaults.setBool(boolUserDefaultInfo[0], forKey: "isSleeping")
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
            ItemsManager.createActivity(itemId, consume: consume, amount: amount_diff)
        }
    }
    
    
    func getIntUserDefaultInfo() -> [Int]
    {
        var intUserDefaultInfo : [Int] = []
        // arrange of these must be same as saveIntUserDefaultInfo()
        intUserDefaultInfo.append(defaults.integerForKey("levelV"))
        intUserDefaultInfo.append(defaults.integerForKey("experienceV"))
        intUserDefaultInfo.append(defaults.integerForKey("staminaV"))
        intUserDefaultInfo.append(defaults.integerForKey("staminaMaxV"))
        intUserDefaultInfo.append(defaults.integerForKey("goldenAmount"))
        intUserDefaultInfo.append(defaults.integerForKey("diamondAmount"))
        intUserDefaultInfo.append(defaults.integerForKey("feedingV"))
        intUserDefaultInfo.append(defaults.integerForKey("sleepingV"))
        intUserDefaultInfo.append(defaults.integerForKey("funV"))
        intUserDefaultInfo.append(defaults.integerForKey("healthV"))
        intUserDefaultInfo.append(defaults.integerForKey("frendshipV"))
        intUserDefaultInfo.append(defaults.integerForKey("isSleeping"))
        intUserDefaultInfo.append(defaults.integerForKey("allAbove60"))
        intUserDefaultInfo.append(defaults.integerForKey("allLess60"))
        intUserDefaultInfo.append(defaults.integerForKey("oneLess60"))
        intUserDefaultInfo.append(defaults.integerForKey("healthZeroPeriod"))
        intUserDefaultInfo.append(defaults.integerForKey("spillGridCorrectAnswers"))
        intUserDefaultInfo.append(defaults.integerForKey("ticTacToeWins"))
        intUserDefaultInfo.append(defaults.integerForKey("quizCorrectAnswers"))
        intUserDefaultInfo.append(defaults.integerForKey("historyCorrectAnswers"))
        intUserDefaultInfo.append(defaults.integerForKey("geographyCorrectAnswers"))
        intUserDefaultInfo.append(defaults.integerForKey("artCorrectAnswers"))
        intUserDefaultInfo.append(defaults.integerForKey("sportCorrectAnswers"))
        intUserDefaultInfo.append(defaults.integerForKey("scienceCorrectAnswers"))
        intUserDefaultInfo.append(defaults.integerForKey("zatugakuCorrectAnswers"))
        intUserDefaultInfo.append(defaults.integerForKey("petgender"))
        
        //通知設定
        intUserDefaultInfo.append(defaults.integerForKey("FoodNotificationPeriod"));
        intUserDefaultInfo.append(defaults.integerForKey("StaminaNotificationPeriod"));
        intUserDefaultInfo.append(defaults.integerForKey("FoodNotificationFlag"));
        intUserDefaultInfo.append(defaults.integerForKey("StaminaNotificationFlag"));
        
        return intUserDefaultInfo
    }
    
    func saveIntUserDefaultInfo(let intUserDefaultInfo : [Int])
    {
        
        defaults.setInteger(intUserDefaultInfo[0], forKey: "firstOpen")
        
        defaults.setInteger(intUserDefaultInfo[1], forKey: "levelV")
        defaults.setInteger(intUserDefaultInfo[2], forKey: "experienceV")
        defaults.setInteger(intUserDefaultInfo[3], forKey: "staminaV")
        defaults.setInteger(intUserDefaultInfo[4], forKey: "staminaMaxV")
        defaults.setInteger(intUserDefaultInfo[6], forKey: "goldenAmount")
        defaults.setInteger(intUserDefaultInfo[7], forKey: "diamondAmount")
        
        defaults.setInteger(intUserDefaultInfo[8], forKey: "feedingV")
        defaults.setInteger(intUserDefaultInfo[9], forKey: "sleepingV")
        defaults.setInteger(intUserDefaultInfo[10], forKey: "funV")
        defaults.setInteger(intUserDefaultInfo[11], forKey: "healthV")
        defaults.setInteger(intUserDefaultInfo[12], forKey: "frendshipV")
        
        defaults.setInteger(intUserDefaultInfo[13], forKey: "allAbove60")
        defaults.setInteger(intUserDefaultInfo[14], forKey: "allLess60")
        defaults.setInteger(intUserDefaultInfo[15], forKey: "oneLess60")
        defaults.setInteger(intUserDefaultInfo[16], forKey: "healthZeroPeriod");
        
        defaults.setInteger(intUserDefaultInfo[17], forKey: "spillGridCorrectAnswers")
        defaults.setInteger(intUserDefaultInfo[18], forKey: "ticTacToeWins")
        defaults.setInteger(intUserDefaultInfo[19], forKey: "quizCorrectAnswers")
        defaults.setInteger(intUserDefaultInfo[20], forKey: "historyCorrectAnswers")
        defaults.setInteger(intUserDefaultInfo[21], forKey: "geographyCorrectAnswers")
        defaults.setInteger(intUserDefaultInfo[22], forKey: "artCorrectAnswers")
        defaults.setInteger(intUserDefaultInfo[23], forKey: "sportCorrectAnswers")
        defaults.setInteger(intUserDefaultInfo[24], forKey: "scienceCorrectAnswers")
        defaults.setInteger(intUserDefaultInfo[25], forKey: "zatugakuCorrectAnswers")
        defaults.setInteger(intUserDefaultInfo[26], forKey: "petgender")

        //通知設定
        defaults.setInteger(intUserDefaultInfo[27], forKey: "FoodNotificationPeriod")
        defaults.setInteger(intUserDefaultInfo[28], forKey: "StaminaNotificationPeriod")
        defaults.setInteger(intUserDefaultInfo[29], forKey: "FoodNotificationFlag")
        defaults.setInteger(intUserDefaultInfo[30], forKey: "StaminaNotificationFlag")
    
    }
}