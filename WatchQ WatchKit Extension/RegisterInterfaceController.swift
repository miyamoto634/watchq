//
//  userInfoInputInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/25.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class RegisterInterfaceController: WKInterfaceController
{
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    //csvパース
    let perthCsv = PerthCsv()
    //ステータスマネージャー
    let statusManager = StatusManager()
    //メッセージレプレイス
    let messageReplace = MessageReplace()
    
    //シーンenum
    enum RegisterState
    {
        case gender
        case petTalk
        case input
        case check
        case checkAll
        case responce
        case tutorial
        case fin
    }
    
    ////アウトレット////
    
    ////大きなアウトレット////
    @IBOutlet weak var soundInputGroup: WKInterfaceGroup!
    @IBOutlet weak var petGroup: WKInterfaceGroup!
    @IBOutlet weak var checkGroup: WKInterfaceGroup!
    @IBOutlet weak var genderGroup: WKInterfaceGroup!
    @IBOutlet var checkAllGroup: WKInterfaceGroup!
    
    ////ペット////
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
    
    //文字
    @IBOutlet weak var messageLine1Label: WKInterfaceLabel!
    @IBOutlet weak var messageLine2Label: WKInterfaceLabel!
    
    ////音声入力////
    //文字
    @IBOutlet weak var soundInputLabel: WKInterfaceLabel!
    
    //ボタン
    @IBOutlet weak var determineButton: WKInterfaceButton!
    
    ////確認////
    //文字
    @IBOutlet weak var checkLabel: WKInterfaceLabel!
    
    ////全体確認////
    //文字
    @IBOutlet var playerNameLabel: WKInterfaceLabel!
    @IBOutlet var petNameLabel: WKInterfaceLabel!
    @IBOutlet var petGenderLabel: WKInterfaceLabel!
    
    ////変数////
    var petImageName = ""
    var animationName = ""
    var petGender = ""
    var sceneState:RegisterState = .gender
    var flowState = "Gender"
    var countForTutorial = 0
    
    var tutorialMessage = [[String:String]]()//チュートリアルのメッセージ
    var messageArray = [String]()//文字を格納する配列
    var showMessage:String = ""//表示する文字
    var showMessage2:String = ""//２行目に表示する文字
    var firstLineEnd:Int = 0//文字取得終了位置
    var firstLineStart = 0//文字取得開始位置
    var secondLineStart = 0//２行目開始位置
    var secondLineEnd = 0//２行目終了位置
    var maxlengthString = 13
    var allItemsDict = [[String:String]]()
    
    var isPushed = false//はい・いいえ判定
    
    ////登録////
    var playerName = ""
    var petName = ""
    var petGenderNum = 1
    
    var moveNextTimer:NSTimer!
    var messageTimer:NSTimer!
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //画面サイズを取得、会話文の長さ設定
        let currentDevice = WKInterfaceDevice.currentDevice()
        let bounds = currentDevice.screenBounds
        if bounds.width <= 136.0 { maxlengthString = 11 }
        
        //ペット画像をセット
        petGender = "man"
        
        //画像のセット
        statusManager.initPetImageDict(petGender)
        
        let petImageDict = statusManager.getPetImageDict()
        for (key, value) in petImageDict
        {
            if value != ""
            {
                setPetImage(key,value: value)
            }
        }
        animationName = petImageDict["petBodyType"]!
        
        //csvをパースする
        allItemsDict = perthCsv.getAll("items")
        tutorialMessage = perthCsv.filterType("newtalk",type: "type",typeNum: "18")
        
        //テスト
        playerName = "にん太郎"
        petName = "Ｑすけ"
        
        flowState = "Gender"
        sceneState = RegisterState.gender
        changeScene()
    }
    
    func changeScene()
    {
        switch sceneState
        {
        case RegisterState.gender://性別決定
            print("Gender")
            //表示・非表示の変更
            petGroup.setHidden(true)
            soundInputGroup.setHidden(true)
            checkGroup.setHidden(true)
            genderGroup.setHidden(false)
            checkAllGroup.setHidden(true)
            
            sceneState  = RegisterState.check
            break
        case RegisterState.petTalk://ペットシーン
            print("PetTalk")
            //表示・非表示の変更
            petGroup.setHidden(false)
            soundInputGroup.setHidden(true)
            checkGroup.setHidden(true)
            genderGroup.setHidden(true)
            checkAllGroup.setHidden(true)
            
            if petGenderNum == 1 { petGender = "man" }
            else { petGender = "woman" }
            
            //画像のセット
            statusManager.initPetImageDict(petGender)
            
            //set up image of pet
            let petImageDict = statusManager.getPetImageDict()
            for (key, value) in petImageDict
            {
                if value != ""
                {
                    setPetImage(key,value: value)
                }
            }
            animationName = petImageDict["petBodyType"]!
            
            sceneState = RegisterState.input
            
            //ペットの表情追加
            setPetExpressionImage("", isSkinEffect: false, isHeadEffect: false)
            print("flow state:"+flowState)
            //しゃべる為の機構
            if flowState == "Player" { showMessage("はじめまして！きみは何ていう名前なの？") }
            else if flowState == "Pet" { showMessage("ぼくにはまだ名前がないんだ。%＜飼い主＞、ぼくに名前をつけてくれる？") }
            break
        case RegisterState.input://入力シーン
            print("Input")
            //表示・非表示の変更
            petGroup.setHidden(true)
            soundInputGroup.setHidden(false)
            checkGroup.setHidden(true)
            genderGroup.setHidden(true)
            checkAllGroup.setHidden(true)
            
            soundInputLabel.setText("音声入力から入力してください。")
            
            determineButton.setEnabled(false)
            
            break
        case RegisterState.check://確認シーン
            print("Check")
            
            isPushed = false
            
            //表示・非表示の変更
            petGroup.setHidden(true)
            soundInputGroup.setHidden(true)
            checkGroup.setHidden(false)
            genderGroup.setHidden(true)
            checkAllGroup.setHidden(true)
            
            //確認する為の機構
            if flowState == "Gender"
            {
                var gender = ""
                if petGenderNum == 1 { gender = "男の子" }
                else if petGenderNum == 2 { gender = "女の子" }
                
                checkLabel.setText("ペットの性別は「"+gender+"」でよろしいでしょうか？")
            }
            else if flowState == "Player"
            {
                checkLabel.setText("プレイヤー名は「"+playerName+"」でよろしいでしょうか？")
            }
            else if flowState == "Pet"
            {
                checkLabel.setText("ペット名は「"+petName+"」でよろしいでしょうか？")
            }
            
            break
        case RegisterState.responce://返答シーン
            print("Return")
            //表示・非表示の変更
            petGroup.setHidden(false)
            soundInputGroup.setHidden(true)
            checkGroup.setHidden(true)
            genderGroup.setHidden(true)
            checkAllGroup.setHidden(true)
            
            //ペットの表情変更
            setPetExpressionImage("_happy", isSkinEffect: false,isHeadEffect: false)
            
            //しゃべる為の機構
            if flowState == "Player"
            {
                //保存
                statusManager.updateString("playerName", target_string: playerName)
                
                flowState = "Pet"
                sceneState = RegisterState.petTalk
                showMessage("%＜飼い主＞！これからよろしくね！")
            }
            else if flowState == "Pet"
            {
                sceneState  = RegisterState.checkAll
                showMessage("%＜ペット名＞…！%＜飼い主＞ありがとう！")
            }
            break
        case RegisterState.checkAll:
            print("CheckAll")
            //表示・非表示の変更
            petGroup.setHidden(true)
            soundInputGroup.setHidden(true)
            checkGroup.setHidden(true)
            genderGroup.setHidden(true)
            checkAllGroup.setHidden(false)
            
            //記録されているものを表示
            playerNameLabel.setText(playerName)
            petNameLabel.setText(petName)
            if petGender == "man" { petGenderLabel.setText("♂") }
            else { petGenderLabel.setText("♀") }
            
            break
        case RegisterState.tutorial:
            print("Tutorial")
            //表示・非表示の変更
            petGroup.setHidden(false)
            soundInputGroup.setHidden(true)
            checkGroup.setHidden(true)
            genderGroup.setHidden(true)
            checkAllGroup.setHidden(true)
            
            //ペット名保存
            if countForTutorial == 0
            {
                statusManager.updateString("petName", target_string: petName)
            }
            
            //チュートリアルの候補をID２順で表示する
            if countForTutorial+1 <= tutorialMessage.count
            {
                for elementDict in tutorialMessage
                {
                    if elementDict["ID2"] == String(countForTutorial+2)
                    { showMessage(elementDict["sentence"]!) }
                }
            }
            else
            {
                sceneState = RegisterState.fin
                changeScene()
            }
            
            countForTutorial += 1
            
            break
        case RegisterState.fin://入力を保存
            print("Fin")
            
            //保存する機構
            statusManager.updateValue("petgender", target_value: petGenderNum)
            
            statusManager.updateValue("firstOpen",target_value: 1)
            
            //ステータス用の時間リセット、ついでに値も
            statusManager.saveStatus(100*864, sleepStateValue: 100*60*12, funStateValue: 80*720, isSleeping: false, staminaStateValue: 10*900, maxStaminaStateValue: 10*900)
            
            //プレイヤーデータ初期化
            statusManager.resetPlayerData()
            
            //過ごした時間リセット
            statusManager.resetSpendTime()
            
            //単語保存し直す
            WordsManager.deleteAllActivities()
            WordsManager.fillFoodListForFirstLunchApp()
            
            //レコード関係リセット
            statusManager.updateArray("playLog", target_array: [String]())
            
            //装備追加と変更
            if petGender == "man"
            {
                for Id in [1, 101, 201]
                {
                    if !ItemsManager.checkAboutItem(Int16(Id))
                    {
                        updateItem(Int16(Id), consume: 1, amount_diff: 1)
                    }
                    let itemDict = searchItemById(String(Id))
                    itemEffectManager.equipItem(itemDict, type: 1)
                }
            }
            else
            {
                for Id in [2, 102, 202]
                {
                    if !ItemsManager.checkAboutItem(Int16(Id))
                    {
                        updateItem(Int16(Id), consume: 1, amount_diff: 1)
                    }
                    let itemDict = searchItemById(String(Id))
                    itemEffectManager.equipItem(itemDict, type: 1)
                }
            }
            
            WKInterfaceController.reloadRootControllersWithNames(["pet", "status1", "status2", "game", "shop", "item"], contexts: ["", "", "", "", "", ""])
            
            break
        }
    }
    
    
    @IBAction func selectMale()
    {
        if !isPushed
        {
            isPushed = true
            
            print("male")
            petGenderNum = 1
            flowState = "Gender"
            changeScene()
        }
    }
    
    @IBAction func selectFemale()
    {
        if !isPushed
        {
            isPushed = true
            
            print("female")
            petGenderNum = 2
            flowState = "Gender"
            changeScene()
        }
    }
    
    func showMessage(message:String)
    {
        //目パチ
        _ = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: false)
        //メッセージ表示
        petGroup.setHidden(false)
        
        firstLineEnd = 0
        firstLineStart = 0
        secondLineEnd = 0
        secondLineStart = 0
        
        messageArray = [String]()
        let replaceMessage = messageReplace.replaceSentence(message)
        for chara in replaceMessage.characters
        {
            messageArray.append(String(chara))
        }
        addMessage()
    }
    
    //テキストを追加
    func addMessage()
    {
        if firstLineEnd < messageArray.count && secondLineEnd < messageArray.count
        {
            showMessage = ""
            showMessage2 = ""
            if secondLineStart == 0
            {
                for index in firstLineStart...firstLineEnd
                {
                    showMessage += messageArray[index]
                }
                
                if firstLineEnd - firstLineStart >= maxlengthString - 1
                {
                    secondLineStart = maxlengthString
                    secondLineEnd = maxlengthString
                }
                else
                {
                    firstLineEnd += 1
                }
            }
            else
            {
                if secondLineEnd - secondLineStart >= maxlengthString
                {
                    firstLineStart = secondLineStart
                    firstLineEnd = secondLineEnd - 1
                    secondLineStart = secondLineEnd
                    secondLineEnd = secondLineStart
                }
                
                for index in firstLineStart...firstLineEnd
                {
                    showMessage += messageArray[index]
                }
                for index in secondLineStart...secondLineEnd
                {
                    showMessage2 += messageArray[index]
                }
                secondLineEnd += 1
            }
            
            //文字を表示
            let menloFont = UIFont(name: "HiraKakuProN-W6", size: 12.0)!
            let fontAttrs = [NSFontAttributeName : menloFont]
            let attrString = NSAttributedString(string: showMessage, attributes: fontAttrs)
            let attrString2 = NSAttributedString(string: showMessage2, attributes: fontAttrs)
            messageLine1Label.setAttributedText(attrString)
            messageLine2Label.setAttributedText(attrString2)
            
            //再びこの関数を呼び出す
            messageTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "addMessage", userInfo: nil, repeats: false)
        }
        else
        {
            //時間が経過して次のシーンへ
            messageTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeScene", userInfo: nil, repeats: false)
        }
        
    }
    
    func setPetExpressionImage(expressionName:String, isSkinEffect:Bool, isHeadEffect:Bool)
    {
        let petImageDict = statusManager.getPetImageDict()
        
        animationName = petImageDict["petBodyType"]!+expressionName
        
        petMouth.setBackgroundImageNamed(animationName+"_petMouthMumble_")
        petEye.setBackgroundImageNamed(animationName+"_petEyeWink_")
        
        petMouth.startAnimatingWithImagesInRange(NSMakeRange(1, 3), duration: 0.5, repeatCount: 0)
        
        if isSkinEffect
        {
            petSkinEffect.setBackgroundImageNamed(animationName+"_petSkinEffect")
        }
        
        if isHeadEffect
        {
            petHeadEffect.setBackgroundImageNamed(animationName+"_petHeadEffect_")
            petHeadEffect.startAnimatingWithImagesInRange(NSMakeRange(1, 3), duration: 0.5, repeatCount: 0)
        }
    }
    
    //目パチ（自動１回）
    func updateEyeActionOnce()
    {
        petEye.setBackgroundImageNamed(animationName+"_petEyeWink_")
        petEye.startAnimatingWithImagesInRange(NSMakeRange(1, 5), duration: 0.2, repeatCount: 1)
    }
    
    func setPetImage(key:String, value:String)
    {
        switch key
        {
        case "petHairAcce":
            petHairAcce.setBackgroundImageNamed(value)
            break
        case "petEyeAcce":
            petEyeAcce.setBackgroundImageNamed(value)
            break
        case "petCloth":
            petCloth.setBackgroundImageNamed(value)
            break
        case "petHair":
            petHair.setBackgroundImageNamed(value)
            break
        case "petEye":
            petEye.setBackgroundImageNamed(value)
            break
        case "petMouth":
            petMouth.setBackgroundImageNamed(value)
            break
        case "petSkin":
            if value != "Pet_zatugaku_rand_petSkin" && value != "Pet_science_rand_petSkin"
            { petSkin.setBackgroundImageNamed(value) }
            break
        case "petMakeup":
            petMakeup.setBackgroundImageNamed(value)
            break
        default:
            break
        }
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
    
    func searchItemById(idNum: String) -> [String:String]
    {
        for item in allItemsDict
        {
            if item["ItemID"] == idNum { return item }
        }
        return [String:String]()
    }
    
    @IBAction func pushSoundInputButton()
    {
        presentTextInputControllerWithSuggestions(nil, allowedInputMode: WKTextInputMode.Plain)
            { (results) -> Void in
                self.inputTextToLabel("\(results)")
        }
    }
    
    func inputTextToLabel(text:String)
    {
        if text == "nil"
        {
            soundInputLabel.setText("音声の読み込みに失敗しました。もう一度入力してください")
        }
        else if text.characters.count >= 10+12//12はオプショナル分なぜか!つけれない・・・
        {
            soundInputLabel.setText("文字数が9文字を超えています。もう一度入力してください")
        }
        else
        {
            let new_text = text.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: [], range: nil).stringByReplacingOccurrencesOfString(")", withString: "", options: [], range: nil).stringByReplacingOccurrencesOfString("[", withString: "", options: [], range: nil).stringByReplacingOccurrencesOfString("]", withString: "", options: [], range: nil)
            
            if flowState == "Player" { playerName = new_text }
            if flowState == "Pet" { petName = new_text }
            
            soundInputLabel.setText("入力内容は「"+new_text+"」でよろしいでしょうか？")
            determineButton.setEnabled(true)
        }
        print("player:"+text)
    }
    
    @IBAction func determineInput()
    {
        sceneState = RegisterState.check
        changeScene()
    }
    
    @IBAction func debugAction()
    {
        sceneState = RegisterState.check
        changeScene()
    }
    
    @IBAction func selectYes()
    {
        if !isPushed
        {
            isPushed = true
            
            if flowState == "Gender"
            {
                flowState = "Player"
                sceneState = RegisterState.petTalk
            }
            else if flowState == "Pet"
            {
                sceneState = RegisterState.checkAll
            }
            else { sceneState = RegisterState.responce }
            
            changeScene()
        }
    }
    
    @IBAction func selectNo()
    {
        if !isPushed
        {
            isPushed = true
            
            if flowState == "Gender" { sceneState = RegisterState.gender }
            else { sceneState = RegisterState.input }
            soundInputLabel.setText("音声入力から入力してください。")
            changeScene()
        }
    }
    
    @IBAction func selectConfirm()
    {
        sceneState = RegisterState.tutorial
        changeScene()
    }
    
    @IBAction func selectDissconfirm()
    {
        petGender = "man"
        playerName = "にん太郎"
        petName = "Ｑすけ"
        flowState = "Gender"
        
        isPushed = false
        
        sceneState = RegisterState.gender
        changeScene()
    }
    
    
    override func willActivate()
    {
        super.willActivate()
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
    }
}
