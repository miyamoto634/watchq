//
//  ParceCsv.swift
//  WatchQ
//
//  Created by H1-157 on 2015/08/21.
//  Copyright (c) 2015年 DaisukeMiyamoto. All rights reserved.
//

import Foundation

class PerthCsv: NSObject
{
    //指定ファイルのcsvをパースして、特定の配列の特定の値があるもののみ返す
    func filterType(filename: String, type: String, typeNum:String) -> [[String: String]]
    {
        var filterArray = [[String:String]]()//返す配列
        let originalArray = loadCSV(filename)//loadCSV
        let originalDictArray = replaceArray2Dict(originalArray, filename: filename)//配列を配列辞書へ
        
        //特定の配列（type）に特定の値（typeNum）と同じ物のみをappend
        for item in originalDictArray
        {
            if item[type] == typeNum
            {
                filterArray.append(item)
            }
        }
        return filterArray
    }
    
    //特定ファイルのcsvをパースして、特定の配列から特定の値があるもので一番はじめのものを返す
    func getType(filename: String, type: String, typeNum: String) -> [String:String]
    {
        let originalArray = loadCSV(filename)//loadCSV
        let originalDictArray = replaceArray2Dict(originalArray, filename: filename)//配列を配列辞書へ
        
        //特定の配列（type）に特定の値（typeNum）と同じ物のみをappend
        for item in originalDictArray
        {
            if item[type] == typeNum { return item }
        }
        
        return [String:String]()
    }
    
    //csvをパースして全てを返す
    func getAll(filename: String) -> [[String:String]]
    {
        let originalArray = loadCSV(filename)//loadCSV
        let originalDictArray = replaceArray2Dict(originalArray, filename: filename)//配列を配列辞書へ
        return originalDictArray
    }
    
    //３つランダムに問題を返す
    func randomThreeQuiz(filename: String, type: String) -> [[String:String]]
    {
        var returnArray = [[String:String]]()
        
        //３つの乱数求める
        var randNumArray = [Int]()
        var timeCount = 0
        while true
        {
            let rand = Int(arc4random_uniform(20))
            
            if randNumArray.count > 0
            {
                var flag = 0
                for item in randNumArray
                {
                    if item == rand
                    {
                        flag += 1
                    }
                }
                if flag == 0
                {
                    randNumArray.append(rand)
                    timeCount += 1
                }
            }
            else
            {
                randNumArray.append(rand)
                timeCount += 1
            }
            
            if timeCount == 3 { break }
        }
        print(randNumArray)
        
        //３つ探してくる
        for num in randNumArray
        {
            let dict = getType(filename, type: type, typeNum: String(num))
            returnArray.append(dict)
        }
        
        return returnArray
    }
    
    //laodCSVの配列を辞書に変形
    func replaceArray2Dict(originalArray:[String], filename: String) -> [[String: String]]
    {
        var replaceArray = [[String:String]]()
        
        for rowText in originalArray{
            if rowText != ""
            {
                let rowDict = exchangeArray(rowText, filename: filename)
                replaceArray.append(rowDict)
            }
        }
        return replaceArray
    }
    
    //loadCSVから返ってきた文字列を辞書型に変換する
    func exchangeArray(rowText :String, filename: String)->[String: String]
    {
        let rowArray = rowText.componentsSeparatedByString(",")
        var perthDict = [String:String]()
        
        if filename == "talk"
        {
            perthDict["type"]            =   rowArray[0]
            perthDict["ID1"]             =   rowArray[1]
            perthDict["ID2"]             =   rowArray[2]
            perthDict["condition"]       =   rowArray[3]
            perthDict["sentence"]        =   rowArray[4]
            perthDict["expression"]      =   rowArray[5]
            perthDict["input"]           =   rowArray[6]
            perthDict["property"]        =   rowArray[7]
            perthDict["divergence"]      =   rowArray[8]
            perthDict["compare"]         =   rowArray[9]
            perthDict["div1"]            =   rowArray[10]
            perthDict["div2"]            =   rowArray[11]
            perthDict["relation"]        =   rowArray[12]
            perthDict["fun"]             =   rowArray[13]
            perthDict["food"]            =   rowArray[14]
            perthDict["like"]            =   rowArray[15]
            perthDict["target"]          =   rowArray[16]
            
            return perthDict
        }
        
        if filename == "newtalk"
        {
            perthDict["type"]            =   rowArray[0]
            perthDict["ID1"]             =   rowArray[1]
            perthDict["ID2"]             =   rowArray[2]
            perthDict["condition1"]      =   rowArray[3]
            perthDict["condition1para1"] =   rowArray[4]
            perthDict["condition1para2"] =   rowArray[5]
            perthDict["condition2"]      =   rowArray[6]
            perthDict["condition2para1"] =   rowArray[7]
            perthDict["condition2para2"] =   rowArray[8]
            perthDict["sentence"]        =   rowArray[9]
            perthDict["expression"]      =   rowArray[10]
            perthDict["input"]           =   rowArray[11]
            perthDict["property"]        =   rowArray[12]
            perthDict["divergence"]      =   rowArray[13]
            perthDict["compare"]         =   rowArray[14]
            perthDict["div1"]            =   rowArray[15]
            perthDict["div2"]            =   rowArray[16]
            perthDict["relation"]        =   rowArray[17]
            perthDict["fun"]             =   rowArray[18]
            perthDict["food"]            =   rowArray[19]
            perthDict["like"]            =   rowArray[20]
            perthDict["target"]          =   rowArray[21]
            
            return perthDict
        }
        
        if filename == "items"
        {
            perthDict["ItemID"]          =   rowArray[0]
            perthDict["ItemType"]        =   rowArray[1]
            perthDict["Consume"]         =   rowArray[2]
            perthDict["ItemName"]        =   rowArray[3]
            perthDict["ItemSummary"]     =   rowArray[4]
            perthDict["How2Buy"]         =   rowArray[5]
            perthDict["Gold"]            =   rowArray[6]
            perthDict["Diamonds"]        =   rowArray[7]
            perthDict["Unlock"]          =   rowArray[8]
            perthDict["UnlockThreshold"] =   rowArray[9]
            perthDict["AddStamina"]      =   rowArray[10]
            perthDict["AddHealth"]       =   rowArray[11]
            perthDict["AddFun"]          =   rowArray[12]
            perthDict["AddFood"]         =   rowArray[13]
            perthDict["AddSleep"]        =   rowArray[14]
            perthDict["AddRelation"]     =   rowArray[15]
            perthDict["AddLevel"]        =   rowArray[16]
            perthDict["AddExp"]          =   rowArray[17]
            perthDict["AddGold"]         =   rowArray[18]
            perthDict["AddDiamond"]      =   rowArray[19]
            
            return perthDict
        }
        
        if filename == "quiz" || filename == "history" || filename == "geographic" || filename == "art" || filename == "sport" || filename == "science" || filename == "zatugaku"
        {
            perthDict["ID"]              =   rowArray[0]
            perthDict["Category"]        =   rowArray[1]
            perthDict["Question"]        =   rowArray[2]
            perthDict["select1"]         =   rowArray[3]
            perthDict["select2"]         =   rowArray[4]
            perthDict["select3"]         =   rowArray[5]
            perthDict["select4"]         =   rowArray[6]
            
            return perthDict
        }
        
        if filename == "spellgrid"
        {
            perthDict["ID"]              =   rowArray[0]
            perthDict["Hint"]            =   rowArray[1]
            perthDict["Answer"]          =   rowArray[2]
        }
        
        return perthDict
    }
    
    //CSVファイルの読み込みメソッド。引数にファイル名、返り値にString型の配列。
    func loadCSV(filename :String)->[String]
    {
        //CSVファイルの読み込み
        let csvBundle = NSBundle.mainBundle().pathForResource(filename, ofType: "csv")
      
        //csvBundleのパスを読み込み、UTF8に文字コード変換して、NSStringに格納
        let csvData = try! NSString(contentsOfFile: csvBundle!, encoding: NSUTF8StringEncoding)
        //改行コードが"\r"で行なわれている場合は"\n"に変更する
        let lineChange = csvData.stringByReplacingOccurrencesOfString("\r", withString: "\n")
        //"\n"の改行コードで区切って、配列csvArrayに格納する
        let csvArray = lineChange.componentsSeparatedByString("\n")
        
        return csvArray
    }
}