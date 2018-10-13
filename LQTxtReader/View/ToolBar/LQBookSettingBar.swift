//
//  LQBookSettingBar.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/9.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import SnapKit

private let LQBookSettingBarOneHeight: CGFloat = 60
private let LQBookSettingBarLeftEdge: CGFloat = 30;
private let LQBookSettingBarLightOffset: CGFloat = 12;
private let LQBookSettingBarSliderLeftEdge: CGFloat = LQBookSettingBarLeftEdge + 18 + LQBookSettingBarLightOffset;

class LQBookSettingBar: UIView {
    weak var delegate: LQSettingBarDelegate? = nil
    private var smailImageView: UIImageView!
    private var bigImageView: UIImageView!
    private(set) var lightSlider: LQBookSlider!
    private(set) var bgGroupView: LQBookBgGroupView!
    private(set) var fontSlider: LQFilterSliderControl!
    private var leftFontLabel: UILabel!
    private var rightFontLable: UILabel!
    
    init() {
        let frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: LQBookSettingBarOneHeight*3 + LQSafeAreaInsets.bottom)
        super.init(frame: frame)
        self.backgroundColor = LQBlackTintColor
        setupViews()
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        smailImageView = UIImageView(image: UIImage(named: "txtsettingsunsmall"))
        self.addSubview(smailImageView)
        
        bigImageView = UIImageView(image: UIImage(named: "txtsettingsunbig"))
        self.addSubview(bigImageView)
        
        lightSlider = LQBookSlider(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: LQBookSlider.sliderHeight()))
        lightSlider.addTarget(self, action: #selector(LQBookSettingBar.lightValueChangeAction), for: .valueChanged)
        self.addSubview(lightSlider)
        
        let bgColors = LQReadBGColors
        bgGroupView = LQBookBgGroupView(bgColors: bgColors)
        bgGroupView.selectBlock = { [weak self] (selectIndex) in
            if let selfRef = self {
                selfRef.delegate?.settingBar(selfRef, themeIndex: selectIndex)
            }
        }
        self.addSubview(bgGroupView)
        
        leftFontLabel = UILabel(frame: CGRect.zero)
        leftFontLabel.text = "A";
        leftFontLabel.textColor = UIColor.colorWithHexString(hex: "0388ff")
        leftFontLabel.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(leftFontLabel)
        
        rightFontLable = UILabel(frame: CGRect.zero)
        rightFontLable.text = "A";
        rightFontLable.textColor = UIColor.colorWithHexString(hex: "0388ff")
        rightFontLable.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(rightFontLable)
        
        fontSlider = LQFilterSliderControl(gradeCount: 6)
        fontSlider.addTarget(self, action: #selector(LQBookSettingBar.fontValueChangeAction), for: .valueChanged)
        self.addSubview(fontSlider!)
    }
    
    func layoutViews() {
        lightSlider.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(LQBookSettingBarSliderLeftEdge)
            make.right.equalTo(self.snp.right).offset(-LQBookSettingBarSliderLeftEdge)
            make.centerY.equalTo(self.snp.top).offset(LQBookSettingBarOneHeight/2)
            make.height.equalTo(LQBookSlider.sliderHeight())
        }
        
        let smailSize = smailImageView.image?.size ?? CGSize.zero
        smailImageView.snp.makeConstraints { (make) in
            make.right.equalTo(self.lightSlider.snp.left).offset(-LQBookSettingBarLightOffset);
            make.centerY.equalTo(self.lightSlider.snp.centerY);
            make.size.equalTo(smailSize);
        };
        
        let bigSize = bigImageView.image?.size ?? CGSize.zero;
        bigImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.lightSlider.snp.right).offset(LQBookSettingBarLightOffset);
            make.centerY.equalTo(self.lightSlider.snp.centerY);
            make.size.equalTo(bigSize);
        }
        
        bgGroupView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.lightSlider)
            make.height.equalTo(26)
            make.centerY.equalTo(self.lightSlider.snp.centerY).offset(LQBookSettingBarOneHeight)
        }
        
        fontSlider.snp.makeConstraints { (make) in
            make.left.equalTo(self.lightSlider.snp.left).offset(-12);
            make.right.equalTo(self.lightSlider.snp.right).offset(12);
            make.centerY.equalTo(self.bgGroupView.snp.centerY).offset(LQBookSettingBarOneHeight)
            make.height.equalTo(40);
        }
        
        leftFontLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.smailImageView.snp.centerX);
            make.centerY.equalTo(self.fontSlider.snp.centerY);
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        rightFontLable.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.bigImageView.snp.centerX)
            make.centerY.equalTo(self.fontSlider.snp.centerY)
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
    }
    
    @objc private func fontValueChangeAction() {
        self.delegate?.settingBar(self, fontIndex: self.fontSlider?.selectedIndex ?? 0)
    }
    
    @objc private func lightValueChangeAction() {
        self.delegate?.settingBar(self, lightValue: self.lightSlider.value)
    }
}

class LQBookBgGroupView: UIView {
    var selectBlock: ((UInt) -> Void)?
    private var selectBgView: LQBookBgView? = nil
    init(bgColors: [UIColor?]) {
        super.init(frame: CGRect.zero)
        let indexCurrent = LQReadConfigure.shared().colorIndex
        for index in 0 ..< bgColors.count {
            let bgView = LQBookBgView(frame: CGRect.zero)
            bgView.backgroundColor = bgColors[index]
            bgView.addTarget(self, action: #selector(LQBookBgGroupView.selectedAction(bgView:)), for: .touchUpInside)
            bgView.tag = index
            self.addSubview(bgView)
            if index == indexCurrent {
                selectBgView = bgView
                selectBgView?.isSelected = true
            }
        }
        makeEqualBtnViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeEqualBtnViews() {
        var lastView: UIView? = nil
        for subView in self.subviews {
            if !(subView is LQBookBgView) {
                continue
            }
            if let lastView = lastView {
                subView.snp.makeConstraints { (make) in
                    make.top.bottom.width.equalTo(lastView)
                    make.left.equalTo(lastView.snp.right).offset(14)
                }
            } else {
                subView.snp.makeConstraints { (make) in
                    make.height.equalTo(26)
                    make.left.equalTo(self.snp.left)
                    make.centerY.equalTo(self.snp.centerY)
                }
            }
            lastView = subView
        }
        lastView?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.snp.right)
        })
    }
    
    @objc private func selectedAction(bgView: LQBookBgView) {
        selectBgView?.isSelected = false
        selectBgView = bgView
        selectBgView?.isSelected = true
        self.selectBlock?(UInt(bgView.tag))
    }
}
