//
//  LQChapterMenu.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/11.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import SnapKit

protocol LQChapterSelectDelegate: NSObjectProtocol {
    func chapterMenu(chapterMenu: LQChapterMenu, chapterIndex: Int)
    func chapterMenu(chapterMenu: LQChapterMenu, markIndex: Int)
}

class LQChapterMenu: UIControl, LQSegmentedControlDelegate, UITableViewDelegate, UITableViewDataSource {
    weak var readBook: LQBookController? = nil {
        didSet {tableView.reloadData()}
    }
    weak var delegate: LQChapterSelectDelegate? = nil
    /// topView
    private(set) var topView:LQSegmentedControl!
    /// UITableView
    private(set) var tableView:UITableView!
    /// contentView
    private(set) var contentView:UIView!
    /// 类型 0: 章节 1: 书签
    private var type:NSInteger = 0
    private var currentChapterNo: Int? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // contentView
        contentView = UIView()
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        addSubview(contentView)

        // UITableView
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        contentView.addSubview(tableView)

        // topView
        topView = LQSegmentedControl()
        topView.delegate = self
        topView.normalTitles = ["章节","书签"]
        topView.selectTitles = ["章节","书签"]
        topView.horizontalShowTB = false
        topView.backgroundColor = UIColor.clear
        topView.normalTitleColor = LQColor_6
        topView.selectTitleColor = LQColor_2
        topView.setup()
        contentView.addSubview(topView)
        
        contentView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(self.snp.width).multipliedBy(0.6)
        }
        
        topView.snp.makeConstraints { (make) in
            make.left.right.equalTo(contentView)
            make.top.equalTo(contentView).offset(isX ? TopLiuHeight : 0)
            make.height.equalTo(33)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(contentView)
            make.top.equalTo(topView.snp.bottom)
        }
    }
    
    func scrollReadRecord(chapterNo: Int?) {
        self.currentChapterNo = chapterNo
        if let currentChapterNo = self.currentChapterNo {
            tableView.scrollToRow(at: IndexPath(row: currentChapterNo, section: 0), at: UITableViewScrollPosition.middle, animated: false)
        }
    }
    
    // MARK: -- LQSegmentedControlDelegate
    func segmentedControl(segmentedControl: LQSegmentedControl, clickButton button: UIButton, index: NSInteger) {
        type = index
        tableView.reloadData()
        scrollReadRecord(chapterNo: self.currentChapterNo)
    }
    
    
    // MARK: -- UITableViewDelegate,UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == 0 { // 章节
            return readBook?.totalChapter ?? 0
        }else{ // 书签
            return 0//(readMenu.vc.readModel != nil ? readMenu.vc.readModel.readMarkModels.count : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LQRMLeftViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "LQRMLeftViewCell")
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear
        }
        
        if type == 0 { // 章节
            cell?.textLabel?.text = readBook?.chapterTitle(chapterNo: indexPath.row)
            cell?.textLabel?.numberOfLines = 1
            cell?.textLabel?.font = LQFont_18
            
        }else{ // 书签
            let readMarkModel = ""//readMenu.vc.readModel.readMarkModels[indexPath.row]
            cell?.textLabel?.text = ""//\n\(readMarkModel.name!)\n\(GetTimerString(dateFormat: "YYYY-MM-dd HH:mm:ss", date: readMarkModel.time!))\n\(readMarkModel.content!))"
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.font = LQFont_12
        }
        
        cell?.textLabel?.textColor = LQColor_6
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if type == 0 { // 章节
            return 44
        }else{ // 书签
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if type == 0 { // 章节
            self.delegate?.chapterMenu(chapterMenu: self, chapterIndex: indexPath.row)
            //readMenu.delegate?.readMenuClickChapterList?(readMenu: readMenu, readChapterListModel: readMenu.vc.readModel.readChapterListModels[indexPath.row])
        }else{ // 书签
            self.delegate?.chapterMenu(chapterMenu: self, markIndex: indexPath.row)
            //readMenu.delegate?.readMenuClickMarkList?(readMenu: readMenu, readMarkModel: readMenu.vc.readModel.readMarkModels[indexPath.row])
        }
        
        // 隐藏
        //readMenu.leftView(isShow: false, complete: nil)
    }
    
    // MARK: -- 删除操作
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if type == 0 { // 章节
            return false
        }else{ // 书签
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        let _ = readMenu.vc.readModel.removeMark(readMarkModel: nil, index: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
}
