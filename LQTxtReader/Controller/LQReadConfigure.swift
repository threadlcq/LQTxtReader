//
//  LQReadConfigure.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/12.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

let LQReadConfigureKey:String = "ReadConfigure"
/// 字体类型
enum LQReadFontType:NSInteger {
    case system             // 系统
    case simhei                // 黑体
    case kaiti                // 楷体
    case simsun              // 宋体
}

/// 翻页类型
enum LQReadEffectType:NSInteger {
    case translation = 0       // 平移
    case upAndDown          // 上下
}

/// 单利对象
private var instance:LQReadConfigure? = nil
// MARK: -- 配置属性

/// 背景颜色数组
let LQReadBGColors:[UIColor?] = [UIColor.colorWithHexString(hex: "f5f5f5"),UIColor.colorWithHexString(hex: "c5e6d0"),UIColor.colorWithHexString(hex: "2f333e")]

/// 根据背景颜色 对应的文字颜色 数组(数量必须与 LQReadBGColors 相同)
// let LQReadTextColors:[UIColor] = [LQColor_5,LQColor_5,LQColor_5,LQColor_5,LQColor_5,LQColor_5]

/// 阅读最小阅读字体大小
let LQReadMinFontSize:NSInteger = 12

/// 阅读当前默认字体大小
let LQReadDefaultFontSize:NSInteger = 16

class LQReadConfigure: NSObject {
    private override init() {
         super.init()
    }
    
    /// 单例
    @objc class func shared() -> LQReadConfigure {
        if instance == nil {
            instance = LQReadConfigure.readInfo()
        }
        return instance!
    }
    
    // MARK: -- 属性
    
    /// 当前阅读的背景颜色
    @objc var colorIndex:NSInteger = 0 {didSet{save()}}
    /// 字体类型
    @objc var fontType:NSInteger = LQReadFontType.system.rawValue {didSet{save()}}
    /// 字体大小
    @objc var fontSize:NSInteger = LQReadDefaultFontSize {didSet{save()}}
    /// 翻页效果
    @objc var effectType:NSInteger = LQReadEffectType.translation.rawValue {didSet{save()}}
    /// 阅读文字颜色(根据需求自己选)
    @objc var textColor:UIColor {
        // 固定颜色使用
        get{return LQColor_5}
    }
    /// 保存
    @objc func save() {
        var dict = allPropertys()
        dict.removeValue(forKey: "textColor")
        LQUserDefaults.setObject(dict, key: LQReadConfigureKey)
    }
    
    /// 清理(暂无需求使用)
    private func clear() {
        
        instance = nil
        LQUserDefaults.removeObjectForKey(LQReadConfigureKey)
    }
    
    /// 获得文字属性字典 (isPaging: 为YES的时候只需要返回跟分页相关的属性即可 注意: 包含 UIColor , 小数点相关的...不可返回,因为无法进行比较)
    @objc func readAttribute(isPaging:Bool = false) ->[NSAttributedStringKey:Any] {
        
        // 段落配置
        let paragraphStyle = NSMutableParagraphStyle()
        
        // 行间距
        paragraphStyle.lineSpacing = LQSpace_4
        
        // 段间距
        paragraphStyle.paragraphSpacing = LQSpace_6
        
        // 当前行间距(lineSpacing)的倍数(可根据字体大小变化修改倍数)
        paragraphStyle.lineHeightMultiple = 1.0
        
        // 对其
        paragraphStyle.alignment = NSTextAlignment.justified
        
        // 返回
        if isPaging {
            // 只需要传回跟分页有关的属性即可
            return [NSAttributedStringKey.font:readFont(), NSAttributedStringKey.paragraphStyle:paragraphStyle]
        }else{
            return [NSAttributedStringKey.foregroundColor:textColor, NSAttributedStringKey.font:readFont(), NSAttributedStringKey.paragraphStyle:paragraphStyle]
        }
    }
    
    /// 获得颜色
    @objc func readColor() ->UIColor? {
        return LQReadBGColors[colorIndex]
    }
    
    /// 获得文字Font
    @objc func readFont() ->UIFont {
        if fontType == LQReadFontType.simhei.rawValue { // 黑体
            return UIFont(name: "EuphemiaUCAS-Italic", size: CGFloat(fontSize))!
        }else if fontType == LQReadFontType.kaiti.rawValue { // 楷体
            return UIFont(name: "AmericanTypewriter-Light", size: CGFloat(fontSize))!
        }else if fontType == LQReadFontType.simsun.rawValue { // 宋体
            return UIFont(name: "Papyrus", size: CGFloat(fontSize))!
        }else{ // 系统
            return UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
    }
    
    // MARK: -- 构造初始化
    
    /// 创建获取内存中的用户信息
    @objc class func readInfo() ->LQReadConfigure {
        
        let info = LQUserDefaults.objectForKey(LQReadConfigureKey)
        
        return LQReadConfigure(dict:info)
    }
    
    /// 初始化
    private init(dict:Any?) {
        super.init()
        setData(dict: dict)
    }
    
    /// 更新设置数据
    private func setData(dict:Any?) {
        if dict != nil {
            setValuesForKeys(dict as! [String : AnyObject])
        }
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    
    // MARK: 进度存储
    
    /// 获取进度
    ///
    /// - Parameter bookId: 书名的md5
    /// - Returns: 保存的记录
    func getRecode(bookId: String) -> LQReadRecode {
        let chapterKey = "book_recode\(bookId)"
        if let data = LQUserDefaults.objectForKey(chapterKey) as? Data, let readPage = NSKeyedUnarchiver.unarchiveObject(with: data) as? LQReadRecode {
            return readPage
        } else {
            return LQReadRecode(charIndex: 0, chapterNo: 0)
        }
    }
    
    /// 存储进度
    ///
    /// - Parameters:
    ///   - bookId: 书名的md5
    ///   - recode: 保存的记录
    func setRecode(bookId: String, recode: LQReadRecode) {
        let chapterKey = "book_recode\(bookId)"
        LQUserDefaults.setObject(NSKeyedArchiver.archivedData(withRootObject: recode), key: chapterKey)
    }

}
