//
//  LQHorizontalViewController.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/29.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQHorizontalViewController: UIPageViewController, LQReadTxtProtocol, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var readBook: LQBookController? = nil
    private(set) var currentReadPage: LQReadPage? = nil
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.dataSource = self
    }
    
    func showReaderPage(pageNo: Int, chapterNo: Int, readBook: LQBookController) {
        self.readBook = readBook
        let txtVC = readerController(pageNo: pageNo, chapterNo: chapterNo)
        self.currentReadPage = txtVC.readPager
        self.setViewControllers([txtVC], direction: .forward, animated: false, completion: nil)
    }
    
    func readerController(pageNo: Int, chapterNo: Int) -> LQTxtHorViewController {
        let txtVC = LQTxtHorViewController()
        let readPage = self.readBook?.bookPager(pageNo: pageNo, chapterNo: chapterNo)
        txtVC.readPager = readPage
        txtVC.chapterTitle = readBook?.chapterTitle(chapterNo: chapterNo)
        txtVC.statusValue = "\(pageNo+1)/\(readBook!.totalPage(chapterNo: chapterNo))"
        return txtVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let cutReadPage = (viewController as? LQTxtHorViewController)?.readPager else {
            return nil
        }
        
        currentReadPage = cutReadPage
        
        if (cutReadPage.pageIndex > 0) {
            return readerController(pageNo: cutReadPage.pageIndex - 1, chapterNo: cutReadPage.pageChapter)
        } else if (cutReadPage.pageChapter > 0) {
            return readerController(pageNo: 0, chapterNo: cutReadPage.pageChapter - 1)
        } else {
            print("第一页了\n")
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let readBook = self.readBook, let cutReadPage = (viewController as? LQTxtHorViewController)?.readPager else {
            return nil
        }
        currentReadPage = cutReadPage
        
        if cutReadPage.pageIndex + 1 < readBook.totalPage(chapterNo: cutReadPage.pageChapter) {
            return readerController(pageNo: cutReadPage.pageIndex + 1, chapterNo: cutReadPage.pageChapter)
        } else if cutReadPage.pageChapter + 1 <  readBook.totalChapter {
            return readerController(pageNo: 0, chapterNo: cutReadPage.pageChapter + 1)
        } else {
            print("最后页了\n")
            return nil
        }
    }
}
