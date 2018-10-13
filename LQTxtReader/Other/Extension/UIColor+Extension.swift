//
//  UIColor+Extension.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/3.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import Foundation

// MARK:- 把#ffffff颜色转为UIColor
extension UIColor {
    
    private class func colorComponent(fromStr: String, start:Int, length:Int) -> CGFloat {
        let substring = fromStr.substring(NSRange(location: start, length: length))
        let fullHex = length == 2 ? substring : "\(substring)\(substring)"
        var hexComponent: CUnsignedInt = 0
        Scanner(string: fullHex).scanHexInt32(&hexComponent)
        return CGFloat(hexComponent) / 255.0
    }
    
    class func colorWithHexString(hex:String) ->UIColor? {
        
        var cString = hex.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        var alpha, red, blue, green: CGFloat;
        switch cString.length {
        case 3://#RGB
            alpha = 1;
            red = self.colorComponent(fromStr: cString, start: 0, length: 1)
            green = self.colorComponent(fromStr: cString, start: 1, length: 1)
            blue = self.colorComponent(fromStr: cString, start: 2, length: 1)
        case 4:  // #ARGB
            alpha = self.colorComponent(fromStr: cString, start: 0, length: 1);
            red = self.colorComponent(fromStr: cString, start: 1, length: 1)
            green = self.colorComponent(fromStr: cString, start: 2, length: 1)
            blue = self.colorComponent(fromStr: cString, start: 3, length: 1)
        case 6:  // #RRGGBB
            alpha = 1
            red = self.colorComponent(fromStr: cString, start: 0, length: 2)
            green = self.colorComponent(fromStr: cString, start: 2, length: 2)
            blue = self.colorComponent(fromStr: cString, start: 4, length: 2)
        case 8:  // #AARRGGBB
            alpha = self.colorComponent(fromStr: cString, start: 0, length: 2)
            red = self.colorComponent(fromStr: cString, start: 2, length: 2)
            green = self.colorComponent(fromStr: cString, start: 4, length: 2)
            blue = self.colorComponent(fromStr: cString, start: 6, length: 2)
        default:
            return nil
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha:alpha)
    }
}
