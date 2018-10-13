//
//  LQButtonOperationFactory.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/9.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQButtonOperationFactory: NSObject {
    private class func createButton(normalImage: UIImage?, highlightImage: UIImage?, title: String?, titleColor: UIColor?, hightlightColor: UIColor?, disableColor: UIColor?) -> LQOperationButton {
        let commanButton = LQOperationButton(type: .custom)
        commanButton.setImage(normalImage, for: .normal)
        commanButton.setImage(highlightImage, for: .highlighted)
        commanButton.setTitle(title, for: .normal)

        if titleColor != nil {
            commanButton.setTitleColor(titleColor, for: .normal)
        }
        if hightlightColor != nil {
            commanButton.setTitleColor(hightlightColor, for: .highlighted)
        }
        if (disableColor != nil) {
            commanButton.setTitleColor(disableColor, for: .disabled)
        }
        commanButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        commanButton.sizeToFit()
        
        let spacing:CGFloat = 0
        let imageSize = commanButton.imageView?.frame.size ?? CGSize.zero
        commanButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -(imageSize.height + spacing), 0)
        let titleSize = commanButton.titleLabel?.frame.size ?? CGSize.zero
        commanButton.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0, 0, -titleSize.width)
        return commanButton;
    }
    
    private class func createButton(type: LQToolbarItemType) -> LQOperationButton {
        var normalImage: UIImage? = nil
        var highlightImage: UIImage? = nil
        var title: String? = nil
        switch type {
        case .catalogue:
            normalImage = UIImage(named: "preview_unzip_normal")
            highlightImage = UIImage(named: "preview_unzip_press")
            title = "目录"
        case .progress:
            normalImage = UIImage(named: "proview_doc_speed_normal")
            highlightImage = UIImage(named: "proview_doc_speed_press")
            title = "进度"
        case .setting:
            normalImage = UIImage(named: "proview_doc_moon_normal")
            highlightImage = UIImage(named: "proview_doc_moon_press")
            title = "阅读设置"
        case .turnpage:
            normalImage = UIImage(named: "proview_doc_page_normal")
            highlightImage = UIImage(named: "proview_doc_page_press")
            title = "翻页设置"
        }
        let operationBtn = createButton(normalImage: normalImage, highlightImage: highlightImage, title: title, titleColor: UIColor.white, hightlightColor: UIColor.white.withAlphaComponent(0.8), disableColor: UIColor.gray)
        operationBtn.operType = type.rawValue
        return operationBtn
    }
    
    class func buildOperationButton(typeList: [LQToolbarItemType]) -> [LQOperationButton] {
        var operationBtnArray = [LQOperationButton]()
        for type in typeList {
            operationBtnArray.append(createButton(type: type))
        }
        return operationBtnArray
    }
    
    
}
