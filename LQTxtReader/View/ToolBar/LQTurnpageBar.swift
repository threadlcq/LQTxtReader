//
//  LQTurnpageBar.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQTurnpageBar: UIView {
    weak var delegate: LQTurnpageBarDelegate? = nil
    private var btnArray: [UIButton] = []
    private var selectBtn: UIButton? = nil
    
    init(frame: CGRect, btnTitles: [String]) {
        super.init(frame: frame)
        self.backgroundColor = LQBlackTintColor
        let currentIndex = LQReadConfigure.shared().effectType
        for index in 0 ..< btnTitles.count {
            let btn = UIButton(type: .custom)
            btn.tag = index
            btn.setTitle(btnTitles[index], for: .normal)
            btn.setImage(UIImage(named: "txtunselectcircle"), for: .normal)
            btn.setImage(UIImage(named: "txtslidercircle"), for: .selected)
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.addTarget(self, action: #selector(LQTurnpageBar.btnClickAction(btn:)), for: .touchUpInside)
            addSubview(btn)
            btnArray.append(btn)
            if currentIndex == index {
                selectBtn = btn
                selectBtn?.isSelected = true
            }
        }
        makeEqualBtnViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeEqualBtnViews() {
        var lastView: UIView? = nil
        for subView in self.btnArray {
            if let lastView = lastView {
                subView.snp.makeConstraints { (make) in
                    make.top.bottom.width.equalTo(lastView)
                    make.left.equalTo(lastView.snp.right)
                }
            } else {
                subView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.snp.top)
                    make.bottom.equalTo(self.snp.bottom).offset(-LQSafeAreaInsets.bottom)
                    make.left.equalTo(self.snp.left)
                }
            }
            lastView = subView
        }
        lastView?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.snp.right)
        })
    }
    
    @objc private func btnClickAction(btn: UIButton) {
        selectBtn?.isSelected = false
        btn.isSelected = true
        selectBtn = btn
        if let effectType = LQReadEffectType(rawValue: btn.tag) {
            self.delegate?.turnpageBar(self, effectType: effectType)
        }
    }

}
