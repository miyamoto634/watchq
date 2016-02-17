//
//  StatusSecondInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/07.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

//
//  StatusInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/06/22.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation

class StatusSecondInterfaceController: ConnectionInterfaceController
{
    //ステータスマネージャー
    var statusManager = StatusManager()
    
    //アウトレット
    //文字
    @IBOutlet weak var goldAmountLabel: WKInterfaceLabel!
    @IBOutlet weak var diamondAmountLabel: WKInterfaceLabel!
    @IBOutlet weak var spentTimeLabel: WKInterfaceLabel!
    
    //クラス
    let userCalendar = NSCalendar.currentCalendar()
    let defaults1 = NSUserDefaults.standardUserDefaults();//NSUserDefaults(suiteName:"group.com.platinum-egg.WatchQ.userdefaults")
    
    //変数
    var goldAmount:Int = 0//ゴールドの量
    var diamondAmount:Int = 0//ダイヤの量
    var spentTimeValue:Int = 0//過ごした時間
    
    //定数?
    var maxBarWidth = 125.0//バーの最大の大きさ
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
    }
    
    //全てのステータスを更新して表示させる
    func setAllValue()
    {
        //セットする
        goldAmountLabel.setText(String(goldAmount))
        diamondAmountLabel.setText(String(diamondAmount))
        spentTimeLabel.setText(statusManager.calcSpendTime())
    }
    
    override func willActivate()
    {
        super.willActivate()
        
        let statusDict = statusManager.loadStatus(false)
        
        goldAmount = statusDict["goldenAmount"]!
        diamondAmount = statusDict["diamondAmount"]!//今は10を返す
        
        setAllValue()
        
        exchangeDataWithIphone("userInfoInt", action: "getValue", veriable: "diamondAmount", value1: "", value2: "")
    }
    
    override func getDataFromIphone(content:AnyObject)
    {
        super.getDataFromIphone(content)
        
        let reciveArray = content as! [String:AnyObject]
        
        //取得した値を保存してラベルに書く
        diamondAmount = reciveArray["result"]! as! Int
        statusManager.updateValue("diamondAmount", target_value: diamondAmount)
        diamondAmountLabel.setText(String(diamondAmount))
    }
    
    override func didDeactivate()
    {
        super.didDeactivate()
    }
}

