///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　ファイル名称：HelpViewController.swift
//　変更履歴：2015/12/2 作成
//
///////////////////////////////////////////////////////////////////////////////////////////////////
import UIKit



///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:ヘルプ画面クラス
//　概要：通知設定・クレジット等のメニューを表示する
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class HelpViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    // テーブルの識別用
    enum TableCell : Int{
        case TitleCell = 0
        case StatusHelpCell = 1
        case QuizHelpCell = 2
        case TictactoeHelpCell = 3
        case SpellGridHelpCell = 4
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
        
        // セルの内容をセットする
        customTable.append( labelcellData(name:"ヘルプ", height: 70 ))
        customTable.append( labelcellData(name:"ステータス", height: 45 ))
        customTable.append( labelcellData(name:"クイズ", height: 45 ))
        customTable.append( labelcellData(name:"三目並べ", height: 45 ))
        customTable.append( labelcellData(name:"SpellGrid", height: 45 ))
        
        
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Cellが選択された際に呼び出される.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch( indexPath.row )
        {
        case TableCell.StatusHelpCell.rawValue...TableCell.SpellGridHelpCell.rawValue:
            goToNextView(indexPath.row - TableCell.StatusHelpCell.rawValue);
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
        if( indexPath.row == TableCell.TitleCell.rawValue ){
            let cell: HelpTitleCell = tableView.dequeueReusableCellWithIdentifier("CustomHelpTitleCell", forIndexPath: indexPath) as! HelpTitleCell
            cell.SetData(customTable[indexPath.row])
            
            cell.layer.borderWidth = 8
            cell.layer.cornerRadius = 0
            cell.heightAnchor
        }
        
        //該当しない場合は標準セル
        let defcell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath)
        defcell.textLabel?.text = customTable[indexPath.row].name as String
        return defcell
    }
    
    //スワイプのスタイル設定
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None // スワイプ動作をなしにする
    }
    
    //セルの高さを調整する
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let celldata:labelcellData  = customTable[ indexPath.row ] as labelcellData
        
        return celldata.height
    }
    
    //ビューの遷移
    func goToNextView( nextid : Int )
    {
        let mainStb = UIStoryboard(name: "Main", bundle: nil)
        let nextview : [UIViewController] = [mainStb.instantiateViewControllerWithIdentifier("StatusHelpView")
            ,mainStb.instantiateViewControllerWithIdentifier("QuizHelpView")
            ,mainStb.instantiateViewControllerWithIdentifier("TictactoeHelpView")
            ,mainStb.instantiateViewControllerWithIdentifier("SpellGridHelpView")]
        self.presentViewController(nextview[nextid], animated: false, completion: nil);
    }
}
