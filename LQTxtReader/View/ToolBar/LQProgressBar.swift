//
//  LQProgressBar.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import SnapKit

private let LQProcessIndexHeight:CGFloat = 50;

class LQProgressBar: UIView {
    weak var delegate: LQProgressBarDelegate? = nil
    private var pageIndexView: LQPageIndexView!
    private var sliderBgView: UIView!
    private var sliderView: LQBookSlider!
    private var effectType: LQReadEffectType = LQReadEffectType.translation
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: LQProcessIndexHeight + TabBarHeight))
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor.clear
        pageIndexView = LQPageIndexView(frame: CGRect.zero)
        pageIndexView.image =  UIImage(named: "txtpagesplay")
        addSubview(pageIndexView)
        
        let imageSize = pageIndexView.image?.size ?? CGSize.zero
        pageIndexView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top)
            make.centerX.equalTo(self.snp.centerX)
            make.size.equalTo(imageSize)
        }
        
        self.sliderBgView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: TabBarHeight))
        self.sliderBgView.backgroundColor = LQBlackTintColor
        addSubview(self.sliderBgView)
        
        sliderBgView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(TabBarHeight)
        }
        
        sliderView = LQBookSlider(frame: CGRect(x: 0, y: 0, width: self.width, height: 40))
        sliderView.addTarget(self, action: #selector(LQProgressBar.sliderValueWillChanage(slider:)), for: .touchDown)
        sliderView.addTarget(self, action: #selector(LQProgressBar.sliderValueChanage(slider:)), for: .valueChanged)
        sliderView.addTarget(self, action: #selector(LQProgressBar.sliderValueDidChanage(slider:)), for: [.touchUpInside,.touchUpOutside])
        sliderBgView.addSubview(sliderView)
        sliderView.snp.makeConstraints { (make) in
            make.left.equalTo(self.sliderBgView.snp.left).offset(40)
            make.right.equalTo(self.sliderBgView.snp.right).offset(-40)
            make.bottom.equalTo(self.sliderBgView).offset(-LQSafeAreaInsets.bottom)
            make.height.equalTo(40)
        }
    }
    
    func setTurnpageType(effect: LQReadEffectType) {
        if effectType == effect {
            return
        }
        effectType = effect
        switch effectType {
        case .translation:
            self.height += sliderBgView.height
            self.y += sliderBgView.height
            sliderBgView.isHidden = false
        case .upAndDown:
            self.height -= sliderBgView.height
            self.y -= sliderBgView.height
            sliderBgView.isHidden = true
        }
    }
    
    @objc private func sliderValueWillChanage(slider: LQBookSlider) {
        self.delegate?.progressBar(self, willChange: slider.value)
    }
    @objc private func sliderValueDidChanage(slider: LQBookSlider) {
        self.delegate?.progressBar(self, didChange: slider.value)
    }
    @objc private func sliderValueChanage(slider: LQBookSlider) {
        self.delegate?.progressBar(self, changing: slider.value)
    }
    
    func setPageValue(value: String) {
        pageIndexView.label.text = value
    }
    
    func setPageScale(value: Float) {
        self.sliderView.value = value
    }
}

class LQPageIndexView: UIImageView {
    private(set) var label: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: bounds)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.white
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
