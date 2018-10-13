//
//  LQReadPage.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/29.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQReadPage: NSObject {
    let pageContent: String
    let pageIndex: Int
    let pageChapter: Int
    
    init(pageNo: Int, chapterNo: Int, pageContent: String) {
        self.pageIndex = pageNo
        self.pageChapter = chapterNo
        self.pageContent = pageContent
        super.init()
    }
    
}

class LQReadRecode: NSObject, NSCoding {
    let chapterNo: Int
    let charIndex: Int
    init(charIndex: Int, chapterNo: Int) {
        self.charIndex = charIndex
        self.chapterNo = chapterNo
        super.init()
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(chapterNo, forKey: "chapterNo")
        aCoder.encode(charIndex, forKey: "charIndex")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.chapterNo = aDecoder.decodeInteger(forKey: "chapterNo")
        self.charIndex = aDecoder.decodeInteger(forKey: "charIndex")
        super.init()
    }
}
