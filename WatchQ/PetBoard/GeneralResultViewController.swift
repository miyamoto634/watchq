//
//  File.swift
//  WatchQ
//
//  Created by Ali on 18/11/2015.
//  Copyright © 2015 Ninja Egg. All rights reserved.
//

import UIKit
protocol GeneralResultViewControllerDelegate
{
    //to send
    func updateGeneralStatus(itemsAmount : Int, talkWithPetTimes : Int);
    func updateGeneralStatusBodyType(bodyType : String)
}

class GeneralResultViewController: UIViewController, PetViewControllerDelegate2
{
    var delegate: GeneralResultViewControllerDelegate?;
    
    @IBOutlet weak var quizResults: UILabel!//クイズ成績
    @IBOutlet weak var quizAccuracyRate: UILabel!//クイズ正解率
    @IBOutlet weak var tokui: UILabel!//とくい name
    @IBOutlet weak var tokuiResult: UILabel!//とくい rate
    @IBOutlet weak var weakName: UILabel!//にがて name
    @IBOutlet weak var weakRate: UILabel!//にがて rate
    @IBOutlet weak var spellGridResults: UILabel!//SpellGrid成績
    @IBOutlet weak var splellGridCorrectAnswers: UILabel!//SpellGrid正解率
    @IBOutlet weak var ticTacToePerformance: UILabel!//三目並べ成績
    @IBOutlet weak var ticTacToeWinning: UILabel!//三目並べ勝率
    
    //let generalResultViewController2 = GeneralResultViewController2();
    let statusManager = StatusManager();
    //let defaults = NSUserDefaults.standardUserDefaults();
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //for receive
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        appDelegate.generalResultViewController = self ;
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        //for send
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        delegate = appDelegate.generalResultViewController2;
        
         updateGeneralStatus()
    }
    
    func updateGeneralStatus()
    {
        //get dictionary
        var recordDict = statusManager.loadStringIntDict("recordDict1")
        print("recordDict1")
        
        if(recordDict == [:])
        {
            print("recordDict is empty");
            statusManager.initRecodeDict(true);
            recordDict = statusManager.loadStringIntDict("recordDict1");
        }
        
        //send it to GeneralResultViewController2 
        self.delegate?.updateGeneralStatus(recordDict["equipItemAmount"]!, talkWithPetTimes: recordDict["petTalkTime"]!);
        
        //to get name of category by index
        let nameD = ["歴史", "地理", "科学", "スポーツ", "芸術", "雑学"];
        
        //to get category answers by index
        let allAnswers = [recordDict["quizPlayedHistory"]!, recordDict["quizPlayedGeograpy"]!, recordDict["quizPlayedScience"]!, recordDict["quizPlayedSports"]!,  recordDict["quizPlayedArt"]!, recordDict["quizPlayedZatugaku"]!];
        //to get category correct answers by index
        let correctA = [recordDict["quizCorrectHistory"]!, recordDict["quizCorrectGeograpy"]!, recordDict["quizCorrectScience"]!, recordDict["quizCorrectSports"]!,  recordDict["quizCorrectArt"]!, recordDict["quizCorrectZatugaku"]!];
        
        var minValue = allAnswers[0];// using it only to get indexMin
        var maxValue = allAnswers[0];// using it only to get indexMax
        var indexMax = 0; // to save index of category that have bigest correct aswers
        var indexMin = 0; // to save index of category that have smallest correct aswers
        var quizResultsValue  = allAnswers[0]; // total of all answers
        var quizResultsCorrectValue  = correctA[0]; // total of of correct answers
        
        //search about min and max correct answer and save its index
        for(var i = 1; i < allAnswers.count; i++)
        {
            quizResultsValue  += allAnswers[i]; //  total all answers
            quizResultsCorrectValue += correctA[i]; //  total correct answers
            
            if(allAnswers[i] > maxValue)// get max index
            {
                maxValue = allAnswers[i];
                indexMax = i;
            }
            else if( allAnswers[i] < minValue)// get min index
            {
                minValue = allAnswers[i];
                indexMin = i;
            }
        }
        
        //quiz total answers
        quizResults.text = "\(quizResultsCorrectValue)/\(quizResultsValue)";
        changeLabelText(quizAccuracyRate, correctA: quizResultsCorrectValue, allAnswers: quizResultsValue)
        
        //quiz by category
        tokui.text = "とくい：\(nameD[indexMax])";
        weakName.text = "にがて：\(nameD[indexMin])";
        changeLabelText(tokuiResult, correctA: correctA[indexMax], allAnswers: allAnswers[indexMax])
        changeLabelText(weakRate, correctA: correctA[indexMin], allAnswers: allAnswers[indexMin]);
        
        //SpellGrid
        spellGridResults.text = "\(recordDict["spellGridCorrect"]!)/\(recordDict["spellGridPlayed"]!)";
        changeLabelText(splellGridCorrectAnswers, correctA: recordDict["spellGridCorrect"]!, allAnswers: recordDict["spellGridPlayed"]!)
        
        
        //TTT
        let TTTlosses = recordDict["TTTPlayed"]! - ( recordDict["TTTWin"]! +  recordDict["TTTDraw"]! );
        ticTacToePerformance.text = " \(recordDict["TTTWin"]!)勝\(TTTlosses)敗\(recordDict["TTTDraw"]!)引き分け";
        changeLabelText(ticTacToeWinning, correctA: recordDict["TTTWin"]!, allAnswers: recordDict["TTTPlayed"]!)
    }
   
    
    func changeLabelText(label : UILabel, correctA : Int, allAnswers : Int)
    {
        // to aviod division on 0
        if(allAnswers != 0)
        {
            let rate : Int = Int((Float(correctA)/Float(allAnswers)) * 100);
            label.text = "\(rate)%";
        }
        else
        {
            label.text = "0%";
        }
    }
    
    func updateGeneralStatusBodyType(bodyType : String)
    {
        delegate?.updateGeneralStatusBodyType(bodyType);
    }


}
