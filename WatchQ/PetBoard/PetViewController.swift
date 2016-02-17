//
//  PetViewController.swift
//  WatchQ
//
//  Created by Ali Ayasrah on 10/06/2015.
//  Copyright (c) 2015 Ninja Egg. All rights reserved.
//

import UIKit
import Foundation
import WatchConnectivity

@objc protocol PetViewControllerDelegate
{
    @objc func goToMainView()
}

protocol PetViewControllerDelegate2
{
    func updateGeneralStatus();
    func updateGeneralStatusBodyType(bodyType : String);
}


class PetViewController: UIViewController, BWWalkthroughViewControllerDelegate, UITextFieldDelegate, WCSessionDelegate{

    let session : WCSession!
    
    required init(coder aDecoder: NSCoder) {
        self.session = WCSession.defaultSession()
        super.init(coder: aDecoder)!
    }
    
    let generalResultViewController = GeneralResultViewController();
    let statusManager = StatusManager();
    let messageReplace = MessageReplace();
    let perthCsv = PerthCsv();
    
    weak var delegate: PetViewControllerDelegate?;
    var delegate2: PetViewControllerDelegate2?;
    
   // let defaults = NSUserDefaults.standardUserDefaults()// to save data in user file
    
    var eyeCloseInterval:NSTimeInterval = 0.2 //目パチの時間
    var eyeWinkOneceInterval:NSTimeInterval = 4 //目パチの間隔
    var eyeWinkTwiceInterval:NSTimeInterval = 10 //目パチの間隔
    var timerEyeWink:NSTimer! //目パチタイマー（一回）
    var timerEyeWink2:NSTimer! //目パチタイマー（二回）
    var timerMessageClose:NSTimer!//吹き出し削除タイマー
    var timerMouthMumble:NSTimer! //for mouth mumble 
    var timerEffect1Animation:NSTimer! //for effect1 animation
    var petTalkTextSpeed:NSTimeInterval = 0.2//pet text talk speed
    
    var leftEyeImgesForWink :[UIImage] = [];
    var mouthImgesForMumble :[UIImage] = [];
    var effect1ImgesForAnimation :[UIImage] = [];
    
    
    @IBOutlet weak var hairImage: UIImageView!
    //@IBOutlet weak var clothsImage: UIImageView!
    
    @IBOutlet weak var mouthImage: UIImageView!
    @IBOutlet weak var clothImage: UIImageView!
    
    @IBOutlet weak var leftEyeImage: UIImageView!
    
    @IBOutlet weak var petHairAcceImage: UIImageView!
    @IBOutlet weak var makeupImage: UIImageView!// around mouth
    @IBOutlet weak var eyesAcceImage: UIImageView!// aound eyes
    @IBOutlet weak var headEffectImage: UIImageView!// around hair
    @IBOutlet weak var SkinEffect: UIImageView!
    
    @IBOutlet weak var baloon: UIImageView!
  //  @IBOutlet weak var baloonMassege: UILabel!
    
    @IBOutlet weak var baloonMassege: UITextView!// to show pet talking text and to show pet message when the player tap at screen
    @IBOutlet weak var backGroundImage: UIImageView!//background of iphone screeen
    
    @IBOutlet weak var backGround: UIImageView!//background of pet
    
    @IBOutlet weak var openWatchFirstL: UILabel!//to delete
    
    func hidePet()
    {
        self.view.bringSubviewToFront(backGroundImage);
        backGroundImage.hidden = false;
        self.view.bringSubviewToFront(inputText);
        self.view.bringSubviewToFront(noBtn);
        self.view.bringSubviewToFront(yesBtn);
    }
    
    let context = CIContext(options: nil);// for apply filter on image
    
    //var petWink = true;
    
    var petImageName = ""
    
    var MiniGameNo = 0;
    var backToMiniGame = false;
    
    var miniGameMessage =
    [
        ["・・・手を抜いたんだよね？", "(´・ω・`)", "なかなかやるね！", "すごい！かんぺきだね！！"],// quiz
        ["負けちゃった〜・・・", "勝ったー！！", "ぐぬぬ…"],// tic tac toe
        ["勝った〜！","次はもっと難しいのを用意しておくよ","勝った〜！"], // spell grid
    ];

  
    var responseTime:Int = 0//会話のセット数
    var responseTimes:Int = 0;
    
    var funStateValue = 100//funの数値
    var relationStateValue = 100//relationshipの数値
    var foodStateValue = 100//foodの数値
    var playerName:String = ""//プレイヤー名
    var petName:String = ""//ペット名
    var foodName:String = ""//食べ物の名前
   
    var converSession:[String] = [String]();
    
    var converSessionM = [[String: String]]()//全会話を入れる辞書
    var petTalkDict = [String: String]()//会話が入る
    var usedWordDict = [String:String]()//会話に使った単語を入れる配列
    var playerInput:String!//プレイヤーの入力
    var wordProperty:String!//学習プロパティー
    
    let defaults1 = NSUserDefaults.standardUserDefaults(); // to save data in user file

    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var inputText: UITextField!
    
    var messageNo = 0;
    var stamina = 0;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //文字速度設定
        petTalkTextSpeed = statusManager.getPetTalkTextSpeed()
        
    // _  = NSTimer.scheduledTimerWithTimeInterval(0.1 , target: self, selector: "hidePet", userInfo: nil, repeats: false)
        
        if(WCSession.isSupported()) {
            session.delegate = self
            session.activateSession()
        }
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.petViewController = self ;
        
        
        WordsManager.fillFoodListForFirstLunchApp();
        self.reloadInputViews()
       
        
        if(statusManager.getPetImageDict() == [String:String]())
        {
            //show popup to ask hime to open watch
            _  = NSTimer.scheduledTimerWithTimeInterval(0.1 , target: self, selector: "showOpenWatchFirstAlert", userInfo: nil, repeats: false)
          return;
        }
        
        backGround.hidden = false;
        

        //this message from tic tac toe view
        MiniGameNo = defaults1.integerForKey("MiniGameNo");
        if(MiniGameNo != 0)
        {
            backGroundImage.hidden = false;
            showMiniGameMessage();
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        //文字速度設定
        petTalkTextSpeed = statusManager.getPetTalkTextSpeed()
        
        let appDelegate2:AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        delegate2 = appDelegate2.generalResultViewController;
        
        let imagesDict = statusManager.getPetImageDict()
        setupPetImages(imagesDict);
    }
    
    
    func showOpenWatchFirstAlert()
    {
        let alertController = UIAlertController(title: "AppleWatchでゲームをはじめてね！", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion:nil)
            self.setDefaultPet()
        }))
        
        presentViewController(alertController, animated: true) { () -> Void in }
    }
    
    func setDefaultPet()
    {
        self.statusManager.initPetImageDict("man");
        let imagesDict = self.statusManager.getPetImageDict()
        self.setupPetImages(imagesDict);
        self.statusManager.upadatePetImageNameFromIphone(imagesDict)
    }
    
    func  setupPetImages(imagesDict : [String:String])
    {

        if(imagesDict == [String:String]())
        {
            return;
        }
        
        petImageName  = imagesDict["petBodyType"]!;
        
        if(openWatchFirstL.hidden  == false)
        {
            openWatchFirstL.hidden = true;
        }
        
        backGround.hidden = false;
        
        //user can change
        if(imagesDict["petHairAcce"]! == "")
        {
            petHairAcceImage.hidden = true;
        }
        else
        {
            petHairAcceImage.hidden = false;
            petHairAcceImage.image = UIImage(named:  imagesDict["petHairAcce"]!);
        }
        
        //user can change
        if(imagesDict["petEyeAcce"]! == "")
        {
            eyesAcceImage.hidden = true;
        }
        else
        {
            eyesAcceImage.hidden = false;
            eyesAcceImage.image = UIImage(named: imagesDict["petEyeAcce"]!);
        }
        
        //user can change
        if(imagesDict["petCloth"]! == "")
        {
            clothImage.hidden = true;
        }
        else
        {
            clothImage.hidden = false;
            clothImage.image = UIImage(named:imagesDict["petCloth"]!);
        }
        
        //user can change
        if(imagesDict["petMakeup"]! == "")
        {
            makeupImage.hidden = true;
        }
        else
        {
            makeupImage.hidden = false;
            makeupImage.image = UIImage(named:imagesDict["petMakeup"]!);
        }
        
        //user can change
        if(imagesDict["petBalloon"]! == "")
        {
            baloon.hidden = true;
        }
        else
        {
            // baloon.hidden = false;
            baloon.image = UIImage(named: imagesDict["petBalloon"]!);
        }
        
        //rendom change
        if(imagesDict["petHair"]! == "")
        {
            hairImage.hidden = true;
        }
        else
        {
            hairImage.hidden = false;
            hairImage.image = UIImage(named:imagesDict["petHair"]!);
        }
        
        if(imagesDict["petEye"]! == "")
        {
            leftEyeImage.hidden = true;
        }
        else
        {
            leftEyeImage.hidden = false;
            leftEyeImage.image = UIImage(named:imagesDict["petEye"]!);
        }
        
        if(imagesDict["petMouth"]! == "")
        {
            mouthImage.hidden = true;
        }
        else
        {
            mouthImage.hidden = false;
            mouthImage.image = UIImage(named: imagesDict["petMouth"]!);
            //add images to the mouth mumble array
           
            mouthImgesForMumble = [];
           for position in 1...2
            {
                let mouthImagesName : String = imagesDict["petMouth"]! + "Mumble_\(position)";
                let mouthImage  = UIImage(named:mouthImagesName);
                
                if(mouthImage == nil)
                {
                    break;
                }
                mouthImgesForMumble.append(mouthImage!);
            }
        }
        
        
        if(imagesDict["petSkin"]! == "")
        {
            SkinEffect.hidden = true;
        }
        else
        {
            SkinEffect.hidden = false;
            SkinEffect.image = UIImage(named: imagesDict["petSkin"]!);
        }

        
        leftEyeImgesForWink = [];
        
        if(timerEyeWink != nil)
        {
            timerEyeWink.invalidate();
            timerEyeWink2.invalidate();
        }
        
        //add images to the array
        for position in 1...5
        {
            let leftImagesName : String = imagesDict["petEye"]! + "Wink_\(position)";
            let leftImage  = UIImage(named:leftImagesName);
            leftEyeImgesForWink.append(leftImage!);
        }
        
        // timers for eye wink
        timerEyeWink = NSTimer.scheduledTimerWithTimeInterval(eyeWinkOneceInterval, target: self, selector: "updateEyeActionOnce", userInfo: nil, repeats: true)
        timerEyeWink2 = NSTimer.scheduledTimerWithTimeInterval(eyeWinkTwiceInterval, target: self, selector: "updateEyeActionTwice", userInfo: nil, repeats: true)

    }
    
    func die()
    {
        self.delegate?.goToMainView()
    }
    
    func showMiniGameMessage()
    {
    }
    
    var nextStep = 0;
    
    func displayPetTalk(Id2String:String)
    {
        //指定されたID2が0なら終了
        if Id2String == "0"
        {
            print(" *** Nothing to Do *** ", terminator: "")
        }
        else
        {
            //petTalkArrayにID2に対応した配列を代入する
            for index in 0...(converSessionM.count-1)
            {
                let dict = converSessionM[index]
                
                if dict["ID2"] == Id2String
                {
                    petTalkDict = converSessionM[index]
                    callExpressionByNo(dict["expression"]!)
                }
            }
            
            //ペットの文章追加
            petTalk( messageReplace.replaceSentence(petTalkDict["sentence"]!) );
            
            //好感度etcの上下
            //fun
            //println("fun:"+petTalkDict["fun"]!)
            let funStateIncreace = Int(petTalkDict["fun"]!)
            funStateValue += funStateIncreace!
            defaults1.setInteger(funStateValue, forKey: "funV")
            //food
           // println("food"+petTalkDict["food"]!)
            let foodStateIncreace = Int(petTalkDict["food"]!)
            foodStateValue += foodStateIncreace!
            defaults1.setInteger(foodStateValue, forKey: "feedingV")
            //relation
           // println("relation:"+petTalkDict["relation"]!)
            let relationStateIncreace = Int(petTalkDict["relation"]!)
            relationStateValue += relationStateIncreace!
            defaults1.setInteger(relationStateValue, forKey: "relationV")
            //like
           // println(selectProperty(petTalkDict["property"]!))
            if WordsManager.selectProperty(petTalkDict["property"]!) != "all"{
                wordProperty = WordsManager.selectProperty(petTalkDict["property"]!)
            }
         
            
            //入力の種類によってボタンの表示を変更
            if petTalkDict["input"]! == "1"//入力なし
            {
                nextStep = 1;
            }
            else if petTalkDict["input"]! == "2"//text input
            {
                nextStep = 2;
            }
            else if petTalkDict["input"]! == "3"//yes/no selecting
            {
                nextStep = 3;
            }
        }
    }
    
    //ボタンを押した後の入力と次の会話呼び出し
    func showNextMessage()
    {
            //分岐条件によって次呼び出す配列を決定する
            if petTalkDict["divergence"] == "1"//終わり
            {
                print("divType:1")
                print("show ID2:0")
                showEndMessage()
            }
            else if petTalkDict["divergence"] == "2"//無条件にdiv1
            {
                
                print("divType:2")
                print("show ID2:"+petTalkDict["div1"]!)
                displayPetTalk(petTalkDict["div1"]!)
                callExpressionByNo(petTalkDict["expression"]!)
            }
            else if petTalkDict["divergence"] == "3"//ペットが単語を知ってるか
            {
                
                print("divType:3")
                //単語があるか判定
                var wordNum:Int = 0 as Int
                let checkWordList = WordsManager.fetchAllWords()
                for item in checkWordList{
                    if playerInput == item.word{ wordNum += 1 }
                }
                
                if wordNum >= 1{
                    print("show ID2:"+petTalkDict["div1"]!)
                    displayPetTalk(petTalkDict["div1"]!)
                }else{
                    print("show ID2:"+petTalkDict["div2"]!)
                    displayPetTalk(petTalkDict["div2"]!)
                }
                callExpressionByNo(petTalkDict["expression"]!)
                //単語を記憶
            }
            else if petTalkDict["divergence"] == "4"//比較内容がプレーヤー入力と同じか
            {
                print("divType:4")
                //比較する単語を取得する
                var compareWord = petTalkDict["compare"]!
                //置き換えが必要なら置き換え
                compareWord = messageReplace.replaceSentence(compareWord)
                //比較する
                if playerInput == compareWord
                {
                    //println("show ID2:"+petTalkDict["div1"]!)
                    displayPetTalk(petTalkDict["div1"]!)
                }
                else
                {
                    //println("show ID2:"+petTalkDict["div2"]!)
                    displayPetTalk(petTalkDict["div2"]!)
                }
                callExpressionByNo(petTalkDict["expression"]!)
            }
            else if petTalkDict["divergence"] == "5"//yes/noでyes
            {
                callExpressionByNo(petTalkDict["expression"]!)
                
                print("divType:5")
                if playerInput == "Yes"
                {
                    //println(" gsgs show ID2:"+petTalkDict["div1"]!)
                    displayPetTalk(petTalkDict["div1"]!)
                }
                else
                {
                    //println("show ID2:"+petTalkDict["div2"]!)
                    displayPetTalk(petTalkDict["div2"]!)
                }
            }
    }
    

    //会話終了
    func showEndMessage()
    {
        //入力された言葉を記憶
        print("---new---")
        print("word:"+playerInput)
        print("property:"+wordProperty)
        print("like:0")
        WordsManager.updateWord(playerInput, property: wordProperty, likediff: 0);
        
        //評価を変化させる単語
        let likediff = Int16(Int(petTalkDict["like"]!)!)
        let targetWord = messageReplace.replaceSentence(petTalkDict["target"]!)
        print("---change---")
        print("word:"+targetWord)
        print("property:"+wordProperty)
        print("like:"+String(likediff))
        WordsManager.updateWord(targetWord, property: wordProperty, likediff: likediff)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "backToPagesView", userInfo: nil, repeats: false);
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {   //delegate method
        textField.resignFirstResponder()
        getTextInput(textField.text!);
        return true
    }
    
    func getTextInput(textInput: String)
    {
        //backGroundImage.hidden = true;
        self.view.sendSubviewToBack(backGroundImage);
        
        inputText.hidden = true;
        //  soundInputButton.setTitle("音声入力")
        let new_text = textInput.stringByReplacingOccurrencesOfString("[", withString: "", options: [], range: nil).stringByReplacingOccurrencesOfString("]", withString: "", options: [], range: nil)

        playerInput = new_text
        showNextMessage()
        
        print("player:"+textInput)
    }
    
    
    // YES NO Btn  --->
    @IBAction func responseNo(sender: UIButton)
    {
    }
    
    
    @IBAction func responseYes(sender: UIButton)
    {
    }
    /////  <----
    
    
 
    
    var relationshipV = 0;
    var isSleepV = false;
    var isDeadV = false;
    var healthV  = 0;
    var SleepV   = 0;
    var foodV    = 0;
    var funV     = 0;
    
    func setUpNormalExpression()
    {
        if(isSleepV == true)
        {
            return;
        }
        setNormalExpression();
    }
    
    func setNormalExpression()// make pet normal expression
    {
        headEffectImage.hidden = true;
        let imagesDict = statusManager.getPetImageDict()
        setupPetImages(imagesDict);

    }
    
    //TOFIX: make it using setNormalExpression func 
    func setupSleepingState( isSleeping: Bool)
    {
    }
    
    
    // I Calling this one time every change on the parameters
    // this func here to resive data from stateViewController
    func sendDataToPetViewController(health : Int, feed: Int, fun: Int, sleep: Int, relationship: Int, isSleeping: Bool, isDead: Bool)
    {
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if(openWatchFirstL.hidden == false)
        {
            return;
        }
        
        if let _ = touches.first as UITouch?
        {
            showBaloon();
            //print(touch.locationInView(self.view))
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    func showBaloon()
    {
        // to avoid another tap during open the balloon
        if(baloon.hidden == false)
        {
            return;
        }
        
        baloon.hidden = false; //show baloon
        baloonMassege.hidden = false; //show baloon text
     
        //start mumble
        if(timerMouthMumble != nil)
        {
            timerMouthMumble.invalidate();
        }
        timerMouthMumble = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "updateMouthMumble", userInfo: nil, repeats: true);

        
      //read csv file to get random line(sentence) from it
        let converSessionFile = perthCsv.filterType("tutorial", type: "type", typeNum: "13")
        
        let count = converSessionFile.count;
        let rand = randomInt(0, max: count - 1);
        print(count);
        let targetDict  = converSessionFile[rand];
        print(targetDict["expression"]!)
        
        callExpressionByNo(targetDict["expression"]!);
        petTalk(targetDict["sentence"]!);
        print(targetDict["sentence"]!)
        if( effect1ImgesForAnimation.count != 0)
        {
            timerEffect1Animation = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "updateEffect1Animation", userInfo: nil, repeats: true);
        }
        
        baloonMassege.font = UIFont(name: "Arial", size: 14.2);
    }
    
    func callExpressionByNo(ExpressionNo : String)
    {
        switch(ExpressionNo)
        {
        case "0", "1":
            setUpNormalExpression();
            break;
        case "2":
            setupExpression( "_happy", isThereMakeup: false, isThereEffect1: false, isThereEffect2: false);
            break;
        case "3":
            setupExpression( "_angry", isThereMakeup: false, isThereEffect1: false, isThereEffect2: true);
            break;
        case "4":
            setupExpression( "_sad", isThereMakeup: false, isThereEffect1: false, isThereEffect2: false);
            break;
        case "5":
            setupExpression("_surprise", isThereMakeup: false, isThereEffect1: false, isThereEffect2: true);
            break;
        case "6":
            setupExpression("_sleepy", isThereMakeup: false, isThereEffect1: false, isThereEffect2: true);
            break;
        case "7":
            //sleping
            break;
        case "8":
            setupExpression("_hungry", isThereMakeup: true, isThereEffect1: false, isThereEffect2: false);
            break;
        case "9":
            setupExpression("_benotsatisfied", isThereMakeup: false, isThereEffect1: false, isThereEffect2: false);
            break;
        case "10":
            setupExpression("_shy", isThereMakeup: false, isThereEffect1: false, isThereEffect2: false);
            break;
        case "11":
            setupExpression("_lovelove", isThereMakeup: false, isThereEffect1: true, isThereEffect2: false);
            break;
        case "12":
            setupExpression("_lovelove", isThereMakeup: false, isThereEffect1: true, isThereEffect2: true);
            break;
        default:
            break;
        }
    }
    
    var messageArray = [String]()//文字を格納する配列
    var showMessage:String = ""//表示する文字
    var maxMessageLength:Int = 0//文字取得終了位置
    var minMessageLength = 0//文字取得開始位置
    
    //ペットが話す
    func petTalk(talk:String)
    {
        messageArray = [String]()
        
        for char in talk.characters
        {
            messageArray.append(String(char))
        }
        maxMessageLength = 0
        minMessageLength = 0
        addMessage();
    }
    
    //テキストを追加
    func addMessage()
    {
        
        if maxMessageLength < messageArray.count
        {
            showMessage = ""
            
            for index in 0...maxMessageLength
            {
                showMessage += messageArray[index]
            }
           
            baloonMassege.text = showMessage;
            
            //長さを更新
            maxMessageLength += 1
            
            //再びこの関数を呼び出す
            timerMessageClose = NSTimer.scheduledTimerWithTimeInterval(petTalkTextSpeed, target: self, selector: "addMessage", userInfo: nil, repeats: false)
            baloonMassege.font = UIFont(name: "Arial", size: 14.2);//because every change at text will make font size to 14, so this line to keep font size 17
        }
        else// finish showing sentence
        {
            if(MiniGameNo == 0)
            {
                //hiddenBaloon and back to normal expression
                _ = NSTimer.scheduledTimerWithTimeInterval(2.3, target: self, selector: Selector("hiddenBaloon"), userInfo: nil, repeats: false);
            }
            else
            {
                if(backToMiniGame == true)
                {
                    if(MiniGameNo == -1) //first open info
                    {
                        let messageNo = defaults1.integerForKey("messageNo") + 1;
                        defaults1.setInteger(messageNo, forKey: "messageNo");
                        
                        //go to main view
                        _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "goToMainView", userInfo: nil, repeats: false);
                    }
                    else if(MiniGameNo == 1)
                    {
                        //go to quiz view
                          _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "goToQuizView", userInfo: nil, repeats: false);
                    }
                    else if(MiniGameNo == 2)//tic tac toe
                    {
                        if(stamina < 2)
                        {
                            goGamesViewController();
                        }
                        else
                        {
                            //show yes amd No buttons
                            hidePet();
                            noBtn.setTitle("やめる", forState: .Normal);
                            yesBtn.setTitle("挑戦する！", forState: .Normal);
                            noBtn.hidden = false;
                            yesBtn.hidden = false;
                        }
                    }
                    else if(MiniGameNo == 3)//spell grid
                    {
                        if(stamina < 2)
                        {
                            goGamesViewController();
                        }
                        else if(messageNo == 0)
                        {
                            //show yes amd No buttons
                            hidePet();
                            noBtn.setTitle("やめる", forState: .Normal);
                            yesBtn.setTitle("挑戦する！", forState: .Normal);
                            noBtn.hidden = false;
                            yesBtn.hidden = false;
                        }
                        else
                        {
                        //go to spell view
                            defaults1.setBool(false, forKey: "backToMiniGame");
                            _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "goToSpellView", userInfo: nil, repeats: false);
                        }
                    }
                    else if(MiniGameNo == 4)
                    {
                        if(nextStep == 1)// next message
                        {
                            showNextMessage();
                        }
                        else  if(nextStep == 2)// text input
                        {
                            hidePet();
                            inputText.hidden = false;
                        }
                        else  if(nextStep == 3)// yes no select
                        {
                            hidePet();
                            noBtn.hidden = false;
                            yesBtn.hidden = false;
                        }
                    }
                }
                else
                {
                //move to result view
                _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "goToResultScreen", userInfo: nil, repeats: false);
                }
            }
        }
        
    }
    
    
    func setupExpression(animationName : String, isThereMakeup: Bool, isThereEffect1: Bool, isThereEffect2: Bool)
    {
    
        var petImageNameLocal = petImageName;
        
        eyesAcceImage.hidden = true;
        headEffectImage.hidden = true;
        
        self.leftEyeImage.stopAnimating()
        
        leftEyeImgesForWink = [];
        
        let eyeImage  = UIImage(named: petImageNameLocal + animationName+"_petEye");
        if(eyeImage == nil)
        {
           petImageNameLocal = "Pet_default_man";
        }
        
        for position in 1...5
        {
            
            let leftImagesName : String = petImageNameLocal + animationName+"_petEyeWink_\(position)";
            let leftImage  = UIImage(named:leftImagesName);
            if(leftImage != nil)
            {
                leftEyeImgesForWink.append(leftImage!);
            }
            else
            {
                print(petImageNameLocal + " not exist")
            }
        }
     
        
        self.mouthImage.stopAnimating()
        self.headEffectImage.stopAnimating()
        
        mouthImgesForMumble = [];
        effect1ImgesForAnimation = [];
        
        //add images to the mouth mumble array 
        if(petImageName != "Pet_gold_10000_man" && petImageName != "Pet_quiz_1000" && petImageName != "Pet_spend_man")
        {
            for position in 1...2
            {
                let mouthImagesName : String = petImageNameLocal + animationName + "_petMouthMumble_\(position)";
                let mouthImage  = UIImage(named:mouthImagesName);
                if(mouthImage == nil)
                {
                    break;
                }
                mouthImgesForMumble.append(mouthImage!);
            }
            mouthImage.image = UIImage(named: petImageNameLocal + animationName+"_petMouthMumble_1");
        }
        
       leftEyeImage.image =  UIImage(named: petImageNameLocal + animationName+"_petEye");
        
        
        
        if(isThereMakeup)
        {
            makeupImage.hidden = false;
            makeupImage.image = UIImage(named: petImageNameLocal + animationName+"_petEffect3");
        }
      
        
        if(isThereEffect2)
        {
            eyesAcceImage.hidden = false;
            eyesAcceImage.image = UIImage(named: petImageNameLocal + animationName+"_petEffect2");
        }
        
        if(isThereEffect1)//hair effect
        {
            headEffectImage.hidden = false;
            headEffectImage.image = UIImage(named: petImageNameLocal + animationName+"_petEffect1_1");
            
            for position in 1...2
            {
                let effect1ImagesName : String = petImageNameLocal + animationName + "_petEffect1_\(position)";
                let effect1Image  = UIImage(named:effect1ImagesName);
                effect1ImgesForAnimation.append(effect1Image!);
            }
        }
    }
    
    //hidden balloon after the pet finish speaking
    func hiddenBaloon()
    {
    
        //stop animation if exisit --->
        if(self.timerEffect1Animation != nil)
        {
            self.timerEffect1Animation.invalidate();
            self.mouthImage.stopAnimating();
        }
        
        if(self.timerMouthMumble != nil)
        {
            self.timerMouthMumble.invalidate();
            self.mouthImage.stopAnimating()
        }
        //<---
        
        baloon.hidden = true;
        baloonMassege.hidden = true;
        setUpNormalExpression();// back to normal expression for the pet
    }
    
    //func to genarat random number in esay way
    func randomInt(min: Int, max:Int) -> Int
    {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
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
    
    //目パチ（０入れるとループ再生）
    func eyeAnimation(count:Int)
    {
        self.leftEyeImage.animationImages = leftEyeImgesForWink as [UIImage];
        self.leftEyeImage.animationDuration = 0.3
        self.leftEyeImage.animationRepeatCount = count
        self.leftEyeImage.startAnimating()
    }
 
    func updateMouthMumble()
    {
        self.mouthImage.animationImages = mouthImgesForMumble as [UIImage];
        self.mouthImage.animationDuration = 0.3
        self.mouthImage.animationRepeatCount = 1
        self.mouthImage.startAnimating()
    }
    
    func updateEffect1Animation()
    {
        self.headEffectImage.animationImages = effect1ImgesForAnimation as [UIImage];
        self.headEffectImage.animationDuration = 0.3
        self.headEffectImage.animationRepeatCount = 1
        self.headEffectImage.startAnimating()
    }
    
    func goToMainView()
    {
        if(defaults1.integerForKey("messageNo")  == 2)
        {
            petTalk("僕の名前を決めてね？");
        }
        else
        {
            if(self.timerEffect1Animation != nil)
            {
                self.timerEffect1Animation.invalidate();
                self.mouthImage.stopAnimating();
            }
            
            if(self.timerMouthMumble != nil)
            {
                self.timerMouthMumble.invalidate();
                self.mouthImage.stopAnimating()
            }
            
            //load main view
            let mainStb = UIStoryboard(name: "Main", bundle: nil)
            let mainView = mainStb.instantiateViewControllerWithIdentifier("mainView") as! ViewController
            self.presentViewController(mainView, animated: false, completion: nil);
        }
    }
    
    func goGamesViewController()
    {
        defaults1.setBool(false, forKey: "backToMiniGame");
        defaults1.setInteger(0, forKey: "messageNo");
        defaults1.setInteger(0, forKey: "MiniGameNo");
        defaults1.setInteger(3, forKey: "pageNo");
        
        let walkthrough1  = helper.goToPetView();
        self.presentViewController(walkthrough1, animated: false, completion: nil);
    }
    

    
    var helper = Helper();
    func backToPagesView()
    {
        if(self.timerEffect1Animation != nil)
        {
            self.timerEffect1Animation.invalidate();
            self.mouthImage.stopAnimating();
        }
        
        if(self.timerMouthMumble != nil)
        {
            self.timerMouthMumble.invalidate();
            self.mouthImage.stopAnimating()
        }
        
        defaults1.setInteger(0, forKey: "MiniGameNo");
        defaults1.setInteger(4, forKey: "pageNo");
        let walkthrough1  = helper.goToPetView();
        self.presentViewController(walkthrough1, animated: false, completion: nil);
    }
    
    // to receive ifno from watch and reply to it
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        var replyValues = Dictionary<String, AnyObject>()
        // let rand = helper.randomInt(1, max: 1000);
        var getDict  = [String:String]()
        
        // verify that we've gotten a number at the "buttonOffset" key
        if let offsetValue = message["name"] as! String? {
            
            switch (offsetValue)
            {
            case "coreDataWords":
                if(message["action"] as! String? == "getWord")
                {
                    let foodWordList = WordsManager.fetchWordByProperty("food")
                    let randNum = Int(arc4random_uniform(UInt32(foodWordList.count)))
                    let foodName = foodWordList[randNum].word
                    replyValues["result"] = String(foodName)
                    replyValues["type"] = "string";
                }
                else // update
                {
                    print((message["veriable"] as! String?)!)
                    WordsManager.updateWord((message["veriable"] as! String?)! , property: "food", likediff : Int16((message["value1"] as! String?)!))
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";
                }
                break;
            case "coreDataItems":
                
                if(message["action"] as! String? == "fetchItemByConsume")
                {
                    var itemDictArray = [[String:Int]]()
                    let fetchItems = ItemsManager.fetchItemByConsume(Int16(message["veriable"]! as! String)!);
                    for item in fetchItems
                    {
                        itemDictArray.append(["itemId": Int(item.itemId) , "amount": Int(item.amount) ])
                    }
                    replyValues["result"] = itemDictArray;
                    replyValues["type"] = "Items";
                }
                if(message["action"] as! String? == "fetchItemById")
                {
                    var itemDictArray = [[String:Int]]()
                    let fetchItems = ItemsManager.fetchItemById(Int16(message["veriable"]! as! String)!);
                    itemDictArray.append(["itemId": Int(fetchItems.itemId) , "amount": Int(fetchItems.amount) ])
                    
                    replyValues["result"] = itemDictArray;
                    replyValues["type"] = "Items";
                }
                else if(message["action"] as! String? == "updateSavedData")
                {
                    ItemsManager.updateSavedData(Int16(message["veriable"]! as! String)!, amount: Int16(message["value1"]! as! String)!)
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";
                }
                else if(message["action"] as! String? == "checkAboutItem")
                {
                    replyValues["result"] = ItemsManager.checkAboutItem(Int16(message["veriable"]! as! String)!)
                    replyValues["type"] = "bool";
                }
                else if(message["action"] as! String? == "getAmountofItem")
                {
                    replyValues["result"] = Int(ItemsManager.getAmountofItem(Int16(message["veriable"]! as! String)!))
                    replyValues["type"] = "int";
                }
                else if(message["action"] as! String? == "createItem")
                {
                    ItemsManager.createItem(Int16(message["veriable"]! as! String)!, consume: Int16(message["value1"]! as! String)!, amount: Int16(message["value2"]! as! String)!)
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";
                }
                else if(message["action"] as! String? == "deleteItemByID")
                {
                    ItemsManager.deleteItemByID(Int16(message["veriable"]! as! String)!)
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";
                    
                }
                
                break;
            case "userInfoInt":
                if(message["action"] as! String? == "getValue")
                {
                    replyValues["result"] = defaults1.integerForKey((message["veriable"] as! String?)!);
                    replyValues["type"] = "int";
                    
                }
                else if(message["action"] as! String? == "addValue")
                {
                    var tempPara = defaults1.integerForKey((message["veriable"] as! String?)!)
                    tempPara += Int((message["value1"] as! String?)!)!
                        
                    defaults1.setInteger(tempPara, forKey: (message["veriable"] as! String?)!)
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";                }
                else// update
                {
                    defaults1.setInteger(Int((message["value1"] as! String?)!)!, forKey: (message["veriable"] as! String?)!)
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";
                }
                
                break;
                //
            case "userInfoObject":
                if(message["action"] as! String? == "getValue")
                {
                    replyValues["result"] = defaults1.objectForKey((message["veriable"] as! String?)!) as! [String];
                    replyValues["type"] = "Object";
                }
                else// update
                {
                    defaults1.setObject( message["value1"]!, forKey: (message["veriable"] as! String?)!)
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";
                }
                break;
                
            case "userInfoString":
                if(message["action"] as! String? == "getValue")
                {
                    replyValues["result"] = defaults1.stringForKey((message["veriable"] as! String?)!);
                    replyValues["type"] = "string";
                }
                else//update
                {
                    defaults1.setValue( (message["value1"] as! String?)!, forKey: (message["veriable"] as! String?)!)
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";
                }
                break;
                
            case "userInfoBool":
                if(message["action"] as! String? == "getValue")
                {
                    replyValues["result"] = defaults1.boolForKey((message["veriable"] as! String?)!);
                    replyValues["type"] = "bool";
                    
                }
                else//update
                {
                    defaults1.setBool(Bool((message["value1"] as! Int?)!), forKey: (message["veriable"] as! String?)!)
                    replyValues["result"] = "success";
                    replyValues["type"] = "string";
                }
                break;
                
            case "sendNotificationInfo":
                if message["action"] as! String? == "updateValue"
                {
                    let array = message["value1"] as! [String]
                    statusManager.updateValue("FoodNotificationPeriod", target_value: Int(array[0])!)
                    statusManager.updateValue("StaminaNotificationPeriod", target_value: Int(array[1])!)
                    
                    //set up new notification
                    SetNotification()
                }
                
                break
                
            case "sendPetImageInfo":
                if message["action"] as! String? == "updateValue"
                {
                    getDict = message["value1"] as! [String:String]
                    self.statusManager.upadatePetImageNameFromIphone(getDict)
                }
                break
                
            case "sendStringIntDict":
                if message["action"] as! String? == "updateValue"
                {
                    let getDict = message["value1"] as! [String:Int]
                    self.statusManager.updateStringIntDict("recordDict1", newDict: getDict, callFromWatch: false)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate2?.updateGeneralStatus();
                    })

                    print("-- get record dict from watch --")
                
                }
                
                break
                /*
            case "errorReport":
                if message["action"] as! String? == "showError"
                {
                   let  exceptionError = message["value1"] as! String
                      print("--error--: " + "exceptionError")
                  //  self.statusManager.upadatePetImageNameFromIphone(getDict)
                 
                     defaults1.setValue(exceptionError, forKey: "exceptionStr");
                    
                    let alertController = UIAlertController(title: "AppleWatch Error", message: exceptionError, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                        alertController.dismissViewControllerAnimated(true, completion:nil)
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        alertController.dismissViewControllerAnimated(true, completion:nil)
                        let mainStb = UIStoryboard(name: "Main", bundle: nil)
                        let nextview = mainStb.instantiateViewControllerWithIdentifier("CatchError") as! CatchError
                        self.presentViewController(nextview, animated: false, completion: nil);
                    }))
                   
                    
                    presentViewController(alertController, animated: true) { () -> Void in }
                    
                }
                break */
            default:
                replyValues["result"] = "nothing"
                replyValues["type"] = "string";
                break;
            }
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                ///  tappedButton.setTitle("😍", forState:UIControlState.Normal)
                //self.SwichDeviceView.hidden = false;
                if(getDict != [String:String]())
                {
                    self.delegate2?.updateGeneralStatusBodyType(getDict["petBodyType"]!);
                    self.setupPetImages(getDict);
                    print(self.statusManager.getPetImageDict())
                }
                
            })
            
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                //   tappedButton.setTitle(oldTitle, forState:UIControlState.Normal)
            }
            
            replyHandler(replyValues)
        }
    }

    // 通知の設定を行う
    func SetNotification(){
        
        //Notification登録前のおまじない。テストの為、現在のノーティフケーションを削除します
        UIApplication.sharedApplication().cancelAllLocalNotifications();
        
        //共通データから読み取り
        let foodFlag = statusManager.loadValue("FoodNotificationFlag")
        let StaminaFlag = statusManager.loadValue( "StaminaNotificationFlag" )
        
        let foodPeriod:Int = statusManager.loadValue( "FoodNotificationPeriod" )
        let StaminaPeriod:Int = statusManager.loadValue( "StaminaNotificationPeriod" )
        
        if( foodFlag == 1 ) {
            
            //以下で登録処理
            if( foodPeriod != 0 ){
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval( foodPeriod ) );
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.alertTitle = "ペットがクイズを見つけてきた！"
                notification.alertBody = "ペットがお腹をすかしています。クイズに挑みますか？"
                notification.category = "WatchQNotification"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification);
            }
        }
        
        if( StaminaFlag == 1 ) {
            //以下で登録処理
            if( StaminaPeriod != 0 ){
                let notification = UILocalNotification()
                notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval( StaminaPeriod ));
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.alertTitle = "元気いっぱい！スタミナ満タンだよ！！"
                notification.alertBody = "ペットのスタミナが最大まで回復しました。"
                notification.category = "WatchQNotification"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification);
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}