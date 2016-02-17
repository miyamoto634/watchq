//
//  SpellGridControllerView.swift
//  WatchQ
//
//  Created by H1-157 on 2015/06/22.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class SpellGridInterfaceController: PetBaseInterfaceController
{
    //csvパース
    var perthCsv = PerthCsv()
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    //メッセージリプレイス
    let messageReplace = MessageReplace()
    
    //enum
    enum SGState
    {
        case hint
        case main
        case pet
        case miniResult
        case mainResult
    }
    
    ////// ボードのアウトレット //////
    //ボタンのアウトレット
    @IBOutlet weak var buttonCell1: WKInterfaceButton!
    @IBOutlet weak var buttonCell2: WKInterfaceButton!
    @IBOutlet weak var buttonCell3: WKInterfaceButton!
    @IBOutlet weak var buttonCell4: WKInterfaceButton!
    @IBOutlet weak var buttonCell5: WKInterfaceButton!
    @IBOutlet weak var buttonCell6: WKInterfaceButton!
    @IBOutlet weak var buttonCell7: WKInterfaceButton!
    @IBOutlet weak var buttonCell8: WKInterfaceButton!
    @IBOutlet weak var buttonCell9: WKInterfaceButton!
    
    //ボタンのグループのアウトレット
    @IBOutlet weak var buttonGroup1: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup2: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup3: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup4: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup5: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup6: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup7: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup8: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup9: WKInterfaceGroup!
    
    //ボタンラベルのアウトレット
    @IBOutlet weak var buttonLabel1: WKInterfaceLabel!
    @IBOutlet weak var buttonLabel2: WKInterfaceLabel!
    @IBOutlet weak var buttonLabel3: WKInterfaceLabel!
    @IBOutlet weak var buttonLabel4: WKInterfaceLabel!
    @IBOutlet weak var buttonLabel5: WKInterfaceLabel!
    @IBOutlet weak var buttonLabel6: WKInterfaceLabel!
    @IBOutlet weak var buttonLabel7: WKInterfaceLabel!
    @IBOutlet weak var buttonLabel8: WKInterfaceLabel!
    @IBOutlet weak var buttonLabel9: WKInterfaceLabel!
    
    //タイムバー
    @IBOutlet weak var timeBarImage: WKInterfaceImage!
    @IBOutlet weak var margeGroup: WKInterfaceGroup!
    
    //// 大きいグループのアウトレット ////
    //ボードのアウトレット
    @IBOutlet weak var boardGroup: WKInterfaceGroup!
    //ペットのアウトレット
    @IBOutlet weak var petGroup: WKInterfaceGroup!
    //ミニゲームリザルトのアウトレット
    @IBOutlet weak var miniResultGroup: WKInterfaceGroup!
    //メインリザルトのアウトレット
    @IBOutlet weak var mainResultGroup: WKInterfaceGroup!
    
    
    //// リザルトのアウトレット ////
    //文字
    @IBOutlet weak var leastTimeLabel: WKInterfaceLabel!
    @IBOutlet weak var goldLabel: WKInterfaceLabel!
    @IBOutlet weak var expPointLabel: WKInterfaceLabel!
    @IBOutlet weak var resultLabel: WKInterfaceLabel!
    //画像
    @IBOutlet weak var expBarImage: WKInterfaceImage!
    //マージグループ
    @IBOutlet weak var margeExpGroup: WKInterfaceGroup!
    //仮のもの
    @IBOutlet weak var testLabel: WKInterfaceLabel!
    //// ペットのアウトレット ////
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
    @IBOutlet weak var messageOneLabel: WKInterfaceLabel!
    @IBOutlet weak var messageTwoLabel: WKInterfaceLabel!
    
    //// 変数 ////
    //最後に押したボタン番号
    var lastPushedNum:Int = 0
    
    //全ボタンの状態を格納する辞書
    var allButtonState = [String: Int]()
    //全ボタンに対応する文字を格納する辞書
    var allButtonLetter = [String: String]()
    //選択したボタンを格納する配列
    var selectButtonNum = [Int]()
    
    var gameState = 0//ゲームの状態
    var spellGridAnswer = ""//正解
    var hintText = ""//問題のヒント
    var correctAnswer = ""//正しい回答
    var afterMessageCorrect = ""//終了後メッセージ・正解
    var afterMessageWrong = ""//終了後メッセージ・不正解
    var afterMessageCorrectExpression = ""
    var afterMessageWrongExpression = ""
    
    var playerLevel = 1//プレイヤーのレベル
    var playerExp = 0//プレイヤーの経験値
    var playerExpBefore = 0//ゲーム前のプレイヤーの経験値
    var playerGoldAmount = 0//プレイヤーの所持ゴールド
    var playerFun = 100
    var playerFriendship = 100
    var leastTimer:NSTimer!//残り時間のタイマー
    var changeSceneTimer:NSTimer!//シーン遷移タイマー
    var resultTimer:NSTimer!//結果シーンタイマー
    var eyeWinkTimer:NSTimer!//目パチタイマー
    var leastTimeValue = 20.0//残り時間の値
    var maxBarWidth = 125.0//バーの最大の大きさ
    var maxExpPoint = 0.0
    
    var gameWin = false//ゲーム勝利判定
    var isTimeOver = false//時間オーバー判定
    
    var gameSGState:SGState = .hint//ゲームの状態
    
    //定数
    let eyeCloseInterval:NSTimeInterval = 0.2//目ぱち間隔
    
    //色々面倒なので
    var blockNo1 = [2, 4]
    var blockNo2 = [1, 3, 4, 6]
    var blockNo3 = [2, 6]
    var blockNo4 = [1, 2, 7, 8]
    var blockNo5 = [1, 2, 3, 4, 6, 7, 8, 9]
    var blockNo6 = [2, 3, 8, 9]
    var blockNo7 = [4, 8]
    var blockNo8 = [4, 6, 7, 9]
    var blockNo9 = [6, 8]
    var allBlock = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    var isBlock5HasChar = false
    var enCharacters:[Character] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var jaCharacters:[Character] = ["あ","い","う","え","お","か","き","く","け","こ","さ","し","す","せ","そ","た","ち","つ","て","と","な","に","ぬ","ね","の","は","ひ","ふ","へ","ほ","ま","み","む","め","も","や","ゆ","よ","ら","り","る","れ","ろ","わ","を","ん","が","ぎ","ぐ","げ","ご","ざ","じ","ず","ぜ","ぞ","だ","ぢ","づ","で","ど","ば","び","ぶ","べ","ぼ","ぱ","ぴ","ぷ","ぺ","ぽ","ゃ","ゅ","ょ","っ"]
    var kanaCharacters:[Character] = ["ア","イ","ウ","エ","オ","カ","キ","ク","ケ","コ","サ","シ","ス","セ","ソ","タ","チ","ツ","ツ","ト","ナ","ニ","ヌ","ネ","ノ","ハ","ヒ","フ","ヘ","ホ","マ","ミ","ム","メ","モ","ヤ","ユ","ヨ","ラ","リ","ル","レ","ロ","ワ","ヲ","ン","ガ","ギ","グ","グ","ゲ","ゴ","ザ","ジ","ズ","ゼ","ゾ","ダ","ヂ","ヅ","デ","ド","パ","ピ","プ","ペ","ポ","ャ","ュ","ョ","ッ"]
    var characters:[Character] = [Character]()
    
    
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
            petBalloonLabel1: messageOneLabel,
            petBalloonLabel2: messageTwoLabel
        )
        
        //画面サイズを取得、タイムバーの長さ設定
        let currentDevice = WKInterfaceDevice.currentDevice()
        let bounds = currentDevice.screenBounds
        if bounds.width > 136.0 {
            maxBarWidth = 149.0
            margeGroup.setWidth(2.5)
            margeExpGroup.setWidth(2.5)
        } else {
            maxBarWidth = 130.0
            margeGroup.setWidth(2.0)
            margeExpGroup.setWidth(2.0)
        }
        
        //ペットの発言
        let AMCArray = ["次はもっと難しいのを用意しておくよ", "流石%＜飼い主＞だな～", "%＜飼い主＞物知り～", "%＜飼い主＞はこれも分かるんだね！"]
        let AMCDExpress = ["7","5","11","2"]
        let AMWArray = ["勝った～！", "難しすぎたかな？", "%＜ペット名＞はわかると思ったんだけどな～", "えへへ、勝っちゃった！"]
        let AMWDExpress = ["2","5","2","2"]
        let randNumCorrect = Int(arc4random_uniform(UInt32(AMCArray.count)))
        let randNumWrong = Int(arc4random_uniform(UInt32(AMWArray.count)))
        afterMessageCorrect = AMCArray[randNumCorrect]
        afterMessageWrong = AMWArray[randNumWrong]
        afterMessageCorrectExpression = AMCDExpress[randNumCorrect]
        afterMessageWrongExpression = AMWDExpress[randNumCorrect]
        
        //レベル、経験値読み込み
        playerLevel = statusManager.loadValue("levelV")
        playerExp = statusManager.loadValue("experienceV")
        playerGoldAmount = statusManager.loadValue("goldenAmount")
        playerExpBefore = playerExp
        playerFun = Int(statusManager.loadValue("funV")/720)
        playerFriendship = statusManager.loadValue("frendshipV")
        print("saved_exp:"+String(playerExp))
        
        //ペットのイメージ名
        if statusManager.loadValue("petgender") == 1 { petGender = "man" }
        else { petGender = "woman" }
        
        petBalloon.setBackgroundImageNamed("Pet_default_"+petGender+"_petBalloon")
        
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
        
        //ここで問題を決定する処理を行う
        let rand = randomInt(1, max: 100)
        let spellGridDict = perthCsv.getType("spellgrid", type:"ID", typeNum:String(rand))
        hintText = spellGridDict["Hint"]!
        correctAnswer = spellGridDict["Answer"]!
        switch spellGridDict["Category"]!
        {
        case "0":
            characters = enCharacters
            break
        case "1":
            characters = jaCharacters
            break
        case "2":
            characters = kanaCharacters
            break
        default:
            break
        }
        
        //初期化
        gameState = 0
        gameSGState = SGState.hint
        leastTimeValue = 20.0
        
        //タイムバー初期化
        timeBarImage.setWidth(CGFloat(maxBarWidth))
        
        //シーン変化
        changeScene()
    }
    
    //シーン遷移
    func changeScene(){
        switch gameState
        {
        case 0:
            //ヒント
            boardGroup.setHidden(true)
            miniResultGroup.setHidden(true)
            mainResultGroup.setHidden(true)
            showMessage(hintText)
            gameState += 1
            changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeScene", userInfo: nil, repeats: false)
            break
        case 1:
            //ボード
            gameSGState = SGState.main
            boardGroup.setHidden(false)
            petGroup.setHidden(true)
            miniResultGroup.setHidden(true)//note:念のため
            mainResultGroup.setHidden(true)//note:念のため
            gameState += 1
            initGame(correctAnswer)
            break
        case 2:
            //メッセ
            gameSGState = SGState.pet
            boardGroup.setHidden(true)
            miniResultGroup.setHidden(true)//note:念のため
            mainResultGroup.setHidden(true)//note:念のため
            gameWin = finishSpellGrid()
            if gameWin
            {
                showMessage(afterMessageCorrect)
                setExpressionFromDict(afterMessageCorrectExpression)
            }
            else
            {
                showMessage(afterMessageWrong)
                setExpressionFromDict(afterMessageWrongExpression)
            }
            gameState += 1
            changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeScene", userInfo: nil, repeats: false)
            break
        case 3:
            //ゲームリザルト
            gameSGState = SGState.miniResult
            boardGroup.setHidden(true)//note:念のため
            miniResultGroup.setHidden(false)
            mainResultGroup.setHidden(true)//note:念のため
            petGroup.setHidden(true)
            
            //タイマーの停止
            if leastTimer.valid { leastTimer.invalidate() }
            
            //色々計算・保存
            var gold_increase = 0
            var exp_increase = 0
            if gameWin
            {
                resultLabel.setText("成功！")
                gold_increase = Int(40.0*(1+(Double(playerLevel)-1.0)*0.1))
                exp_increase = 100
                statusManager.addValue("funV", add_value: 3*720)
            }
            else
            {
                resultLabel.setText("失敗…")
                gold_increase = Int(10.0*(1+(Double(playerLevel)-1.0)*0.1))
                exp_increase = 10
            }
            
            let leastTime_last2:String = String(format:"%.2f", leastTimeValue)
            var calcArray = statusManager.calcExpGoldPoint("spell", expBase: exp_increase, goldBase: gold_increase, bounusPoint: 0)
            
            if playerLevel >= 10
            {
                calcArray[0] = 0
                calcArray[1] *= 2
            }
            
            leastTimeLabel.setText(leastTime_last2+"秒")
            goldLabel.setText("+"+String(calcArray[1]))
            expPointLabel.setText("+"+String(calcArray[0]))
            
            //保存
            print("cal exp:"+String(calcArray[0]))
            print("cal gold:"+String(calcArray[1]))
            playerExp += calcArray[0]
            playerGoldAmount += calcArray[1]
            statusManager.updateValue("experienceV", target_value: playerExp)
            statusManager.updateValue("goldenAmount", target_value: playerGoldAmount)
            
            //変化
            itemEffectManager.changePetImage(2, newLog: ["default" ,"default" ,"default"])
            
            //解放
            statusManager.increaceValue("spellGrid",increaceValue: 1)
            
            //記録
            var recordDict = statusManager.loadStringIntDict("recordDict")
            recordDict["spellGridPlayed"]! += 1
            if gameWin { recordDict["spellGridCorrect"]! += 1 }
            statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
            
            //シーン移動
            gameState += 1
            changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeScene", userInfo: nil, repeats: false)
            break
        case 4:
            //メインリザルト
            gameSGState = SGState.mainResult
            boardGroup.setHidden(true)//note:念のため
            miniResultGroup.setHidden(true)
            mainResultGroup.setHidden(false)
            petGroup.setHidden(true)//note:念のため
            
            //バーのアニメーション
            maxExpPoint = perthCsv.getMaxExp(playerLevel)
            print("max exp:"+String(maxExpPoint))
            if maxExpPoint < 0.0
            {
                expBarImage.setWidth(CGFloat(maxBarWidth))
                resultTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "gotoTop", userInfo: nil, repeats: false)
            }
            else
            {
                print(String(stringInterpolationSegment: maxBarWidth), terminator: "")
                print("max:"+String(stringInterpolationSegment: maxExpPoint))
                let timeBarSize = CGFloat((Double(playerExpBefore)/maxExpPoint)*maxBarWidth)
                expBarImage.setWidth(timeBarSize)
                resultTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "updateBar", userInfo: nil, repeats: false)
            }
            break
        default:
            break
        }
    }
    
    //バーの長さを更新
    func updateBar()
    {
        playerExpBefore += 5*playerLevel
        let maxExpPoint = perthCsv.getMaxExp(playerLevel)
        if playerExpBefore >= playerExp
        {
            if Int(maxExpPoint) <= playerExpBefore
            {
                testLabel.setText("Rank Up!")
                playerExp -= playerExpBefore
                playerExpBefore = 0
                playerLevel += 1
            }
            if maxExpPoint < 0.0
            {
                expBarImage.setWidth(CGFloat(maxBarWidth))
                resultTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "gotoTop", userInfo: nil, repeats: false)
            }
            else
            {
                let timeBarSize = CGFloat((Double(playerExpBefore)/maxExpPoint)*maxBarWidth)
                expBarImage.setWidth(timeBarSize)
                print("finish all")
                print("bf:"+String(playerExpBefore))
                print("exp:"+String(playerExp))
                resultTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "gotoTop", userInfo: nil, repeats: false)
            }
        }
        else
        {
            if Int(maxExpPoint) <= playerExpBefore
            {
                testLabel.setText("Rank Up!")
                playerExp -= playerExpBefore
                playerExpBefore = 0
                playerLevel += 1
            }
            if maxExpPoint < 0.0
            {
                expBarImage.setWidth(CGFloat(maxBarWidth))
                resultTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "gotoTop", userInfo: nil, repeats: false)
            }
            else
            {
                let timeBarSize = CGFloat((Double(playerExpBefore)/maxExpPoint)*maxBarWidth)
                expBarImage.setWidth(timeBarSize)
                resultTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "updateBar", userInfo: nil, repeats: false)
            }
        }
    }
    
    func gotoTop()
    {
        let probableNum:Double = Double(playerFun/5) - Double(playerFriendship/10)
        let randNum = Int(arc4random_uniform(1000))
        
        if Double(randNum) <= probableNum*10
        {
            WKInterfaceController.reloadRootControllersWithNames(["pet", "status1", "status2", "game", "shop", "item"], contexts: ["pettalk", "", "", "", "", ""])
        }
        else
        {
            WKInterfaceController.reloadRootControllersWithNames(["pet", "status1", "status2", "game", "shop", "item"], contexts: ["", "", "", "", "", ""])
        }
    }
    
    //制限時間減少
    func decreaseLeastTime()
    {
        leastTimeValue -= 0.2
        let barWidth = CGFloat(leastTimeValue*maxBarWidth/20.0)
        timeBarImage.setWidth(barWidth)
        //timeBarImage.setWidth(CGFloat(maxBarWidth))
        if leastTimeValue < 0.2
        {
            if leastTimer.valid == true { leastTimer.invalidate() }
            isTimeOver = true
            changeScene()
        }
    }
    
    func initGame(answer: String)
    {
        //文字とか
        spellGridAnswer = answer
        
        //ボードに文字を追加する
        initBoard(spellGridAnswer)
        
        //最後に押したボタン初期化
        lastPushedNum = 0
        //状態の辞書初期化
        allButtonState = [String:Int]()//念のため全削除
        allButtonState["buttonCell1"] = 0
        allButtonState["buttonCell2"] = 0
        allButtonState["buttonCell3"] = 0
        allButtonState["buttonCell4"] = 0
        allButtonState["buttonCell5"] = 0
        allButtonState["buttonCell6"] = 0
        allButtonState["buttonCell7"] = 0
        allButtonState["buttonCell8"] = 0
        allButtonState["buttonCell9"] = 0
        
        //色を設定
        for (key, _) in allButtonState
        {
            updateButtonColor(key)
        }
        
        //タイマー起動
        leastTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "decreaseLeastTime", userInfo: nil, repeats: true)
    }
    
    ////////////////////盤面初期化の処理/////////////////////
    
    func initBoard(targetString: String)
    {
        //初期値で選択するブロックたち。いらないかも
        let cornersBlock = [1, 3, 7, 9]
        let except5Block = [1, 2, 3, 4, 6, 7, 8, 9]
        allBlock = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        blockNo1 = [2, 4]
        blockNo2 = [1, 3, 4, 6]
        blockNo3 = [2, 6]
        blockNo4 = [1, 2, 7, 8]
        blockNo5 = [1, 3, 7, 9]//多分問題はないはず。あれば修正
        blockNo6 = [2, 3, 8, 9]
        blockNo7 = [4, 8]
        blockNo8 = [4, 6, 7, 9]
        blockNo9 = [6, 8]
        isBlock5HasChar = false
        var lastSelectNum = 0
        
        //選んだ数字の配列
        var selectArray = [Int]()
        
        //対象の文字列の文字数を求める
        let wordLength = targetString.characters.count
        
        //選べるボタンを文字数まで選択し続ける
        for index in 1...wordLength
        {
            if lastSelectNum == 0//初期値
            {
                print("--init--")
                if wordLength <= 4//どこでも選択か
                {
                    let rand = randomInt(0, max: 8)
                    lastSelectNum = allBlock[rand]
                }
                else if wordLength <= 6//真ん中以外選択する
                {
                    let rand = randomInt(0, max: 7)
                    lastSelectNum = except5Block[rand]
                }
                else//四隅のみ選択する
                {
                    let rand = randomInt(0, max: 3)
                    lastSelectNum = cornersBlock[rand]
                }
                //配列に追加
                print("add:"+String(lastSelectNum))
                selectArray.append(lastSelectNum)
                deleteNumber(lastSelectNum)
            }
            else if lastSelectNum == 1
            {
                let num = selectNextChara(blockNo1, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                print("add:"+String(num))
            }
            else if lastSelectNum == 2
            {
                let num = selectNextChara(blockNo2, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                print("add:"+String(num))
            }
            else if lastSelectNum == 3
            {
                let num = selectNextChara(blockNo3, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                print("add:"+String(num))
            }
            else if lastSelectNum == 4
            {
                let num = selectNextChara(blockNo4, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                print("add:"+String(num))
            }
            else if lastSelectNum == 5
            {
                let num = selectNextChara(blockNo5, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                isBlock5HasChar = true
                print("add:"+String(num))
            }
            else if lastSelectNum == 6
            {
                let num = selectNextChara(blockNo6, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                print("add:"+String(num))
            }
            else if lastSelectNum == 7
            {
                let num = selectNextChara(blockNo7, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                print("add:"+String(num))
            }
            else if lastSelectNum == 8
            {
                let num = selectNextChara(blockNo8, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                print("add:"+String(num))
            }
            else if lastSelectNum == 9
            {
                let num = selectNextChara(blockNo9, index: index, wordLength: wordLength)
                lastSelectNum = num
                selectArray.append(num)
                deleteNumber(num)
                print("add:"+String(num))
            }
        }
        
        //決められた文字をボードに反映させる
        var stringArray = Array(targetString.characters)
        for index in 0...wordLength-1
        {
            setCharaToButton(selectArray[index], chara: stringArray[index])
        }
        
        //残りをランダムに埋める
        for item in allBlock
        {
            let randChara = randomInt(0, max: characters.count - 1)
            setCharaToButton(item, chara: characters[randChara])
        }
    }
    
    //ボタンに文字を追加する
    func setCharaToButton(num: Int, chara: Character)
    {
        //最後にランダムに選ぶ候補の文字から削除
        for (index, each_chara) in characters.enumerate()
        {
            if each_chara == chara
            {
                characters.removeAtIndex(index)
            }
        }
        //文字をセット
        switch num
        {
        case 1:
            buttonLabel1.setText(String(chara))
            allButtonLetter["buttonCell1"] = String(chara)
            break
        case 2:
            buttonLabel2.setText(String(chara))
            allButtonLetter["buttonCell2"] = String(chara)
            break
        case 3:
            buttonLabel3.setText(String(chara))
            allButtonLetter["buttonCell3"] = String(chara)
            break
        case 4:
            buttonLabel4.setText(String(chara))
            allButtonLetter["buttonCell4"] = String(chara)
            break
        case 5:
            buttonLabel5.setText(String(chara))
            allButtonLetter["buttonCell5"] = String(chara)
            break
        case 6:
            buttonLabel6.setText(String(chara))
            allButtonLetter["buttonCell6"] = String(chara)
            break
        case 7:
            buttonLabel7.setText(String(chara))
            allButtonLetter["buttonCell7"] = String(chara)
            break
        case 8:
            buttonLabel8.setText(String(chara))
            allButtonLetter["buttonCell8"] = String(chara)
            break
        case 9:
            buttonLabel9.setText(String(chara))
            allButtonLetter["buttonCell9"] = String(chara)
            break
        default:
            break
        }
    }
    
    //候補から選択する
    func selectNextChara(var arrayBlocks: [Int], index: Int, wordLength: Int) -> Int
    {
        if arrayBlocks.count > 0
        {
            if index == wordLength && wordLength != 9 && isBlock5HasChar == false
            {
                arrayBlocks.append(5)
            }
            
            let rand = randomInt(0, max: arrayBlocks.count - 1)
            return arrayBlocks[rand]
        }
        else if isBlock5HasChar == false
        {
            return 5
        }
        return 10
    }
    
    //可能性辞書から選択された数字を削除
    func deleteNumber(blockNo: Int)
    {
        deleteNumberFromArray(&blockNo1, blockNo1: blockNo)
        deleteNumberFromArray(&blockNo2, blockNo1: blockNo)
        deleteNumberFromArray(&blockNo3, blockNo1: blockNo)
        deleteNumberFromArray(&blockNo4, blockNo1: blockNo)
        deleteNumberFromArray(&blockNo5, blockNo1: blockNo)
        deleteNumberFromArray(&blockNo6, blockNo1: blockNo)
        deleteNumberFromArray(&blockNo7, blockNo1: blockNo)
        deleteNumberFromArray(&blockNo8, blockNo1: blockNo)
        deleteNumberFromArray(&blockNo9, blockNo1: blockNo)
        deleteNumberFromArray(&allBlock, blockNo1: blockNo)
        
    }
    
    //配列から数字を消す
    func deleteNumberFromArray(inout blockNoArray : [Int], blockNo1: Int)
    {
        if(blockNoArray.count > 0)
        {
            for index122 in 0...blockNoArray.count - 1
            {
                if(blockNoArray[index122] == blockNo1)
                {
                    blockNoArray.removeAtIndex(index122);
                    break;
                }
            }
        }
    }
    
    ////////////////////盤面初期化の処理/////////////////////
    
    //ボタンを押した時の処理
    @IBAction func buttonAction1() { selectProcess(1) }
    @IBAction func buttonAction2() { selectProcess(2) }
    @IBAction func buttonAction3() { selectProcess(3) }
    @IBAction func buttonAction4() { selectProcess(4) }
    @IBAction func buttonAction5() { selectProcess(5) }
    @IBAction func buttonAction6() { selectProcess(6) }
    @IBAction func buttonAction7() { selectProcess(7) }
    @IBAction func buttonAction8() { selectProcess(8) }
    @IBAction func buttonAction9() { selectProcess(9) }
    
    //メニューの処理
    @IBAction func endSpell()
    {
        if gameState == 2
        {
            print("---finish---")
            //最後に押したボタンを緑にする
            let newLastKey = "buttonCell" + String(lastPushedNum)
            if lastPushedNum != 0 { changeState(newLastKey, changeType: "increase") }
            if leastTimer.valid { leastTimer.invalidate() }
            //終了画面へ
            changeScene()
        }
    }
    
    //長押しバージョンの処理決定
    func selectProcess(pushNum: Int)
    {
        let newKey = "buttonCell" + String(pushNum)
        checkButtonCanPush(newKey, pushNum: pushNum)
    }
    
    ////////////////////ボタンの処理/////////////////////
    
    //押せるか判定
    func checkButtonCanPush(key: String, pushNum: Int)
    {
        let stateNum = allButtonState[key]
        print("last:"+String(stringInterpolationSegment: lastPushedNum))
        print("push:"+String(stringInterpolationSegment: pushNum))
        print("state:"+String(stringInterpolationSegment: stateNum))
        
        if lastPushedNum == 0
        {
            print("---first push---")
            //押した時処理
            selectButtonNum.append(pushNum)
            lastPushedNum = pushNum
            //押したボタンを先頭に変更
            let newKey = "buttonCell" + String(lastPushedNum)
            changeState(newKey, changeType: "increase")
            updateConection(newKey, arrowType: "arrow0")
        }
        else
        {
            if stateNum == 0//押されていない
            {
                //範囲内か判定
                if checkButtonInRange(lastPushedNum, push: pushNum)
                {
                    print("---can push---")
                    //押される前の先頭を緑に変更
                    let lastKey = "buttonCell" + String(lastPushedNum)
                    changeState(lastKey, changeType: "increase")
                    //２つのコネクションを作成
                    changeConection(lastPushedNum, pushNum: pushNum, changeType: "add")
                    //押した時処理
                    selectButtonNum.append(pushNum)
                    lastPushedNum = pushNum
                    //押したボタンを先頭に変更
                    let newKey = "buttonCell" + String(lastPushedNum)
                    changeState(newKey, changeType: "increase")
                }
            }
            
            if stateNum == 1//最後に選択した
            {
                print("---cancel---")
                //押したボタンをグレーに
                let newKey = "buttonCell" + String(pushNum)
                changeState(newKey, changeType: "decrease")
                //押したボタンを配列から削除
                selectButtonNum.removeLast()
                //lastPushNumを変更
                if !selectButtonNum.isEmpty
                {
                    //前のボタンの状態を下げる
                    lastPushedNum = selectButtonNum[selectButtonNum.count-1]
                    let newLastKey = "buttonCell" + String(lastPushedNum)
                    changeState(newLastKey, changeType: "decrease")
                    //２つのコネクションを削除
                    changeConection(lastPushedNum, pushNum: pushNum, changeType: "delete")
                }
                else
                {
                    lastPushedNum = 0
                    let pushKey = "buttonCell" + String(pushNum)
                    updateConection(pushKey, arrowType: "delete")
                }
            }
        }
    }
    
    //範囲内にあるか判定
    func checkButtonInRange(last: Int, push: Int) -> Bool
    {
        if last % 3 == 0//右側
        {
            let range = [last-4, last-3, last-1, last+2, last+3]
            for item in range
            {
                if push == item { return true }
            }
        }
        if last % 3 == 1//左側
        {
            let range = [last-3, last-2, last+1, last+3, last+4]
            for item in range
            {
                if push == item { return true }
            }
        }
        if last % 3 == 2//中央
        {
            if push <= last+4 && push >= last-4 { return true }
        }
        return false
    }
    
    
    //状態、ボタンの色を変更する
    func changeState(key:String, changeType:String)
    {
        if changeType == "increase"//増加
        {
            let tmpState = allButtonState[key]
            allButtonState[key] = tmpState! + 1
            updateButtonColor(key)
            
        }
        else if changeType == "decrease"//減少
        {
            let tmpState = allButtonState[key]
            allButtonState[key] = tmpState! - 1
            updateButtonColor(key)
        }
    }
    
    //keyからボタンの色を更新する
    func updateButtonColor(key: String)
    {
        switch key
        {
        case "buttonCell1":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup1.setBackgroundColor(newColor)
            break
        case "buttonCell2":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup2.setBackgroundColor(newColor)
            break
        case "buttonCell3":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup3.setBackgroundColor(newColor)
            break
        case "buttonCell4":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup4.setBackgroundColor(newColor)
            break
        case "buttonCell5":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup5.setBackgroundColor(newColor)
            break
        case "buttonCell6":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup6.setBackgroundColor(newColor)
            break
        case "buttonCell7":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup7.setBackgroundColor(newColor)
            break
        case "buttonCell8":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup8.setBackgroundColor(newColor)
            break
        case "buttonCell9":
            let newColor = getColor(allButtonState[key]!)
            buttonGroup9.setBackgroundColor(newColor)
            break
        default:
            break
        }
    }
    
    //状態から指定された色を返す
    func getColor(stateNum: Int) -> UIColor
    {
        if stateNum == 0{ return UIColor.darkGrayColor() }
        if stateNum == 1{ return UIColor.redColor() }
        if stateNum == 2{ return UIColor.greenColor() }
        return UIColor.darkGrayColor()
    }
    
    ////////////////////ボタンの処理////////////////////
    
    ///////////////////コネクションの処理///////////////////
    
    //コネクションの変更
    func changeConection(lastNum: Int, pushNum: Int, changeType: String)
    {
        let lastKey = "buttonCell" + String(lastNum)
        let pushKey = "buttonCell" + String(pushNum)
        
        if changeType == "add"
        {
            updateConection(pushKey, arrowType: "arrow0")
            let setArrowType = searchArrow(lastNum, pushNum: pushNum)
            updateConection(lastKey, arrowType: setArrowType)
        }
        else if changeType == "delete"
        {
            updateConection(pushKey, arrowType: "delete")
            updateConection(lastKey, arrowType: "arrow0")
        }
    }
    
    //コネクション更新
    func updateConection(key: String, arrowType: String)
    {
        switch key
        {
        case "buttonCell1":
            setBG(buttonGroup1, arrowType: arrowType)
            break
        case "buttonCell2":
            setBG(buttonGroup2, arrowType: arrowType)
            break
        case "buttonCell3":
            setBG(buttonGroup3, arrowType: arrowType)
            break
        case "buttonCell4":
            setBG(buttonGroup4, arrowType: arrowType)
            break
        case "buttonCell5":
            setBG(buttonGroup5, arrowType: arrowType)
            break
        case "buttonCell6":
            setBG(buttonGroup6, arrowType: arrowType)
            break
        case "buttonCell7":
            setBG(buttonGroup7, arrowType: arrowType)
            break
        case "buttonCell8":
            setBG(buttonGroup8, arrowType: arrowType)
            break
        case "buttonCell9":
            setBG(buttonGroup9, arrowType: arrowType)
            break
        default:
            break
        }
    }
    
    //削除or追加判定
    func setBG(btnGroup: WKInterfaceGroup, arrowType: String)
    {
        if arrowType == "delete"
        {
            btnGroup.setBackgroundImage(nil)
            print("delete")
        }
        else
        {
            btnGroup
                .setBackgroundImageNamed(arrowType)
        }
    }
    
    //矢印を判定
    func searchArrow(lastNum: Int, pushNum: Int) -> String
    {
        let diff = lastNum - pushNum
        switch diff
        {
        case -4:
            return "arrow4"
        case -3:
            return "arrow5"
        case -2:
            return "arrow6"
        case -1:
            return "arrow3"
        case 0:
            return "arrow0"
        case 1:
            return "arrow7"
        case 2:
            return "arrow2"
        case 3:
            return "arrow1"
        case 4:
            return "arrow8"
        default:
            return "arrow0"
        }
    }
    
    ///////////////////コネクションの処理///////////////////
    
    //終了処理
    func finishSpellGrid() -> Bool
    {
        if isTimeOver { return false }
        
        if selectButtonNum.count == 0
        {
            return false
        }
        
        var answerText:String = ""
        
        for item in selectButtonNum
        {
            let newKey = "buttonCell" + String(item)
            answerText += allButtonLetter[newKey]!
        }
        print(answerText)
        
        if answerText == spellGridAnswer { return true }
        else { return false }
    }
    
    //メッセージ表示
    func showMessage(message:String)
    {
        //目パチ
        eyeWinkTimer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: false)
        //メッセージ表示
        petGroup.setHidden(false)
        let repMessage = messageReplace.replaceSentence(message)
        let menloFont = UIFont(name: "HiraKakuProN-W6", size: 12.0)!
        let fontAttrs = [NSFontAttributeName : menloFont]
        let attrString = NSAttributedString(string: repMessage, attributes: fontAttrs)
        messageOneLabel.setAttributedText(attrString)
    }
    
    //目パチ（自動１回）
    func updateEyeActionOnce()
    {
        if petWink
        {
            petEye.setBackgroundImageNamed(animationName+"_petEyeWink_")
            petEye.startAnimatingWithImagesInRange(NSMakeRange(1, 5), duration: eyeCloseInterval, repeatCount: 1)
        }
    }
    
    //ランダムの数を返す
    func randomInt(min: Int, max:Int) -> Int
    {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        //ゲーム再開
        switch gameSGState
        {
        case SGState.hint:
            if !changeSceneTimer.valid
            {
                gameState = 1
                changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeScene", userInfo: nil, repeats: false)
                print("hint")
            }
            break
        case SGState.main:
            if !leastTimer.valid
            {
                leastTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "decreaseLeastTime", userInfo: nil, repeats: true)
                print("main")
            }
            break
        case SGState.pet:
            if !changeSceneTimer.valid
            {
                gameState = 3
                changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeScene", userInfo: nil, repeats: false)
                print("pet")
            }
            break
        case SGState.miniResult:
            if !changeSceneTimer.valid
            {
                gameState = 4
                changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeScene", userInfo: nil, repeats: false)
                print("mini")
            }
            break
        case SGState.mainResult:
            if !resultTimer.valid
            {
                resultTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "updateBar", userInfo: nil, repeats: false)
                print("result")
            }
            break
        }
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
        //タイマーの破棄
        if leastTimer != nil && leastTimer.valid { leastTimer.invalidate() }
        if eyeWinkTimer != nil && eyeWinkTimer.valid { eyeWinkTimer.invalidate() }
        if changeSceneTimer != nil && changeSceneTimer.valid { changeSceneTimer.invalidate() }
        if resultTimer != nil && resultTimer.valid { resultTimer.invalidate() }
    }
}
