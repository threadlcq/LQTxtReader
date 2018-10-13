//
//  LQReaderView.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQReaderView: UIView {
    private var frameSetter: CTFramesetter? = nil
    
    /// CTFrame
    private var frameRef:CTFrame? = nil
    /// 内容
    var content:String? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefultInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefultInfo()
    }
    
    private func setupDefultInfo () {
        self.contentMode = .redraw
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let content = self.content else {
            return;
        }
        
        let attributedString = NSMutableAttributedString(string: content,attributes: LQReadConfigure.shared().readAttribute())
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        let path = CGPath(rect: rect, transform: nil)
        self.frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        if (self.frameRef == nil) {
            return
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.textMatrix = .identity
        ctx?.translateBy(x: 0, y: bounds.size.height)
        ctx?.scaleBy(x: 1.0, y: -1.0)
        if (ctx == nil) {
            return;
        }
        CTFrameDraw(self.frameRef!, ctx!)
    }
    
}
