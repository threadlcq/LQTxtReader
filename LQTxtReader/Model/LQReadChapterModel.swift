//
//  LQReadChapterModel.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/15.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

fileprivate let LQReadAttribute = "LQReadAttribute"
fileprivate let LQReadPageArray =  "LQReadPageArray"
fileprivate var LQChapterParserTag = 1

protocol LQChapterCalcuateDelegate : NSObjectProtocol {
    func chapterCalcuateProgress(chapterNo: Int, tag: Int)
    func chapterCalcuateFinish(chapterNo: Int, tag: Int)
    func chapterCancuateCancel(chapterNo: Int, tag: Int)
}

class LQReadChapterModel: NSObject {
    /// 章节名称
    let name: String
    /// 章节内容
    let content: String
    // 章节序号
    let chapterNo: Int
    // 章节存储的目录
    let path: URL
    private(set) var pageRange:[LQParserPage] = Array()
    private var parser: LQChapterParser? = nil
    
    weak var delegate: LQChapterCalcuateDelegate? = nil
    init(name: String, content: String, chapterNo: Int, path: URL) {
        self.name = name
        self.content = content
        self.chapterNo = chapterNo
        self.path = path
        super.init()
    }
    
    func getChapterInfo() -> Int  {
        let readAttribute: [NSAttributedStringKey:Any] = LQReadConfigure.shared().readAttribute(isPaging: true)
        let currentChapterParserTag = LQChapterParserTag
        LQChapterParserTag += 1
        DispatchQueue.global().async {
            if let pageRange = self.loadPageRange(readAttribute: readAttribute) {
                DispatchQueue.main.async {
                    self.pageRange = pageRange
                    self.delegate?.chapterCalcuateFinish(chapterNo: self.chapterNo, tag: currentChapterParserTag)
                }
            } else {
                self.parser = LQChapterParser(content: self.content, showSize: LQTxtShowSize, attrs: readAttribute)
                self.parser?.calculatePageRange(calculateState: { (calcuatePages: [LQParserPage], isFinish : Bool, isCancel: Bool) in
                    DispatchQueue.main.async {
                        self.pageRange = calcuatePages
                        if isCancel {
                            self.delegate?.chapterCancuateCancel(chapterNo: self.chapterNo, tag: currentChapterParserTag)
                        } else if isFinish {
                            self.delegate?.chapterCalcuateFinish(chapterNo: self.chapterNo, tag: currentChapterParserTag)
                            self.savePageRange(readAttribute: readAttribute)
                        } else {
                            self.delegate?.chapterCalcuateProgress(chapterNo: self.chapterNo, tag: currentChapterParserTag)
                        }
                    }
                })
            }
        }
        return currentChapterParserTag
    }
    
    func cancelParser() {
        self.parser?.isCancel = true
        self.parser = nil
    }

    private var chapterInfoPath: URL {
        return self.path.appendingPathComponent("\(self.chapterNo)")
    }
    
    private func loadPageRange(readAttribute: [NSAttributedStringKey:Any]) -> [LQParserPage]? {
        let archiverDic: [String : Any]? = NSKeyedUnarchiver.unarchiveObject(withFile: self.chapterInfoPath.path) as? [String : Any]
        if let readAtt = archiverDic?[LQReadAttribute] as? [NSAttributedStringKey:Any], NSDictionary(dictionary: readAttribute).isEqual(to: readAtt)  {
            return archiverDic![LQReadPageArray] as? [LQParserPage]
        }
        
        return nil
    }
    
    private func savePageRange(readAttribute: [NSAttributedStringKey:Any]) {
        let dic: [String : Any] = [LQReadAttribute: readAttribute,
                                   LQReadPageArray: self.pageRange]
        NSKeyedArchiver.archiveRootObject(dic, toFile: self.chapterInfoPath.path)
    }
    
    // MARK: -- 操作
    
    /// 通过 Page 获得字符串
    func string(page:NSInteger) ->String {
        return content.substring(pageRange[page].pageRange)
    }
}


class LQParserPage: NSObject, NSCoding {
    private(set) var pageRange: NSRange
    private(set) var pagePosition: CGVector
    init(pageRange: NSRange, pagePosition: CGVector) {
        self.pageRange = pageRange
        self.pagePosition = pagePosition
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        self.pagePosition = aDecoder.decodeCGVector(forKey: "pagePosition")
        self.pageRange = (aDecoder.decodeObject(forKey: "pageRange") as! NSValue).rangeValue
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(NSValue(range: pageRange), forKey: "pageRange")
        aCoder.encode(pagePosition, forKey: "pagePosition")
    }
    
    func adjustPosition(adjustValue: CGFloat) {
        var pageHeight: CGFloat = pagePosition.dy
        if pageHeight < adjustValue * 0.5 {
            pageHeight = adjustValue * 0.5
        } else {
            pageHeight = adjustValue
        }
        
        pagePosition = CGVector(dx: pagePosition.dx, dy: pageHeight)
    }
}
