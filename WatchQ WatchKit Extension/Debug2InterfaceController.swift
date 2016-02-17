//
//  Debug2InterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/10/22.
//  Copyright © 2015年 Ninja Egg. All rights reserved.
//

import WatchKit
import Foundation


class Debug2InterfaceController: WKInterfaceController
{
    //ステータスマネージャー
    let statusManager = StatusManager()
    
    //アウトレット
    @IBOutlet var foodLabel: WKInterfaceLabel!
    @IBOutlet var sleepLabel: WKInterfaceLabel!
    @IBOutlet var funLabel: WKInterfaceLabel!
    @IBOutlet var relationLabel: WKInterfaceLabel!
    @IBOutlet var isSleepLabel: WKInterfaceLabel!
    
    
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
    
    //パラメーターを下げる関数
    func decreaceValue()
    {
        //foodを下げる
        foodStateValue -= 864
        //funを下げる
        funStateValue -= 720
        
        //スタミナ関係
        staminaStateValue -= 900
        if staminaStateValue < 0
        {
            staminaStateValue = 0
        }
        
        //sleepを上下
        if !isSleeping { sleepStateValue -= 60*12 }
        
        //起きているか判定
        if sleepStateValue >= 100 && isSleeping == true
        {
            isSleeping = false
            statusManager.updateValue("isSleeping", target_value: 0)
        }
        setAllValue()
    }
    
    @IBAction func decValueButton()
    {
        decreaceValue()
    }
    
    @IBAction func retValueButton()
    {
        resetValues()
    }
    
    @IBAction func decValueTen()
    {
        decreaceValue()
        decreaceValue()
        decreaceValue()
        decreaceValue()
        decreaceValue()
        decreaceValue()
        decreaceValue()
        decreaceValue()
        decreaceValue()
        decreaceValue()
    }
    
    @IBAction func switchSleep()
    {
        if isSleeping == true
        {
            isSleeping = false
            statusManager.updateValue("isSleeping", target_value: 0)
        }
        else if isSleeping == false
        {
            isSleeping = true
            statusManager.updateValue("isSleeping", target_value: 1)
        }
    }
    
    @IBAction func addGold()
    {
        let tmp_gold = statusManager.loadValue("goldenAmount")
        statusManager.updateValue("goldenAmount", target_value: tmp_gold + 10000)
    }
    
    @IBAction func addDia()
    {
        ConnectionManager.sharedManager.exchangeDataWithIphone("userInfoInt", action: "addValue", veriable: "diamondAmount", value1: "5", value2: "")
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
        
        foodLabel.setText("Food:"+String(Int(foodStateValue/864))+"%")
        sleepLabel.setText("Sleep:"+String(Int(sleepStateValue/720))+"%")
        funLabel.setText("Fun:"+String(Int(funStateValue/720))+"%")
        if isSleeping == false { isSleepLabel.setText("awake") }
        else { isSleepLabel.setText("sleep") }
        relationLabel.setText("Relation:"+String(relationStateValue)+"%")
        if isSleeping == false { isSleepLabel.setText("awake") }
        else { isSleepLabel.setText("sleep") }
        
        statusManager.saveStatus(foodStateValue, sleepStateValue: sleepStateValue, funStateValue: funStateValue, isSleeping: isSleeping, staminaStateValue: staminaStateValue, maxStaminaStateValue: maxStaminaStateValue)
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
    
    //名前変更
    @IBAction func changeName()
    {
        presentControllerWithName("specialItem", context: "8debug")
    }
    
    //性別変更
    @IBAction func changeGender()
    {
        presentControllerWithName("specialItem", context: "7debug")
    }
    
    override func willActivate()
    {
        let statusDict = statusManager.loadStatus(true)
        
        
        foodStateValue = statusDict["feedingV"]!
        sleepStateValue = statusDict["sleepingV"]!
        funStateValue = statusDict["funV"]!
        print("Fun:"+String(funStateValue))
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
        statusManager.saveStatus(foodStateValue, sleepStateValue: sleepStateValue, funStateValue: funStateValue, isSleeping: isSleeping, staminaStateValue: staminaStateValue, maxStaminaStateValue: maxStaminaStateValue)
        
        super.didDeactivate()
    }

}
