//
//  LQTxtHorViewController.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/29.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import SnapKit

class LQTxtHorViewController: UIViewController {
    var readPager: LQReadPage? = nil
    var statusValue: String? = nil
    var chapterTitle: String? = nil
    private var contentLabel: LQReaderView! = nil
    private var topStatusView: UILabel! = nil
    private var bottomStatusView: LQStatusView! = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = LQReadConfigure.shared().readColor()
        NotificationCenter.default.addObserver(self, selector: #selector(LQTxtHorViewController.readColorChange(notifation:)), name: LQNotifation.themeChange.notificationName, object: nil)
        bottomStatusView = LQStatusView()
        bottomStatusView.backgroundColor = UIColor.clear
        self.view.addSubview(bottomStatusView)
        bottomStatusView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(LQTxtShowInsets.left)
            make.right.equalTo(self.view.snp.right).offset(-LQTxtShowInsets.right)
            make.bottom.equalTo(self.view).offset(-LQTxtShowInsets.bottom)
            make.height.equalTo(25)
        }
        bottomStatusView.setPageInfo(str: statusValue)
        
        contentLabel = LQReaderView(frame: CGRect.init(origin: CGPoint(x: 0, y: 0), size: LQTxtShowSize))
        contentLabel.content = readPager?.pageContent
        self.view.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(LQTxtShowInsets.left)
            make.bottom.equalTo(self.bottomStatusView.snp.top)
            make.width.equalTo(LQTxtShowSize.width)
            make.height.equalTo(LQTxtShowSize.height)
        }
        
        topStatusView = UILabel()
        topStatusView.text = chapterTitle
        topStatusView.lineBreakMode = .byTruncatingMiddle
        topStatusView.textColor = LQColor_4
        topStatusView.font = LQFont_12
        self.view.addSubview(topStatusView)
        topStatusView.snp.makeConstraints { (make) in
            make.left.equalTo(contentLabel.snp.left)
            make.right.equalTo(contentLabel.snp.right)
            make.bottom.equalTo(contentLabel.snp.top).offset(-LQTxtShowInsets.bottom)
            make.height.equalTo(LQTxtShowInsets.top)
        }
    }
    
    @objc private func readColorChange(notifation: Notification) {
        self.view.backgroundColor = LQReadConfigure.shared().readColor()
    }
}
