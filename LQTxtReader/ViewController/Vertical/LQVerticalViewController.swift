//
//  LQVerticalViewController.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import SnapKit

private let LQVerticalCellReuseIdentifier = "LQVerticalCellReuseIdentifier"

class LQVerticalViewController: UIViewController, LQReadTxtProtocol, UITableViewDelegate, UITableViewDataSource, LQSliderBarDelegate {
    var readBook: LQBookController? = nil
    private(set) var currentReadPage: LQReadPage? = nil
    private var readPager: LQReadPage? = nil

    private var topStatusView: UILabel! = nil
    private var bottomStatusView: LQStatusView! = nil
    private var tableView: UITableView! = nil
    private var sliderView: LQSliderView! = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = LQReadConfigure.shared().readColor()
        NotificationCenter.default.addObserver(self, selector: #selector(LQVerticalViewController.readColorChange(notifation:)), name: LQNotifation.themeChange.notificationName, object: nil)
        bottomStatusView = LQStatusView()
        bottomStatusView.backgroundColor = UIColor.clear
        self.view.addSubview(bottomStatusView)
        bottomStatusView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(LQTxtShowInsets.left)
            make.right.equalTo(self.view.snp.right).offset(-LQTxtShowInsets.right)
            make.bottom.equalTo(self.view).offset(-LQTxtShowInsets.bottom)
            make.height.equalTo(25)
        }
        
        
        tableView = UITableView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: LQTxtShowSize))
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = LQTxtShowSize.height
        tableView.backgroundColor = UIColor.clear
        tableView.register(LQTxtCell.classForCoder(), forCellReuseIdentifier: LQVerticalCellReuseIdentifier)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(LQTxtShowInsets.left)
            make.bottom.equalTo(self.bottomStatusView.snp.top)
            make.width.equalTo(LQTxtShowSize.width)
            make.height.equalTo(LQTxtShowSize.height)
        }
        
        topStatusView = UILabel()
        topStatusView.lineBreakMode = .byTruncatingMiddle
        topStatusView.textColor = LQColor_4
        topStatusView.font = LQFont_12
        self.view.addSubview(topStatusView)
        topStatusView.snp.makeConstraints { (make) in
            make.left.equalTo(tableView.snp.left)
            make.right.equalTo(tableView.snp.right)
            make.bottom.equalTo(tableView.snp.top).offset(-LQTxtShowInsets.bottom)
            make.height.equalTo(LQTxtShowInsets.top)
        }
        
        setupSliderView()
    }
    
    private func setupSliderView() {
        sliderView = LQSliderView(frame: CGRect.zero)
        view.addSubview(sliderView)
        adjustcontentSliderValue(forceVisible: false)
        sliderView.setSliderHidden(true, animation: false)
        sliderView.delegate = self
        self.sliderView.snp.remakeConstraints { (make) in
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.tableView.snp.top).offset(self.tableView.contentInset.top);
            make.bottom.equalTo(self.tableView.snp.bottom).offset(-self.tableView.contentInset.bottom);
            make.width.equalTo(sliderView.defaultWidth());
        }
    }
    
    
    
    private func setCurrentReadPage(pageNo: Int, chapterNo: Int) {
        if let currentReadPage = self.currentReadPage, let readBook = self.readBook {
            if currentReadPage.pageChapter != chapterNo {
                topStatusView.text = readBook.chapterTitle(chapterNo: chapterNo)
            }
            bottomStatusView.setPageInfo(str: "\(pageNo+1)/\(readBook.totalPage(chapterNo: chapterNo))")
        } else {
            topStatusView.text = self.readBook?.chapterTitle(chapterNo: chapterNo)
        }
        
        self.currentReadPage = LQReadPage(pageNo: pageNo, chapterNo: chapterNo, pageContent: "")
    }
    
    func showReaderPage(pageNo: Int, chapterNo: Int, readBook: LQBookController) {
        self.readBook = readBook
        tableView.reloadData()
        setCurrentReadPage(pageNo: pageNo, chapterNo: chapterNo)
        tableView.scrollToRow(at: IndexPath(row: pageNo, section: chapterNo), at: .top, animated: false)
    }
    
    func readParseSuccess() {
        tableView.reloadData()
    }
    
    @objc private func readColorChange(notifation: Notification) {
        self.view.backgroundColor = LQReadConfigure.shared().readColor()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.readBook?.pageHeight(pageNo: indexPath.row, chapterNo: indexPath.section) ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.readBook?.totalChapter ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.readBook?.totalPage(chapterNo: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LQTxtCell = (tableView.dequeueReusableCell(withIdentifier: LQVerticalCellReuseIdentifier) as? LQTxtCell) ?? LQTxtCell(style: .default, reuseIdentifier: LQVerticalCellReuseIdentifier)
        cell.selectionStyle = .none
        cell.contentLabel.content = self.readBook?.bookPager(pageNo: indexPath.row, chapterNo: indexPath.section)?.pageContent
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let indexPath = tableView.indexPathForRow(at: scrollView.contentOffset) else {
            return
        }
        setCurrentReadPage(pageNo: indexPath.row, chapterNo: indexPath.section)
        adjustcontentSliderValue(forceVisible: true)
    }
    
    
    // MARK: SLIDER
    private func adjustcontentSliderValue(forceVisible: Bool) {
        var isSliserHidden = true
        if forceVisible {
            if 0 == self.tableView.contentSize.height || 0 == self.tableView.bounds.size.height || self.tableView.contentSize.height < 2 * self.tableView.bounds.size.height {
                isSliserHidden = true
            } else {
                isSliserHidden = false
            }
        } else {
            isSliserHidden = true
        }
        
        if isSliserHidden {
            sliderView.setSliderHidden(true, animation: true)
            return;
        } else {
            sliderView.setSliderHidden(false, animation: true)
        }
        
        let containerHeight = self.tableView.bounds.size.height - self.tableView.contentInset.top - self.tableView.contentInset.bottom
        
        let maxOffset = self.tableView.contentSize.height - containerHeight - self.tableView.contentInset.bottom
        let ratio = self.tableView.contentSize.height / (maxOffset == 0 ? self.tableView.contentSize.height : maxOffset)
        let scrollOffsetY = self.tableView.contentOffset.y + self.tableView.contentInset.top
        let percent = scrollOffsetY / self.tableView.contentSize.height
        self.sliderView.setValue(value: Float(percent * ratio))
    }
    
    func scrollBarContentChange(value: Float) {
        let containerHeight = self.tableView.frame.size.height - self.tableView.contentInset.top -
            self.tableView.contentInset.bottom;
        
        let scrollViewHeight = self.tableView.contentSize.height;
        //DDLogInfo(@"containerHeight:%0.1f,scrollHeight:%0.1f", containerHeight, scrollViewHeight);
        let scrollContentOffsetHeight: CGFloat = scrollViewHeight * CGFloat(value)
        
        let mixOffset = (self.tableView.contentSize.height - containerHeight) / self.tableView.contentSize.height;
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: scrollContentOffsetHeight * mixOffset - self.tableView.contentInset.top)
        self.sliderView.setSliderHidden(false, animation: true)
    }
}

class LQTxtCell: UITableViewCell {
    private(set) var contentLabel: LQReaderView! = nil
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        contentLabel = LQReaderView(frame: self.bounds)
        self.contentView.addSubview(contentLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentLabel.frame = self.bounds
    }
}
