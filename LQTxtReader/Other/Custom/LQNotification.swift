//
//  LQNotification.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/11.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import Foundation

enum LQNotifation: String {
    case themeChange
    
    var stringValue: String {
        return "LQ" + rawValue
    }
    
    var notificationName: NSNotification.Name {
        return NSNotification.Name(stringValue)
    }
}

extension NotificationCenter {
    static func post(customeNotification name: LQNotifation, object: Any? = nil){
        NotificationCenter.default.post(name: name.notificationName, object: object)
    }
}
