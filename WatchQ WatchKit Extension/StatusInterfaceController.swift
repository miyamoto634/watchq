//
//  StatusInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/06/22.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation

class StatusInterfaceController: WKInterfaceController
{
    //ステータスマネージャー
    let statusManager = StatusManager()
    //csvパース
    let perthCsv = PerthCsv()
    
    //アウトレット
    //文字
    @IBOutlet weak var staminaStateLabel: WKInterfaceLabel!
    
    //画像
    @IBOutlet weak var funStateImage: WKInterfaceImage!
    @IBOutlet weak var foodUnit1Image: WKInterfaceImage!
    @IBOutlet weak var foodUnit2Image: WKInterfaceImage!
    @IBOutlet weak var foodUnit3Image: WKInterfaceImage!
    @IBOutlet weak var foodUnit4Image: WKInterfaceImage!
    @IBOutlet weak var sleepUnitImage: WKInterfaceImage!
    @IBOutlet weak var expBarImage: WKInterfaceImage!
    @IBOutlet var rankIconImage: WKInterfaceImage!
    
    
    let userCalendar = NSCalendar.currentCalendar()
    
    //ステータス
    var foodStateValue:Int = 100*60*12
    var sleepStateValue:Int = 100
    var funStateValue:Int = 100
    var relationStateValue = 0
    var staminaStateValue = 10*900
    var maxStaminaStateValue = 10*900
    var levelStateValue = 1
    var goldenAmount = 0
    var timeSpend:Float = 0.0
    var expPointValue = 0
    
    var isSleeping = false
    
    //タイマー
    var timerDecreace:NSTimer!
    var decreaceInterval:NSTimeInterval = 0.2
    var countStaminUpdateTime = 0
    
    var maxBarWidth = 125.0//バーの最大の大きさ
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //画面サイズを取得、タイムバーの長さ設定
        let currentDevice = WKInterfaceDevice.currentDevice()
        let bounds = currentDevice.screenBounds
        // 38mm: (0.0, 0.0, 136.0, 170.0)
        // 42mm: (0.0, 0.0, 156.0, 195.0)
        if bounds.width > 136.0 { maxBarWidth = 45.0 }
        else { maxBarWidth = 39.0 }
    }
    
    //リセット
    func resetValues()
    {
        foodStateValue = 100*864
        sleepStateValue = 100*60*12
        funStateValue = 100*720
        
        staminaStateValue = maxStaminaStateValue
        
        setAllValue()
    }
    
    //全てのステータスを更新して表示させる
    func setAllValue()
    {
        //もし、0以下or100以上ならそこでストップさせる
        if foodStateValue < 0
        {
            foodStateValue = 0
        }
        else if foodStateValue > 100*864
        {
            foodStateValue = 100*864
        }
        
        if sleepStateValue < 0
        {
            sleepStateValue = 0
        }
        else if sleepStateValue > 100*60*12
        {
            sleepStateValue = 100*60*12
        }
        
        if funStateValue < 0
        {
            funStateValue = 0
        }
        else if funStateValue > 100*720
        {
            funStateValue = 100*70
        }
        
        if relationStateValue < 0
        {
            relationStateValue = 0
        }
        else if relationStateValue > 100
        {
            relationStateValue = 100
        }
        
        if staminaStateValue > maxStaminaStateValue
        {
            staminaStateValue = maxStaminaStateValue
        }
        
        setImageUnits(Int(funStateValue/720), type: "fun")
        setImageUnits(Int(foodStateValue/864), type: "food")
        setImageUnits(Int(sleepStateValue/720), type: "sleep")
        
        if levelStateValue >= 10
        {
            expBarImage.setWidth(CGFloat(maxBarWidth))
        }
        else
        {
            let maxExpPoint:Double = perthCsv.getMaxExp(levelStateValue)
            var BarSize = CGFloat((Double(expPointValue)/maxExpPoint)*maxBarWidth)
            if BarSize < 2.0 { BarSize = 2.0 }
            expBarImage.setWidth(BarSize)
        }
        
        staminaStateLabel.setText(String(staminaStateValue/900)+"/"+String(maxStaminaStateValue/900))
        
        var rankImageName = "rank_icon_"
        if levelStateValue >= 10 { rankImageName += "10" }
        else { rankImageName += String(levelStateValue) }
        rankIconImage.setImageNamed(rankImageName)
    }
    
    func setImageUnits(stateValue: Int,type: String)
    {
        var stateNum = 0
        
        switch stateValue
        {
        case 0:
            stateNum = 0
            break
        case 1...30:
            stateNum = 1
            break
        case 31...50:
            stateNum = 2
            break
        case 51...80:
            stateNum = 3
            break
        case 81...100:
            stateNum = 4
            break
        default:
            break
        }
        
        if type == "fun"
        {
            switch stateNum
            {
            case 0, 1:
                funStateImage.setImageNamed("fun_01_icon")
                break
            case 2:
                funStateImage.setImageNamed("fun_02_icon")
                break
            case 3:
                funStateImage.setImageNamed("fun_03_icon")
                break
            case 4:
                funStateImage.setImageNamed("fun_04_icon")
                break
            default:
                break
            }
            
            return
        }
        
        if type == "food"
        {
            switch stateNum
            {
            case 0:
                foodUnit1Image.setImageNamed("foodunit_icon_blank")
                foodUnit2Image.setImageNamed("foodunit_icon_blank")
                foodUnit3Image.setImageNamed("foodunit_icon_blank")
                foodUnit4Image.setImageNamed("foodunit_icon_blank")
                break
            case 1:
                foodUnit1Image.setImageNamed("foodunit_icon_blank")
                foodUnit2Image.setImageNamed("foodunit_icon_blank")
                foodUnit3Image.setImageNamed("foodunit_icon_blank")
                foodUnit4Image.setImageNamed("foodunit_icon")
                break
            case 2:
                foodUnit1Image.setImageNamed("foodunit_icon_blank")
                foodUnit2Image.setImageNamed("foodunit_icon_blank")
                foodUnit3Image.setImageNamed("foodunit_icon")
                foodUnit4Image.setImageNamed("foodunit_icon")
                break
            case 3:
                foodUnit1Image.setImageNamed("foodunit_icon_blank")
                foodUnit2Image.setImageNamed("foodunit_icon")
                foodUnit3Image.setImageNamed("foodunit_icon")
                foodUnit4Image.setImageNamed("foodunit_icon")
                break
            case 4:
                foodUnit1Image.setImageNamed("foodunit_icon")
                foodUnit2Image.setImageNamed("foodunit_icon")
                foodUnit3Image.setImageNamed("foodunit_icon")
                foodUnit4Image.setImageNamed("foodunit_icon")
                break
            default:
                break
            }
            
            return
        }
        
        if type == "sleep"
        {
            sleepUnitImage.setImageNamed("sleepunit_icon_"+String(stateNum)+"@42")
            if isSleeping { sleepUnitImage.setImageNamed("sleepunit_icon_0@42") }
            
            return
        }
    }
    
//    func testfunction(notification:NSNotification)
//    {
//        print("**** it works! function 2 ***")
//    }
    
    override func willActivate()
    {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "testfunction:", name: "TestNotificationFunction2", object: nil)
        
        let statusDict = statusManager.loadStatus(true)
        
        foodStateValue = statusDict["feedingV"]!
        sleepStateValue = statusDict["sleepingV"]!
        funStateValue = statusDict["funV"]!
        relationStateValue = statusDict["relationV"]!
        staminaStateValue = statusDict["staminaV"]!
        levelStateValue = statusDict["levelV"]!
        maxStaminaStateValue =  statusDict["staminaMaxV"]!
        goldenAmount = statusDict["goldenAmount"]!
        expPointValue = statusDict["experienceV"]!
        if statusDict["isSleeping"] == 0 { isSleeping = false }
        else { isSleeping = true }
        
        setAllValue()
        
        super.willActivate()
    }
    
    override func didDeactivate()
    {
        //SaveVars()
        statusManager.saveStatus(foodStateValue, sleepStateValue: sleepStateValue, funStateValue: funStateValue, isSleeping: isSleeping, staminaStateValue: staminaStateValue, maxStaminaStateValue: maxStaminaStateValue)
        
        super.didDeactivate()
    }
}
