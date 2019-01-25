//
//  XBGridCell.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import SnapKit

/// MARK - XBGridCell
public class XBGridCell: UICollectionViewCell {
    
    /// Cell唯一标示
    public static var identifier = "XBGridCell"
    
    /// 资源唯一标示
    public var representedAssetIdentifier: String!
    
    /// 缩略图
    public var thumbnailImage: UIImage! {
        didSet {
            self.imageView.image = thumbnailImage
        }
    }
    
    /// 实况图片
    public var livePhotoBadgeImage: UIImage? {
        didSet {
            self.livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }
    
    
    /// private
    /// 图片View
    private lazy var imageView: UIImageView = {
        let temImageView = UIImageView()
        temImageView.contentMode = .scaleAspectFill
        temImageView.clipsToBounds = true
        return temImageView
    }()
    
    /// 实况Badge
    private lazy var livePhotoBadgeImageView: UIImageView = {
        let temImageView = UIImageView()
        return temImageView
    }()
    
    /// 选择图片View
    private lazy var selectImageView: UIImageView = {
        let temImageView = UIImageView()
        return temImageView
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.white
        self.configView()
        self.configLocation()
    }
    
    /// 配置View
    private func configView() {
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(livePhotoBadgeImageView)
    }
    
    /// 配置位置
    private func configLocation() {
        
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        
        self.livePhotoBadgeImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
