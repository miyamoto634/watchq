//
//  TicTacToInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/06/22.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class TicTacToeInterfaceController: PetBaseInterfaceController
{
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    //メッセージリプレイス
    let messageReplace = MessageReplace()
    //パース
    let perthCsv = PerthCsv()
    
    //enum
    enum TTTState
    {
        case start
        case main
        case pet
        case miniResult
        case mainResult
    }
    
    /////// ボードのアウトレット ///////
    //ボタンのoutletを登録
    @IBOutlet weak var buttonR1C1: WKInterfaceButton!
    @IBOutlet weak var buttonR1C2: WKInterfaceButton!
    @IBOutlet weak var buttonR1C3: WKInterfaceButton!
    @IBOutlet weak var buttonR2C1: WKInterfaceButton!
    @IBOutlet weak var buttonR2C2: WKInterfaceButton!
    @IBOutlet weak var buttonR2C3: WKInterfaceButton!
    @IBOutlet weak var buttonR3C1: WKInterfaceButton!
    @IBOutlet weak var buttonR3C2: WKInterfaceButton!
    @IBOutlet weak var buttonR3C3: WKInterfaceButton!
    
    //グループのアウトレット
    @IBOutlet weak var boardGroup: WKInterfaceGroup!
    @IBOutlet weak var miniGameResultGroup: WKInterfaceGroup!
    @IBOutlet weak var resultGroup: WKInterfaceGroup!
    @IBOutlet weak var petGroup: WKInterfaceGroup!
    
    //画像のアウトレット
    @IBOutlet weak var imageR1C1: WKInterfaceImage!
    @IBOutlet weak var imageR1C2: WKInterfaceImage!
    @IBOutlet weak var imageR1C3: WKInterfaceImage!
    @IBOutlet weak var imageR2C1: WKInterfaceImage!
    @IBOutlet weak var imageR2C2: WKInterfaceImage!
    @IBOutlet weak var imageR2C3: WKInterfaceImage!
    @IBOutlet weak var imageR3C1: WKInterfaceImage!
    @IBOutlet weak var imageR3C2: WKInterfaceImage!
    @IBOutlet weak var imageR3C3: WKInterfaceImage!
    @IBOutlet weak var timeBarImage: WKInterfaceImage!
    
    //マージグループ
    @IBOutlet weak var margeGroup: WKInterfaceGroup!
    @IBOutlet weak var margeExpGroup: WKInterfaceGroup!
    
    /////// リザルトシーンのアウトレット ///////
    //文字
    @IBOutlet weak var winnerNameLabel: WKInterfaceLabel!
    @IBOutlet weak var leastTimeLabel: WKInterfaceLabel!
    @IBOutlet weak var goldLabel: WKInterfaceLabel!
    @IBOutlet weak var expPointLabel: WKInterfaceLabel!
    //画像
    @IBOutlet weak var expBarImage: WKInterfaceImage!
    
    //仮のもの
    @IBOutlet weak var testLabel: WKInterfaceLabel!
    
    /////// ペットのアウトレット ///////
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
    
    /////// 変数 ///////
    var boardState: Array<Int>  = []    //ボードの状態を示す配列
    var turnState:Int!          = 1     //ターンの状態 1.プレイヤー/2.ペット
    var winPlayer               = 10    //勝利したプレイヤー
    var maxBarWidth             = 125.0 //バーの最大の大きさ
    
    var playerLevel             = 1     //プレイヤーのレベル
    var playerExp               = 0     //プレイヤーの経験値
    var playerExpBefore         = 0     //ゲーム前のプレイヤーの経験値
    var playerGoldAmount        = 0     //プレイヤーの所持ゴールド
    var playerFun               = 100   //ペット機嫌
    var playerFriendship        = 100   //ペット信頼度
    var leastTimeValue          = 10.0  //残り時間の値
    var maxExpPoint             = 0.0   //現在のレベルでの最大経験値
    var gameState : TTTState    = .start//シーンの状態
    
    var leastTimer:NSTimer!             //残り時間のタイマー
    var changeSceneTimer:NSTimer!       //シーン遷移タイマー
    var resultTimer:NSTimer!            //結果シーンタイマー
    var eyeWinkTimer:NSTimer!           //目パチタイマー
    var petWaitTimer:NSTimer!           //ペットの待ち時間
    
    var hadChange               = false //変化判定
    
    
    //定数
    let eyeCloseInterval:NSTimeInterval = 0.2//目ぱち間隔
    
    var allLine = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6]
    ]
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
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
        if bounds.width > 136.0
        {
            maxBarWidth = 149.0
            margeGroup.setWidth(2.5)
            margeExpGroup.setWidth(2.5)
        }
        else
        {
            maxBarWidth = 130.0
            margeGroup.setWidth(2.0)
            margeExpGroup.setWidth(2.0)
        }
        
        //レベル、経験値読み込み
        playerLevel = statusManager.loadValue("levelV")
        playerExp = statusManager.loadValue("experienceV")
        playerGoldAmount = statusManager.loadValue("goldenAmount")
        playerExpBefore = playerExp
        playerFun = Int(statusManager.loadValue("funV")/720)
        playerFriendship = statusManager.loadValue("frendshipV")
        
        //ペットのイメージ名
        if statusManager.loadValue("petgender") == 1 { petGender = "man" }
        else { petGender = "woman" }
        
        petBalloon.setBackgroundImageNamed("Pet_default_"+petGender+"_petBalloon")
        
        //set up image of pet
        let petImageDict = statusManager.getPetImageDict()
        for (key, value) in petImageDict
        { setPetImage(key,value: value) }
        animationName = petImageDict["petBodyType"]!
        
        //初期化
        gameState = TTTState.start
        initGame()
    }
    
    //ゲームの初期化
    func initGame()
    {
        //ボードの初期化
        boardState = Array(count: 9, repeatedValue: 0)
        turnState = 1
        miniGameResultGroup.setHidden(true)
        resultGroup.setHidden(true)
        petGroup.setHidden(true)
        boardGroup.setHidden(false)
        
        leastTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "decreaseLeastTime", userInfo: nil, repeats: true)
        
        let randomNum = Int(arc4random_uniform(2))
        if randomNum >= 1
        {
            turnState = 2
            if leastTimer.valid { leastTimer.invalidate() }
            petWaitTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "aiPlay", userInfo: nil, repeats: false)
        }else{
            turnState = 1
        }
    }
    
    func decreaseLeastTime()
    {
        leastTimeValue -= 0.2
        let barWidth = CGFloat(leastTimeValue*maxBarWidth/10.0)
        timeBarImage.setWidth(barWidth)
        if leastTimeValue < 0.2
        {
            if leastTimer.valid == true { leastTimer.invalidate() }
            let barWidth = 0.1 as CGFloat
            timeBarImage.setWidth(barWidth)
            winPlayer = 2
            printResult()
        }
    }
    
    //ボタンを押した時の反応
    @IBAction func pushR1C1()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR1C1, image: imageR1C1)
            buttonR1C1.setEnabled(false)
            boardState[0] = turnState
            print("pc:0")
            checkResult()
        }
    }
    @IBAction func pushR1C2()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR1C2, image: imageR1C2)
            buttonR1C2.setEnabled(false)
            boardState[1] = turnState
            print("pc:1")
            checkResult()
        }
    }
    @IBAction func pushR1C3()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR1C3, image: imageR1C3)
            buttonR1C3.setEnabled(false)
            boardState[2] = turnState
            print("pc:2")
            checkResult()
        }
    }
    @IBAction func pushR2C1()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR2C1, image: imageR2C1)
            buttonR2C1.setEnabled(false)
            boardState[3] = turnState
            print("pc:3")
            checkResult()
        }
    }
    @IBAction func pushR2C2()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR2C2, image: imageR2C2)
            buttonR2C2.setEnabled(false)
            boardState[4] = turnState
            print("pc:4")
            checkResult()
        }
    }
    @IBAction func pushR2C3()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR2C3, image: imageR2C3)
            buttonR2C3.setEnabled(false)
            boardState[5] = turnState
            print("pc:5")
            checkResult()
        }
    }
    @IBAction func pushR3C1()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR3C1, image: imageR3C1)
            buttonR3C1.setEnabled(false)
            boardState[6] = turnState
            print("pc:6")
            checkResult()
        }
    }
    @IBAction func pushR3C2()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR3C2, image: imageR3C2)
            buttonR3C2.setEnabled(false)
            boardState[7] = turnState
            print("pc:7")
            checkResult()
        }
    }
    @IBAction func pushR3C3()
    {
        if turnState == 1
        {
            setMaruBatu(buttonR3C3, image: imageR3C3)
            buttonR3C3.setEnabled(false)
            boardState[8] = turnState
            print("pc:8")
            checkResult()
        }
    }
    
    //揃っているか調べる
    func checkResult()
    {
        var alignedLine = 0 as Int
        for line in allLine
        {
            alignedLine += checkLines(line[0], num2:line[1], num3:line[2])
        }
        if alignedLine >= 1
        {
            //checkLineが全て1でも10は超えない
            if alignedLine >= 10
            {
                winPlayer = 2
                if leastTimer.valid == true { leastTimer.invalidate() }
                printResult()
            }else{
                winPlayer = 1
                if leastTimer.valid == true { leastTimer.invalidate() }
                printResult()
            }
        }else{
            //ドロー判定
            var zeroBoxNumber = 0 as Int
            for state in boardState
            {
                if state == 0
                {
                    zeroBoxNumber += 1
                }
            }
            if zeroBoxNumber == 0
            {
                if winPlayer  != 0
                {
                    winPlayer = 0
                    if leastTimer.valid == true { leastTimer.invalidate() }
                    printResult()
                }
            }
        }
        
        //ターン切り替え
        if alignedLine == 0 && winPlayer == 10{ switchTurn() }
    }
    
    //列が揃っているか調べる
    func checkLines(num1: Int, num2: Int, num3: Int) -> Int
    {
        if (boardState[num1] as Int) == (boardState[num2] as Int) && (boardState[num2] as Int) == (boardState[num3] as Int)
        {
            if (boardState[num1] as Int) == 1 && (boardState[num1] as Int) != 0
            {
                return 1//player1の勝利
            }
            else if (boardState[num1] as Int) != 0
            {
                return 10//player2の勝利
            }
        }
        return 0 as Int
    }
    
    //ターンを切り替える
    func switchTurn()
    {
        if turnState == 1
        {
            if leastTimer.valid == true { leastTimer.invalidate() }
            turnState = 2
            petWaitTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "aiPlay", userInfo: nil, repeats: false)
            //pushButtonAi(gameAi())
        }
        else if turnState == 2
        {
            turnState = 1
            if leastTimer.valid == false
            {
                leastTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "decreaseLeastTime", userInfo: nil, repeats: true)
            }
        }
    }
    
    func aiPlay()
    {
        pushButtonAi(gameAi())
    }
    
    //リザルトを表示する
    func printResult()
    {
        //game state : pet
        gameState = TTTState.pet
        //タイマーを止める
        if leastTimer.valid == true { leastTimer.invalidate() }
        //全てのボタンを無効にする
        dismissAllButton()
        //タイムアップの時なぜかゲージがマックスになるので仕方なく削除
        timeBarImage.setHidden(true)
        
        //数値を求める・文字をセット
        
        var gold_increase = 0
        var exp_increase = 0
        var message = ""
        let randNum = Int(arc4random_uniform(2))
        switch winPlayer
        {
        case 0:
            winnerNameLabel.setText("引き分け〜")
            gold_increase = Int(20.0*(1+(Double(playerLevel)-1.0)*0.1))
            exp_increase = 50
            if randNum == 0
            {
                message += "同じくらいの強さだね！"
                setExpressionFromDict("5")
            }
            else if randNum == 1
            {
                message += "うぐぐ、もう一回！"
                setExpressionFromDict("5")
            }
            else
            {
                message += "次は%＜ペット名＞が勝つよ！"
                setExpressionFromDict("9")
            }
            break
        case 1:
            winnerNameLabel.setText("プレイヤーの勝利！")
            gold_increase = Int(40.0*(1+(Double(playerLevel)-1.0)*0.1))
            exp_increase = 100
            statusManager.addValue("funV", add_value: 3*720)
            if randNum == 0
            {
                message += "%＜飼い主＞にはかなわないなー"
                setExpressionFromDict("5")
            }
            else if randNum == 1
            {
                message += "負けちゃった〜・・・"
                setExpressionFromDict("4")
            }
            else
            {
                message += "流石%＜飼い主＞はつよいなー！"
                setExpressionFromDict("10")
            }
            break
        case 2:
            winnerNameLabel.setText("ペットの勝利")
            gold_increase = Int(10.0*(1+(Double(playerLevel)-1.0)*0.1))
            exp_increase = 10
            if randNum == 0
            {
                message += "勝った〜！！"
                setExpressionFromDict("2")
            }
            else if randNum == 1
            {
                message += "%＜ペット名＞の勝ちだね！"
                setExpressionFromDict("2")
            }
            else
            {
                message += "ねむくなってきちゃった"
                setExpressionFromDict("6")
            }
            break
        default:
            winnerNameLabel.setText("引き分け〜")
            gold_increase = Int(40.0*(1+(Double(playerLevel)-1.0)*0.1))
            exp_increase = 50
            if randNum == 0 { message += "同じくらいの強さだね！" }
            else if randNum == 1 { message += "うぐぐ、もう一回！" }
            else { message += "次は%＜ペット名＞が勝つよ！" }
            break
        }
        
        //文字セット
        let repMessage = messageReplace.replaceSentence(message)
        let menloFont = UIFont(name: "HiraKakuProN-W6", size: 12.0)!
        let fontAttrs = [NSFontAttributeName : menloFont]
        let attrString = NSAttributedString(string: repMessage, attributes: fontAttrs)
        messageOneLabel.setAttributedText(attrString)
        
        
        let leastTime_last2:String = String(format:"%.2f", leastTimeValue)
        var calcArray = statusManager.calcExpGoldPoint("tic", expBase: exp_increase, goldBase: gold_increase, bounusPoint: 0)
        if playerLevel >= 10
        {
            calcArray[0] = 0
            calcArray[1] *= 2
        }
        
        leastTimeLabel.setText(leastTime_last2+"秒")
        goldLabel.setText("+"+String(calcArray[1]))
        expPointLabel.setText("+"+String(calcArray[0]))
        
        //保存
        playerExp += calcArray[0]
        playerGoldAmount += calcArray[1]
        statusManager.updateValue("experienceV", target_value: playerExp)
        statusManager.updateValue("goldenAmount", target_value: playerGoldAmount)
        
        //変化
        hadChange = itemEffectManager.changePetImage(2, newLog: ["default" ,"default" ,"default"])
        
        //解放
        statusManager.increaceValue("ticTacToe",increaceValue: 1)
        
        //記録
        var recordDict = statusManager.loadStringIntDict("recordDict")
        recordDict["TTTPlayed"]! += 1
        switch winPlayer
        {
        case 0:
            recordDict["TTTDraw"]! += 1
            break
        case 1:
            recordDict["TTTWin"]! += 1
            break
        default:
            break
        }
        statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
        
        //しばらく待機してペットのシーンへ遷移
         changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "showPetMessage", userInfo: nil, repeats: false)
    }
    
    //メッセージを表示させる
    func showPetMessage()
    {
        //game state : pet
        gameState = TTTState.pet
        //表示の切り替え
        petGroup.setHidden(false)
        boardGroup.setHidden(true)
        //目パチ
        eyeWinkTimer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: false)
        //次に画面に遷移
        changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "miniGameResult", userInfo: nil, repeats: false)
    }
    
    //結果を見せる
    func miniGameResult()
    {
        //game state : pet
        gameState = TTTState.miniResult
        //表示の切り替え
        miniGameResultGroup.setHidden(false)
        petGroup.setHidden(true)
        
        changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "mainResult", userInfo: nil, repeats: false)
    }
    
    //経験値等表示
    func mainResult()
    {
        //game state : pet
        gameState = TTTState.mainResult
        //表示切り替え
        miniGameResultGroup.setHidden(true)
        resultGroup.setHidden(false)
        
        //バーのアニメーションを入れる予定
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
    }
    
    //バーの長さを更新
    func updateBar()
    {
        playerExpBefore += 5*playerLevel
        maxExpPoint = perthCsv.getMaxExp(playerLevel)
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
        //ダイアログを表示する必要があるか確認
        //hadChangeで変異したか判定
        //開放しかたチェック
        
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
    
    //目パチ（自動１回）
    func updateEyeActionOnce()
    {
        if petWink
        {
            petEye.setBackgroundImageNamed(animationName+"_petEyeWink_")
            petEye.startAnimatingWithImagesInRange(NSMakeRange(1, 5), duration: eyeCloseInterval, repeatCount: 1)
        }
    }
    
    //ボタンを全て無効にする
    func dismissAllButton()
    {
        buttonR1C1.setEnabled(false)
        buttonR1C2.setEnabled(false)
        buttonR1C3.setEnabled(false)
        buttonR2C1.setEnabled(false)
        buttonR2C2.setEnabled(false)
        buttonR2C3.setEnabled(false)
        buttonR3C1.setEnabled(false)
        buttonR3C2.setEnabled(false)
        buttonR3C3.setEnabled(false)
    }
    
    /////////////// AI start ///////////////
    
    func pushButtonAi(selectNum:Int){
        switch selectNum
        {
        case 0:
            setMaruBatu(buttonR1C1, image: imageR1C1)
            buttonR1C1.setEnabled(false)
            boardState[0] = turnState
            checkResult()
            print("npc:0")
            break
        case 1:
            setMaruBatu(buttonR1C2, image: imageR1C2)
            buttonR1C2.setEnabled(false)
            boardState[1] = turnState
            checkResult()
            print("npc:1")
            break
        case 2:
            setMaruBatu(buttonR1C3, image: imageR1C3)
            buttonR1C3.setEnabled(false)
            boardState[2] = turnState
            checkResult()
            print("npc:2")
            break
        case 3:
            setMaruBatu(buttonR2C1, image: imageR2C1)
            buttonR2C1.setEnabled(false)
            boardState[3] = turnState
            checkResult()
            print("npc:3")
            break
        case 4:
            setMaruBatu(buttonR2C2, image: imageR2C2)
            buttonR2C2.setEnabled(false)
            boardState[4] = turnState
            checkResult()
            print("npc:4")
            break
        case 5:
            setMaruBatu(buttonR2C3, image: imageR2C3)
            buttonR2C3.setEnabled(false)
            boardState[5] = turnState
            checkResult()
            print("npc:5")
            break
        case 6:
            setMaruBatu(buttonR3C1, image: imageR3C1)
            buttonR3C1.setEnabled(false)
            boardState[6] = turnState
            checkResult()
            print("npc:6")
            break
        case 7:
            setMaruBatu(buttonR3C2, image: imageR3C2)
            buttonR3C2.setEnabled(false)
            boardState[7] = turnState
            checkResult()
            print("npc:7")
            break
        case 8:
            setMaruBatu(buttonR3C3, image: imageR3C3)
            buttonR3C3.setEnabled(false)
            boardState[8] = turnState
            checkResult()
            print("npc:8")
            break
        case 100:
            checkResult()
            print("npc:100")
            break
        default:
            checkResult()
            print("npc:default")
            break
        }
    }
    
    //背景にマルバツ画像を表示させる
    func setMaruBatu(button: WKInterfaceButton, image: WKInterfaceImage)
    {
        if turnState == 1
        {
            button.setHidden(true)
            image.setHidden(false)
            image.setImageNamed("maru")
        }
        else if turnState == 2
        {
            button.setHidden(true)
            image.setHidden(false)
            image.setImageNamed("batu")
        }
    }
    
    //高速でないしあまり頭良くないAi
    func gameAi() -> Int
    {
        //アホ手
        let notBestSelect = Int(arc4random_uniform(12))
        if notBestSelect <= 8
        {
            if boardState[notBestSelect] == 0
            {
                print("not good")
                return notBestSelect
            }
        }
        
        //自分が揃いそうなら揃える
        var willAlignedLine = 0 as Int
        for line in allLine
        {
            willAlignedLine += checkWillAligne(line[0], num2:line[1], num3:line[2])
            if willAlignedLine >= 10
            {
                if boardState[line[0]] == 0
                {
                    return line[0]
                }
                else if boardState[line[1]] == 0
                {
                    return line[1]
                }
                else
                {
                    return line[2]
                }
            }
        }
        
        //相手が揃いそうなら阻止する
        willAlignedLine = 0 as Int
        for line in allLine
        {
            willAlignedLine += checkWillAligne(line[0], num2:line[1], num3:line[2])
            if willAlignedLine >= 1
            {
                if boardState[line[0]] == 0
                {
                    return line[0]
                }
                else if boardState[line[1]] == 0
                {
                    return line[1]
                }
                else
                {
                    return line[2]
                }
            }
        }
        
        //真ん中が空いているならば入れる
        if boardState[4] == 0
        {
            return 4
        }
        
        //四隅が空いているならば入れる。ランダムに選択
        var fourCorner = [0, 2, 6, 8]
        var randomNum = Int(arc4random_uniform(4))
        for _ in 0...3
        {
            if randomNum >= 4
            {
                randomNum -= 4
            }
            if boardState[fourCorner[randomNum]] == 0
            {
                return fourCorner[randomNum]
            }
            randomNum += 1
        }
        
        //適当に入れる
        var fourMiddle = [1, 3, 5, 7]
        randomNum = Int(arc4random_uniform(4))
        for _ in 0...3
        {
            if randomNum >= 4
            {
                randomNum -= 4
            }
            if boardState[fourMiddle[randomNum]] == 0
            {
                return fourMiddle[randomNum]
            }
            randomNum += 1
        }
        return 100
    }
    
    ///////////// AI end /////////////
    
    //揃いそうか判定
    func checkWillAligne(num1: Int, num2: Int, num3: Int) -> Int
    {        
        var zeroNum = 0
        if boardState[num1] as Int == 0 { zeroNum += 1 }
        if boardState[num2] as Int == 0 { zeroNum += 1 }
        if boardState[num3] as Int == 0 { zeroNum += 1 }
        
        if zeroNum == 1
        {
            switch boardState[num1] + boardState[num2] + boardState[num3]
            {
            case 2:
                return 1
            case 3:
                break
            case 4:
                return 10
            default:
                break
            }
            return 0 as Int
        }
        return 0 as Int
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        switch gameState
        {
        case TTTState.start:
            break
        case TTTState.main:
            if turnState == 1
            {
                if !leastTimer.valid
                {
                    leastTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "decreaseLeastTime", userInfo: nil, repeats: true)
                }
            }
            else if turnState == 2
            {
                if !petWaitTimer.valid
                {
                    petWaitTimer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: "aiPlay", userInfo: nil, repeats: false)
                }
            }
            break
        case TTTState.pet:
            if !changeSceneTimer.valid
            {
                changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "miniGameResult", userInfo: nil, repeats: false)
            }
            break
        case TTTState.miniResult:
            if !changeSceneTimer.valid
            {
                changeSceneTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "mainResult", userInfo: nil, repeats: false)
            }
            break
        case TTTState.mainResult:
            if !resultTimer.valid
            {
                resultTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "updateBar", userInfo: nil, repeats: false)
            }
            break
        }
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
        //タイマーの破棄
        if leastTimer != nil && leastTimer.valid { leastTimer.invalidate() }
        if petWaitTimer != nil && petWaitTimer.valid { petWaitTimer.invalidate() }
        if changeSceneTimer != nil && changeSceneTimer.valid { changeSceneTimer.invalidate() }
        if eyeWinkTimer != nil && eyeWinkTimer.valid { eyeWinkTimer.invalidate() }
        if resultTimer != nil && resultTimer.valid { resultTimer.invalidate() }
        switch gameState
        {
        case TTTState.start:
            break
        case TTTState.main:
            if turnState == 1 { if leastTimer != nil && leastTimer.valid { leastTimer.invalidate() } }
            else if turnState == 2 { if petWaitTimer != nil && petWaitTimer.valid { petWaitTimer.invalidate() } }
            break
        case TTTState.pet:
            if changeSceneTimer != nil && changeSceneTimer.valid { changeSceneTimer.invalidate() }
            if eyeWinkTimer != nil && eyeWinkTimer.valid { eyeWinkTimer.invalidate() }
            break
        case TTTState.miniResult:
            if changeSceneTimer != nil && changeSceneTimer.valid { changeSceneTimer.invalidate() }
            break
        case TTTState.mainResult:
            if resultTimer != nil && resultTimer.valid { resultTimer.invalidate() }
            break
        }
    }
}