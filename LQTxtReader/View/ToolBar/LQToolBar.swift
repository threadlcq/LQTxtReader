//
//  LQToolBar.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/9.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import SnapKit

class LQToolBar: UIView {
    private var operationBtnArray: [LQOperationButton] = []
    weak var delegate: LQToolBarDelegate? = nil
    var barStyle: LQToolbarStyle = .normal {
        didSet{self.backgroundColor = self.barStyle == .normal ? LQBlackTintColor : UIColor.white}
    }
    var translucent: Bool = false
    var leftrightPadding: CGFloat = 0
    var topPading: CGFloat = 0
    var bottomPading: CGFloat = 0
    var viewPading: CGFloat = 0
    init(frame: CGRect, delegate: LQToolBarDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        bottomPading = LQSafeAreaInsets.bottom
        self.backgroundColor = LQBlackTintColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func setOperationBtnArray(operBtnArray: [LQOperationButton]) {
        if operationBtnArray == operBtnArray {
            return
        }
        operationBtnArray = operBtnArray
        setupToolbarItem(operationArray: operBtnArray)
        updateEnableStatus()
    }
    
    private func removeSubBtnView() {
        let subviews = self.subviews
        for view in subviews {
            if view is LQOperationButton {
                view.removeFromSuperview()
            }
        }
    }
    
    private func setupToolbarItem(operationArray: [LQOperationButton]) {
        removeSubBtnView()
        for btn in operationArray {
            btn.addTarget(self, action: #selector(LQToolBar.handleOperationButtonClick(btn:)), for: .touchUpInside)
            self.addSubview(btn)
        }
        makeEqualBtnViews()
    }
    
    private func makeEqualBtnViews() {
        var lastView: UIView? = nil
        for subView in self.subviews {
            if !(subView is LQOperationButton) {
                continue
            }
            if let lastView = lastView {
                subView.snp.makeConstraints { (make) in
                    make.top.bottom.width.equalTo(lastView)
                    make.left.equalTo(lastView.snp.right).offset(self.viewPading)
                }
            } else {
                subView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.snp.top).offset(self.topPading)
                    make.bottom.equalTo(self.snp.bottom).offset(-self.bottomPading)
                    make.left.equalTo(self.snp.left).offset(self.leftrightPadding)
                }
            }
            lastView = subView
        }
        lastView?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.snp.right).offset(-self.leftrightPadding)
        })
    }
    
    func updateEnableStatus() {
        for subview in self.subviews {
            guard let btn = subview as? LQOperationButton, let delegate = self.delegate else {
                continue
            }
            btn.isEnabled = delegate.toolbar(self, enable: btn.operType)
        }
    }
    
    func updateTitle() {
        for subview in self.subviews {
            guard let btn = subview as? LQOperationButton, let delegate = self.delegate else {
                continue
            }
            btn.setTitle(delegate.toolbar(self, title: btn.operType), for: .normal)
        }
    }
    
    @objc private func handleOperationButtonClick(btn: LQOperationButton) {
        self.delegate?.toolbar(self, didselect: btn.operType)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection,
            previousTraitCollection.verticalSizeClass != .unspecified,
            self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass else {
                return
        }
    }
    
}
