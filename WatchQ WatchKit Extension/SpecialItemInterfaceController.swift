//
//  SpecialItemInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/11/19.
//  Copyright © 2015年 Ninja Egg. All rights reserved.
//

import WatchKit
import Foundation


class SpecialItemInterfaceController: WKInterfaceController
{
    //ステータスマネージャー
    let statusManager = StatusManager()
    //メッセージリプレイス
    var messageReplace = MessageReplace()
    //アイテムマネージャー
    var itemEffectManager = ItemEffectManager()
    //csvパース
    var perthCsv = PerthCsv()
    
    //アウトレット
    @IBOutlet var titlelLabel: WKInterfaceLabel!
    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var yesButton: WKInterfaceButton!
    @IBOutlet var noButton: WKInterfaceButton!
    @IBOutlet var soundInputLabel: WKInterfaceLabel!
    @IBOutlet var determineButton: WKInterfaceButton!
    
    //大きいアウトレット
    @IBOutlet var selectButtonGroup: WKInterfaceGroup!
    @IBOutlet var soundInputGroup: WKInterfaceGroup!
    @IBOutlet var selectGroup: WKInterfaceGroup!
    
    //enum
    enum SceneState
    {
        case InitScene
        case GenderSelect
        case NameSelect
        case SoundInput
        case ConfirmInput
        case GenderFinish
        case NameFinish
    }
    
    //変数
    var itemType                =   ""              //アイテム種類
    var sceneState:SceneState   =   .InitScene      //シーンの状態
    var hadPushed               =   false           //同時押しを禁止
    var selectName              =   ""              //変更する名前
    var userInput               =   ""              //ユーザーの入力
    var fromDebug               =   false           //デバッグ用
    var closeSceneTimer:NSTimer!                    //シーン閉じる用のタイマー
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //なんのアイテムか判別する
        itemType = (context as? String)!
        
        if itemType == "7"//性別変更
        {
            sceneState = SceneState.GenderSelect
        }
        else if itemType == "8"//名前変更
        {
            sceneState = SceneState.NameSelect
        }
        else if itemType == "7debug"//デバッグから性別変更
        {
            sceneState = SceneState.GenderSelect
            fromDebug = true
        }
        else if itemType == "8debug"//デバッグから名前変更
        {
            sceneState = SceneState.NameSelect
            fromDebug = true
        }
        else//その他（例外）
        {
            sceneState = SceneState.InitScene
        }
        changeScene()
    }
    
    func changeScene()
    {
        //シーン操作
        switch sceneState
        {
        case SceneState.InitScene:
            //初期値、表示されることはない。つまりエラー
            print("-- init scene --")
            
            //画面変更
            selectGroup.setHidden(false)
            soundInputGroup.setHidden(false)
            selectButtonGroup.setHidden(true)
            
            //メッセージ
            titlelLabel.setText("エラー")
            messageLabel.setText("正しいアイテムが選ばれていません。もう一度アイテム選択からやり直してください。")
            
            break
        case SceneState.GenderSelect:
            //性別選択
            print("-- gender select --")
            
            //画面変更
            selectGroup.setHidden(false)
            soundInputGroup.setHidden(true)
            selectButtonGroup.setHidden(false)
            yesButton.setTitle("はい")
            noButton.setTitle("いいえ")
            
            //メッセージ
            titlelLabel.setText("性別を変更する")
            var messageString = messageReplace.replaceSentence("せいなるこなを１つ使って%＜ペット名＞の性別を")
            if statusManager.loadValue("petgender") == 1
            { messageString += "オスからメスへ変更します。よろしいですか？" }
            else { messageString += "メスからオスへ変更します。よろしいですか？" }
            messageLabel.setText(messageString)
            
            //同時押し対策
            hadPushed = false
            
            break
        case SceneState.GenderFinish:
            //性別変更終了
            print("-- gender finish --")
            
            //画面変更
            selectGroup.setHidden(false)
            soundInputGroup.setHidden(true)
            selectButtonGroup.setHidden(true)
            
            //メッセージ
            let messageString = messageReplace.replaceSentence("%＜ペット名＞の性別が変更されました。")
            messageLabel.setText(messageString)
            
            //性別変更を保存
            var petGender = "man"
            if statusManager.loadValue("petgender") == 1
            {
                petGender = "woman"
                statusManager.updateValue("petgender", target_value: 2)
            }
            else
            {
                petGender = "man"
                statusManager.updateValue("petgender", target_value: 1)
            }
            
            //ペット顔を性別で初期化
            statusManager.initPetImageDict(petGender)
            
            //服装変換
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
            
            //アイテムの消費
            if !fromDebug
            {
                itemEffectManager.useConsumeItem(["ItemID":"901"])
            }
            
            //シーンを閉じる
            closeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "closeScene", userInfo: nil, repeats: false)
            
            break
        case SceneState.NameSelect:
            //変更する名前選択
            print("-- name select --")
            
            //画面変更
            selectGroup.setHidden(false)
            soundInputGroup.setHidden(true)
            selectButtonGroup.setHidden(false)
            
            //メッセージ
            titlelLabel.setText("名前を変更する")
            messageLabel.setText("どちらの名前を変更しますか？")
            yesButton.setTitle("プレイヤー")
            noButton.setTitle("ペット")
            
            //同時押し対策
            hadPushed = false
            
            break
        case SceneState.SoundInput:
            //音声入力
            print("-- sound input --")
            
            //画面変更
            selectGroup.setHidden(true)
            soundInputGroup.setHidden(false)
            selectButtonGroup.setHidden(false)
            
            //入力決定できないようにする
            determineButton.setEnabled(false)
            
            break
        case SceneState.ConfirmInput:
            //確認画面
            print("-- confirm input --")
            
            //画面変更
            selectGroup.setHidden(false)
            soundInputGroup.setHidden(true)
            selectButtonGroup.setHidden(false)
            yesButton.setTitle("はい")
            noButton.setTitle("いいえ")
            
            //メッセージ
            var targetString = ""
            if selectName == "player" { targetString = "ユーザー" }
            else { targetString = "ペット" }
            messageLabel.setText("かいめいのおふだを１つ使って、\(targetString)の名前を「\(userInput)」に変更します。よろしいでしょうか？")
            
            //同時押し対策
            hadPushed = false
            
            break
        case SceneState.NameFinish:
            //名前変更終了
            print("-- name finish --")
            
            //画面変更
            selectGroup.setHidden(false)
            soundInputGroup.setHidden(true)
            selectButtonGroup.setHidden(true)
            
            //メッセージ
            messageLabel.setText("名前を変更しました。")
            
            //名前変更を保存
            if selectName == "player" { statusManager.updateString("playerName", target_string: userInput) }
            else { statusManager.updateString("petName", target_string: userInput) }
            
            //アイテムの消費
            if !fromDebug
            {
                itemEffectManager.useConsumeItem(["ItemID":"1001"])
            }
            
            //シーンを閉じる
            closeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "closeScene", userInfo: nil, repeats: false)
            
            break
        }
    }
    
    //はいボタン選択
    @IBAction func pushYes()
    {
        if !hadPushed
        {
            hadPushed = true
            pushButton(true)
        }
    }
    
    //いいえボタン選択
    @IBAction func pushNo()
    {
        if !hadPushed
        {
            hadPushed = true
            pushButton(false)
        }
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
            
            userInput = new_text
            
            soundInputLabel.setText("入力内容は「"+new_text+"」でよろしいでしょうか？")
            determineButton.setEnabled(true)
        }
        print("Input:"+text)
    }
    
    @IBAction func pushDetermin()
    {
        if userInput != ""
        {
            sceneState = SceneState.ConfirmInput
            changeScene()
        }
    }
    
    func pushButton(isYesPush:Bool)
    {
        print("button is pushed")
        
        switch sceneState
        {
        case SceneState.GenderSelect:
            //性別変更確認
            
            if isYesPush
            {
                sceneState = SceneState.GenderFinish
                changeScene()
            }
            else
            {
                dismissController()
            }
            
            break
        case SceneState.NameSelect:
            //変更対象選択
            //今回はyesでプレイヤー、noでペット
            
            if isYesPush
            {
                selectName = "player"
                sceneState = SceneState.SoundInput
                changeScene()
            }
            else
            {
                selectName = "pet"
                sceneState = SceneState.SoundInput
                changeScene()
            }
            
            break
        case SceneState.ConfirmInput:
            //入力確認
            
            if isYesPush
            {
                sceneState = SceneState.NameFinish
                changeScene()
            }
            else
            {
                sceneState = SceneState.NameSelect
                userInput = ""
                determineButton.setEnabled(false)
                soundInputLabel.setText("音声入力から入力してください")
                changeScene()
            }
            
            break
        default:
            break
        }
    }
    
    //アイテム追加
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
    
    //idで検索
    func searchItemById(idNum: String) -> [String:String]
    {
        let allItemsDict = perthCsv.getAll("items")
        for item in allItemsDict
        {
            if item["ItemID"] == idNum { return item }
        }
        return [String:String]()
    }
    
    //このシーンを閉じてトップへ
    func closeScene()
    {
        WKInterfaceController.reloadRootControllersWithNames(["pet", "status1", "status2", "game", "shop", "item"], contexts: ["", "", "", "", "", ""])
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        //タイマー復活
        if sceneState == SceneState.GenderFinish || sceneState == SceneState.NameFinish
        {
            if !closeSceneTimer.valid
            {
                closeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "closeScene", userInfo: nil, repeats: false)
            }
        }
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
        
        //タイマー破棄
        if closeSceneTimer != nil && closeSceneTimer.valid
        { closeSceneTimer.valid }
    }
}
