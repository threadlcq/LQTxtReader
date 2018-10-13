//
//  LQToolBarController.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/8.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQToolBarController: NSObject, LQToolBarDelegate, LQChapterSelectDelegate, LQSettingBarDelegate, LQProgressBarDelegate, LQTurnpageBarDelegate {
    weak var readBook: LQBookController? = nil {
        didSet {
            chapterView.readBook = readBook
        }
    }
    private weak var viewController: LQReadViewController?
    private var toolbarView: LQToolBar!
    private var settingBar = LQBookSettingBar()
    private var currentBar: UIView? = nil
    private var isEnable:Bool = false
    private var chapterView: LQChapterMenu!
    private var turnpageBar: LQTurnpageBar!
    private var progressBar: LQProgressBar!
    var view: UIView? {
        get {
            return currentBar
        }
    }
    
    init(viewController: LQReadViewController) {
        self.viewController = viewController
        super.init()
        setupToolBar()
    }
    
    private func setupToolBar() {
        guard let viewController = self.viewController else {
            return
        }
        
        let toolBarFrame = CGRect(x: 0, y: viewController.view.height - TabBarHeight, width: viewController.view.width, height: TabBarHeight)
        self.toolbarView = LQToolBar(frame: toolBarFrame, delegate: self)
        self.toolbarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.viewController?.view.addSubview(self.toolbarView)
        self.toolbarView.setOperationBtnArray(operBtnArray: LQButtonOperationFactory.buildOperationButton(typeList: [.catalogue, .progress, .setting, .turnpage]))
        self.currentBar = self.toolbarView
        
        settingBar.delegate = self
        settingBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        settingBar.y = viewController.view.height
        
        viewController.view.addSubview(settingBar)
        
        chapterView = LQChapterMenu(frame: viewController.view.bounds)
        chapterView.delegate = self
        chapterView.backgroundColor = UIColor.clear
        chapterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chapterView.rightX = 0
        chapterView.isHidden = true
        viewController.view.addSubview(chapterView)
        chapterView.addTarget(self, action: #selector(LQToolBarController.clickChapterView), for: .touchUpInside)
        
        turnpageBar = LQTurnpageBar(frame: toolBarFrame, btnTitles: ["左右翻页", "上下翻页"])
        turnpageBar.delegate = self
        turnpageBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        turnpageBar.y = viewController.view.height
        viewController.view.addSubview(turnpageBar)
        
        progressBar = LQProgressBar()
        progressBar.delegate = self
        progressBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressBar.y = viewController.view.height
        viewController.view.addSubview(progressBar)
    }
    
    func setToolBarHidden(_ hidden: Bool, animated: Bool) {
        guard let viewController = self.viewController, let currentBar = self.currentBar else {
            self.currentBar = self.toolbarView
            return
        }
        let topValue = hidden ? viewController.view.height : viewController.view.height - currentBar.height
        if animated {
            UIView.animate(withDuration: 0.3) {
                currentBar.y = topValue
            }
        } else {
            currentBar.y = topValue
        }
        self.currentBar = self.toolbarView
    }
    
    func setToolbarItem(enable: Bool) {
        isEnable = enable
        self.toolbarView.updateEnableStatus()
    }
    
    func toolbar(_ toolbar: LQToolBar, enable operationType:UInt) -> Bool {
        return isEnable
    }
    
    func toolbar(_ toolbar: LQToolBar, didselect operationType: UInt) {
        switch operationType {
        case LQToolbarItemType.catalogue.rawValue:
            showChapterView()
        case LQToolbarItemType.progress.rawValue:
            self.resetProgressInfo()
            switchBar(toBar: self.progressBar)
        case LQToolbarItemType.setting.rawValue:
            settingBar.lightSlider.value = Float(UIScreen.main.brightness)
            settingBar.fontSlider.selectedIndex = UInt(LQReadConfigure.shared().fontSize - LQReadMinFontSize) >> 2
            switchBar(toBar: self.settingBar)
        case LQToolbarItemType.turnpage.rawValue:
            switchBar(toBar: self.turnpageBar)
        default:
            break
        }
    }
    
    private func switchBar(toBar: UIView) {
        guard let viewController = self.viewController else {
            return
        }
        if let currentBar = self.currentBar {
            UIView.animate(withDuration: 0.3) {
                currentBar.y = viewController.view.height
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            toBar.y = viewController.view.height - toBar.height
        }) { (isSuccess) in
            self.currentBar = toBar
        }
    }
    
    private func resetProgressInfo() {
        guard let currentReadPage = self.viewController?.currentReadPage, let readBook = self.readBook, let effectType = LQReadEffectType(rawValue: LQReadConfigure.shared().effectType) else {
            return
        }
        self.progressBar.setTurnpageType(effect: effectType)
        let currentPage = currentReadPage.pageIndex
        let totalChapterPage = readBook.totalPage(chapterNo: currentReadPage.pageChapter)
        self.progressBar.setPageValue(value: "\(min(currentPage + 1, totalChapterPage))/\(totalChapterPage)")
        if totalChapterPage > 0 {
            self.progressBar.setPageScale(value: Float(currentPage + 1)/Float(totalChapterPage))
        } else {
            self.progressBar.setPageScale(value: 0)
        }
        
    }
    
    private func showChapterView() {
        guard let viewController = self.viewController else {
            return
        }
        if let currentBar = self.currentBar {
            UIView.animate(withDuration: 0.3) {
                currentBar.y = viewController.view.height
            }
        }
        viewController.navigationController?.setNavigationBarHidden(true, animated: true)
        chapterView.scrollReadRecord(chapterNo: viewController.currentReadPage?.pageChapter)
        chapterView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.chapterView.rightX = viewController.view.width
            self.chapterView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }) { (isSuccess) in
            self.currentBar = self.chapterView
        }
    }
    
    /// 点击事件
    @objc private func clickChapterView() {
        self.chapterView.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.3, animations: {
            self.chapterView.rightX = 0
        }) { (isSuccess) in
            self.currentBar = self.toolbarView
            self.chapterView.isHidden = true
        }
    }
    
    func chapterMenu(chapterMenu: LQChapterMenu, chapterIndex: Int) {
        clickChapterView()
        self.viewController?.menuReadChapter(chapterNo: chapterIndex)
    }
    
    func chapterMenu(chapterMenu: LQChapterMenu, markIndex: Int) {
        clickChapterView()
        
    }
    
    func settingBar(_ settingBar: LQBookSettingBar, themeIndex: UInt) {
        LQReadConfigure.shared().colorIndex = Int(themeIndex)
        NotificationCenter.post(customeNotification: .themeChange)
    }
    
    func settingBar(_ settingBar: LQBookSettingBar, fontIndex: UInt) {
        let newFontSize = LQReadMinFontSize + Int(fontIndex << 2)
        if newFontSize != LQReadConfigure.shared().fontSize {
            LQReadConfigure.shared().fontSize = newFontSize
            viewController?.reParseBook()
        }
    }
    
    func settingBar(_ settingBar: LQBookSettingBar, lightValue: Float) {
        UIScreen.main.brightness = CGFloat(lightValue)
    }
    
    func progressBar(_ progressBar: LQProgressBar, willChange value: Float) {
        
    }
    func progressBar(_ progressBar: LQProgressBar, changing value: Float) {
        guard let currentReadPage = self.viewController?.currentReadPage, let readBook = self.readBook else {
            return
        }
        
        let totalChapterPage = readBook.totalPage(chapterNo: currentReadPage.pageChapter)
        let currentPage = Int(value * Float(totalChapterPage))
        self.progressBar.setPageValue(value: "\(min(currentPage + 1, totalChapterPage))/\(totalChapterPage)")
    }
    
    func progressBar(_ progressBar: LQProgressBar, didChange value: Float) {
        viewController?.menuProgressRead(value: value)
    }
    
    func turnpageBar(_ turnpageBar: LQTurnpageBar, effectType: LQReadEffectType) {
        LQReadConfigure.shared().effectType = effectType.rawValue
        viewController?.turnpageChange()
    }
}
