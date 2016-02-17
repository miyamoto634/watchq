//
//  GeneralResultViewController2.swift
//  WatchQ
//
//  Created by Ali on 18/11/2015.
//  Copyright © 2015 Ninja Egg. All rights reserved.
//

import UIKit

class GeneralResultViewController2 : UIViewController, GeneralResultViewControllerDelegate
{
    
    
    @IBOutlet weak var itemsRate: UILabel!//装備アイテム所持率
    @IBOutlet weak var currentType: UILabel!//現在のタイプ
    @IBOutlet weak var timesSpeakWithPet: UILabel!//ペットとの会話回数
    
    let statusManager = StatusManager();
   
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.generalResultViewController2 = self ;
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        let imagesDict = statusManager.getPetImageDict()
        if (imagesDict != [String:String]())
        {
            cahngeBodyTypetext(imagesDict["petBodyType"]!);
        }
    }
    
    
    
    func updateGeneralStatus(itemsAmount : Int, talkWithPetTimes : Int)
    {
        itemsRate.text = "\(itemsAmount)個";
        timesSpeakWithPet.text = "\(talkWithPetTimes)回";
        
        print("GeneralResultViewController2");
    }
    
    func updateGeneralStatusBodyType(bodyType : String)
    {
        cahngeBodyTypetext(bodyType)
        print("bodyType");
    }
    
   func cahngeBodyTypetext(bodyType : String)
   {
        var setText = "デフォルト"
        switch bodyType
        {
        case "Pet_history_rand":
            setText = "歴史"
            break
        case "Pet_science_rand":
            setText = "科学"
            break
        case "Pet_sport_rand":
            setText = "スポーツ"
            break
        case "Pet_zatugaku_rand":
            setText = "雑学"
            break
        case "Pet_geography_rand":
            setText = "地理"
            break
        case "Pet_art_rand":
            setText = "芸術"
            break
        default:
            break
        }
        currentType.text = setText;
    }
}