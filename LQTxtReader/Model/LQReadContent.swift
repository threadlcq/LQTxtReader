//
//  LQReaderContent.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/21.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

fileprivate let ReadFolderName = "LQBOOKFOLDER"
fileprivate let ContentPath = "content"

class LQReadContent: NSObject, NSCoding, LQChapterCalcuateDelegate {
    private var url: URL
    private var content: String = ""
    private(set) var chapterList: [LQReadChapterModel] = []
    private var chapterContentRangeList = [NSRange]()
    private var chapterTitleRangeList = [NSRange]()
    private var chapterParserTag: Int = 0
    private weak var currentParserChapter: LQReadChapterModel? = nil
    weak var delegate: LQBookCalcuateDelegate? = nil
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    //必须在异步线程中完成
    func readContent() {
        self.content = contentTypesetting(content: encodeURL(url))
        explainChapter()
        NSKeyedArchiver.archiveRootObject(self, toFile: LQReadContent.contentArchivePath(url: self.url).path)
    }
    
    func contentLength() -> Int {
        return self.content.length
    }
    
    //
    func parseContent() {
        currentParserChapter = chapterList.first
        self.delegate?.bookCalcuateBegin()
        chapterParserTag = currentParserChapter?.getChapterInfo() ?? 0
    }
    
    func cancelParse() {
        currentParserChapter?.cancelParser()
        currentParserChapter = nil
        chapterParserTag = 0
    }
    
    func chapterCalcuateProgress(chapterNo: Int, tag: Int) {
        let currentPageCountCount = self.chapterList[chapterNo].pageRange.count
        self.delegate?.bookCalcuateProgress(curPageNo: currentPageCountCount, curChapterNo: chapterNo)
    }
    
    func chapterCalcuateFinish(chapterNo: Int, tag: Int) {
        //如果没有被取消
        if (tag == chapterParserTag) {
            //开始切下一章
            let nextChapterNo = chapterNo + 1
            if nextChapterNo < chapterList.count {
                let currentPageCountCount = self.chapterList[chapterNo].pageRange.count
                self.delegate?.bookCalcuateProgress(curPageNo: currentPageCountCount, curChapterNo: chapterNo)

                currentParserChapter = chapterList[nextChapterNo]
                chapterParserTag = currentParserChapter?.getChapterInfo() ?? 0
            } else {
                //所有章节全部切完
                currentParserChapter = nil
                chapterParserTag = 0
                self.delegate?.bookCalcuateFinish()
            }
        }
    }
    
    func chapterCancuateCancel(chapterNo: Int, tag: Int) {
        self.delegate?.bookCancuateCancel()
    }
    
    func getPageContent(pageNo: Int, chapterNo: Int) -> String? {
        if chapterNo < chapterList.count && pageNo < chapterList[chapterNo].pageRange.count {
            return chapterList[chapterNo].string(page: pageNo)
        }
        return nil
    }
    
    func getPageHeight(pageNo: Int, chapterNo: Int) -> CGFloat? {
        if chapterNo < chapterList.count && pageNo < chapterList[chapterNo].pageRange.count {
            return chapterList[chapterNo].pageRange[pageNo].pagePosition.dy
        }
        return nil
    }
    
    func getCharIndex(pageNo: Int, chapterNo: Int) -> Int? {
        if chapterNo < chapterList.count && pageNo < chapterList[chapterNo].pageRange.count {
            let range = chapterList[chapterNo].pageRange[pageNo].pageRange
            return range.location + range.length/2
        }
        return nil
    }
    
    func getPageNo(record:LQReadRecode) -> Int? {
        if record.chapterNo >= chapterList.count {
            return nil
        }
        for index in 0 ..< self.chapterList[record.chapterNo].pageRange.count {
            let parserPage:LQParserPage = self.chapterList[record.chapterNo].pageRange[index]
            if NSLocationInRange(record.charIndex, parserPage.pageRange) {
                return index
            }
        }
        return nil
    }
    
    
    /// 切割章节
    private func explainChapter() {
        // 正则
        let parten = "第[0-9一二三四五六七八九十百千]*[章回].*"
        var results:[NSTextCheckingResult] = []
        do{
            let regularExpression:NSRegularExpression = try NSRegularExpression(pattern: parten, options: .caseInsensitive)
            results = regularExpression.matches(in: content, options: .reportCompletion, range: NSRange(location: 0, length: self.content.length))
        } catch {
            
        }
        
        let path = LQReadContent.filePath(url:url)
        chapterContentRangeList.removeAll()
        chapterTitleRangeList.removeAll()
        if results.isEmpty {
            let chapterModel = LQReadChapterModel(name: "开始", content: self.content, chapterNo: 0, path: path)
            chapterModel.delegate = self
            chapterContentRangeList.append(NSRange(location: 0, length: self.content.length))
            chapterTitleRangeList.append(NSRange(location: 0, length: 0))
            self.chapterList = [chapterModel]

            return
        }
        self.chapterList.removeAll()
        // 记录最后一个Range
        var lastRange = NSRange(location: 0, length: 0)
        var range = NSRange(location: 0, length: 0)
        var chapterRange = NSRange(location: 0, length: 0)
        var location = 0
        
        // 遍历
        for index in 0 ... results.count {
            var chapterModel: LQReadChapterModel? = nil
            if index < results.count {
                range = results[index].range
                location = range.location
            }
            if index == 0 { // 开始
                if (location > 0) {
                    chapterRange = NSRange(location: 0, length: location)
                    chapterModel = LQReadChapterModel(name: "开始", content: content.substring(chapterRange), chapterNo: index, path: path)
                } else {
                    continue;
                }
            } else if index == results.count { // 结尾

                chapterRange = NSRange(location: lastRange.location, length: content.length - lastRange.location)
                chapterModel = LQReadChapterModel(name: self.content.substring(lastRange), content: content.substring(chapterRange), chapterNo: index, path: path)
            } else { // 中间章节
                chapterRange = NSRange(location: lastRange.location, length: location - lastRange.location)
                chapterModel = LQReadChapterModel(name: self.content.substring(lastRange), content: content.substring(chapterRange), chapterNo: index, path: path)
                
            }
            if let chapterModel = chapterModel {
                chapterModel.delegate = self
                chapterTitleRangeList.append(lastRange)
                chapterContentRangeList.append(chapterRange)
                self.chapterList.append(chapterModel)
            }
            
            lastRange = range
        }
    }
    
    private func encodeURL(_ url:URL) ->String {
        var content = ""
        // 检查URL是否有值
        if url.absoluteString.isEmpty {
            return content
        }
        // NSUTF8StringEncoding 解析
        content = encodeURL(url, encoding: String.Encoding.utf8.rawValue)
        // 进制编码解析
        if content.isEmpty {
            content = encodeURL(url, encoding: 0x80000632)
        }
        
        if content.isEmpty {
            content = encodeURL(url, encoding: 0x80000631)
        }
        
        if content.isEmpty {
            content = ""
        }
        
        return content
    }
    
    private func encodeURL(_ url:URL,encoding:UInt) ->String {
        do{
            return try NSString(contentsOf: url, encoding: encoding) as String
        }catch{}
        
        return ""
    }
    
    // MARK: -- 对内容进行整理排版 比如去掉多余的空格或者段头留2格等等
    /// 内容排版整理
    private func contentTypesetting(content:String) ->String {
        // 替换单换行
        var content = content.replacingOccurrences(of: "\r", with: "")
        // 替换换行 以及 多个换行 为 换行加空格
        content = content.replacing(pattern: "\\s*\\n+\\s*", template: "\n　　")
        // 返回
        return content
    }
    
    private class func filePath(url: URL) -> URL {
        let path = ((NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as String) + "/\(ReadFolderName)/\(GetFileName(url).md5())")
        _ = CreatFilePath(path)
        return URL(fileURLWithPath: path)
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let url = aDecoder.decodeObject(forKey: "url") as? URL else {
            return nil
        }
        guard let content = aDecoder.decodeObject(forKey: "content") as? String else {
            return nil
        }
        guard let chapterContentRangeList = aDecoder.decodeObject(forKey: "chapterContentRangeList") as? [NSRange] else {
            return nil
        }
        guard let chapterTitleRangeList = aDecoder.decodeObject(forKey: "chapterTitleRangeList") as? [NSRange], chapterContentRangeList.count == chapterTitleRangeList.count else {
            return nil
        }
        
        
        self.url = url
        self.content =  content
        self.chapterContentRangeList = chapterContentRangeList
        self.chapterTitleRangeList = chapterTitleRangeList
        super.init()
        let path = LQReadContent.filePath(url: url)
        var titleRange = NSRange(location: 0, length: 0)
        var range = NSRange(location: 0, length: 0)
        var title = ""
        for index in 0 ..< chapterContentRangeList.count {
            titleRange = self.chapterTitleRangeList[index]
            range = chapterContentRangeList[index]
            if titleRange.length == 0 {
                title = "开始"
            } else {
                title = content.substring(titleRange)
            }
            let chapterModel = LQReadChapterModel(name: title, content: content.substring(range), chapterNo: index, path: path)
            chapterModel.delegate = self
            chapterList.append(chapterModel)
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(chapterContentRangeList, forKey: "chapterContentRangeList")
        aCoder.encode(chapterTitleRangeList, forKey: "chapterTitleRangeList")
    }
    
    class func contentArchivePath(url: URL) -> URL {
        let bookNameMD5 = GetFileName(url).md5()
        return LQReadContent.filePath(url: url).appendingPathComponent(bookNameMD5)
    }
    
    class func unarchiveSelf(url: URL) -> LQReadContent? {
        let contentPath = contentArchivePath(url: url).path
        return NSKeyedUnarchiver.unarchiveObject(withFile: contentPath) as? LQReadContent
    }
}
