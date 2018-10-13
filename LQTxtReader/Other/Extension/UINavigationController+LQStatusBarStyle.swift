//
//  UINavigationController+LQStatusBarStyle.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/4.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import Foundation

extension UINavigationController {
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.visibleViewController
    }
}
