//
//  FilterSliderControl.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/10.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

private let LQFilterSliderControlSmailSize = CGSize(width: 7, height: 7)
private let LQFilterSliderColor = UIColor.colorWithHexString(hex: "#1c1c1c")
private let LQFilterSliderOffset: CGFloat = 12
private let LQFilterSliderControlHeight: CGFloat = 40

class LQFilterSliderControl: UIControl {
    var selectedIndex: UInt = 0 {
        didSet {
            setThumbBtnFrame(index: selectedIndex)
        }
    }
    private let gradeCount: Int
    private var trackView: UIView!
    private var thumbBtn: UIButton!
    private var imageArray: [UIView] = []
    private var diffPoint: CGPoint = CGPoint.zero
    private var thumbBtnPoint: CGPoint = CGPoint.zero

    init?(gradeCount: Int) {
        if gradeCount < 1 {
            return nil
        }
        self.gradeCount = gradeCount
        super.init(frame: CGRect.zero)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        let gest = UITapGestureRecognizer(target: self, action: #selector(LQFilterSliderControl.itemSelected(tap:)))
        self.addGestureRecognizer(gest)
        trackView = UIView(frame: CGRect.zero)
        trackView.backgroundColor = LQFilterSliderColor
        self.addSubview(trackView)
        for _ in 0 ..< gradeCount {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: LQFilterSliderControlSmailSize.width, height: LQFilterSliderControlSmailSize.height))
            view.backgroundColor = LQFilterSliderColor
            view.layer.masksToBounds = true
            view.layer.cornerRadius = LQFilterSliderControlSmailSize.width/2
            self.addSubview(view)
            imageArray.append(view)
        }
        
        thumbBtn = UIButton(type: .custom)
        let image = UIImage(named: "txtslidercircle")
        thumbBtn.setImage(image, for: .normal)
        thumbBtn.setImage(image, for: .highlighted)
        thumbBtn.addTarget(self, action: #selector(LQFilterSliderControl.touchDown(btn:event:)), for: .touchDown)
        thumbBtn.addTarget(self, action: #selector(LQFilterSliderControl.touchUp(btn:)), for: [.touchUpInside, .touchUpOutside])
        thumbBtn.addTarget(self, action: #selector(LQFilterSliderControl.touchMove(btn:event:)), for: [.touchDragInside, .touchDragOutside])
        self.addSubview(thumbBtn)
    }
    
    private var oneSlotSize: CGFloat {
        let width = self.bounds.size.width - LQFilterSliderControlSmailSize.width - 2*LQFilterSliderOffset
        return width / CGFloat(gradeCount-1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        trackView.frame = CGRect(x: 2+LQFilterSliderOffset, y: size.height/2-2, width: size.width-4-2*LQFilterSliderOffset, height: 4)
        let oneSlotSize = self.oneSlotSize
        for index in 0 ..< gradeCount {
            imageArray[index].origin = CGPoint(x: LQFilterSliderOffset + CGFloat(index) * oneSlotSize, y: (size.height-LQFilterSliderControlSmailSize.height)/2)
        }
        
        setThumbBtnFrame(index: self.selectedIndex)
    }
    
    private func setThumbBtnFrame(index: UInt) {
        let size = self.bounds.size;
        let width = size.width - LQFilterSliderControlSmailSize.width - 2*LQFilterSliderOffset;
        let begin = LQFilterSliderOffset+(LQFilterSliderControlSmailSize.width-LQFilterSliderControlHeight)/2+CGFloat(index)*width/CGFloat(gradeCount-1);
        thumbBtn.frame = CGRect(x: begin, y: (size.height-LQFilterSliderControlHeight)/2, width: LQFilterSliderControlHeight, height: LQFilterSliderControlHeight)
    }
    
    
    @objc private func itemSelected(tap: UITapGestureRecognizer) {
        
    }
    
    @objc private func touchDown(btn: UIButton, event: UIEvent) {
        diffPoint = event.allTouches?.first?.location(in: self) ?? CGPoint.zero
        thumbBtnPoint = thumbBtn.frame.origin
        self.sendActions(for: .touchDown)
    }
    
    @objc private func touchMove(btn: UIButton, event: UIEvent) {
        let currPoint = event.allTouches?.first?.location(in: self) ?? CGPoint.zero
        let deltaX = currPoint.x - diffPoint.x;
        diffPoint = currPoint;
        thumbBtnPoint.x += deltaX;
        thumbBtnPoint = fixFinal(point: thumbBtnPoint)
        thumbBtn.frame =  CGRect(x: thumbBtnPoint.x, y: thumbBtnPoint.y, width: LQFilterSliderControlHeight, height: LQFilterSliderControlHeight)
        self.sendActions(for: .touchDragInside)
    }
    
    @objc private func touchUp(btn: UIButton) {
        selectedIndex = getSelectedPointInSlider(point: btn.center)
        animateHandler(to: selectedIndex)
        self.sendActions(for: .touchUpInside)
        self.sendActions(for: .valueChanged)
    }
    
    private func fixFinal(point: CGPoint) ->CGPoint {
        var point = point
        if point.x < LQFilterSliderOffset+LQFilterSliderControlSmailSize.width/2 - LQFilterSliderControlHeight/2 {
            point.x = LQFilterSliderOffset+LQFilterSliderControlSmailSize.width/2 - LQFilterSliderControlHeight/2
        } else if point.x > self.frame.size.width - LQFilterSliderControlSmailSize.width/2 - LQFilterSliderControlHeight/2 - LQFilterSliderOffset {
            point.x = self.frame.size.width - LQFilterSliderControlSmailSize.width/2 - LQFilterSliderControlHeight/2 - LQFilterSliderOffset;
        }
        return point;
    }
    
    private func getSelectedPointInSlider(point: CGPoint) -> UInt {
        return UInt(round((point.x-LQFilterSliderControlSmailSize.width/2-LQFilterSliderOffset)/self.oneSlotSize))
    }
    
    private func animateHandler(to index: UInt) {
        UIView.beginAnimations(nil, context: nil)
        setThumbBtnFrame(index: index)
        UIView.commitAnimations()
    }
}
