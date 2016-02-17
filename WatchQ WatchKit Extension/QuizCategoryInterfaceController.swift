//
//  QuizCategoryInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/06/25.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation

class QuizCategoryInterfaceController: PetBaseInterfaceController
{
    //メッセージリプレイス
    let messageReplace = MessageReplace()
    //csvパース
    let perthCsv = PerthCsv()
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    
    //アウトレット
    @IBOutlet weak var CategoryTable: WKInterfaceTable!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    @IBOutlet var userInputGroup: WKInterfaceGroup!
    @IBOutlet var tutorialButton: WKInterfaceButton!
    @IBOutlet var tutorialGroup: WKInterfaceGroup!
    
    //ペット
    //画像
    @IBOutlet var petGroup: WKInterfaceGroup!
    @IBOutlet var petSkin: WKInterfaceGroup!
    @IBOutlet var petMakeup: WKInterfaceGroup!
    @IBOutlet var petSkinEffect: WKInterfaceGroup!
    @IBOutlet var petEye: WKInterfaceGroup!
    @IBOutlet var petMouth: WKInterfaceGroup!
    @IBOutlet var petHair: WKInterfaceGroup!
    @IBOutlet var petHairAcce: WKInterfaceGroup!
    @IBOutlet var petEyeAcce: WKInterfaceGroup!
    @IBOutlet var petCloth: WKInterfaceGroup!
    @IBOutlet var petHeadEffect: WKInterfaceGroup!
    @IBOutlet var petBalloon: WKInterfaceGroup!
    
    //文字
    @IBOutlet var message1Label: WKInterfaceLabel!
    @IBOutlet var message2Label: WKInterfaceLabel!
    @IBOutlet var playerInputMessageLabel: WKInterfaceLabel!
    
    
    var selectCategory = "not select"
    let categorys = ["歴史","地理","芸術","スポーツ","科学", "雑学"]
    
    var staminaValue = 0//スタミナ
    var timerEyeWink:NSTimer!//目パチタイマー（一回）
    var timerEyeWink2:NSTimer!//目パチタイマー（二回）
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
        
        //ペット画像セット
        let petImageDict = statusManager.getPetImageDict()
        for (key, value) in petImageDict
        { setPetImage(key,value: value) }
        animationName = petImageDict["petBodyType"]!
        petBalloon.setBackgroundImageNamed("Pet_default_"+petGender+"_petBalloon")
        
        loadTableData()
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        if statusManager.loadValue("quizTutorialFlag") == 0
        {
            tutorialGroup.setBackgroundImageNamed("quizhelp_0")
            
            //チュートリアルシーンに遷移
            tutorialButton.setHidden(false)
            petGroup.setHidden(true)
            userInputGroup.setHidden(true)
            CategoryTable.setHidden(true)
        }
        else
        {
            //カテゴリ選択に遷移
            petGroup.setHidden(false)
            CategoryTable.setHidden(true)
            userInputGroup.setHidden(true)
            tutorialButton.setHidden(true)
            
            updateUI()
        }
        
        //目ぱち
        timerEyeWink = NSTimer.scheduledTimerWithTimeInterval(eyeWinkOneceInterval, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: true)
        timerEyeWink2 = NSTimer.scheduledTimerWithTimeInterval(eyeWinkTwiceInterval, target: self, selector: "updateEyeActionTwice", userInfo: nil, repeats: true)
        
        //スタミナの値を取得
        staminaValue = statusManager.loadValue("staminaV")
    }
    
    func updateUI()
    {
        let staminaValue = statusManager.loadValue("staminaV")
        if staminaValue < 2*900
        {
            petGroup.setHidden(false)
            CategoryTable.setHidden(true)
            userInputGroup.setHidden(true)
            tutorialButton.setHidden(true)
            petTalk()
        }
        else
        {
            petGroup.setHidden(true)
            CategoryTable.setHidden(false)
            userInputGroup.setHidden(true)
            tutorialButton.setHidden(true)
        }
    }
    
    //遷移する時情報を渡す
    override func contextForSegueWithIdentifier(
        segueIdentifier: String,
        inTable table: WKInterfaceTable,
        rowIndex: Int) -> AnyObject?
    {
        let newStamina = statusManager.loadValue("staminaV") - 2*900
        statusManager.updateValue("staminaV", target_value: newStamina)
        statusManager.addValue("sleepingV", add_value: -2)
        
        let categoryName = categorys[rowIndex]
        selectCategory = categoryName
        return categoryName
    }
    
    //ペットのコメント
    func petTalk()
    {
        //コメントの表示
        var petMessage = ""
        petWink = true
        if staminaValue < 2*300
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
        updateMessage()
    }
    
    //メッセージ終了したらシーンを閉じる
    override func finishMessage()
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
            CategoryTable.setHidden(true)
            userInputGroup.setHidden(false)
            tutorialButton.setHidden(true)
            playerInputMessageLabel.setText("スタミナがありません。スタミナ回復アイテムをショップで購入できます。ショップに移動しますか？")
        }
        else
        {
            //あり：アイテム使用誘導
            petGroup.setHidden(true)
            CategoryTable.setHidden(true)
            userInputGroup.setHidden(false)
            tutorialButton.setHidden(true)
            //アイテムIDからアイテム名取得
            playerInputMessageLabel.setText("スタミナがありません。「"+targetStaminaItemDict["ItemName"]!+"」を使用してスタミナを回復しますか？")
        }
    }
    
    @IBAction func pushYes()
    {
        if targetStaminaItemDict == [String:String]()
        {
            //なし：ショップへ遷移
            print("-- move to shop --")
            presentControllerWithNames(["shoplist", "shoplist"], contexts: ["goldConsume", "diaConsume"])
        }
        else
        {
            //あり：回復してカテゴリ選択画面に
            print("-- use item --")
            print("item decrease")
            itemEffectManager.useConsumeItem(targetStaminaItemDict)
            
            //カテゴリ選択画面へ
            petGroup.setHidden(true)
            CategoryTable.setHidden(false)
            userInputGroup.setHidden(true)
            tutorialButton.setHidden(true)
        }
    }
    
    @IBAction func pushNo()
    {
        dismissController()
    }
    
    //テーブル作成
    func loadTableData()
    {
        CategoryTable.setNumberOfRows(categorys.count, withRowType: "CategoryTableRowController")
        
        for (index, categoryName) in categorys.enumerate() {
            let row = CategoryTable.rowControllerAtIndex(index) as! CategoryTableRowController
            
            row.categoryLabel.setText(categoryName)
        }
    }
    
    //チュートリアル用のシーン
    @IBAction func moveNextImage()
    {
        if tutorialImageNum >= 1
        {
            //flagを更新
            statusManager.updateValue("quizTutorialFlag",target_value: 1)
            
            //カテゴリ選択に遷移
            petGroup.setHidden(true)
            CategoryTable.setHidden(false)
            userInputGroup.setHidden(true)
            tutorialButton.setHidden(true)
            
            return
        }
        
        tutorialImageNum += 1
        
        animateWithDuration(0.2) { () -> Void in
            self.tutorialGroup.setBackgroundImageNamed("quizhelp_"+String(self.tutorialImageNum))
        }
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
    
    override func didDeactivate()
    {
        super.didDeactivate()
        //タイマーの破棄
        if timerEyeWink != nil && timerEyeWink.valid { timerEyeWink.invalidate() }
        if timerEyeWink2 != nil && timerEyeWink2.valid { timerEyeWink2.invalidate() }
        if usefulTimer != nil && usefulTimer.valid { usefulTimer.invalidate() }
    }
}
