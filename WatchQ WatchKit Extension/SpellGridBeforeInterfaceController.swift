//
//  SpellGridBeforeInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/17.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class SpellGridBeforeInterfceController: PetBaseInterfaceController
{
    //メッセージリプレイス
    var messageReplace = MessageReplace()
    //csvパース
    let perthCsv = PerthCsv()
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    
    //アウトレット
    //大きいアウトレット
    @IBOutlet weak var petGroup: WKInterfaceGroup!
    @IBOutlet weak var userInputGroup: WKInterfaceGroup!
    @IBOutlet var tutorialButton: WKInterfaceButton!
    @IBOutlet var tutorialGroup: WKInterfaceGroup!
    
    //文字
    @IBOutlet weak var message1Label: WKInterfaceLabel!
    @IBOutlet weak var message2Label: WKInterfaceLabel!
    @IBOutlet var playerInputMessageLabel: WKInterfaceLabel!
    
    //画像
    @IBOutlet var petBalloon: WKInterfaceGroup!
    @IBOutlet var petHeadEffect: WKInterfaceGroup!
    @IBOutlet var petCloth: WKInterfaceGroup!
    @IBOutlet var petEyeAcce: WKInterfaceGroup!
    @IBOutlet var petHairAcce: WKInterfaceGroup!
    @IBOutlet var petMouth: WKInterfaceGroup!
    @IBOutlet var petEye: WKInterfaceGroup!
    @IBOutlet var petHair: WKInterfaceGroup!
    @IBOutlet var petSkinEffect: WKInterfaceGroup!
    @IBOutlet var petMakeup: WKInterfaceGroup!
    @IBOutlet var petSkin: WKInterfaceGroup!
    
    //変数
    var timerEyeWink:NSTimer!//目パチタイマー（一回）
    var timerEyeWink2:NSTimer!//目パチタイマー（二回）
    var staminaValue = 0//スタミナ
    var hadMoved = false
    var usefulTimer:NSTimer!//色々使うタイマー
    var targetStaminaItemDict = [String:String]()//スタミナ回復アイテムデータ
    var tutorialImageNum = 0
    
    //定数
    let eyeWinkOneceInterval:NSTimeInterval = 4 //目パチの間隔（一回）
    let eyeWinkTwiceInterval:NSTimeInterval = 10 //目パチの間隔（二回）
    let eyeCloseInterval:NSTimeInterval = 0.2//目パチの間隔
    
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
            petBalloonLabel1: message1Label,
            petBalloonLabel2: message2Label
        )
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        //表示の切り替え
        petGroup.setHidden(false)
        userInputGroup.setHidden(true)
        tutorialButton.setHidden(true)
        
        //画面サイズを取得、会話文の長さ設定
        let currentDevice = WKInterfaceDevice.currentDevice()
        let bounds = currentDevice.screenBounds
        if bounds.width <= 136.0 { maxCharacter = 11 }
        
        //ペットのイメージ名
        if statusManager.loadValue("petgender") == 1 { petGender = "man" }
        else { petGender = "woman" }
        
        petBalloon.setBackgroundImageNamed("Pet_default_"+petGender+"_petBalloon")
        
        //set up image of pet
        let petImageDict = statusManager.getPetImageDict()
        for (key, value) in petImageDict
        { setPetImage(key,value: value) }
        animationName = petImageDict["petBodyType"]!
        
        //目パチ
        timerEyeWink = NSTimer.scheduledTimerWithTimeInterval(eyeWinkOneceInterval, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: true)
        timerEyeWink2 = NSTimer.scheduledTimerWithTimeInterval(eyeWinkTwiceInterval, target: self, selector: "updateEyeActionTwice", userInfo: nil, repeats: true)
        
        usefulTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "updateMessage", userInfo: nil, repeats: false)
        
        //スタミナの値を取得
        staminaValue = statusManager.loadValue("staminaV")
        
        petTalk()
    }
    
    //目パチ（自動１回）
    func updateEyeActionOnce() { eyeAnimation(1) }
    
    //目パチ（自動２回）
    func updateEyeActionTwice() { eyeAnimation(2) }
    
    //目パチ（０入れるとループ再生）
    func eyeAnimation(count:Int)
    {
        petEye.setBackgroundImageNamed(animationName+"_petEyeWink_")
        petEye.startAnimatingWithImagesInRange(NSMakeRange(1, 5), duration: eyeCloseInterval, repeatCount: count)
    }
    
    //ペットのコメント
    func petTalk()
    {
        //コメントの表示
        var petMessage = ""
        petWink = true
        if staminaValue >= 2*900
        {
            let challengeMessageArray = ["ヒントから単語を連想してね", "%＜飼い主＞は分かるかな？", "文字を繋げて単語を作ってね！", "分かったら単語を入力してね！"]
            let randNum = Int(arc4random_uniform(4))
            petMessage = challengeMessageArray[randNum]
            setPetExpressionImage("default_talk", isSkinEffect: false, isHeadEffect: false)
        }
        else
        {
            let randNum = Int(arc4random_uniform(8))
            switch randNum
            {
            case 0:
                petMessage += "スタミナが足りないよ～"
                setPetExpressionImage("_sad", isSkinEffect:true, isHeadEffect: false)
                break
            case 1:
                petMessage += "スタミナを回復してね！"
                setPetExpressionImage("_sad", isSkinEffect:true, isHeadEffect: false)
                break
            case 2:
                petMessage += "体力切れだよ！"
                setPetExpressionImage("_sad", isSkinEffect:true, isHeadEffect: false)
                break
            case 3:
                petMessage += "少し休ませて！"
                setPetExpressionImage("_benotsatisfied", isSkinEffect:true, isHeadEffect: false)
                break
            case 4:
                petMessage += "%＜飼い主＞は元気だね・・・"
                setPetExpressionImage("_sad", isSkinEffect:true, isHeadEffect: false)
                break
            case 5:
                petMessage += "きゅーけー"
                if petGender == "man"
                {
                    setPetExpressionImage("_sleepy", isSkinEffect:false, isHeadEffect: true)
                }
                else
                {
                    setPetExpressionImage("_sleepy", isSkinEffect:false, isHeadEffect: false)
                }
                petWink = false
                break
            case 6:
                petMessage += "少し待って～"
                setPetExpressionImage("default_talk", isSkinEffect: false, isHeadEffect: false)
                break
            case 7:
                petMessage += "疲れたよ～"
                setPetExpressionImage("_sad", isSkinEffect:true, isHeadEffect: false)
                break
            default:
                break
            }
        }
        addMessage(petMessage)
    }
    
    //テーブルにメッセージ追加
    func addMessage(message: String)
    {
        messageArray = [String]()
        let repMessage = messageReplace.replaceSentence(message)
        for char in repMessage.characters
        {
            messageArray.append(String(char))
        }
        
        //初期化
        firstLineEnd = 0
        firstLineStart = 0
        secondLineEnd = 0
        secondLineStart = 0
        
        message1Label.setText("")
        message2Label.setText("")
        //吹き出しを表示
        usefulTimer = NSTimer.scheduledTimerWithTimeInterval(petTalkTextSpeed, target: self, selector: "updateMessage", userInfo: nil, repeats: false)
    }
    
    override func finishMessage()
    {
        if staminaValue >= 2*900
        {
            if statusManager.loadValue("spellGridTutorialFlag") == 0
            {
                //画像セット
                tutorialGroup.setBackgroundImageNamed("spellgridhelp_0")
                
                //シーン変換
                tutorialButton.setHidden(false)
                petGroup.setHidden(true)
                userInputGroup.setHidden(true)
                
                return
            }
            
            //goto next scene
            if hadMoved { return }
            hadMoved = true
            let newStamina = staminaValue - 2*900
            statusManager.updateValue("staminaV", target_value: newStamina)
            print("staminaV:"+String(newStamina))
            statusManager.addValue("sleepingV", add_value: -2)
            presentControllerWithName("spellgrid", context: nil)
        }
        else
        {
            //スタミナアイテムがあるかチェック
            for staminaItemID:Int16 in [501, 502, 503]
            {
                if ItemsManager.checkAboutItem(staminaItemID)
                {
                    targetStaminaItemDict = perthCsv.getType("items", type: "ItemID", typeNum: String(staminaItemID))
                    break
                }
            }
            
            //表示切り替え
            if targetStaminaItemDict == [String:String]()
            {
                //なし：ショップ誘導
                petGroup.setHidden(true)
                userInputGroup.setHidden(false)
                tutorialButton.setHidden(true)
                playerInputMessageLabel.setText("スタミナがありません。スタミナ回復アイテムをショップで購入できます。ショップに移動しますか？")
            }
            else
            {
                //あり：アイテム使用誘導
                petGroup.setHidden(true)
                userInputGroup.setHidden(false)
                tutorialButton.setHidden(true)
                //アイテムIDからアイテム名取得
                playerInputMessageLabel.setText("スタミナがありません。「"+targetStaminaItemDict["ItemName"]!+"」を使用してスタミナを回復しますか？")
            }
        }
        
    }
    
    @IBAction func pushChallenge()
    {
        if targetStaminaItemDict == [String:String]()
        {
            //なし：ショップへ遷移
            print("-- move to shop --")
            presentControllerWithNames(["shoplist", "shoplist"], contexts: ["goldConsume", "diaConsume"])
        }
        else
        {
            //あり：回復してゲームスタート
            print("-- use item --")
            print("item decrease")
            itemEffectManager.useConsumeItem(targetStaminaItemDict)
            
            //ゲーム画面に遷移
            if hadMoved { return }
            hadMoved = true
            staminaValue = statusManager.loadValue("staminaV")
            let newStamina = staminaValue - 2*900
            statusManager.updateValue("staminaV", target_value: newStamina)
            statusManager.addValue("sleepingV", add_value: -2)
            presentControllerWithName("spellgrid", context: nil)
        }
    }
    
    @IBAction func pushCancel()
    {
        dismissController()
    }
    
    @IBAction func pushChangeSceneButton()
    {
        if tutorialImageNum >= 1
        {
            //flagを更新
            statusManager.updateValue("spellGridTutorialFlag",target_value: 1)
            
            //ゲーム画面に遷移
            if hadMoved { return }
            hadMoved = true
            staminaValue = statusManager.loadValue("staminaV")
            let newStamina = staminaValue - 2*900
            statusManager.updateValue("staminaV", target_value: newStamina)
            statusManager.addValue("sleepingV", add_value: -2)
            presentControllerWithName("spellgrid", context: nil)
            
            return
        }
        
        tutorialImageNum += 1
        
        animateWithDuration(0.5) { () -> Void in
            self.tutorialGroup.setBackgroundImageNamed("spellgridhelp_"+String(self.tutorialImageNum))
        }
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
        //タイマーの破棄
        if timerEyeWink != nil && timerEyeWink.valid { timerEyeWink.invalidate() }
        if timerEyeWink2 != nil && timerEyeWink2.valid { timerEyeWink2.invalidate() }
        if usefulTimer != nil && usefulTimer.valid { usefulTimer.invalidate() }
    }
}