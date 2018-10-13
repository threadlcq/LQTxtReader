//
//  LQGlobalProperty.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
// MARK: -- 屏幕属性

/// 屏幕宽度
let ScreenWidth:CGFloat = UIScreen.main.bounds.size.width

/// 屏幕高度
let ScreenHeight:CGFloat = UIScreen.main.bounds.size.height

/// iPhone X
let isX:Bool = {
    if #available(iOS 11.0, *) {
        let mainWindow: UIWindow? = UIApplication.shared.delegate?.window ?? nil
        if let window = mainWindow, window.safeAreaInsets.bottom > 0 {
            return true
        }
    }
    return false
}()

/// 导航栏高度
let NavgationBarHeight:CGFloat = isX ? 88 : 64

/// iPhone X 顶部刘海高度
let TopLiuHeight:CGFloat = 30

/// StatusBar高度
let StatusBarHeight:CGFloat = isX ? 44 : 20

/// TabBar高度
let TabBarHeight: CGFloat = {
    return LQSafeAreaInsets.bottom + 49
}()


// MARK: -- 颜色支持
///
let LQBlackTintColor: UIColor? = UIColor.colorWithHexString(hex: "#373737")
/// 灰色
let LQColor_1:UIColor = RGB(51, g: 51, b: 51)

/// 粉红色
let LQColor_2:UIColor = RGB(253, g: 85, b: 103)

/// 阅读上下状态栏颜色
let LQColor_3:UIColor = RGB(127, g: 136, b: 138)

/// 小说阅读上下状态栏字体颜色
let LQColor_4:UIColor = RGB(127, g: 136, b: 138)

/// 小说阅读颜色
let LQColor_5:UIColor = RGB(145, g: 145, b: 145)

/// LeftView文字颜色
let LQColor_6:UIColor = RGB(200, g: 200, b: 200)


/// 阅读背景颜色支持
let LQReadBGColor_1:UIColor = RGB(238, g: 224, b: 202)
let LQReadBGColor_2:UIColor = RGB(205, g: 239, b: 205)
let LQReadBGColor_3:UIColor = RGB(206, g: 233, b: 241)
let LQReadBGColor_4:UIColor = RGB(251, g: 237, b: 199)  // 牛皮黄
let LQReadBGColor_5:UIColor = RGB(51, g: 51, b: 51)

/// 菜单背景颜色
let LQMenuUIColor:UIColor = UIColor.black.withAlphaComponent(0.85)

// MARK: -- 字体支持
let LQFont_10:UIFont = UIFont.systemFont(ofSize: 10)
let LQFont_12:UIFont = UIFont.systemFont(ofSize: 12)
let LQFont_18:UIFont = UIFont.systemFont(ofSize: 18)


// MARK: -- 间距支持
let LQSpace_3:CGFloat = 1
let LQSpace_4:CGFloat = 10
let LQSpace_5:CGFloat = 20
let LQSpace_6:CGFloat = 5

// MARK: 拖拽触发光标范围
let LQCursorOffset:CGFloat = -20


// MARK: -- Key

/// 是夜间还是日间模式   true:夜间 false:日间
let LQKey_IsNighOrtDay:String = "isNightOrDay"

/// ReadView 手势开启状态
let LQKey_ReadView_Ges_isOpen:String = "isOpen"

// MARK: 通知名称

/// ReadView 手势通知
let LQNotificationName_ReadView_Ges = "ReadView_Ges"

// MARK: 阅读器的边缘距离
// 显示图片的边缘距离
let LQTxtShowInsets: UIEdgeInsets = UIEdgeInsets(top: 25, left: 15, bottom: 10, right: 15)

let LQSafeAreaInsets: UIEdgeInsets = {
    var safeAreaInsets: UIEdgeInsets = UIEdgeInsets.zero
    if #available(iOS 11.0, *) {
        let mainWindow: UIWindow? = UIApplication.shared.delegate?.window ?? nil
        if let window = mainWindow {
            safeAreaInsets = window.safeAreaInsets
        }
    }
    return safeAreaInsets
} ()

// MARK:文字切割大小
///  切割文字的可展示区域大小
let LQTxtShowSize: CGSize = {
    let safeAreaInsets: UIEdgeInsets = LQSafeAreaInsets
    let screenSize = UIScreen.main.bounds.size
    return CGSize(width: screenSize.width - LQTxtShowInsets.left - LQTxtShowInsets.right,
                  height: screenSize.height - safeAreaInsets.top - safeAreaInsets.bottom - LQTxtShowInsets.top - LQTxtShowInsets.bottom)
    
} ()
