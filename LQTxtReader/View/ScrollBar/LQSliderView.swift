//
//  LQSliderView.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol LQSliderBarDelegate {
    @objc optional func scrollBarContentWillChange(value: Float)
    @objc optional func scrollBarContentChange(value: Float)
    @objc optional func scrollBarContentDidChange(value: Float)
    
    @objc optional func scrollBarContentDidStopScroll(value: Float)
}

class LQSliderView: UIView {
    var thumbOn: Bool = false
    weak var delegate: LQSliderBarDelegate? = nil
    private var slider: LQImageScrollbar!
    private var sliderVisibilityTimer: Timer? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        slider = LQImageScrollbar(frame: frame)
        slider.backgroundColor = UIColor.clear
        slider.addTarget(self, action: #selector(LQSliderView.handleSliderWillChange(slider:)), for: .touchDown)
        slider.addTarget(self, action: #selector(LQSliderView.handleSliderChange(slider:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(LQSliderView.handleSliderDidChange(slider:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(LQSliderView.handleSliderCancel(slider:)), for: .touchCancel)
        self.addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.left.right.bottom.top.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSliderHidden(_ hidden: Bool, animation: Bool) {
        cancelSliderHiding()
        self.alpha = hidden ? 0 : 1
        if !hidden && animation {
            self.sliderVisibilityTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false, block: { [weak self] (timer) in
                self?.hideSlider()
            })
        }
    }
    
    func setValue(value: Float) {
        if !thumbOn {
            slider.value = value
        }
        
        setSliderHidden(false, animation: true)
    }
    
    private func hideSlider() {
        UIView.animate(withDuration: 0.35) {
            self.alpha = 0
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointt = self.convert(point, to: self.slider)
        if self.slider.isTracking || self.slider.trackRect().contains(pointt) {
            return super.hitTest(point, with: event)
        }
        
        return nil
    }
    
    func defaultWidth() -> CGFloat {
        return self.slider.trackRect().size.width
    }
    
    private func cancelSliderHiding() {
        if sliderVisibilityTimer != nil {
            sliderVisibilityTimer?.invalidate()
            sliderVisibilityTimer = nil
        }
    }
    
    @objc private func handleSliderWillChange(slider: LQImageScrollbar) {
        thumbOn = true
        cancelSliderHiding()
        self.delegate?.scrollBarContentWillChange?(value: slider.value)
    }
    
    @objc private func handleSliderChange(slider: LQImageScrollbar) {
        self.delegate?.scrollBarContentChange?(value: slider.value)
    }
    
    @objc private func handleSliderDidChange(slider: LQImageScrollbar) {
        thumbOn = false
        self.delegate?.scrollBarContentDidChange?(value: slider.value)
        setSliderHidden(false, animation: true)
    }
    
    @objc private func handleSliderCancel(slider: LQImageScrollbar) {
        thumbOn = false
        self.delegate?.scrollBarContentDidStopScroll?(value: slider.value)
        setSliderHidden(false, animation: true)
    }

}

