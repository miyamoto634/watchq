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
    let defaults = NSUserDefaults(suiteName:"group.com.platinum-egg.WatchQ.userdefaults")
    let userCalendar = NSCalendar.currentCalendar()
    
    override init()
    {
        
    }
    
    //各数値を読み込み
    internal func loadValue(target_name: String) -> Int
    {
        
        if target_name == "isSleeping"
        {
            if defaults!.boolForKey("isSleeping") { return 1 }
            else { return 0 }
        }
        
        return defaults!.integerForKey(target_name)
    }
    
    //文字を読み込む
    func loadString(target_name: String) -> String
    {
        return defaults!.stringForKey(target_name)!
    }
    
    //各数値の更新
    func updateValue(target_name: String, target_value: Int)
    {
        if target_name == "isSleeping"
        {
            //0/1をtrue/falseに変換
            if target_value == 0 { defaults!.setBool(false, forKey: "isSleeping") }
            else if target_value == 1 { defaults!.setBool(true, forKey: "isSleeping") }
            
            return
        }
        
        if target_name == "experienceV"
        {
            var new_exp_value = target_value
            var new_level = defaults!.integerForKey("levelV")
            var new_max_stamina = defaults!.integerForKey("staminaMaxV")
            
            //レベルアップ処理
            let max_exp = 50*new_level*(new_level+1)
            while max_exp <= new_exp_value
            {
                new_exp_value -= max_exp
                new_level += 1
                new_max_stamina += 1
            }
            
            defaults!.setInteger(new_exp_value, forKey: "experienceV")
            defaults!.setInteger(new_level, forKey: "levelV")
            defaults!.setInteger(new_max_stamina, forKey: "staminaMaxV")
            defaults!.setInteger(new_max_stamina, forKey: "staminaV")
            
            return
        }
        
        if target_name == "staminaV"
        {
            var new_stamina = target_value
            let maxStamina = defaults!.integerForKey("staminaMaxV")
            
            if new_stamina > maxStamina { new_stamina = maxStamina }
            
            defaults!.setInteger(new_stamina, forKey: "staminaV")
            
            return
        }
        
        defaults!.setInteger(target_value, forKey: target_name)
        
    }
    
    //文字を更新
    func updateString(target_name: String, target_string: String)
    {
        defaults!.setObject(target_string, forKey: target_name)
    }
    
    //ステータス画面の値を保存
    func saveStatus(foodStateValue: Int, sleepStateValue: Int, funStateValue: Int, healthStateValue: Int, isSleeping: Bool, staminaStateValue: Int, maxStaminaStateValue: Int, timerForStamina: Int)
    {
        //保存する時の時間
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Day, .Month, .Year] , fromDate: date)
        let timeOfCloseHour = components.hour
        let timeOfCloseMin = components.minute
        let timeOfCloseDay = components.day
        let timeOfCloseMonth = components.month
        let timeOfCloseYear  = components.year
        
        //時間保存
        defaults!.setInteger(timeOfCloseHour, forKey: "timeOfLastCloseHour")
        defaults!.setInteger(timeOfCloseMin, forKey: "timeOfLastCloseMin")
        defaults!.setInteger(timeOfCloseDay, forKey: "timeOfLastCloseDay")
        defaults!.setInteger(timeOfCloseMonth, forKey: "timeOfLastCloseMonth")
        defaults!.setInteger(timeOfCloseYear, forKey: "timeOfLastCloseYear")
        
        //各数値を保存
        defaults!.setInteger(foodStateValue, forKey: "feedingV")
        defaults!.setInteger(sleepStateValue, forKey: "sleepingV")
        defaults!.setInteger(funStateValue, forKey: "funV")
        defaults!.setInteger(healthStateValue, forKey: "healthV")
        defaults!.setBool(isSleeping, forKey: "isSleeping")
        print(String(stringInterpolationSegment: isSleeping))
        defaults!.setInteger(staminaStateValue, forKey: "staminaV")
        defaults!.setInteger(maxStaminaStateValue, forKey: "staminaMaxV")
        defaults!.setInteger(timerForStamina, forKey: "timerForStamina")
        print("save_hel:"+String(healthStateValue))
        
        SaveDataForHealthValue(foodStateValue, funStateValue: funStateValue)
    }
    
    func SaveDataForHealthValue(foodStateValue: Int, funStateValue: Int)
    {
        var overPointAmount:Int = 0
        // if sleepingV >= 60 { overPointAmount += 1 }
        if funStateValue >= 60 { overPointAmount += 1}
        if foodStateValue >= 60 { overPointAmount += 1}
        
        switch overPointAmount
        {
        case 2:
            calculateAllOverThan60Period(foodStateValue, fun: funStateValue)
            break;
        case 1:
            // ++0
            defaults!.setInteger(0, forKey: "allAbove60")
            calculateOneLessThan60Period(foodStateValue, fun: funStateValue)
            break;
        case 0:
            if funStateValue == 0 && foodStateValue == 0 // all 0
            {
                //
                defaults!.setInteger(0, forKey: "allAbove60")
                defaults!.setInteger(0, forKey: "allLess60")
                defaults!.setInteger(0, forKey: "oneLess60")
            }
            else // all less 60
            {
                defaults!.setInteger(0, forKey: "allAbove60")
                defaults!.setInteger(0, forKey: "oneLess60")
                calculateAllLessThan60Period(foodStateValue, fun: funStateValue)
            }
            break;
        default:
            break
        }
    }
    
    func calculateAllOverThan60Period( feed : Int , fun : Int)
    {
        // get min one
        var minValue = 0;// get min value between the parameters
        let feedObve60 : Int = (feed - 60)/2
        
        minValue = min(fun - 60, feedObve60);
        
        defaults!.setInteger(minValue, forKey: "allAbove60")
        
        calculateOneLessThan60Period(feed - minValue * 2, fun: fun - minValue );
    }
    
    func calculateOneLessThan60Period( feed : Int , fun : Int)
    {
        // get min one
        var minValue = 0;// get min value between the parameters
        
        if( feed > 60 )
        {
            minValue = (feed - 60)/2
        }
        else if( fun > 60 )
        {
            minValue = fun - 60;
        }
        
        defaults!.setInteger(minValue, forKey: "oneLess60")
        
        calculateAllLessThan60Period(feed - minValue * 2, fun: fun - minValue);
    }
    
    func calculateAllLessThan60Period( feed : Int , fun : Int)
    {
        var UperValue = 0;// in this we need to get bigger value between the parameters
        
        if(feed/2 > fun )
        {
            UperValue = feed/2;
        }
        else
        {
            UperValue = fun
        }
        
        defaults!.setInteger(UperValue, forKey: "allLess60")
    }
    
    //ステータス画面の値を取得
    func loadStatus(needSave: Bool) -> [String: Int]
    {
        var returnDict = [String: Int]()
        
        //保存した時の時間を取得
        let timeOfLastCloseMin = defaults!.integerForKey("timeOfLastCloseMin")
        let timeOfLastCloseHour = defaults!.integerForKey("timeOfLastCloseHour")
        let timeOfLastCloseDay = defaults!.integerForKey("timeOfLastCloseDay")
        let timeOfLastCloseMonth = defaults!.integerForKey("timeOfLastCloseMonth")
        let timeOfLastCloseYear = defaults!.integerForKey("timeOfLastCloseYear")
        
        //現在との時間差を求める
        var time_diff = 0
        time_diff = TimeDifference(timeOfLastCloseYear,month: timeOfLastCloseMonth,day: timeOfLastCloseDay,hour: timeOfLastCloseHour,minute: timeOfLastCloseMin)
        //デバッグ用
        //time_diff *= 5
        print("Dis:"+String(time_diff), terminator: "")
        
        //保存時の全値を取得
        var food_saved = defaults!.integerForKey("feedingV")
        var sleep_saved = defaults!.integerForKey("sleepingV")
        var fun_saved = defaults!.integerForKey("funV")
        var health_saved = defaults!.integerForKey("healthV")
        var isSleeping_saved = defaults!.boolForKey("isSleeping")
        var stamina_saved = defaults!.integerForKey("staminaV")
        let maxStamina_saved = defaults!.integerForKey("staminaMaxV")
        let timeForStamina_saved = defaults!.integerForKey("timerForStamina")
        let healthZeroPeriod_saved = defaults!.integerForKey("healthZeroPeriod")
        print("saved_hel:"+String(health_saved))
        print("saved_zer:"+String(healthZeroPeriod_saved))
        
        //時間差の最小と最大
        if time_diff < 0 { time_diff = 0 }
        
        //各数値を計算して現在の値に
        //health
        health_saved += calculateDiscountForHealthValue(time_diff)
        
        //check if the pet is dead
        if(health_saved < 0)
        {
            var healthZeroPeriod = defaults!.integerForKey("healthZeroPeriod")
            healthZeroPeriod += -1 * health_saved;
            
            if(healthZeroPeriod > 60 * 24)//health is zero more than 24 hours
            {
                //death procedure
                // statusManager.resetPlayerData();
                
            }
            else
            {
                // save healthZeroPeriod
                defaults!.setInteger(healthZeroPeriod, forKey: "healthZeroPeriod");
            }
        }
        
        
        //food
        food_saved =  food_saved - time_diff*2
        if food_saved < 0 { food_saved = 0; }
        
        //sleep
        if isSleeping_saved == true { sleep_saved += time_diff*3 }
        else{ sleep_saved -= time_diff }
        if sleep_saved < 0 { sleep_saved = 0 }
        if sleep_saved > 100 { sleep_saved = 100 }
        
        if sleep_saved >= 100{ isSleeping_saved = false }
        else if sleep_saved <= 0 { isSleeping_saved = true }
        
        //fun
        fun_saved = fun_saved - time_diff
        if fun_saved < 0 { fun_saved = 0; }
        
        //stamina
        let addToStamina : Int = Int((time_diff)/5)// add 1 to stamina every 5 minutes
        stamina_saved += addToStamina;
        if stamina_saved > maxStamina_saved { stamina_saved = maxStamina_saved }
        
        if needSave == true
        {
            //値を保存しなおす
            saveStatus(
                food_saved,
                sleepStateValue: sleep_saved,
                funStateValue: fun_saved,
                healthStateValue: health_saved,
                isSleeping: isSleeping_saved,
                staminaStateValue: stamina_saved,
                maxStaminaStateValue: maxStamina_saved,
                timerForStamina: timeForStamina_saved
            )
            defaults!.setInteger(healthZeroPeriod_saved, forKey: "healthZeroPeriod")
            
        }
        
        //最終的な計算結果を辞書に登録して返す
        returnDict["feedingV"] = food_saved
        returnDict["sleepingV"] = sleep_saved
        returnDict["funV"] = fun_saved
        returnDict["healthV"] = health_saved
        if isSleeping_saved { returnDict["isSleeping"] = 1 }
        else { returnDict["isSleeping"] = 0 }
        returnDict["staminaV"] = stamina_saved
        returnDict["staminaMaxV"] = maxStamina_saved
        returnDict["timeForStamina"] = timeForStamina_saved
        returnDict["levelV"] = defaults!.integerForKey("levelV")
        returnDict["relationV"] = defaults!.integerForKey("relationV")
        returnDict["goldenAmount"] = defaults!.integerForKey("goldenAmount")
        returnDict["diamondAmount"] = defaults!.integerForKey("diamondAmount")
        returnDict["experienceV"] = defaults!.integerForKey("experienceV")
        returnDict["healthZeroPeriod"] = healthZeroPeriod_saved
        
        return returnDict
    }
    
    func calculateDiscountForHealthValue(closecAppPeriod : Int ) ->Int
    {
        let health = defaults!.integerForKey("healthV");
        var period = closecAppPeriod; //  5
        var discount = 0;
        
        let allAbove60 = defaults!.integerForKey("allAbove60") * 3;// ++ 2
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
        
        
        let oneLess60 = defaults!.integerForKey("oneLess60");// -+0
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
        
        let allLess60 = defaults!.integerForKey("allLess60");// --2
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
    func TimeDifference( var year: Int, var month: Int , var day: Int, var hour: Int, var minute: Int ) -> Int
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
        
        // first open
        if(year == 0)
        {
            print("first time open", terminator: "");
            year = currentyear;
            month = currentmonth;
            day = currentday;
            hour = currenthour;
            minute = currentminute;
            
            defaults!.setInteger(1, forKey: "levelV")
            defaults!.setInteger(0, forKey: "experienceV")
            defaults!.setInteger(10, forKey: "staminaV")
            defaults!.setInteger(10, forKey: "staminaMaxV")
            defaults!.setInteger(0, forKey: "timerForStamina")
            defaults!.setInteger(0, forKey: "goldenAmount")
            defaults!.setInteger(0, forKey: "diamondAmount")
            
            defaults!.setInteger(100, forKey: "feedingV")
            defaults!.setInteger(100, forKey: "sleepingV")
            defaults!.setInteger(100, forKey: "funV")
            defaults!.setInteger(100, forKey: "healthV")
            defaults!.setInteger(0, forKey: "relationV")
            defaults!.setInteger(0, forKey: "healthZeroPeriod")
            
            defaults!.setBool(false, forKey: "isSleeping")
            
            defaults!.setInteger(0, forKey: "allAbove60")
            defaults!.setInteger(0, forKey: "allLess60")
            defaults!.setInteger(0, forKey: "oneLess60")
            
            defaults!.setInteger(0, forKey: "equippedItemHair")
            defaults!.setInteger(0, forKey: "equippedItemHairAcc")
            defaults!.setInteger(0, forKey: "equippedItemCloth")
            defaults!.setInteger(0, forKey: "equippedItemMouthBg")
            defaults!.setInteger(0, forKey: "equippedItemBalloon")
            
            defaults!.setInteger(0, forKey: "spillGridCorrectAnswers")
            defaults!.setInteger(0, forKey: "quizCorrectAnswers")
            defaults!.setInteger(0, forKey: "ticTacToeWins")
        }
        
        // Let's create an NSDate for St. Patrick's Day
        // using NSDateFormatter
        let dateMakerFormatter = NSDateFormatter()
        dateMakerFormatter.calendar = userCalendar
        
        
        // How many hours and minutes between two dates
        dateMakerFormatter.dateFormat = "yyyy/MM/dd kk:mm"
        let startTime = dateMakerFormatter.dateFromString("\(year)/\(month)/\(day) \(hour):\(minute)")!
        let endTime = dateMakerFormatter.dateFromString("\(currentyear)/\(currentmonth)/\(currentday) \(currenthour):\(currentminute)")!
        let hourMinuteComponents: NSCalendarUnit = [.Hour, .Minute]
        let timeDifference = userCalendar.components( hourMinuteComponents, fromDate: startTime,toDate: endTime, options: [])
        
        return timeDifference.hour * 60 + timeDifference.minute
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
        
        defaults!.setInteger(currentyear, forKey: "spendYear")
        defaults!.setInteger(currentmonth, forKey: "spendMonth")
        defaults!.setInteger(currentday, forKey: "spendDay")
        defaults!.setInteger(currenthour, forKey: "spendHour")
        defaults!.setInteger(currentminute, forKey: "spendMinute")
    }
    
    //過ごした時間計算
    func calcSpendTime() -> String
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
        
        var savedYear = defaults!.integerForKey("spendYear")
        var savedMonth = defaults!.integerForKey("spendMonth")
        var savedDay = defaults!.integerForKey("spendDay")
        var savedHour = defaults!.integerForKey("spendHour")
        var savedMinute = defaults!.integerForKey("spendMinute")
        
        if savedYear == 0
        {
            defaults!.setInteger(currentyear, forKey: "spendYear")
            defaults!.setInteger(currentmonth, forKey: "spendMonth")
            defaults!.setInteger(currentday, forKey: "spendDay")
            defaults!.setInteger(currenthour, forKey: "spendHour")
            defaults!.setInteger(currentminute, forKey: "spendMinute")
            
            savedYear = currentyear
            savedMonth = currentmonth
            savedDay = currentday
            savedHour = currenthour
            savedMinute = currentminute
            
            return "0時間0分"
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
        //copy end//
        
        
        //文字の変換
        var returnString = ""
        var diffMinute = 0
        var diffHour = 0
        
        diffMinute += timeDifference.minute
        diffHour += timeDifference.hour
        
        returnString += String(diffHour)+"時間"
        returnString += String(diffMinute)+"分"

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
        let itemId = Int(itemDict["ItemID"]!)!
        
        defaults!.setInteger(itemId, forKey: targetKey)
    }
    
    func releaseItem(itemDict:[String:String])
    {
        let itemType = itemDict["ItemType"]!
        let targetKey = SearchKeyFromItemType(itemType)
       // let itemId = Int(itemDict["ItemID"]!)!
        
        defaults!.setInteger(0, forKey: targetKey)
    }
    
    //itemtypeから
    func SearchKeyFromItemType(itemType:String) -> String
    {
        if itemType == "1" { return "equippedItemHair" }
        if itemType == "2" { return "equippedItemHairAcc" }
        if itemType == "3" { return "equippedItemCloth" }
        if itemType == "4" { return "equippedItemMouthBg" }
        if itemType == "5" { return "equippedItemBalloon" }
        
        return ""
    }
    
    func avoidDeath()
    {
        defaults!.setInteger(100, forKey: "healthV");
        defaults!.setInteger(0, forKey: "healthZeroPeriod");
        defaults!.setBool(false, forKey: "isDead");
    }
    
    func resetPlayerData()
    {
        defaults!.setInteger(0, forKey: "firstOpen")
        
        defaults!.setInteger(1, forKey: "levelV")
        defaults!.setInteger(0, forKey: "experienceV")
        defaults!.setInteger(10, forKey: "staminaV")
        defaults!.setInteger(10, forKey: "staminaMaxV")
        defaults!.setInteger(0, forKey: "timerForStamina")
        //defaults!.setInteger(0, forKey: "goldenAmount")
        //defaults!.setInteger(0, forKey: "diamondAmount")
        
        defaults!.setInteger(100, forKey: "feedingV")
        defaults!.setInteger(100, forKey: "sleepingV")
        defaults!.setInteger(100, forKey: "funV")
        defaults!.setInteger(100, forKey: "healthV")
        defaults!.setInteger(0, forKey: "frendshipV")
        
        defaults!.setBool(false, forKey: "isSleeping");
        
        defaults!.setInteger(0, forKey: "allAbove60")
        defaults!.setInteger(0, forKey: "allLess60")
        defaults!.setInteger(0, forKey: "oneLess60")
        defaults!.setInteger(0, forKey: "healthZeroPeriod");
        defaults!.setBool(false, forKey: "isDead");
        
        defaults!.setInteger(0, forKey: "spillGridCorrectAnswers")
        defaults!.setInteger(0, forKey: "quizCorrectAnswers")
        defaults!.setInteger(0, forKey: "ticTacToeWins")
    }
}