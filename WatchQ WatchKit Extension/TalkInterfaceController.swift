//
//  TalkInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/06/26.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation

class TalkInterfaceController: PetBaseInterfaceController
{
    //csvパース
    let perthCsv = PerthCsv()
    //メッセージリプレイス
    var messageReplace = MessageReplace()
    
    //状態enum
    enum TalkState
    {
        case pet
        case player
        case move
    }
    
    //アウトレット
    //入力
    //グループ
    @IBOutlet weak var soundInputGroup: WKInterfaceGroup!
    @IBOutlet weak var selectInputGroup: WKInterfaceGroup!
    //文字
    @IBOutlet weak var soundInputLabel: WKInterfaceLabel!
    //ボタン
    @IBOutlet weak var determineButton: WKInterfaceButton!
    @IBOutlet var yesButton: WKInterfaceButton!
    @IBOutlet var noButton: WKInterfaceButton!
    
    //ペット
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
    
    //大きなアウトレット
    @IBOutlet weak var petGroup: WKInterfaceGroup!
    @IBOutlet weak var inputGroup: WKInterfaceGroup!
    
    
    //変数
    var responseTime:Int = 0//会話のセット数
    var funStateValue = 100//funの数値
    var relationStateValue = 100//relationshipの数値
    var foodStateValue = 100//foodの数値
    var converSession = [[String: String]]()//全会話を入れる辞書
    var petTalkDict = [String: String]()//会話が入る
    var usedWordDict = [String:String]()//会話に使った単語を入れる配列
    var playerInput:String!//プレイヤーの入力
    var wordProperty:String!//学習プロパティー
    var playerState:TalkState = .pet
    
    //変数ペット
    var timerEyeWink:NSTimer!//目パチタイマー（一回）
    var timerEyeWink2:NSTimer!//目パチタイマー（二回）
    
    //変数会話
    var timerMessageClose:NSTimer!//吹き出し削除タイマー
    
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
            petBalloonLabel1: messageLine1Label,
            petBalloonLabel2: messageLine2Label
        )
        
        //ペット画像セット
        let petImageDict = statusManager.getPetImageDict()
        for (key, value) in petImageDict
        { setPetImage(key,value: value) }
        animationName = petImageDict["petBodyType"]!
        
        petBalloon.setBackgroundImageNamed("Pet_default_"+petGender+"_petBalloon")
        
        //初期設定
        WordsManager.fillFoodListForFirstLunchApp()
        
        //funとrelstionshipの値をロードする
        relationStateValue = statusManager.loadValue("relationV")
        funStateValue = statusManager.loadValue("funV")
        foodStateValue = statusManager.loadValue("feedingV")
        
        //名前をセット
        playerName = statusManager.loadString("playerName")
        petName = statusManager.loadString("petName")
        
        //会話回数の記録を更新
        var recordDict = statusManager.loadStringIntDict("recordDict")
        recordDict["petTalkTime"]! += 1
        statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
        
        //プレイヤー入力初期化
        playerInput = ""
        //学習プロパティー初期化
        wordProperty = ""
        
        //会話のテキストを取得
        converSession = perthCsv.filterType("newtalk", type: "type", typeNum: "5")
        
        //ペットのステータス条件に合うものをフィルター
        var statusDict = statusManager.loadStatus(false)
        
        foodStateValue = Int(statusDict["feedingV"]!)
        print("food default:"+String(foodStateValue))
        let sleepStateValue = Int(statusDict["sleepingV"]!/720)
        funStateValue = Int(statusDict["funV"]!)
        let relationshipStateValue = statusDict["relationV"]!
        var isSleeping = false
        if statusDict["isSleeping"] == 0 { isSleeping = false }
        else { isSleeping = true }
        
        converSession = messageReplace.filterByStatus(foodStateValue/864, sleepStateValue: sleepStateValue, funStateValue: funStateValue/720, relationshipStateValue: relationshipStateValue, isSleeping: isSleeping, converSession: converSession)
        
        //会話の一番初めの単語
        var firstSentence = [[String: String]]()
        for item in converSession
        {
            if item["ID1"] != "0"
            {
                firstSentence.append(item)
            }
        }
        
        //一番初めの単語を探す
        let randNum = Int(arc4random_uniform(UInt32(firstSentence.count)))
        let firstItem = firstSentence[randNum]
        displayPetTalk(firstItem["ID2"]!)
        print("---FirstItem---")
        print(firstItem)
    }
    
    func displayPetTalk(Id2String:String)
    {
        //シーンの状態：pet
        playerState = TalkState.pet
        
        //指定されたID2が0なら終了
        if Id2String == "0"
        {
            soundInputGroup.setHidden(true)
            selectInputGroup.setHidden(true)
        }
        else
        {
            //表示の切り替え
            petGroup.setHidden(false)
            inputGroup.setHidden(true)
            
            //petTalkArrayにID2に対応した配列を代入する
            for index in 0...(converSession.count-1)
            {
                let dict = converSession[index]
                if dict["ID2"] == Id2String
                {
                    petTalkDict = converSession[index]
                }
            }
            
            //ペットの文章追加
            addMessageRow(petTalkDict["sentence"]!)
            //表情追加
            setExpressionFromDict(petTalkDict["expression"]!)
            
            //好感度etcの上下
            //fun
            print("fun:"+petTalkDict["fun"]!)
            let funStateIncreace = Int(petTalkDict["fun"]!)
            funStateValue += funStateIncreace!*720
            if funStateValue >= 100*720 { funStateValue = 100*720 }
            statusManager.updateValue("funV", target_value: funStateValue)
            //food
            print("food:"+petTalkDict["food"]!)
            let foodStateIncreace = Int(petTalkDict["food"]!)
            foodStateValue += foodStateIncreace!*864
            if foodStateValue >= 100*864 { foodStateValue = 100*864 }
            statusManager.updateValue("feedingV", target_value: foodStateValue)
            //relation
            print("relation:"+petTalkDict["relation"]!)
            let relationStateIncreace = Int(petTalkDict["relation"]!)
            relationStateValue += relationStateIncreace!
            if relationStateValue >= 100 { relationStateValue = 100 }
            statusManager.updateValue("relationV", target_value: relationStateValue)
            //like
            print(WordsManager.selectProperty(petTalkDict["property"]!))
            if WordsManager.selectProperty(petTalkDict["property"]!) != "all"
            {
                wordProperty = WordsManager.selectProperty(petTalkDict["property"]!)
            }
        }
    }
    
    //ペットメッセージ終わり・プレイヤー入力表示
    override func finishMessage()
    {
        //シーンの状態：player
        playerState = TalkState.player
        
        //表示切り替え
        petGroup.setHidden(true)
        inputGroup.setHidden(false)
        
        //ペット初期化
        messageLine1Label.setText("")
        messageLine2Label.setText("")
        petMouth.stopAnimating()
        petHeadEffect.stopAnimating()
        
        //入力の種類によってボタンの表示を変更
        if petTalkDict["input"]! == "1"//入力なし
        {
            soundInputGroup.setHidden(true)
            selectInputGroup.setHidden(true)
            print("button:1")
            showNextMessage()
        }
        else if petTalkDict["input"]! == "2"//音声
        {
            soundInputGroup.setHidden(false)
            selectInputGroup.setHidden(true)
            determineButton.setHidden(true)
            print("button:2")
        }
        else if petTalkDict["input"]! == "3"//２択
        {
            soundInputGroup.setHidden(true)
            selectInputGroup.setHidden(false)
            print("button:3")
            
            //選択肢変更
            switch petTalkDict["variation"]!
            {
            case "1":
                yesButton.setTitle("はい")
                noButton.setTitle("いいえ")
                break
            case "2":
                yesButton.setTitle("頑張ったね！")
                noButton.setTitle("もっと頑張って")
                break
            case "3":
                yesButton.setTitle("仕方ない")
                noButton.setTitle("嫌だ")
                break
            case "4":
                yesButton.setTitle("賛成")
                noButton.setTitle("反対")
                break
            case "5":
                yesButton.setTitle("可愛がる")
                noButton.setTitle("放置する")
            default:
                break
            }
        }
    }
    
    //プレイヤー入力
    //Yes
    @IBAction func pushYesButton()
    {
        messageReplace.playerInput = "Yes"
        showNextMessage()
    }
    //No
    @IBAction func pushNoButton()
    {
        messageReplace.playerInput = "No"
        showNextMessage()
    }
    //音声入力
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
            //何もしない
            soundInputLabel.setText("音声の読み込みに失敗しました。もう一度入力してください")
            playerInput = "・・・"
        }
        else if text.characters.count >= 10+12//12はオプショナル分なぜか!つけれない・・・
        {
            soundInputLabel.setText("文字数が9文字を超えています。もう一度入力してください")
        }
        else
        {
            let new_text = text.stringByReplacingOccurrencesOfString("Optional(", withString: "", options: [], range: nil).stringByReplacingOccurrencesOfString(")", withString: "", options: [], range: nil).stringByReplacingOccurrencesOfString("[", withString: "", options: [], range: nil).stringByReplacingOccurrencesOfString("]", withString: "", options: [], range: nil)
            messageReplace.playerInput = new_text
            soundInputLabel.setText("入力内容は"+new_text+"でよろしいでしょうか？")
            determineButton.setHidden(false)
        }
        print("player:"+text)
    }
    
    //決定ボタン
    @IBAction func determineInput()
    {
        showNextMessage()
    }
    
    
    //ボタンを押した後の入力と次の会話呼び出し
    func showNextMessage()
    {
        //表示を切り替える
        petGroup.setHidden(false)
        inputGroup.setHidden(true)
        
        //二つのボタンを非表示にする
        soundInputGroup.setHidden(true)
        selectInputGroup.setHidden(true)
        
        //分岐条件によって次呼び出す配列を決定する
        if petTalkDict["divergence"] == "1"//終わり
        {
            print("divCond:1")
            print("show ID2:0")
            showEndMessage()
        }
        else if petTalkDict["divergence"] == "2"//無条件にdiv1
        {
            print("divCond:2")
            print("show ID2:"+petTalkDict["div1"]!)
            displayPetTalk(petTalkDict["div1"]!)
        }
        else if petTalkDict["divergence"] == "3"//ペットが単語を知ってるか
        {
            print("divCond:3")
            //単語があるか判定
            var wordNum:Int = 0 as Int
            let checkWordList = WordsManager.fetchAllWords()
            for item in checkWordList{
                if messageReplace.playerInput == item.word{ wordNum += 1 }
            }
            
            if wordNum >= 1
            {
                print("show ID2:"+petTalkDict["div1"]!)
                displayPetTalk(petTalkDict["div1"]!)
            }
            else
            {
                print("show ID2:"+petTalkDict["div2"]!)
                displayPetTalk(petTalkDict["div2"]!)
            }
        }
        else if petTalkDict["divergence"] == "4"//比較内容がプレーヤー入力と同じか
        {
            print("divCond:4")
            //比較する単語を取得する
            var compareWord = petTalkDict["compare"]!
            //置き換えが必要なら置き換え
            compareWord = messageReplace.replaceSentence(compareWord)
            print("元文字："+compareWord)
            print("入力文字："+messageReplace.playerInput)
            //比較する
            if messageReplace.playerInput == compareWord
            {
                print("show ID2:"+petTalkDict["div1"]!)
                displayPetTalk(petTalkDict["div1"]!)
            }
            else
            {
                print("show ID2:"+petTalkDict["div2"]!)
                displayPetTalk(petTalkDict["div2"]!)
            }
        }
        else if petTalkDict["divergence"] == "5"//yes/noでyes
        {
            print("divCond:5")
            if messageReplace.playerInput == "Yes"
            {
                print("show ID2:"+petTalkDict["div1"]!)
                displayPetTalk(petTalkDict["div1"]!)
            }
            else
            {
                print("show ID2:"+petTalkDict["div2"]!)
                displayPetTalk(petTalkDict["div2"]!)
            }
        }
    }
    
    //会話終了
    func showEndMessage()
    {
        if wordProperty == ""
        {
            dismissController()
            return
        }
        
        //入力された言葉を記憶
        if messageReplace.playerInput != "Yes" || messageReplace.playerInput != "No" || messageReplace.playerInput != ""
        {
            WordsManager.updateWord(messageReplace.playerInput, property: wordProperty, likediff: 0)
        }
        
        //評価を変化させる単語
        let likediff = Int16(Int(petTalkDict["like"]!)!)
        //let targetWord = replaceSentence(petTalkDict["target"]!)
        let targetWord = messageReplace.replaceSentence(petTalkDict["target"]!)
        WordsManager.updateWord(targetWord, property: wordProperty, likediff: likediff)
        
        dismissController()
    }
    
    //テーブルにメッセージ追加
    func addMessageRow(message: String)
    {
        //ペットの吹き出しに文章追加
        let change_message = messageReplace.replaceSentence(message)
        
        messageArray = [String]()
        for char in change_message.characters
        {
            messageArray.append(String(char))
        }
        
        //初期化
        firstLineEnd = 0
        firstLineStart = 0
        secondLineEnd = 0
        secondLineStart = 0
        //吹き出しを表示
        timerMessageClose = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "updateMessage", userInfo: nil, repeats: false)
    }
    
    //showPlayerInputMenu
    
    override func willActivate()
    {
        super.willActivate()
        
        if timerMessageClose != nil && !timerMessageClose.valid && playerState != TalkState.player
        {
            print("move message close timer!!!")
            timerMessageClose = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "updateMessage", userInfo: nil, repeats: false)
        }
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
        
        //タイマーの破棄
        if timerEyeWink != nil && timerEyeWink.valid { timerEyeWink.invalidate() }
        if timerEyeWink2 != nil && timerEyeWink2.valid { timerEyeWink2.invalidate() }
        if timerMessageClose != nil && timerMessageClose.valid && playerState != TalkState.player {
            print("stop timer!!!")
            timerMessageClose.invalidate() }
    }
}
