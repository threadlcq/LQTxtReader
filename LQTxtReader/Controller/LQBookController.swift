//
//  LQBookController.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/20.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

protocol LQBookCalcuateDelegate : NSObjectProtocol {
    func bookCalcuateBegin()
    func bookCalcuateProgress(curPageNo: Int, curChapterNo: Int)
    func bookCalcuateFinish()
    func bookCancuateCancel()
}

class LQBookController: NSObject {
    weak var delegate: LQBookCalcuateDelegate? = nil
    private var url: URL
    private var content: LQReadContent? = nil
    
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    ///获取文章信息
    func fetchBookInfo(completion: @escaping (_ success: Bool) -> Void) {
        if let content = self.content {
            completion(content.contentLength() > 0)
        }
        DispatchQueue.global().async {
            self.content = LQReadContent.unarchiveSelf(url: self.url)
            if (self.content == nil) {
                self.content = LQReadContent(url: self.url)
                self.content?.readContent()
            }
            
            DispatchQueue.main.async(execute: {
                self.content?.delegate = self.delegate
                let contentlength = self.content?.contentLength() ?? 0
                completion(contentlength > 0)
            })
        }
    }
    
    func parseBook() {
        self.content?.parseContent()
    }
    
    func cancelParseBook() {
        self.content?.cancelParse()
    }
    
    var totalChapter: Int {
        return self.content?.chapterList.count ?? 0
    }
    
    func totalPage(chapterNo: Int) -> Int {
        return self.content?.chapterList[chapterNo].pageRange.count ?? 0
    }
    
    func chapterTitle(chapterNo: Int) -> String? {
        return self.content?.chapterList[chapterNo].name
    }
    
    func pageHeight(pageNo: Int, chapterNo: Int) -> CGFloat? {
        return self.content?.getPageHeight(pageNo: pageNo, chapterNo:chapterNo)
    }
    
    func bookPager(pageNo: Int, chapterNo: Int) -> LQReadPage? {
        if let pageContent = self.content?.getPageContent(pageNo: pageNo, chapterNo: chapterNo) {
            return LQReadPage(pageNo: pageNo, chapterNo: chapterNo, pageContent: pageContent)
        }
        return nil
    }
    
    func getPageNo(readRecord: LQReadRecode) -> Int? {
        return self.content?.getPageNo(record:readRecord)
    }
    
    func getCharIndex(pageNo: Int, chapterNo: Int) -> Int? {
        return self.content?.getCharIndex(pageNo:pageNo, chapterNo:chapterNo)
    }
}
