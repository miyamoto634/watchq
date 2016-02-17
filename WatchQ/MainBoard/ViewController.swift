//
//  ViewController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, BWWalkthroughViewControllerDelegate, UITextFieldDelegate {
    
  
    
    var locationManager = CLLocationManager()
    let defaults1 = NSUserDefaults.standardUserDefaults();
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var SwichDeviceView: UIView!
    
    @IBOutlet weak var plaerNameL: UILabel!
    
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    
    @IBOutlet weak var playerNameTextF: UITextField!

    let statusManager = StatusManager();
    var petgender = 0;
    
    @IBOutlet weak var myPetBtn: UIButton!
    @IBOutlet weak var unkwonBtn: UIButton!
    @IBOutlet weak var sendQuestionBtn: UIButton!
    
    @IBOutlet weak var titleLable: UILabel!
    
    
    enum Status {
        case showPet
        case death
        case buyDiamons
        case ok
    }
    
    var status = Status.showPet;
    
    @IBAction func notificationButton(sender: AnyObject) {
        
        //Notification登録前のおまじない。テストの為、現在のノーティフケーションを削除します
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //以下で登録処理
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 10);//１０秒後
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertTitle = "ペットがクイズを見つけてきた！"
        notification.alertBody = "ペットがお腹をすかしています。クイズに挑みますか？"
        notification.category = "myCategory"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification);
    }
    
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        statusManager.resetPlayerData();
        
        //位置情報へのアクセスを求める
        locationManager.requestAlwaysAuthorization()

        //must be here to avoid nil value
        defaults1.setInteger(0, forKey: "wonLoss")
        
        //defaults1.setBool(true, forKey: "isDead");
       // defaults1.setInteger(10, forKey:"staminaV");
        defaults1.setInteger(1, forKey:"firstOpen");
        //defaults1.setInteger(1, forKey: "petgender");
        
        if( defaults1.stringForKey("playerName") == nil)
        {
            defaults1.setValue("Ali", forKey: "playerName");
            defaults1.setValue("petName" , forKey: "petName");
            defaults1.setInteger(0, forKey: "petgender");
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "goToPetView", userInfo: nil, repeats: false);

        
        self.playerNameTextF.delegate = self;
        
        if(defaults1.integerForKey("firstOpen") != 0)//not first open
        {
            defaults1.setBool(false, forKey: "backToMiniGame");
            defaults1.setInteger(0, forKey: "messageNo");
            defaults1.setInteger(0, forKey: "MiniGameNo");
        }
        else// first open
        {
            let messageNo = defaults1.integerForKey("messageNo");
            if(messageNo == 0)
            {
                plaerNameL.text = "ペットの性別を選択してください。";
                hideUserInfoInputArea(false);
                playerNameTextF.hidden = true;
            }
            else if(messageNo == 1)
            {
                plaerNameL.text = "あなたの名前を入力してください";
                hideUserInfoInputArea(false)
                maleBtn.hidden = true;
                femaleBtn.hidden = true;
            }
            else if(messageNo == 3)
            {
                plaerNameL.text = "ペットの名前を入力してください";
                hideUserInfoInputArea(false)
                maleBtn.hidden = true;
                femaleBtn.hidden = true;
            }
            
            return;
        }
        
        if(defaults1.boolForKey("isDead") == true)
        {
            showDeathView();
            return;
        }
    }

   override func viewWillAppear(animated: Bool)
   {
        super.viewWillAppear(animated)

        //
        if(defaults1.integerForKey("firstOpen") != 0 && defaults1.boolForKey("isDead") == false)// not first open
        {
            hideUserInfoInputArea(true);
        }
    }
    
       
    func hideUserInfoInputArea(hide : Bool)
    {
        mainView.hidden = !hide;
        plaerNameL.hidden = hide;
        maleBtn.hidden = hide;
        femaleBtn.hidden = hide;
        playerNameTextF.hidden = hide;
    }
    
    func goToPetViewToShowMessage()
    {
        //load pet view
        let mainStb = UIStoryboard(name: "Pet", bundle: nil)
        let petView = mainStb.instantiateViewControllerWithIdentifier("petView") as! PetViewController
        self.presentViewController(petView, animated: false, completion: nil);
    }
    
    var helper = Helper();
   
    
    @IBAction func showWalkthrough()
    {
        if(status == .death)//show confiarm revive view
        {
            let diamondAmount = defaults1.integerForKey("diamondAmount");
            if(diamondAmount >= 3)
            {
                status = .ok;
                
                titleLable.text = "ペットを復活させるためにはダイヤが３つ必要です。";
                hideUserInfoInputArea(true)
                sendQuestionBtn.hidden = true;
                myPetBtn.setTitle("復活させる", forState: .Normal);
                unkwonBtn.setTitle("戻る", forState: .Normal);
            }
            else
            {
                status = Status.buyDiamons;
               // println(status.hashValue)
                titleLable.text = "ダイヤが足りません。\n現在の所持数：\(diamondAmount)個";
                hideUserInfoInputArea(true)
                sendQuestionBtn.hidden = true;
                myPetBtn.setTitle("ダイヤを購入する", forState: .Normal);
                unkwonBtn.setTitle("戻る", forState: .Normal);
            }
        }
        else if(status == .buyDiamons)//go to buy diamons scene
        {
            goToShopListViewController();
        }
        else if(status == .ok)
        {
            var diamondAmount = defaults1.integerForKey("diamondAmount");
            diamondAmount -= 3;
            defaults1.setInteger(diamondAmount, forKey: "diamondAmount");
            statusManager.avoidDeath();
            showMainView();
        }
        else
        {
            goToPetView();
        }
    }

    @IBAction func unknown(sender: AnyObject)
    {
        if(status == .death)//do death procedure
        {
            statusManager.resetPlayerData();
            showMainView();
        }
        else if(status == .ok || status == .buyDiamons)// back to dead view
        {
            showDeathView();
        }
        else
        {}
    }
    
    func showMainView()
    {
        status = Status.showPet;
        titleLable.text = "アップルウォッチで遊んでね！";
        hideUserInfoInputArea(true)
        sendQuestionBtn.hidden = false;
        myPetBtn.setTitle("My Pet", forState: .Normal);
        unkwonBtn.setTitle("通知", forState: .Normal);
    }
    
    @IBAction func male(sender: AnyObject)
    {
        defaults1.setBool(true, forKey: "backToMiniGame");
        defaults1.setInteger(-1, forKey: "MiniGameNo");
        defaults1.setInteger(1, forKey: "petgender");// 1 : male , 2 : female
        goToPetViewToShowMessage();
    }
    
    @IBAction func female(sender: AnyObject)
    {
        defaults1.setBool(true, forKey: "backToMiniGame");
        defaults1.setInteger(-1, forKey: "MiniGameNo");
        defaults1.setInteger(2, forKey: "petgender");// 1 : male , 2 : female
        goToPetViewToShowMessage();
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if(defaults1.integerForKey("messageNo")  == 1)
        {
            defaults1.setValue(playerNameTextF.text , forKey: "playerName");
        }
        else
        {
            defaults1.setInteger(1, forKey: "firstOpen");
            defaults1.setValue(playerNameTextF.text , forKey: "petName");
        }
        goToPetViewToShowMessage();
        return false
    }
    
    func showDeathView()
    {
        status = Status.death;
        print(defaults1.boolForKey("isDead"))
        titleLable.text = "ペットがたびに出てしまった。";
        hideUserInfoInputArea(true)
        sendQuestionBtn.hidden = true;
        myPetBtn.setTitle("復活させる", forState: .Normal);
        unkwonBtn.setTitle("出会いからやり直す", forState: .Normal);
    }
    
    
    func goToPetView()
    {
        defaults1.setInteger(0, forKey: "pageNo");
        
        let walkthrough1  = helper.goToPetView();
        self.presentViewController(walkthrough1, animated: false, completion: nil);
    }
    
    func goToShopListViewController()
    {
        defaults1.setInteger(1, forKey: "messageNo");
        let mainStb = UIStoryboard(name: "Main", bundle: nil)
        let quizCategory = mainStb.instantiateViewControllerWithIdentifier("ShopList") as! ShopListViewController
        self.presentViewController(quizCategory, animated: false, completion: nil);
    }
    
    
    @IBAction func selectIphone(sender: AnyObject)
    {
        //let message : String = "iphone"
    }
    
    
    @IBAction func selectWatch(sender: AnyObject)
    {
         //let message : String = "watch"
    }
    
    
    func showErrorAlert(error : String)
    {
        let alertController = UIAlertController(title: "接続失敗", message: "エラー: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion:nil)
            
        }))

        presentViewController(alertController, animated: true) { () -> Void in }
    }
    
    
    @IBAction func playerNameTextFieldOnChane(sender: AnyObject)
    {
        if (playerNameTextF.text!.characters.count > 9) {
            playerNameTextF.deleteBackward()
        }
    }
    
    // MARK: - Walkthrough delegate -
    func walkthroughPageDidChange(pageNumber: Int)
    {
       // println("Current Page \(pageNumber)")
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
   }

