//
//  LQToolBarDelegate.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/9.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import Foundation

enum LQToolbarStyle:UInt {
    case normal = 0    //黑色
    case lightContent  //白色
}

protocol LQToolBarDelegate: NSObjectProtocol {
    func toolbar(_ toolbar: LQToolBar, enable operationType:UInt) -> Bool
    func toolbar(_ toolbar: LQToolBar, didselect operationType:UInt)
    func toolbar(_ toolbar: LQToolBar, title operationType:UInt) -> String
}

extension LQToolBarDelegate {
    func toolbar(_ toolbar: LQToolBar, enable operationType:UInt) -> Bool {
        return true
    }
    func toolbar(_ toolbar: LQToolBar, didselect operationType:UInt) {
        
    }
    func toolbar(_ toolbar: LQToolBar, title operationType:UInt) -> String {
        return ""
    }
}

protocol LQSettingBarDelegate: NSObjectProtocol {
    func settingBar(_ settingBar: LQBookSettingBar, lightValue: Float)
    func settingBar(_ settingBar: LQBookSettingBar, themeIndex: UInt)
    func settingBar(_ settingBar: LQBookSettingBar, fontIndex: UInt)
}

protocol LQProgressBarDelegate: NSObjectProtocol {
    func progressBar(_ progressBar: LQProgressBar, willChange value: Float)
    func progressBar(_ progressBar: LQProgressBar, changing value: Float)
    func progressBar(_ progressBar: LQProgressBar, didChange value: Float)
}

protocol LQTurnpageBarDelegate: NSObjectProtocol {
    func turnpageBar(_ turnpageBar: LQTurnpageBar, effectType: LQReadEffectType)
}

protocol LQReadTxtProtocol: NSObjectProtocol {
    var readBook: LQBookController? { get set }
    var currentReadPage: LQReadPage? { get }
    func showReaderPage(pageNo: Int, chapterNo: Int, readBook: LQBookController)
    func readParseSuccess()
}

extension LQReadTxtProtocol {
    func readParseSuccess() {}
}
