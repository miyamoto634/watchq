//
//  PetBaseInterfaceController.swift
//  WatchQ
//
//  Created by H1-157 on 2015/11/30.
//  Copyright © 2015年 Ninja Egg. All rights reserved.
//

import WatchKit
import Foundation

class PetBaseInterfaceController: ConnectionInterfaceController
{
    //ステータスクラスマネージャー
    var statusManager = StatusManager()
    
    ////////// アウトレット //////////
    //画像
    var petBaseBalloon        : WKInterfaceGroup!
    var petBaseHeadEffect     : WKInterfaceGroup!
    var petBaseCloth          : WKInterfaceGroup!
    var petBaseEyeAcce        : WKInterfaceGroup!
    var petBaseHairAcce       : WKInterfaceGroup!
    var petBaseMouth          : WKInterfaceGroup!
    var petBaseEye            : WKInterfaceGroup!
    var petBaseHair           : WKInterfaceGroup!
    var petBaseSkinEffect     : WKInterfaceGroup!
    var petBaseMakeup         : WKInterfaceGroup!
    var petBaseSkin           : WKInterfaceGroup!
    var petBaseGroup          : WKInterfaceGroup!
    //文字
    var petBaseBalloonLabel1  : WKInterfaceLabel!
    var petBaseBalloonLabel2  : WKInterfaceLabel!
    
    
    //変数
    var playerName                      = ""//プレイヤー名
    var petName                         = ""//ペット名
    var petGender                       = ""//ペット性別
    var maxCharacter                    = 13//最大文字数
    var animationName                   = ""//アニメーション用イメージ設定するString
    var petWink                         = true//瞬きしているか
    var messageArray                    = [String]()//文字を格納する配列
    var showMessage:String              = ""//表示する文字
    var showMessage2:String             = ""//２行目に表示する文字
    var firstLineEnd:Int                = 0//文字取得終了位置
    var firstLineStart                  = 0//文字取得開始位置
    var secondLineStart                 = 0//２行目開始位置
    var secondLineEnd                   = 0//２行目終了位置
    var petTalkTextSpeed:NSTimeInterval = 0.2//ペット会話速度
    var finishInterval:NSTimeInterval   = 3.0//メッセージ終了後の間
    
    var messageTimer:NSTimer!
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        //文字速度設定
        petTalkTextSpeed = statusManager.getPetTalkTextSpeed()
        
        //名前をセット
        playerName = statusManager.loadString("playerName")
        petName = statusManager.loadString("petName")
        
        //画面サイズを取得、会話文の長さ設定
        let currentDevice = WKInterfaceDevice.currentDevice()
        let bounds = currentDevice.screenBounds
        if bounds.width <= 136.0 { maxCharacter = 11 }
        
        //ペットの性別
        if statusManager.loadValue("petgender") == 1 { petGender = "man" }
        else { petGender = "woman" }
    }
    
    //アウトレットをセットアップ
    func setUpPetOutlets(
        petBalloon:WKInterfaceGroup,
        petHeadEffect:WKInterfaceGroup,
        petCloth:WKInterfaceGroup,
        petEyeAcce:WKInterfaceGroup,
        petHairAcce:WKInterfaceGroup,
        petMouth:WKInterfaceGroup,
        petEye:WKInterfaceGroup,
        petHair:WKInterfaceGroup,
        petSkinEffect:WKInterfaceGroup,
        petMakeup:WKInterfaceGroup,
        petSkin:WKInterfaceGroup,
        petGroup:WKInterfaceGroup,
        petBalloonLabel1:WKInterfaceLabel,
        petBalloonLabel2:WKInterfaceLabel)
    {
        //画像のアウトレット
        petBaseBalloon          = petBalloon
        petBaseHeadEffect       = petHeadEffect
        petBaseCloth            = petCloth
        petBaseEyeAcce          = petEyeAcce
        petBaseHairAcce         = petHairAcce
        petBaseMouth            = petMouth
        petBaseEye              = petEye
        petBaseHair             = petHair
        petBaseSkinEffect       = petSkinEffect
        petBaseMakeup           = petMakeup
        petBaseSkin             = petSkin
        petBaseGroup            = petGroup
        //文字のアウトレット
        petBaseBalloonLabel1    = petBalloonLabel1
        petBaseBalloonLabel2    = petBalloonLabel2
    }
    
    
    //辞書に対応された感情番号からペットの顔を置き換える
    func setExpressionFromDict(expressionNum:String)
    {
        //表情リセット
        petBaseHeadEffect.setBackgroundImage(nil)
        petBaseMouth.setBackgroundImage(nil)
        petBaseEye.setBackgroundImage(nil)
        petBaseSkinEffect.setBackgroundImage(nil)
        
        //新たな表情追加
        switch expressionNum
        {
        case "0":
            setPetExpressionImage("default", isSkinEffect:false, isHeadEffect: false)
            petBaseMouth.stopAnimating()
            return
        case "1":
            setPetExpressionImage("default_talk", isSkinEffect:false, isHeadEffect: false)
            return
        case "2":
            setPetExpressionImage("_happy", isSkinEffect:false, isHeadEffect: false)
            return
        case "3":
            setPetExpressionImage("_angry", isSkinEffect:false,isHeadEffect: true)
            return
        case "4":
            setPetExpressionImage("_sad", isSkinEffect:true, isHeadEffect: false)
            return
        case "5":
            setPetExpressionImage("_surprise", isSkinEffect: false, isHeadEffect: true)
            return
        case "6":
            if petGender == "man"
            {
                setPetExpressionImage("_sleepy", isSkinEffect:false, isHeadEffect: true)
            }
            else
            {
                setPetExpressionImage("_sleepy", isSkinEffect:false, isHeadEffect: false)
            }
            petWink = false
            return
        case "7":
            setPetExpressionImage("_sleeping", isSkinEffect:false, isHeadEffect: true)
            petWink = false
            return
        case "8":
            setPetExpressionImage("_hungry", isSkinEffect: true, isHeadEffect: false)
            return
        case "9":
            setPetExpressionImage("_benotsatisfied", isSkinEffect:false,  isHeadEffect: false)
            return
        case "10":
            setPetExpressionImage("_shy", isSkinEffect: true, isHeadEffect: false)
            return
        case "11":
            setPetExpressionImage("_lovelove", isSkinEffect:true,  isHeadEffect: true)
            return
        default:
            return
        }
    }
    
    //実際にセットする
    func setPetExpressionImage(expressionName:String, isSkinEffect:Bool, isHeadEffect:Bool)
    {
        let petImageDict = statusManager.getPetImageDict()
        
        //ヒゲか判定
        var isBeardOn = false
        if (["Pet_gold_10000_man_petMouth", "Pet_quiz_1000_petMouth", "Pet_spend_man_petMouth"].filter{ $0==petImageDict["petMouth"]!}.isEmpty)
            {
                isBeardOn = true
        }
        
        if expressionName == "default"
        {
            for (key, value) in petImageDict
            {
                if value != ""
                {
                    setPetImage(key,value: value)
                }
            }
            animationName = petImageDict["petBodyType"]!
            return
        }
        if expressionName == "default_talk"
        {
            for (key, value) in petImageDict
            {
                if value != ""
                {
                    setPetImage(key,value: value)
                }
            }
            animationName = petImageDict["petBodyType"]!
            
            //ヒゲならヒゲつける
            if !isBeardOn
            {
                petBaseMouth.setBackgroundImageNamed(animationName+"_petMouthMumble_")
                petBaseMouth.startAnimatingWithImagesInRange(NSMakeRange(1, 3), duration: 0.5, repeatCount: 0)
            }
            
            return
        }
        
        animationName = "Pet_default_"+String(petGender)+expressionName
        
        if !isBeardOn
        {
            petBaseMouth.setBackgroundImageNamed(animationName+"_petMouthMumble_")
            petBaseMouth.startAnimatingWithImagesInRange(NSMakeRange(1, 3), duration: 0.5, repeatCount: 0)
        }
        else
        {
            petBaseMouth.setBackgroundImageNamed(petImageDict["petMouth"]!)
            print(petImageDict["petMouth"]!)
        }
        petBaseEye.setBackgroundImageNamed(animationName+"_petEyeWink_")
        
        if isSkinEffect
        {
            petBaseSkinEffect.setBackgroundImageNamed(animationName+"_petSkinEffect")
        }
        
        if isHeadEffect
        {
            petBaseHeadEffect.setBackgroundImageNamed(animationName+"_petHeadEffect_")
            petBaseHeadEffect.startAnimatingWithImagesInRange(NSMakeRange(1, 3), duration: 0.5, repeatCount: 0)
        }
    }
    
    //ペット画像セット
    func setPetImage(key:String, value:String)
    {
        switch key
        {
        case "petHairAcce":
            if value == "" { petBaseHairAcce.setBackgroundImage(nil) }
            else { petBaseHairAcce.setBackgroundImageNamed(value) }
            break
        case "petEyeAcce":
            if value == "" { petBaseEyeAcce.setBackgroundImage(nil) }
            else { petBaseEyeAcce.setBackgroundImageNamed(value) }
            break
        case "petCloth":
            if value == "" { petBaseCloth.setBackgroundImage(nil) }
            else { petBaseCloth.setBackgroundImageNamed(value) }
            break
        case "petHair":
            if value == "" { petBaseHair.setBackgroundImage(nil) }
            else { petBaseHair.setBackgroundImageNamed(value) }
            break
        case "petEye":
            if value == "" { petBaseEye.setBackgroundImage(nil) }
            else { petBaseEye.setBackgroundImageNamed(value) }
            break
        case "petMouth":
            if value == "" { petBaseMouth.setBackgroundImage(nil) }
            else { petBaseMouth.setBackgroundImageNamed(value) }
            break
        case "petSkin":
            if value != "Pet_zatugaku_rand_petSkin" && value != "Pet_science_rand_petSkin"
            {
                if value == "" { petBaseSkin.setBackgroundImage(nil) }
                else { petBaseSkin.setBackgroundImageNamed(value) }
            }
            break
        case "petMakeup":
            if value == "" { petBaseMakeup.setBackgroundImage(nil) }
            else { petBaseMakeup.setBackgroundImageNamed(value) }
            break
        default:
            break
        }
    }
    
    //テキストを追加
    func updateMessage()
    {
        if firstLineEnd < messageArray.count && secondLineEnd < messageArray.count
        {
            showMessage = ""
            showMessage2 = ""
            if secondLineStart == 0
            {
                for index in firstLineStart...firstLineEnd
                {
                    showMessage += messageArray[index]
                }
                
                if firstLineEnd - firstLineStart >= maxCharacter - 1
                {
                    secondLineStart = maxCharacter
                    secondLineEnd = maxCharacter
                }
                else
                {
                    firstLineEnd += 1
                }
            }
            else
            {
                if secondLineEnd - secondLineStart >= maxCharacter
                {
                    firstLineStart = secondLineStart
                    firstLineEnd = secondLineEnd - 1
                    secondLineStart = secondLineEnd
                    secondLineEnd = secondLineStart
                }
                
                for index in firstLineStart...firstLineEnd
                {
                    showMessage += messageArray[index]
                }
                for index in secondLineStart...secondLineEnd
                {
                    showMessage2 += messageArray[index]
                }
                
                secondLineEnd += 1
            }
            
            //文字を表示
            let menloFont = UIFont(name: "HiraKakuProN-W6", size: 12.0)!
            let fontAttrs = [NSFontAttributeName : menloFont]
            let attrString = NSAttributedString(string: showMessage, attributes: fontAttrs)
            let attrString2 = NSAttributedString(string: showMessage2, attributes: fontAttrs)
            petBaseBalloonLabel1.setAttributedText(attrString)
            petBaseBalloonLabel2.setAttributedText(attrString2)
            
            //再びこの関数を呼び出す
            messageTimer = NSTimer.scheduledTimerWithTimeInterval(petTalkTextSpeed, target: self, selector: "updateMessage", userInfo: nil, repeats: false)
        }
        else
        {
            //時間が経過して吹き出しが閉じる
            messageTimer = NSTimer.scheduledTimerWithTimeInterval(finishInterval, target: self, selector: "finishMessage", userInfo: nil, repeats: false)
        }
        
    }
    
    //メッセージ終了後の処理
    func finishMessage()
    {
        //オーバーライドして使用
    }
}