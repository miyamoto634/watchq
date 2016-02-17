//
//  TopInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/09/03.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class TopInterfaceController: WKInterfaceController
{
    //ステータスマネージャー
    let statusManager = StatusManager()
    
    //アウトレット
    @IBOutlet var atentionMessageGroup: WKInterfaceGroup!
    
    //ローカル通知
    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification)
    {
        if identifier == "challenge" { info = "QuizScene" }
    }
    
    //変数
    var moveToNextTimer :NSTimer!
    var info = ""
    var alpa = 1.0
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        moveToNextTimer = NSTimer.scheduledTimerWithTimeInterval(3.2, target: self, selector: "decreaceAlpha", userInfo: nil, repeats: false)
    }
    
    //アルファ値を減少させる関数
    func decreaceAlpha()
    {
        if alpa > 0.1
        {
            alpa -= 0.2
            atentionMessageGroup.setAlpha(CGFloat(alpa))
            moveToNextTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "decreaceAlpha", userInfo: nil, repeats: false)
            return
        }
        moveToNextTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "moveToNext", userInfo: nil, repeats: false)
    }
    
    //次の画面へ遷移
    func moveToNext()
    {
        let firstOpen = statusManager.loadValue("firstOpen")
        
        if firstOpen == 0
        {
            print("firstOpen:"+String(firstOpen))
            WKInterfaceController.reloadRootControllersWithNames(["register"], contexts: nil)
        }
        else
        {
            WKInterfaceController.reloadRootControllersWithNames(["pet", "status1", "status2", "game", "shop", "item"], contexts: [info,"","","","",""])
        }
    }
}
