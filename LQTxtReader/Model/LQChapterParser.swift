//
//  LQChapterParser.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/28.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

fileprivate let LQCalculateOnce = 20

class LQChapterParser: NSObject {
    let content: String
    let showSize: CGSize
    let attrs: [NSAttributedStringKey:Any]
    var isCancel: Bool = false
    
    deinit {
        isCancel = true
    }
    
    init(content: String, showSize:CGSize, attrs:[NSAttributedStringKey:Any]) {
        self.content = content
        self.attrs = attrs
        self.showSize = showSize
        super.init()
    }
    
    func calculatePageRange(calculateState: (_ calcuatePages: [LQParserPage], _ isFinish: Bool, _ isCancel: Bool) -> Void) {
        var pageRangeBegin = 0;
        
        // 记录
        var rangeArray:[LQParserPage] = []
        // 拼接字符串
        let attrString = NSMutableAttributedString(string: content, attributes: attrs)
        let frameSetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: showSize.width, height: showSize.height), transform: nil)
        var range = CFRangeMake(0, 0)
        var rangeOffset:NSInteger = 0
        repeat {
            let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(rangeOffset, 0), path, nil)
            range = CTFrameGetVisibleStringRange(frame)
            let range = NSMakeRange(rangeOffset, range.length)
            
            let childString = content.substring(range)
            let height = measureHeight(pageString: childString)
            let pagePosition = CGVector(dx: CGFloat(pageRangeBegin), dy: height)
            
            rangeArray.append(LQParserPage(pageRange: range, pagePosition: pagePosition))
            pageRangeBegin += Int(height)
            rangeOffset += range.length
            
            if (rangeArray.count % LQCalculateOnce == 0) {
                //获得中间结果
                calculateState(rangeArray, false, false)
            }
        } while(!self.isCancel && range.location + range.length < attrString.length)
        
        //返回结果
        if (self.isCancel) {
            calculateState(rangeArray, false, true)
        } else {
            if let lastRange = rangeArray.last {
                lastRange.adjustPosition(adjustValue: showSize.height)
            }
            
            calculateState(rangeArray, true, false)
        }
    }
    
    func measureHeight(pageString: String) -> CGFloat {
        let attrString = NSMutableAttributedString(string: pageString, attributes: attrs)
        let frameSetter = CTFramesetterCreateWithAttributedString(attrString as CFAttributedString)
        let stringRange: CFRange = CFRangeMake(0, pageString.length)
        let constraints: CGSize =  CGSize.init(width: showSize.width, height: 1000000)
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, stringRange, nil, constraints, nil)
        return suggestedSize.height+LQSpace_4
    }
}
