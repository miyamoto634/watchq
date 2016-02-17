//
//  PetInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation

let userCalendar = NSCalendar.currentCalendar()


class PetInterfaceController: PetBaseInterfaceController
{
    //csvパース
    var perthCsv = PerthCsv()
    //メッセージリプレイス
    var messageReplace = MessageReplace()
    //アイテムエフェクトマネージャー
    var itemEffectManager = ItemEffectManager()
    //カレンダー
    let userCalendar = NSCalendar.currentCalendar()
    
    //アウトレット
    //ペット画像
    @IBOutlet var petBalloon        : WKInterfaceGroup!
    @IBOutlet var petHeadEffect     : WKInterfaceGroup!
    @IBOutlet var petCloth          : WKInterfaceGroup!
    @IBOutlet var petEyeAcce        : WKInterfaceGroup!
    @IBOutlet var petHairAcce       : WKInterfaceGroup!
    @IBOutlet var petMouth          : WKInterfaceGroup!
    @IBOutlet var petEye            : WKInterfaceGroup!
    @IBOutlet var petHair           : WKInterfaceGroup!
    @IBOutlet var petSkinEffect     : WKInterfaceGroup!
    @IBOutlet var petMakeup         : WKInterfaceGroup!
    @IBOutlet var petSkin           : WKInterfaceGroup!
    @IBOutlet var petGroup          : WKInterfaceGroup!
    
    //文字
    @IBOutlet var petBalloonLabel   : WKInterfaceLabel!
    @IBOutlet var petBalloonLabel2  : WKInterfaceLabel!
    
    //ボタン
    @IBOutlet var petBigButton      : WKInterfaceButton!
    
    
    //変数
    var petSpeaking                     = false
    var foodStateValue:Int              = 100
    var sleepStateValue:Int             = 100
    var funStateValue:Int               = 100
    var relationshipStateValue:Int      = 100
    var isSleeping                      = false
    var tapTime                         = 0
    var isPetTalk                       = false
    var converSession                   = [[String: String]]()//全会話内容を格納する配列
    var doesMoveToNextScene             = false//画面遷移用のもの
    
    var timerEyeWink:NSTimer! //目パチタイマー（一回）
    var timerEyeWink2:NSTimer! //目パチタイマー（二回）
    var timerMessageClose:NSTimer!//吹き出し削除タイマー
    
    
    //定数
    let messageCloseInterval:NSTimeInterval =  3.0 //メッセージ削除されるまでの間隔
    let eyeCloseInterval:NSTimeInterval = 0.2 //目パチの時間
    let eyeWinkOneceInterval:NSTimeInterval = 4 //目パチの間隔
    let eyeWinkTwiceInterval:NSTimeInterval = 10 //目パチの間隔
    
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //アウトレットをセット
        setUpPetOutlets(
            petBalloon,
            petHeadEffect: petHeadEffect,
            petCloth: petCloth,
            petEyeAcce: petEyeAcce,
            petHairAcce: petHairAcce,
            petMouth: petMouth,
            petEye: petEye,
            petHair: petHair,
            petSkinEffect: petSkinEffect,
            petMakeup: petMakeup,
            petSkin: petSkin,
            petGroup: petGroup,
            petBalloonLabel1: petBalloonLabel,
            petBalloonLabel2: petBalloonLabel2
        )
        
        //ジャンプ先が指定されていれば指定先にジャンプ
        let moveScene = context as! String
        if moveScene != ""
        {
            doesMoveToNextScene = true
            petBigButton.setEnabled(false)
            presentControllerWithName(moveScene, context: nil)
        }
        
        //全つぶやき内容取得
        converSession = perthCsv.filterType("newtalk", type: "type", typeNum: "13")
        
        //目ぱちタイマー
        timerEyeWink = NSTimer.scheduledTimerWithTimeInterval(eyeWinkOneceInterval, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: true)
        timerEyeWink2 = NSTimer.scheduledTimerWithTimeInterval(eyeWinkTwiceInterval, target: self, selector: "updateEyeActionTwice", userInfo: nil, repeats: true)
    }
    
    //目パチ（自動１回）
    func updateEyeActionOnce()
    {
        eyeAnimation(1)
    }
    
    //目パチ（自動２回）
    func updateEyeActionTwice()
    {
        eyeAnimation(2)
    }
    
    //画面をタッチした時の反応
    @IBAction func petTalkHello()
    {
        if !isPetTalk
        {
            if tapTime >= 3 && isSleeping
            {
                //pet awake by user
                print("pet wake up by user")
                statusManager.addValue("sleepingV", add_value: 30)
                statusManager.addValue("funV", add_value: -5*720)
                statusManager.addValue("relationV", add_value: -5)
                statusManager.updateValue("isSleeping", target_value: 0)
                isSleeping = false
                setExpressionFromDict("6")
                petTalk("うう…まだ眠いのに…")
            }
            else
            {
                if !isSleeping
                {
                    //ランダムで会話シーンに遷移
                    let playerRank = statusManager.loadValue("levelV")
                    let playerFun = Int(statusManager.loadValue("funV")/720)
                    var probabilityNum:Double = Double(playerRank) + Double((playerFun-40)/3)
                    if probabilityNum < 0 { probabilityNum = 0.0 }
                    
                    let randNum = Int(arc4random_uniform(1000))
                    print("rand:"+String(randNum)+"__prob:"+String(probabilityNum*10))
                    
                    if Double(randNum) < probabilityNum*10
                    {
                        petBigButton.setHidden(true)
                        presentControllerWithName("pettalk", context: nil)
                        return
                    }
                }
                
                //ペット会話中
                isPetTalk = true
                
                var statusDict = statusManager.loadStatus(false)
                
                let foodStateValue = Int(statusDict["feedingV"]!/864)
                let sleepStateValue = Int(statusDict["sleepingV"]!/720)
                let funStateValue = Int(statusDict["funV"]!/720)
                let relationshipStateValue = statusDict["relationV"]!
                isSleeping = false
                if statusDict["isSleeping"] == 0 { isSleeping = false }
                else { isSleeping = true }
                
                //会話辞書を取得
                var targetDict = messageReplace.selectPhrase(foodStateValue, sleepStateValue: sleepStateValue, funStateValue: funStateValue, relationshipStateValue: relationshipStateValue, isSleeping: isSleeping, balloonConverSession: converSession)
                setExpressionFromDict(targetDict["expression"]!)
                petTalk(messageReplace.replaceSentence(targetDict["sentence"]!))
                tapTime += 1
                petBigButton.setEnabled(false)
            }
        }
    }
    
    //ペットが話す
    func petTalk(talk:String)
    {
        if !petSpeaking
        {
            petSpeaking = true
            messageArray = [String]()
            for message in talk.characters
            {
                messageArray.append(String(message))
            }
            firstLineEnd = 0
            firstLineStart = 0
            //吹き出しを表示(とりあえずデフォルトしかないと思うのでそれのみ指定)
            petBalloon.setBackgroundImageNamed("Pet_default_"+petGender+"_petBalloon")
            updateMessage()
        }
    }
    
    //メッセージ終了後の処理
    override func finishMessage()
    {
        //ペット会話中解除
        isPetTalk = false
        
        petBalloon.setBackgroundImage(nil)
        //表情のセット
        if isSleeping == true
        {
            setExpressionFromDict("7")
        }
        else
        {
            setExpressionFromDict("0")
            petWink = true
        }
        petBigButton.setEnabled(true)
        messageArray = []
        firstLineEnd = 0
        firstLineStart = 0
        secondLineStart = 0
        secondLineEnd = 0
        petBalloonLabel.setText("")
        petBalloonLabel2.setText("")
        petSpeaking = false
        
        petHeadEffect.stopAnimating()
        petMouth.stopAnimating()
    }
    
    //目パチ（０入れるとループ再生）
    func eyeAnimation(count:Int)
    {
        if petWink
        {
            petEye.setBackgroundImageNamed(animationName+"_petEyeWink_")
            petEye.startAnimatingWithImagesInRange(NSMakeRange(1, 5), duration: eyeCloseInterval, repeatCount: count)
        }
    }
    
    override func willActivate()
    {
        //シーン遷移する場合はpetを非表示にする
        if doesMoveToNextScene
        {
            petBigButton.setHidden(true)
            doesMoveToNextScene = false
            return
        }
        else
        {
            petBigButton.setHidden(false)
        }
        
        //ペットの画像をセットする
        let petImageDict = statusManager.getPetImageDict()
        for (key, value) in petImageDict
        { setPetImage(key,value: value) }
        animationName = petImageDict["petBodyType"]!
        
        //Unlockダイアログが表示できるか確認する
        var flagDictArray = statusManager.loadFlagDictArray()
        let conditionNumDict = itemEffectManager.getConditionDict()
        var releaseItemName = ""
        
        for index in 0...flagDictArray.count-1
        {
            var elementDict = flagDictArray[index]
            
            if elementDict["UnlockFlag"] == "0"
            {
                let keyString = itemEffectManager.returnStringKey(String(elementDict["Unlock"]!))
                
                //条件を満たしているか確認
                if keyString != "" && conditionNumDict[keyString] >= Int(elementDict["UnlockThreshold"]!)!
                {
                    //フラグを更新・保存
                    elementDict["Unlock"] = "1"
                    flagDictArray[index] = elementDict
                    statusManager.updateFlagDictArray(flagDictArray)
                    
                    //アイテム名追加
                    if releaseItemName != "" { releaseItemName += "\n"+String(elementDict["ItemName"]!) }
                    else { releaseItemName += String(elementDict["ItemName"]!) }
                }
            }
        }
        
        //表示するものがあるならば遷移する。Stringも渡す
        if releaseItemName != ""
        {
            showPopup("次のアイテムがショップに追加されました！",popMessage: releaseItemName)
            return
        }
        
        //アイテム付与を行ったか判定
        let itemGrantMessage = statusManager.loadString("itemGrantMessage")
        if itemGrantMessage != ""
        {
            showPopup("次のアイテムがプレゼントされました！",popMessage: itemGrantMessage)
            statusManager.updateString("itemGrantMessage", target_string: "")
            return
        }
        
        //情報を取得
        var statusDict = statusManager.loadStatus(false)
        
        foodStateValue = Int(statusDict["feedingV"]!/864)
        sleepStateValue = Int(statusDict["sleepingV"]!/720)
        funStateValue = Int(statusDict["funV"]!/720)
        relationshipStateValue = statusDict["relationV"]!
        if statusDict["isSleeping"] == 0 { isSleeping = false }
        else { isSleeping = true }
        
        //寝ているときは寝ている表情
        if isSleeping
        {
            print("sleeping!!")
            setExpressionFromDict("7")
            petWink = false
        }
        
        //吹き出しを閉じておく
        finishMessage()
        
        //目パチの再開
        if !timerEyeWink.valid
        {
            timerEyeWink = NSTimer.scheduledTimerWithTimeInterval(eyeWinkOneceInterval, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: true)
        }
        if !timerEyeWink2.valid
        {
            timerEyeWink2 = NSTimer.scheduledTimerWithTimeInterval(eyeWinkTwiceInterval, target: self, selector: "updateEyeActionTwice", userInfo: nil, repeats: true)
        }
        
        //send error bug to iPhone if there an error 
        /*
        if(defaults1.stringForKey("exceptionStr") != nil &&  defaults1.stringForKey("exceptionStr")! != "")
        {
            let exceptionError = defaults1.stringForKey("exceptionStr")!;
            connectionManager.exchangeDataWithIphone("errorReport", action: "showError", veriable: "", value1: exceptionError, value2: "")
            print(exceptionError);
        }*/
        
        //リクエストデータ送信
        exchangeDataWithIphone("userInfoInt", action: "getValue", veriable: "petTalkTextSpeed", value1: "", value2: "")
        
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        //目パチの破棄
        if timerEyeWink.valid { timerEyeWink.invalidate() }
        if timerEyeWink2.valid { timerEyeWink2.invalidate() }
        
        //init tap time
        tapTime = 0
    }
    
    override func getDataFromIphone(content:AnyObject)
    {
        super.getDataFromIphone(content)
        
        //データ受け取り後の処理
        let reciveArray = content as! [String:AnyObject]
        
        //取得した値を保存してラベルに書く
        statusManager.updateValue("petTalkTextSpeed",target_value: reciveArray["result"]! as! Int)
        petTalkTextSpeed = statusManager.getPetTalkTextSpeed()
        
    }
    
    //ポップアップ
    func showPopup(popTitle:String, popMessage:String)
    {
        let action1 = WKAlertAction(title: "了解", style: .Default) {}
        
        presentAlertControllerWithTitle(popTitle, message: popMessage, preferredStyle: .ActionSheet, actions: [action1])
    }
    
}
