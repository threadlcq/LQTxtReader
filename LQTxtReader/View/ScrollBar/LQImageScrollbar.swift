//
//  LQImageScrollbar.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQImageScrollbar: UIControl {
    private var thumbBtn: UIButton!
    private var diffPoint: CGPoint = CGPoint.zero
    private var thumbBtnPoint: CGPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = UIColor.clear
        thumbBtn = UIButton(type: .custom)
        let thumbImage = UIImage(named: "file_hdt")
        thumbBtn.setImage(thumbImage, for: .normal)
        thumbBtn.setImage(thumbImage, for: .highlighted)
        thumbBtn.addTarget(self, action: #selector(LQImageScrollbar.touchDown(btn:event:)), for: .touchDown)
        thumbBtn.addTarget(self, action: #selector(LQImageScrollbar.touchUp(btn:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        thumbBtn.addTarget(self, action: #selector(LQImageScrollbar.touchMove(btn:event:)), for: [.touchDragInside, .touchDragOutside])
        thumbBtn.size = thumbImage?.size ?? CGSize.zero
        addSubview(thumbBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let availableHeight = self.availableHeight()
        var thumbLeft = self.width - thumbBtn.width;
        thumbLeft = thumbLeft < 0 ? 0 : thumbLeft
        thumbBtn.origin = CGPoint(x: thumbLeft, y: CGFloat(availableHeight * value))
    }
    
    func trackRect() -> CGRect {
        return thumbBtn.frame
    }
    
    @objc private func touchDown(btn: UIButton, event: UIEvent) {
        diffPoint = event.allTouches?.first?.location(in: self) ?? CGPoint.zero
        thumbBtnPoint = thumbBtn.frame.origin
        self.sendActions(for: .touchDown)
    }
    
    @objc private func touchMove(btn: UIButton, event: UIEvent) {
        let currPoint = event.allTouches?.first?.location(in: self) ?? CGPoint.zero
        let deltaY = currPoint.y - diffPoint.y
        diffPoint = currPoint
        thumbBtnPoint.y += deltaY
        thumbBtnPoint = fixFinal(point: thumbBtnPoint)
        thumbBtn.y = thumbBtnPoint.y
        self.sendActions(for: .touchDragInside)
        self.sendActions(for: .valueChanged)
    }
    
    @objc private func touchUp(btn: UIButton) {
        self.sendActions(for: .touchUpInside)
        self.sendActions(for: .valueChanged)
    }
    
    private func fixFinal(point: CGPoint) -> CGPoint {
        var point: CGPoint = point
        let thumbSize = thumbBtn.size;
        if point.y + thumbSize.height > self.height {
            point.y = self.height - thumbSize.height;
        }
        if (point.y < 0) {
            point.y = 0;
        }
        return point;
    }
    
    var value: Float {
        get {
            let availableHeight = self.availableHeight()
            if availableHeight <= 0 {
                return 0
            }
            return Float(thumbBtn.y) / availableHeight
        }
        set {
            var currentValue: Float = newValue
            if currentValue < 0 {
                currentValue  = 0
            } else if currentValue > 1 {
                currentValue = 1
            }
            
            thumbBtn.y = CGFloat(availableHeight() * currentValue)
        }
    }
    
    private func availableHeight() -> Float {
        let availableHeight = self.height - thumbBtn.height
        return availableHeight < 0 ? 0 : Float(availableHeight)
    }
    
}
