//
//  ViewController.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import MBProgressHUD

class LQReadViewController: LQBaseViewController, UIGestureRecognizerDelegate, LQBookCalcuateDelegate {
    var url: URL? = nil {
        didSet {
            if let url = self.url {
                self.readRecode = LQReadConfigure.shared().getRecode(bookId: GetFileName(url).md5())
            }
        }
    }
    var currentReadPage: LQReadPage? {
        return pageViewController?.currentReadPage
    }
    private var readRecode: LQReadRecode? = nil
    private var pageView: UIView = UIView()
    private var readBook: LQBookController? = nil
    private var pageViewController: (UIViewController & LQReadTxtProtocol)? = nil
    private var isCalcuateSuccess: Bool = false
    private var isCountingCurrentPage: Bool = false
    private var toolbar: LQToolBarController? = nil
    
    deinit {
        self.readBook?.cancelParseBook()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupViews()
        openBook()
        if let url = self.url {
            self.title = GetFileName(url)
        } else {
            self.title = "未知"
        }
        
        self.toolbar = LQToolBarController(viewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveRecode()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.navigationController?.isNavigationBarHidden ?? false
    }
    
    private func setupViews() {
        self.pageView.frame = self.view.bounds
        self.pageView.backgroundColor = UIColor.clear
        self.pageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(self.pageView)
        
        resetPageViewController()
        
        let recogizer = UITapGestureRecognizer(target: self, action: #selector(LQReadViewController.handleTap(recognizer:)))
        recogizer.cancelsTouchesInView = true
        recogizer.delegate = self
        self.view.addGestureRecognizer(recogizer)
    }

    private func openBook() {
        if let url = self.url {
            readBook = LQBookController(url: url)
            readBook?.delegate = self
            readBook?.fetchBookInfo(completion: { [weak self] (isSuccess: Bool) in
                if isSuccess {
                    self?.readBook?.parseBook()
                    self?.toolbar?.readBook = self?.readBook
                } else {
                    print("打开文件失败")
                }
            })
        }
    }
    
    private func resetPageViewController() {
        if let pageViewController = self.pageViewController {
            pageViewController.willMove(toParentViewController: nil)
            pageViewController.view.removeFromSuperview()
            pageViewController.removeFromParentViewController()
        }
        
        
        if LQReadConfigure.shared().effectType == LQReadEffectType.translation.rawValue {
            self.pageViewController = LQHorizontalViewController()
        } else {
            self.pageViewController = LQVerticalViewController()
        }
        
        if let pageViewController = self.pageViewController {
            pageViewController.view.frame = self.pageView.bounds
            pageViewController.view.autoresizingMask = [.flexibleWidth, .flexibleWidth]
            self.pageView.addSubview(pageViewController.view)
            self.didMove(toParentViewController: pageViewController)
        }
    }
    
    private func saveRecode() {
        if let currentPage = pageViewController?.currentReadPage,let charIndex = self.readBook?.getCharIndex(pageNo: currentPage.pageIndex, chapterNo: currentPage.pageChapter), let url = self.url {
            let readRecode = LQReadRecode(charIndex: charIndex, chapterNo: currentPage.pageChapter)
            LQReadConfigure.shared().setRecode(bookId: GetFileName(url).md5(), recode: readRecode)
            self.readRecode = readRecode
        }
    }
    
    func bookCalcuateBegin() {
        MBProgressHUD.showMessage("正在加载...", to: self.view)
    }
    
    func bookCalcuateProgress(curPageNo: Int, curChapterNo: Int) {
        print("curpage\(curPageNo),curChapterNo\(curChapterNo)")
        guard !isCountingCurrentPage, let readRecode: LQReadRecode = self.readRecode, readRecode.chapterNo <= curChapterNo else {
            return
        }
        if let pageNo = self.readBook?.getPageNo(readRecord: readRecode) {
            self.pageViewController?.showReaderPage(pageNo: pageNo, chapterNo: readRecode.chapterNo, readBook: self.readBook!)
            self.toolbar?.setToolbarItem(enable: true)
            isCountingCurrentPage = true
            MBProgressHUD.hide(for: self.view)
        }
    }
    
    func bookCalcuateFinish() {
        if !isCountingCurrentPage {
            self.pageViewController?.showReaderPage(pageNo: 0, chapterNo: 0, readBook: self.readBook!)
        }
        self.pageViewController?.readParseSuccess()
        self.toolbar?.setToolbarItem(enable: true)
        MBProgressHUD.hide(for: self.view)
        isCountingCurrentPage = true
        isCalcuateSuccess = true
    }
    
    func bookCancuateCancel() {
        
    }
    
    func menuReadChapter(chapterNo: Int) {
        let readRecode = LQReadRecode(charIndex: 1, chapterNo: chapterNo)
        self.readRecode = readRecode
        if isCalcuateSuccess || nil != self.readBook?.getPageNo(readRecord: readRecode) {
            self.pageViewController?.showReaderPage(pageNo: 0, chapterNo: chapterNo, readBook: self.readBook!)
        } else {
            bookCalcuateBegin()
        }
    }
    
    func menuProgressRead(value: Float) {
        guard let readBook = self.readBook, let currentReadPage = self.currentReadPage else {
            return;
        }
        let totalPage = readBook.totalPage(chapterNo: currentReadPage.pageChapter)
        let pageNo = totalPage == 0 ? 0 : min(Int(value*Float(totalPage)), totalPage - 1)
        self.pageViewController?.showReaderPage(pageNo: pageNo, chapterNo: currentReadPage.pageChapter, readBook: readBook)
    }
    
    //手势控制
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if let navigationController = self.navigationController {
            let willChange = !navigationController.isNavigationBarHidden
            navigationController.setNavigationBarHidden(willChange, animated: true)
            self.toolbar?.setToolBarHidden(willChange, animated: true)
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return isCalcuateSuccess
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, let toolbarView = self.toolbar?.view, touchView.isDescendant(of: toolbarView) {
            return false
        }
        
        return true
    }
    
    func reParseBook() {
        saveRecode()
        isCalcuateSuccess = false
        isCountingCurrentPage = false
        self.readBook?.parseBook()
    }
    
    func turnpageChange() {
        guard let currentReadPage = self.currentReadPage, let readBook = self.readBook else {
            return
        }
        resetPageViewController()
        pageViewController?.showReaderPage(pageNo: currentReadPage.pageIndex, chapterNo: currentReadPage.pageChapter, readBook: readBook)
        //[self sliderCurrentPage:currentPage totalPage:_readerBook.totalPage];
    }
}

