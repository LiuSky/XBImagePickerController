//
//  ImagePermissionsTipView.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/31.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import SnapKit

/// MARK - 权限提示View
final class ImagePermissionsTipView: UIView {

    /// 提示
    public var tip: String! {
        didSet {
            self.tipLabel.text = tip
        }
    }
    
    /// 提示标签
    private lazy var tipLabel: UILabel = {
        let temLabel = UILabel()
        temLabel.textAlignment = .center
        temLabel.numberOfLines = 0
        return temLabel
    }()
    
    init() {
        
        super.init(frame: CGRect.zero)
        self.addSubview(tipLabel)
        self.tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.centerY.equalTo(self).offset(-100)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
