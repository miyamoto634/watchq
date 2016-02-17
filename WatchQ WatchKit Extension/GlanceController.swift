//
//  GlanceController.swift
//  WatchQ WatchKit Extension
//
//  Created by H1-157 on 2015/05/14.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController
{
    //ステータスマネージャー
    let statusManager = StatusManager()
    
    //アウトレット
    //画像
    @IBOutlet var foodUnit1Image: WKInterfaceImage!
    @IBOutlet var foodUnit2Image: WKInterfaceImage!
    @IBOutlet var foodUnit3Image: WKInterfaceImage!
    @IBOutlet var foodUnit4Image: WKInterfaceImage!

    @IBOutlet var sleepUnitImage: WKInterfaceImage!
    
    //文字
    @IBOutlet var staminaLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
    }

    override func willActivate()
    {
        super.willActivate()
        
        //各値の取得
        setImageUnits(statusManager.loadValue("feedingV")/864, type: "food")
        setImageUnits(statusManager.loadValue("sleepingV")/720, type: "sleep")
        
        staminaLabel.setText(String(statusManager.loadValue("staminaV")/900)+"/"+String(statusManager.loadValue("staminaMaxV")/900))
    }

    override func didDeactivate()
    {
        super.didDeactivate()
    }

    func setImageUnits(stateValue: Int,type: String)
    {
        var stateNum = 0
        
        switch stateValue
        {
        case 0:
            stateNum = 0
            break
        case 1...30:
            stateNum = 1
            break
        case 31...50:
            stateNum = 2
            break
        case 51...80:
            stateNum = 3
            break
        case 81...100:
            stateNum = 4
            break
        default:
            break
        }
        
        if type == "food"
        {
            switch stateNum
            {
            case 0:
                foodUnit1Image.setImageNamed("foodunit_icon_blank")
                foodUnit2Image.setImageNamed("foodunit_icon_blank")
                foodUnit3Image.setImageNamed("foodunit_icon_blank")
                foodUnit4Image.setImageNamed("foodunit_icon_blank")
                break
            case 1:
                foodUnit1Image.setImageNamed("foodunit_icon_blank")
                foodUnit2Image.setImageNamed("foodunit_icon_blank")
                foodUnit3Image.setImageNamed("foodunit_icon_blank")
                foodUnit4Image.setImageNamed("foodunit_icon")
                break
            case 2:
                foodUnit1Image.setImageNamed("foodunit_icon_blank")
                foodUnit2Image.setImageNamed("foodunit_icon_blank")
                foodUnit3Image.setImageNamed("foodunit_icon")
                foodUnit4Image.setImageNamed("foodunit_icon")
                break
            case 3:
                foodUnit1Image.setImageNamed("foodunit_icon_blank")
                foodUnit2Image.setImageNamed("foodunit_icon")
                foodUnit3Image.setImageNamed("foodunit_icon")
                foodUnit4Image.setImageNamed("foodunit_icon")
                break
            case 4:
                foodUnit1Image.setImageNamed("foodunit_icon")
                foodUnit2Image.setImageNamed("foodunit_icon")
                foodUnit3Image.setImageNamed("foodunit_icon")
                foodUnit4Image.setImageNamed("foodunit_icon")
                break
            default:
                break
            }
            
            return
        }
        
        if type == "sleep"
        {
            sleepUnitImage.setImageNamed("sleepunit_icon_"+String(stateNum)+"@42")
            
            return
        }
    }
    
}
