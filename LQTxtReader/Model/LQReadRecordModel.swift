//
//  LQReadRecordModel.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/16.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

/// 最后一页标示
let LQReadLastPageValue:NSInteger = -1

import UIKit

class LQReadRecordModel: NSObject {
    /// 是否存在记录
    var isRecord:Bool {get{return readChapterModel != nil}}
    
    /// 小说ID
    var bookID:String!
    
    /// 当前阅读到的章节模型
    var readChapterModel:LQReadChapterModel?
    
    /// 当前章节阅读到的页码(如果有云端记录或者多端使用阅读记录需求 可以记录location 通过location转成页码进行使用)
    var page:NSNumber = NSNumber(value: 0)
    
    // MARK: -- init
    
    override init() {
        
        super.init()
    }
    
    /// 通过书ID 获得阅读记录模型 没有则进行创建传出
    class func readRecordModel(bookID:String, isUpdateFont:Bool = false, isSave:Bool = false) ->LQReadRecordModel {
        
        var readModel:LQReadRecordModel!
        
        if LQReadRecordModel.IsExistReadRecordModel(bookID: bookID) { // 存在
            
            readModel = ReadKeyedUnarchiver(folderName: bookID, fileName: (bookID + "ReadRecord")) as! LQReadRecordModel
            
            if isUpdateFont {readModel.updateFont(isSave: isSave)}
            
        }else{ // 不存在
            
            readModel = LQReadRecordModel()
            
            readModel.bookID = bookID
        }
        
        return readModel!
    }
    
    // MARK: -- 操作
    
    /// 保存
    func save() {
        
        ReadKeyedArchiver(folderName: bookID, fileName: (bookID + "ReadRecord"), object: self)
    }
    
    /// 修改阅读记录为指定章节ID 指定页码 (toPage: -1 为最后一页 也可以使用 LQReadLastPageValue)
    func modify(chapterID:String, toPage:NSInteger = 0, isUpdateFont:Bool = false, isSave:Bool = false) {
        
        
    }
    
    /// 修改阅读记录为指定书签记录
    func modify(readMarkModel:LQReadMarkModel, isUpdateFont:Bool = false, isSave:Bool = false) {
        
       
    }
    
    /// 刷新字体
    func updateFont(isSave:Bool = false) {
        
        
    }
    
    /// 是否存在阅读记录模型
    class func IsExistReadRecordModel(bookID:String) ->Bool {
        
        return ReadKeyedIsExistArchiver(folderName: bookID, fileName: (bookID + "ReadRecord"))
    }
    
    // MARK: -- NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init()
        
        bookID = aDecoder.decodeObject(forKey: "bookID") as! String
        readChapterModel = aDecoder.decodeObject(forKey: "readChapterModel") as? LQReadChapterModel
        page = aDecoder.decodeObject(forKey: "page") as! NSNumber
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(bookID, forKey: "bookID")
        aCoder.encode(readChapterModel, forKey: "readChapterModel")
        aCoder.encode(page, forKey: "page")
    }
    
    // MARK: -- 拷贝
    func copySelf() ->LQReadRecordModel {
        
        let readRecordModel = LQReadRecordModel()
        readRecordModel.bookID = bookID
        readRecordModel.readChapterModel = readChapterModel        
        readRecordModel.page = page
        
        return readRecordModel
    }
}
