///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　ファイル名称：CustomCell.swift
//　変更履歴：２０１５年１０月９日作成
//
///////////////////////////////////////////////////////////////////////////////////////////////////

import Foundation
import UIKit

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:labelcellData
//　概要：ラベルのみのデータを取り扱うデータクラス
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class labelcellData : NSObject {
    var name: NSString
    var height: CGFloat
    
    init(name: String, height: CGFloat) {
        self.name = name
        self.height = height
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:labelswitchcellData
//　概要：ラベルとスイッチを持つタイプのセルデータクラス
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class labelswitchcellData : labelcellData {
    var sw: Bool

    init(name: String, sw: Bool, height: CGFloat) {
        self.sw = sw
        super.init( name: name, height: height )
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:slider3cellData
//　概要：ラベルと３段階のスライダー・ラベルを持つタイプのセルデータクラス
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class slider3cellData : labelcellData {
    var slider: Float
    var leftLabel: NSString
    var middleLabel: NSString
    var rightLabel: NSString
    
    init(name: String, slider: Float, leftLabel: String, middleLabel: String, rightLabel: String, height: CGFloat ) {
        self.slider = slider
        self.leftLabel = leftLabel
        self.middleLabel = middleLabel
        self.rightLabel = rightLabel
        super.init( name: name, height: height )
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:NotificationSettingCell
//　概要：通知設定に使用するスイッチとラベルが付いたカスタムセルのコントロールクラス
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class NotificationSettingCell : UITableViewCell {
    var data: labelswitchcellData?
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    
    //初期化
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func SetData(obj: NSObject){
        data = obj as? labelswitchcellData
        cellText.text = data!.name as String
        cellSwitch.on = data!.sw
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:SettingTitleCell
//　概要：通知設定画面に使用する、ボタンとラベルが付いたカスタムセルのコントロールクラス
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class SettingTitleCell : UITableViewCell {
    var data: labelcellData?
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    
    //初期化
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func SetData(obj: NSObject){
        data = obj as? labelcellData
        cellText.text = data!.name as String
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:SettingSubTitleCell
//　概要：見出し用に文字の大きさを調整した、サブタイトル用のカスタムセルのコントロールクラス
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class SettingSubTitleCell : UITableViewCell {
    
    var data: labelcellData?
    @IBOutlet weak var cellText: UILabel!
    
    //初期化
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func SetData(obj: NSObject){
        data = obj as? labelcellData
        cellText.text = data!.name as String
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:SettingTalkSpeedCell
//　概要：会話のスピード調節用のスライダーを実装したセル
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class SettingTalkSpeedCell : UITableViewCell {
    
    var data: slider3cellData?
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var slowText: UILabel!
    @IBOutlet weak var defaultText: UILabel!
    @IBOutlet weak var fastText: UILabel!
    @IBOutlet weak var talkspeedSlider: UISlider!
    
    //初期化
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func SetData(obj: NSObject){

        data = obj as? slider3cellData
        cellText.text = data!.name as String
        slowText.text = data!.leftLabel as String
        defaultText.text = data!.middleLabel as String
        fastText.text = data!.rightLabel as String
        
        talkspeedSlider.minimumValue = -1
        talkspeedSlider.maximumValue = 1
        talkspeedSlider.value = data!.slider
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//
//　クラス名称:SettingTitleCell
//　概要：通知設定画面に使用する、ボタンとラベルが付いたカスタムセルのコントロールクラス
//
///////////////////////////////////////////////////////////////////////////////////////////////////
class HelpTitleCell : UITableViewCell {
    var data: labelcellData?
    @IBOutlet weak var cellText: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    
    //初期化
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func SetData(obj: NSObject){
        data = obj as? labelcellData
        cellText.text = data!.name as String
    }
}
