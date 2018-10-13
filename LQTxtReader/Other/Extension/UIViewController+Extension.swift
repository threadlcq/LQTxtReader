//
//  UIViewController+Extension.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/11.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        return self.viewControllers.last?.shouldAutorotate ?? true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.viewControllers.last?.supportedInterfaceOrientations ?? .portrait
        
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.viewControllers.last?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}
