//
//  LQStatusView.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/3.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQStatusView: UIView {
    /// 电池
    private var batteryView:LQBatteryView!
    /// 时间
    private(set) var timeLabel:UILabel!
    /// 标题
    private(set) var titleLabel:UILabel!
    /// 计时器
    private var timer:Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        // 背景颜色
        backgroundColor = LQColor_1.withAlphaComponent(0.4)
        
        // 电池
        batteryView = LQBatteryView()
        batteryView.tintColor = LQColor_3
        addSubview(batteryView)
        
        batteryView.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-LQTxtShowInsets.right)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(LQBatterySize.width)
            make.height.equalTo(LQBatterySize.height)
        }
        
        // 时间
        timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.font = LQFont_12
        timeLabel.textColor = LQColor_3
        addSubview(timeLabel)
        
        let timeLabelW:CGFloat = LQSizeW(50)
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(batteryView.snp.left)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(self.snp.height)
            make.width.equalTo(timeLabelW)
        }
        
        // 标题
        titleLabel = UILabel()
        titleLabel.font = LQFont_12
        titleLabel.textColor = LQColor_3
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(LQTxtShowInsets.right)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(self.snp.height)
            make.right.equalTo(timeLabel.snp.left)
        }
        // 初始化调用
        didChangeTime()
        // 添加定时器
        addTimer()
    }
    
    func setPageInfo(str: String?) {
        titleLabel.text = str
    }
    
    // MARK: -- 时间相关
    /// 添加定时器
    func addTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(didChangeTime), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    /// 删除定时器
    func removeTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    /// 时间变化
    @objc func didChangeTime() {
        timeLabel.text = GetCurrentTimerString(dateFormat: "HH:mm")
        batteryView.batteryLevel = UIDevice.current.batteryLevel
    }
    
    /// 销毁
    deinit {
        removeTimer()
    }
}
