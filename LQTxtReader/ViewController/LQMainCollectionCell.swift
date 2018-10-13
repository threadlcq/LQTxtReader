//
//  LQMainCollectionCell.swift
//  LQTxtReader
//
//  Created by liuchaoqun on 2018/9/30.
//  Copyright © 2018年 liuchaoqun. All rights reserved.
//

import UIKit

class LQMainCollectionCell: UICollectionViewCell {
    private let titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.darkGray
        
        titleLabel.frame = frame
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        
        self.contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = self.contentView.bounds
    }
    
    func setTitle(title: String?) {
        titleLabel.text = title
    }
}
