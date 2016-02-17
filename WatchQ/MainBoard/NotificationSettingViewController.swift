///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　ファイル名称：notificationSettingViewController.swift
//　変更履歴：2015/10/9 作成
//          2015/10/22 ステータスの仕様変更に伴い、健康通知・空腹通知の削除
//　　　　　　　　　　　　 ❌ボタンの位置調整、ちょっと上すぎた
//          2015/12/1 ３段階で会話を調整するスライドバー追加
//
///////////////////////////////////////////////////////////////////////////////////////////////////
import UIKit


///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:通知設定画面クラス
//　概要：通知設定・クレジット等のメニューを表示する
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class SettingViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    // テーブルの識別用
    enum TableCell : Int{
        case OptionCell = 0
        case StaminaNotificationCell = 1
        case FoodNotificationCell = 2
        case TalkSpeedCell = 3
        case OtherCell = 4
        case CreditCell = 5
        case NinjaEggCell = 6
    }
    
    var customTable:[labelcellData] = [labelcellData]()
    
    let defaults = NSUserDefaults(suiteName:"group.com.platinum-egg.WatchQ.userdefaults")
    let defaults1 = NSUserDefaults.standardUserDefaults();
    let statusManager = StatusManager();
    
    //ビュー
    @IBOutlet weak var customTableView: UITableView!
    
    // 画面が開こうとしている時
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定を読み込む
        var staminaflag : Bool = true
        var foodflag : Bool = true
        var talkspeed : Float = 0.0;
        if( statusManager.loadValue( "StaminaNotificationFlag" ) == 1 ) {
            staminaflag = true
        } else {
            staminaflag = false
        }
        if( statusManager.loadValue( "FoodNotificationFlag" ) == 1 ) {
            foodflag = true
        } else {
            foodflag = false
        }
        talkspeed = Float(statusManager.loadValue( "petTalkTextSpeed" ))
        
        // セルの内容をセットする
        customTable.append( labelcellData(name:"オプション", height: 70 ))
        customTable.append( labelswitchcellData(name:"スタミナの通知", sw:staminaflag, height: 45 ))
        customTable.append( labelswitchcellData(name:"満腹度の通知",sw:foodflag, height: 45 ))
        customTable.append( slider3cellData(name:"会話スピード", slider: talkspeed, leftLabel: "おそい", middleLabel: "ふつう" , rightLabel: "はやい", height: 90 ))
        
        customTable.append( labelcellData(name:"その他", height: 70 ))
        customTable.append( labelcellData(name:"クレジット", height: 45 ))
        customTable.append( labelcellData(name:"Ninja Egg", height: 45 ))
        
        
        //iPhone固有のステータスバーに被らない様にする
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        customTableView.frame = CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight)
        
        // Cellの登録.
        customTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        customTableView.dataSource = self
        customTableView.delegate = self
        
        // 枠の調整
//        customTableView.estimatedRowHeight = 70
        customTableView.rowHeight = UITableViewAutomaticDimension
        customTableView.layer.borderWidth = 8
        customTableView.layer.borderColor = UIColor.blackColor().CGColor
        customTableView.layer.cornerRadius = 10//枠を丸める
        customTableView.layer.masksToBounds = true//枠線によってマスク
        
    }
    
    // 画面が閉じようとするとき
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    //❌ボタンが押された
    @IBAction func onTouchUpBackButton(sender: AnyObject) {
        let staminacell: labelswitchcellData = customTable[TableCell.StaminaNotificationCell.rawValue] as! labelswitchcellData
        let foodcell: labelswitchcellData = customTable[TableCell.FoodNotificationCell.rawValue] as! labelswitchcellData
        let talkspeedcell: slider3cellData = customTable[TableCell.TalkSpeedCell.rawValue] as! slider3cellData
        let talkspeed = Int( talkspeedcell.slider )
        
        //値取得と保存
        if( staminacell.sw == true ){
            statusManager.updateValue( "StaminaNotificationFlag", target_value:1 )
        } else {
            statusManager.updateValue( "StaminaNotificationFlag", target_value:0 )
        }
        if( foodcell.sw == true ){
            statusManager.updateValue( "FoodNotificationFlag", target_value:1 )
        } else {
            statusManager.updateValue( "FoodNotificationFlag", target_value:0 )
        }
        statusManager.updateValue( "petTalkTextSpeed", target_value:talkspeed )
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Cellが選択された際に呼び出される.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch( indexPath.row )
        {
        case TableCell.CreditCell.rawValue:
            // クレジットビューに移動させる
            goToCreditView();
            break;
        case TableCell.NinjaEggCell.rawValue:
            // WebSiteに移動させる
            let url = NSURL(string: "http://www.ninja-egg.com/home/contact/")!
            UIApplication.sharedApplication().openURL(url)//open url by web browser
            break;
        default:
            break;
        }
    }
    
    //Cellの総数を返す.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customTable.count
    }
    
    //Editableの状態にする.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //特定の行のボタン操作を有効にする.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //テーブル内のセルに値を設定する
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // トップセル　戻るボタン付き
        if( indexPath.row == TableCell.OptionCell.rawValue ){
            let cell: SettingTitleCell = tableView.dequeueReusableCellWithIdentifier("CustomTitleCell", forIndexPath: indexPath) as! SettingTitleCell
            cell.SetData(customTable[indexPath.row])
            
            cell.layer.borderWidth = 8
            cell.layer.cornerRadius = 0
            cell.heightAnchor
        }
        
        //通知設定セル
        if( indexPath.row == TableCell.StaminaNotificationCell.rawValue ||
            indexPath.row == TableCell.FoodNotificationCell.rawValue ){

            let cell: NotificationSettingCell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as! NotificationSettingCell
            cell.SetData(customTable[indexPath.row])
            cell.cellSwitch.tag = indexPath.row;
            cell.cellSwitch.addTarget(self, action: "changeUISwitchValue:", forControlEvents: .ValueChanged)
            
            return cell
        }
        
        //見出しセル
        if( indexPath.row == TableCell.OtherCell.rawValue ){
            let cell: SettingSubTitleCell = tableView.dequeueReusableCellWithIdentifier("CustomSubTitleCell", forIndexPath: indexPath) as! SettingSubTitleCell
            cell.SetData(customTable[indexPath.row])
            
            cell.layer.borderWidth = 5
            cell.layer.cornerRadius = 0
            return cell
        }
        
        //会話スピード調節セル
        if( indexPath.row == TableCell.TalkSpeedCell.rawValue ){
            let cell: SettingTalkSpeedCell = tableView.dequeueReusableCellWithIdentifier("CustomSliderCell", forIndexPath: indexPath) as! SettingTalkSpeedCell
            cell.SetData(customTable[indexPath.row])
            cell.talkspeedSlider.tag = indexPath.row;
            cell.talkspeedSlider.addTarget(self, action: "changeUISliderValue:", forControlEvents: .ValueChanged)
            return cell
        }

        //該当しない場合は標準セル
        let defcell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)
        defcell.textLabel?.text = customTable[indexPath.row].name as String
        return defcell
    }
 
    //スイッチ操作時のイベント
    func changeUISwitchValue(sender: UISwitch) {
        
        // スイッチに割り振っておいた番号を表示
        let cell: labelswitchcellData = customTable[sender.tag] as! labelswitchcellData
        cell.sw = sender.on
    }
    
    //スライダー操作時のイベント
    func changeUISliderValue(sender: UISlider) {
        
        // スイッチに割り振っておいた番号を表示
        let cell: slider3cellData = customTable[sender.tag] as! slider3cellData
        if( sender.value < -0.5 ){
            cell.slider = -1.0
        }else if( sender.value < 0.5 ){
            cell.slider = 0.0
        }else if( sender.value < 1.0 ){
            cell.slider = 1.0
        }
        sender.value = cell.slider
    }

    //スワイプのスタイル設定
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None // スワイプ動作をなしにする
    }
    
    // セルの高さを調整する
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let celldata:labelcellData  = customTable[ indexPath.row ] as labelcellData

        return celldata.height
    }
    
    //by Ali,  to move to creditViewController when call this func
    func goToCreditView()
    {
        let mainStb = UIStoryboard(name: "Main", bundle: nil)
        let nextview = mainStb.instantiateViewControllerWithIdentifier("CreditView") //as! CreditViewController
        self.presentViewController(nextview, animated: false, completion: nil);
    }
}
