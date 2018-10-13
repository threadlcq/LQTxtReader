//
//  LQBookSlider.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/10/9.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit
import SnapKit

class LQBookSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let thumbImage = UIImage(named: "txtslidercircle")
        self.setThumbImage(thumbImage, for: .normal)
        self.setThumbImage(thumbImage, for: .highlighted)
        self.maximumTrackTintColor = UIColor.colorWithHexString(hex: "#1c1c1c")
        self.minimumTrackTintColor = UIColor.colorWithHexString(hex: "#0388ff")
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: self.bounds.height/2-2, width: self.bounds.width, height: 4)
    }
    
    class func sliderHeight() -> CGFloat {
        return 17
    }
}

class LQBookBgView: UIControl {
    private var imageView: UIImageView!
    private var selectBorderColor: UIColor? = UIColor.colorWithHexString(hex: "0388ff")
    var normalBorderColor: UIColor? = nil
    var image: UIImage? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(image: nil)
        self.addSubview(imageView)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3
        self.layer.borderWidth = 1
        imageView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self)
            make.width.height.equalTo(14)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            setSelectColor()
        }
    }
    
    func setSelectColor() {
        if self.isSelected {
            self.layer.borderColor = selectBorderColor?.cgColor
            self.imageView.image = UIImage(named: "txtselecticon")
        } else {
            self.layer.borderColor = normalBorderColor?.cgColor;
            self.imageView.image = self.image;
        }
    }
    
}
