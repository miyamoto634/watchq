//
//  QuizInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class QuizInterfaceController: PetBaseInterfaceController
{
    //csvパース
    var perthCsv = PerthCsv()
    //アイテムエフェクトマネージャー
    let itemEffectManager = ItemEffectManager()
    //メッセージリプレイス
    var messageReplace = MessageReplace()
    
    var quizCategoryInterface: QuizCategoryInterfaceController?
    
    //クイズシーンenum
    enum QState
    {
        case start
        case pet
        case main
        case result
        case end
        case mainResult
    }
    
    //アウトレットの登録
    @IBOutlet weak var choice1Button: WKInterfaceButton!
    @IBOutlet weak var choice2Button: WKInterfaceButton!
    @IBOutlet weak var choice3Button: WKInterfaceButton!
    @IBOutlet weak var choice4Button: WKInterfaceButton!
    @IBOutlet weak var questionLabel: WKInterfaceLabel!
    @IBOutlet weak var timeBarImage: WKInterfaceImage!
    @IBOutlet weak var timeBarGroup: WKInterfaceGroup!
    @IBOutlet weak var quizNumberLabel: WKInterfaceLabel!
    @IBOutlet weak var margeGroup: WKInterfaceGroup!
    
    /////// リザルトシーンのアウトレット ///////
    //文字
    @IBOutlet weak var categoryLabel: WKInterfaceLabel!
    @IBOutlet weak var correctNumLabel: WKInterfaceLabel!
    @IBOutlet weak var leastTimeLabel: WKInterfaceLabel!
    @IBOutlet weak var goldLabel: WKInterfaceLabel!
    @IBOutlet weak var expPointLabel: WKInterfaceLabel!
    @IBOutlet weak var foodLabel: WKInterfaceLabel!
    //画像
    @IBOutlet weak var expBarImage: WKInterfaceImage!
    //マージ
    @IBOutlet weak var margeExpGroup: WKInterfaceGroup!
    
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
    
    //大きいアウトレット
    @IBOutlet weak var quizGroup: WKInterfaceGroup!
    @IBOutlet weak var buttonGroup: WKInterfaceGroup!
    @IBOutlet weak var petGroup: WKInterfaceGroup!
    @IBOutlet weak var quizResultGroup: WKInterfaceGroup!
    @IBOutlet weak var mainResultGroup: WKInterfaceGroup!
    
    var quizArray = [String:String]()//取り出した問題を格納する配列
    var quizArrayNew = [[String:String]]()//問題を格納する配列
    var quizArray1 = [String:String]()//取り出した問題１
    var quizArray2 = [String:String]()//取り出した問題２
    var quizArray3 = [String:String]()//取り出した問題３
    
    var timerMoveNextQuiz:NSTimer!//次のクイズに移るためのタイマー
    var timerSubRemainTime:NSTimer!//回答するのにかかる時間を引くタイマー
    var timerPetTalk:NSTimer!//ペットのコメントを消すまでのタイマー
    var resultTimer:NSTimer!//結果画面でのタイマー
    var quizNumber:Int! //クイズ番号
    var correctAnswer:Int!//正解した数
    var remainTime:Double!//残り時間
    var subTime:Double!//引く時間
    var correctAnswerNum:Int!//正解のクイズ番号
    var quizCsvName = "history"//クイズカテゴリー
    var isChecked = false
    var maxExpPoint:Double = 0.0
    
    //プレイヤー固有の変数
    var playerLevel = 1//プレイヤーのレベル
    var playerExp = 0//プレイヤーの経験値
    var playerExpBefore = 0//ゲーム前のプレイヤーの経験値
    var playerGoldAmount = 0//プレイヤーの所持ゴールド
    var playerFun = 100
    var playerFriendship = 100
    
    //定数
    let totalQuiz = 3//全問題数
    let moveBackSceneInterval:NSTimeInterval = 2.0//次のクイズに移るまでの間隔
    let subRemainTimeInterval:NSTimeInterval = 0.2//時間が引かれる間隔
    let petTalkTimeInterval:NSTimeInterval = 2.0//ペットのコメントが消えるまでの間隔
    let eyeCloseInterval:NSTimeInterval = 0.2//目ぱち間隔
    
    
    var maxTimeBarSize:Float!//タイムバー最大サイズ
    var maxExpBarSize:Float!//タイムバー最大サイズ
    var quizComment = [String]()//問題前コメント
    var resultComment = [String]()//リザルトペットコメント
    var resultExpression = [String]()//リザルト表情

    var quizState: QState = .start//現在のクイズシーンの状態
    
    let defaults1 = NSUserDefaults.standardUserDefaults();//NSUserDefaults(suiteName:"group.com.platinum-egg.WatchQ.userdefaults")
    var foodStateValue = 100//foodの値
    
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
            petBalloonLabel2: messageOneLabel
        )
        
        quizNumber = 1//クイズ番号初期化
        correctAnswer = 0//正解数初期化
        remainTime = 20.0 * Double(totalQuiz)//残り時間
        quizState = QState.start//クイズシーン：start
        
        foodStateValue = statusManager.loadValue("feedingV")//foodの値代入
        
        //画面サイズを取得、タイムバーの長さ設定
        let currentDevice = WKInterfaceDevice.currentDevice()
        let bounds = currentDevice.screenBounds
        if bounds.width > 136.0
        {
            maxTimeBarSize = 118.0
            maxExpBarSize = 149.0
            margeGroup.setWidth(2.5)
            margeExpGroup.setWidth(2.5)
        }
        else
        {
            maxTimeBarSize = 103.0
            maxExpBarSize = 130.0
            margeGroup.setWidth(2.0)
            margeExpGroup.setWidth(2.0)
        }
        
        //レベル、経験値読み込み
        playerLevel = statusManager.loadValue("levelV")
        playerExp = statusManager.loadValue("experienceV")
        playerGoldAmount = statusManager.loadValue("goldenAmount")
        playerFun = Int(statusManager.loadValue("funV")/720)
        playerFriendship = statusManager.loadValue("frendshipV")
        playerExpBefore = playerExp
        
        //ペット画像セット
        let petImageDict = statusManager.getPetImageDict()
        for (key, value) in petImageDict
        { setPetImage(key,value: value) }
        animationName = petImageDict["petBodyType"]!
        petBalloon.setBackgroundImageNamed("Pet_default_"+petGender+"_petBalloon")
        
        //ペットの会話文セット
        let quizFirstComment = ["第一問！", "最初の問題だよ！", "分かるかな？", "分かるかな？"]
        let quizSecondComment = ["第二問！！", "次の問題！", "これはどう？", "これは分かる？"]
        let quizThirdComment = ["第三問！！！", "最後はこれ！", "ラスト！", "%＜飼い主＞、最後だよ！"]
        let randNumFirst = Int(arc4random_uniform(UInt32(quizFirstComment.count)))
        let randNumSecond = Int(arc4random_uniform(UInt32(quizSecondComment.count)))
        let randNumThird = Int(arc4random_uniform(UInt32(quizThirdComment.count)))
        quizComment += [quizFirstComment[randNumFirst], quizSecondComment[randNumSecond], quizThirdComment[randNumThird]]//コメントを挿入
        let resultZeroComment = ["・・・手を抜いたんだよね？", "・・・難しすぎた？", "うーん、頑張って！", "%＜ペット名＞、かなしい…。"]
        let resultOneComment = ["難しかったかな？", "%＜飼い主＞頑張ってー", "%＜ペット名＞の問題、難しかった？", "次は頑張ってね・・・"]
        let resultTwoComment = ["なかなかやるね！", "なかなかやるね！", "さすが%＜飼い主＞！", "%＜ペット名＞も嬉しい！"]
        let resultThreeComment = ["すごい！かんぺきだね！！", "さすが%＜飼い主＞だね！" , "余裕だね！", "%＜ペット名＞は%＜飼い主＞といれて嬉しいよ！"]
        let resultZeroExpression = ["5", "5", "5", "9"]
        let resultOneExpression = ["4", "4", "4", "4"]
        let resultTwoExpression = ["2", "2", "2", "2"]
        let resultThreeExpression = ["11", "11", "11", "11"]
        let randNumZero = Int(arc4random_uniform(UInt32(resultZeroComment.count)))
        let randNumOne = Int(arc4random_uniform(UInt32(resultOneComment.count)))
        let randNumTwo = Int(arc4random_uniform(UInt32(resultTwoComment.count)))
        let randNumThree = Int(arc4random_uniform(UInt32(resultThreeComment.count)))
        resultComment += [resultZeroComment[randNumZero], resultOneComment[randNumOne], resultTwoComment[randNumTwo], resultThreeComment[randNumThree]]
        resultExpression += [resultZeroExpression[randNumZero], resultOneExpression[randNumOne], resultTwoExpression[randNumTwo], resultThreeExpression[randNumThree]]
        
        //前のシーンから受け取ったカテゴリ
        if let categoryName = context as? String
        {
            print("Quiz:"+categoryName)
            
            //カテゴリを数字に変える
            if categoryName == "歴史" { quizCsvName = "history" }
            else if categoryName == "地理" { quizCsvName = "geography" }
            else if categoryName == "芸術" { quizCsvName = "art" }
            else if categoryName == "スポーツ" { quizCsvName = "sport" }
            else if categoryName == "科学" { quizCsvName = "science" }
            else if categoryName == "雑学" { quizCsvName = "zatugaku" }
            
            
            //問題を取得
            quizArrayNew = perthCsv.return3random(quizCsvName)
            
            quizArray1 = quizArrayNew[0]
            quizArray2 = quizArrayNew[1]
            quizArray3 = quizArrayNew[2]
            
            //atention:あまり好ましくないけどここでセットする。できれば変える。
            categoryLabel.setText(categoryName)
            
            //ペットが話す
            changeScene("pet")
        }
        else
        {
            dismissController()
        }
    }
    
    //シーン切り替え
    func changeScene(sceneName:String)
    {
        switch sceneName
        {
        case "pet":
            //表示切り替え
            quizState = QState.pet
            quizGroup.setHidden(true)
            buttonGroup.setHidden(true)
            quizResultGroup.setHidden(true)
            mainResultGroup.setHidden(true)
            petGroup.setHidden(false)
            petTalk(quizComment[quizNumber-1])
            timerSubRemainTime = NSTimer.scheduledTimerWithTimeInterval(petTalkTimeInterval, target: self, selector: "deletePetTalk", userInfo: nil, repeats: false)
        case "quiz":
            //表示切り替え
            quizState = QState.main
            quizGroup.setHidden(false)
            buttonGroup.setHidden(false)
            quizResultGroup.setHidden(true)
            mainResultGroup.setHidden(true)
            petGroup.setHidden(true)
            isChecked = false
            initQuiz(quizNumber)
            break
        case "before":
            //表示切り替え
            quizGroup.setHidden(true)
            buttonGroup.setHidden(true)
            quizResultGroup.setHidden(true)
            mainResultGroup.setHidden(true)
            petGroup.setHidden(false)
            
            //ペットのメッセージ
            petTalk(resultComment[correctAnswer])
            setExpressionFromDict(resultExpression[correctAnswer])
            //次へ
            timerSubRemainTime = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "quizResult", userInfo: nil, repeats: false)
        default:
            break
        }
    }
    
    //クイズリザルト画面
    func quizResult()
    {
        //表示切り替え
        quizGroup.setHidden(true)
        buttonGroup.setHidden(true)
        quizResultGroup.setHidden(false)
        mainResultGroup.setHidden(true)
        petGroup.setHidden(true)
        
        //色々計算・保存
        let gold_increase = Int(20.0*(1+(Double(playerLevel)-1.0)*0.1))*correctAnswer + Int(5.0*(1+(Double(playerLevel)-1.0)*0.1))*(3-correctAnswer)
        let exp_increase = 50*correctAnswer + 10*(3-correctAnswer)
        var food_increase = correctAnswer*5
        var fun_increase = correctAnswer*3
        fun_increase -= 3-correctAnswer
        if correctAnswer == 3
        {
            food_increase += 5
            fun_increase += 1
        }
        else if correctAnswer == 0
        {
            fun_increase -= 2
        }
        
        var calcArray = statusManager.calcExpGoldPoint("quiz", expBase: exp_increase, goldBase: gold_increase, bounusPoint: correctAnswer)
        if playerLevel >= 10
        {
            calcArray[0] = 0
            calcArray[1] *= 2
        }
        
        goldLabel.setText("+"+String(calcArray[1]))
        expPointLabel.setText("+"+String(calcArray[0]))
        foodLabel.setText("+"+String(food_increase)+"%")
        correctNumLabel.setText(String(correctAnswer)+"問")
        let leastTime_last2:String = String(format:"%.2f", remainTime)
        leastTimeLabel.setText(leastTime_last2+"秒")
        
        //保存
        playerExp += calcArray[0]
        playerGoldAmount += calcArray[1]
        statusManager.updateValue("experienceV", target_value: playerExp)
        statusManager.updateValue("goldenAmount", target_value: playerGoldAmount)
        statusManager.addValue("feedingV", add_value: food_increase*864)
        statusManager.addValue("funV", add_value: food_increase*720)
        
        //変化
        if correctAnswer != 0
        {
            let categoryArray = [String](count: correctAnswer, repeatedValue: quizCsvName)
            itemEffectManager.changePetImage(2, newLog: categoryArray)
        }
        
        //解放
        statusManager.increaceValue(quizCsvName, increaceValue: correctAnswer)
        
        //記録
        var recordDict = statusManager.loadStringIntDict("recordDict")
        
        switch quizCsvName
        {
        case "history":
            recordDict["quizPlayedHistory"]! += 3
            recordDict["quizCorrectHistory"]! += correctAnswer
            break
        case "geography":
            recordDict["quizPlayedGeograpy"]! += 3
            recordDict["quizCorrectGeograpy"]! += correctAnswer
            break
        case "art":
            recordDict["quizPlayedArt"]! += 3
            recordDict["quizCorrectHistory"]! += correctAnswer
            break
        case "sport":
            recordDict["quizPlayedSports"]! += 3
            recordDict["quizCorrectSports"]! += correctAnswer
            break
        case "science":
            recordDict["quizPlayedScience"]! += 3
            recordDict["quizCorrectScience"]! += correctAnswer
            break
        case "zatugaku":
            recordDict["quizPlayedZatugaku"]! += 3
            recordDict["quizCorrectZatugaku"]! += correctAnswer
            break
        default:
            break
        }
        
        statusManager.updateStringIntDict("recordDict", newDict: recordDict, callFromWatch: true)
        
        //クイズシーン：end
        quizState = QState.end
        
        //次へ
        timerSubRemainTime = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "mainResult", userInfo: nil, repeats: false)
    }
    
    //メインリザルト画面
    func mainResult()
    {
        //クイズシーン：main result
        quizState = QState.mainResult
        
        //表示切り替え
        quizGroup.setHidden(true)
        buttonGroup.setHidden(true)
        quizResultGroup.setHidden(true)
        mainResultGroup.setHidden(false)
        petGroup.setHidden(true)
        
        //バーのアニメーションを入れる予定
        maxExpPoint = perthCsv.getMaxExp(playerLevel)
        print("max exp:"+String(maxExpPoint))
        if maxExpPoint < 0.0
        {
            expBarImage.setWidth(CGFloat(maxExpBarSize))
            resultTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "gotoTop", userInfo: nil, repeats: false)
        }
        else
        {
            let maxBarWidth:Double = Double(maxExpBarSize)
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
        let maxBarWidth:Double = Double(maxExpBarSize)
        playerExpBefore += 5*playerLevel
        
        if playerExpBefore >= playerExp
        {
            if Int(maxExpPoint) <= playerExpBefore
            {
                testLabel.setText("Rank Up!")
                playerExp -= playerExpBefore
                playerExpBefore = 0
                playerLevel += 1
                maxExpPoint = perthCsv.getMaxExp(playerLevel)
                print("max exp:"+String(maxExpPoint))
            }
            if maxExpPoint < 0.0
            {
                expBarImage.setWidth(CGFloat(maxExpBarSize))
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
                maxExpPoint = perthCsv.getMaxExp(playerLevel)
                print("max exp:"+String(maxExpPoint))
            }
            if maxExpPoint < 0.0
            {
                expBarImage.setWidth(CGFloat(maxExpBarSize))
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
        let probableNum:Double = Double(playerFun/10)*Double(correctAnswer) - Double(playerFriendship/10)
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
    
    // 問題を初期化
    func initQuiz(num:Int)
    {
        //クイズシーン：main
        quizState = QState.main
        //問題になる行の配列を取得
        switch num
        {
        case 1:
            quizArray = quizArray1
            break
        case 2:
            quizArray = quizArray2
            break
        case 3:
            quizArray = quizArray3
            break
        default:
            break
        }
        //正解の番号をセットする
        correctAnswerNum = 1
        //移し替える配列を用意する
        let subQuizArray = NSMutableArray()
        //配列に入れていく
        subQuizArray.addObject(quizArray["select1"]!)
        subQuizArray.addObject(quizArray["select2"]!)
        subQuizArray.addObject(quizArray["select3"]!)
        subQuizArray.addObject(quizArray["select4"]!)

        //シャッフル
        let count = subQuizArray.count-1
        for idx in 0...count
        {
            let randomNum = Int(arc4random_uniform(UInt32(count-idx+1)))
            if correctAnswerNum == randomNum+1
            {
                correctAnswerNum = count-idx+1
            }
            subQuizArray.exchangeObjectAtIndex(count-idx, withObjectAtIndex: randomNum)
        }
        //問題、選択肢をセットする
        questionLabel.setText(quizArray["Question"])
        choice1Button.setTitle(subQuizArray[0] as? String)
        choice2Button.setTitle(subQuizArray[1] as? String)
        choice3Button.setTitle(subQuizArray[2] as? String)
        choice4Button.setTitle(subQuizArray[3] as? String)
        //問題番号表示
        quizNumberLabel.setText(String(quizNumber)+"/"+String(totalQuiz))
        //ボタンの色の初期化
        setUpButtonColor()
        //引く時間を初期化
        subTime = 0.0
        let timeBarSize = CGFloat((maxTimeBarSize/20.0)*Float(20.0 - subTime))
        timeBarImage.setWidth(timeBarSize)
        //回答までかかる時間を引く関数を呼び出す
        timerSubRemainTime = NSTimer.scheduledTimerWithTimeInterval(subRemainTimeInterval, target: self, selector: "subRemainTime", userInfo: nil, repeats: true)
    }
    
    //時間を引く関数
    func subRemainTime()
    {
        subTime! += 0.2
        let timeBarSize = CGFloat((maxTimeBarSize/20.0)*Float(20.0 - subTime))
        timeBarImage.setWidth(timeBarSize)
        //timeBarImage.setWidth(CGFloat(maxTimeBarSize))
        if subTime >= 19.9{
            timeLimitOver()
        }
    }
    
    //四択ボタンを押したときのメソッド
    //頭悪いけど今はこの方法でやる
    @IBAction func choice1Action()
    {
        if !isChecked
        {
            isChecked = true
            let result = checkTheAnswer(1)
            if result { choice1Button.setBackgroundColor(UIColor.greenColor()) }
            else{ choice1Button.setBackgroundColor(UIColor.redColor()) }
        }
    }
    @IBAction func choice2Action()
    {
        if !isChecked
        {
            isChecked = true
            let result = checkTheAnswer(2)
            if result { choice2Button.setBackgroundColor(UIColor.greenColor()) }
            else{ choice2Button.setBackgroundColor(UIColor.redColor()) }
        }
    }
    @IBAction func choice3Action()
    {
        if !isChecked
        {
            isChecked = true
            let result = checkTheAnswer(3)
            if result { choice3Button.setBackgroundColor(UIColor.greenColor()) }
            else { choice3Button.setBackgroundColor(UIColor.redColor()) }
        }
    }
    @IBAction func choice4Action()
    {
        if !isChecked
        {
            isChecked = true
            let result = checkTheAnswer(4)
            if result { choice4Button.setBackgroundColor(UIColor.greenColor()) }
            else { choice4Button.setBackgroundColor(UIColor.redColor()) }
        }
    }
    
    //正解か判定
    func checkTheAnswer(pressBtn:Int) -> Bool
    {
        //クイズシーン：result
        quizState = QState.result
        //自動遷移
        timerMoveNextQuiz = NSTimer.scheduledTimerWithTimeInterval(moveBackSceneInterval, target: self, selector: "moveNextQuiz", userInfo: nil, repeats: false)
        //時間を引くタイマーを破棄する
        timerSubRemainTime.invalidate()
        if pressBtn == correctAnswerNum
        {
            //正解と表示
            let menloFont = UIFont(name: "HiraKakuProN-W6", size: 20.0)!
            let fontAttrs = [NSFontAttributeName : menloFont]
            let attrString = NSAttributedString(string: "正解！", attributes: fontAttrs)
            questionLabel.setAttributedText(attrString)
            //ボタンを押せなくする
            dismissAllButton()
            //正解したのでポイント加算
            correctAnswer! += 1
            //時間を引く
            remainTime! -= subTime
            //timebarを非表示にする
            timeBarGroup.setHidden(true)
            return true
        }
        else
        {
            //不正解と表示
            let menloFont = UIFont(name: "HiraKakuProN-W6", size: 20.0)!
            let fontAttrs = [NSFontAttributeName : menloFont]
            let attrString = NSAttributedString(string: "不正解", attributes: fontAttrs)
            questionLabel.setAttributedText(attrString)
            //ボタンを押せなくする
            dismissAllButton()
            //時間を引く
            remainTime! -= 20.0
            //timebarを非表示にする
            timeBarGroup.setHidden(true)
            return false
        }
    }
    
    //制限時間を越えた時の処理
    func timeLimitOver()
    {
        //クイズシーン：result
        quizState = QState.result
        //timebarを非表示にする
        timeBarGroup.setHidden(true)
        //ボタンを押せなくする
        dismissAllButton()
        //時間を引くタイマーを破棄する
        timerSubRemainTime.invalidate()
        //タイマーを止めてしまうので最後の分をここで引く
        remainTime! -= 20.0
        //自動遷移
        timerMoveNextQuiz = NSTimer.scheduledTimerWithTimeInterval(moveBackSceneInterval, target: self, selector: "moveNextQuiz", userInfo: nil, repeats: false)
        //タイムオーバーと表示
        let menloFont = UIFont(name: "HiraKakuProN-W6", size: 20.0)!
        let fontAttrs = [NSFontAttributeName : menloFont]
        let attrString = NSAttributedString(string: "タイムオーバー", attributes: fontAttrs)
        questionLabel.setAttributedText(attrString)
    }
    
    //次のクイズに移る
    func moveNextQuiz()
    {
        quizNumber! += 1
        if quizNumber == totalQuiz+1
        {
            // リザルト画面を表示
            changeScene("before")
        }
        else
        {
            //timebarを表示させる
            timeBarGroup.setHidden(false)
            //問題を押せる状態にする
            choice1Button.setEnabled(true)
            choice2Button.setEnabled(true)
            choice3Button.setEnabled(true)
            choice4Button.setEnabled(true)
            //ペットの画面を表示させる
            changeScene("pet")
        }
    }
    
    //ボタンの色を設定する
    func setUpButtonColor()
    {
        choice1Button.setBackgroundColor(UIColor.darkGrayColor())
        choice2Button.setBackgroundColor(UIColor.darkGrayColor())
        choice3Button.setBackgroundColor(UIColor.darkGrayColor())
        choice4Button.setBackgroundColor(UIColor.darkGrayColor())
    }
    
    //ボタンを押せなくする
    func dismissAllButton()
    {
        choice1Button.setEnabled(false)
        choice2Button.setEnabled(false)
        choice3Button.setEnabled(false)
        choice4Button.setEnabled(false)
    }
    
    //ペットのコメント
    func petTalk(message:String)
    {
        //コメントを表示
        let repMessage = messageReplace.replaceSentence(message)
        let menloFont = UIFont(name: "HiraKakuProN-W6", size: 12.0)!
        let fontAttrs = [NSFontAttributeName : menloFont]
        let attrString = NSAttributedString(string: repMessage, attributes: fontAttrs)
        messageOneLabel.setAttributedText(attrString)
        //目パチ
        _ = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: false)
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
    
    //ペットのコメントを消す
    func deletePetTalk()
    {
        //timebarを表示
        timeBarGroup.setHidden(false)
        //ボタンを表示させる
        choice1Button.setHidden(false)
        choice2Button.setHidden(false)
        choice3Button.setHidden(false)
        choice4Button.setHidden(false)
        //問題の初期化
        changeScene("quiz")
    }
    
    override func willActivate()
    {
        //再開する何かを入れる
        if quizState == QState.main && (timerSubRemainTime == nil || !timerSubRemainTime.valid)
        {
            //回答までかかる時間を引く関数を呼び出す
            print("state:main")
            timerSubRemainTime = NSTimer.scheduledTimerWithTimeInterval(subRemainTimeInterval, target: self, selector: "subRemainTime", userInfo: nil, repeats: true)
        }
        else if quizState == QState.pet && (timerSubRemainTime == nil || !timerSubRemainTime.valid)
        {
            //talkをデリート
            print("state:talk")
            timerSubRemainTime = NSTimer.scheduledTimerWithTimeInterval(petTalkTimeInterval, target: self, selector: "deletePetTalk", userInfo: nil, repeats: false)
        }
        else if quizState == QState.result && quizNumber > 1 && !timerMoveNextQuiz.valid
        {
            //次の問題に自動遷移
            print("state:result")
            timerMoveNextQuiz = NSTimer.scheduledTimerWithTimeInterval(moveBackSceneInterval, target: self, selector: "moveNextQuiz", userInfo: nil, repeats: false)
        }
        else if quizState == QState.end && !resultTimer.valid
        {
            print("state:end")
            resultTimer = NSTimer.scheduledTimerWithTimeInterval(moveBackSceneInterval, target: self, selector: "updateBar", userInfo: nil, repeats: false)
        }
        else if quizState == QState.mainResult && !resultTimer.valid
        {
            print("state:mian result")
            resultTimer = NSTimer.scheduledTimerWithTimeInterval(moveBackSceneInterval, target: self, selector: "updateBar", userInfo: nil, repeats: false)
        }
        
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate()
    {
        //各種タイマーを破棄
        if timerSubRemainTime != nil && timerSubRemainTime.valid { timerSubRemainTime.invalidate() }
        if timerMoveNextQuiz != nil && timerMoveNextQuiz.valid { timerMoveNextQuiz.invalidate() }
        if resultTimer != nil && resultTimer.valid { resultTimer.invalidate() }
        
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
