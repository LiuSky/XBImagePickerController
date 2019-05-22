//
//  ImageGroupCell.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/29.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import SnapKit


/// MARK - ImageGroupCell
open class ImageGroupCell: UITableViewCell {

    /// 资源唯一标示
    public var representedAssetIdentifier: String!
    
    /// Cell唯一标示
    public static var identifier = "ImageGroupCell"
    
    /// 缩略图
    public var thumbnailImage: UIImage! {
        didSet {
            thumbnailImageView.image = thumbnailImage
        }
    }
    
    /// 相册名称
    public var albumName: String? {
        didSet {
            nameLabel.text = albumName
        }
    }
    
    /// 相册数量
    public var albumCount: String? {
        didSet {
            albumNumberLabel.text = albumCount
        }
    }
    
    /// 选中图标
    public var photoSelImage: UIImage! {
        didSet {
            selectImageView.image = photoSelImage
        }
    }
    
    /// 选中索引
    public var selectedCount: Int = 0 {
        didSet {
            selectedLabel.text = "\(selectedCount)"
            if selectedCount > 0 {
                selectImageView.isHidden = false
                selectedLabel.isHidden = false
            } else {
                selectedLabel.isHidden = true
                selectImageView.isHidden = true
            }
        }
    }
    
    /// 缩略图View
    private lazy var thumbnailImageView: UIImageView = {
        let temImageView = UIImageView()
        temImageView.contentMode = .scaleAspectFill
        temImageView.clipsToBounds = true
        return temImageView
    }()
    
    /// 名称标签
    private lazy var nameLabel: UILabel = {
        let temLabel = UILabel()
        return temLabel
    }()
    
    /// 相册数量标签
    private lazy var albumNumberLabel: UILabel = {
        let temLabel = UILabel()
        temLabel.textColor = UIColor.gray
        return temLabel
    }()
    
    /// 选择图片View
    private lazy var selectImageView: UIImageView = {
        let temImageView = UIImageView()
        return temImageView
    }()
    
    /// 选中标签
    private lazy var selectedLabel: UILabel = {
        let temLabel = UILabel()
        temLabel.font = UIFont.systemFont(ofSize: 14)
        temLabel.textColor = UIColor.white
        temLabel.textAlignment = .center
        return temLabel
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configView()
        configLocation()
    }
    
    
    /// 配置View
    private func configView() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(albumNumberLabel)
        contentView.addSubview(selectImageView)
        contentView.addSubview(selectedLabel)
    }
    
    /// 配置位置
    private func configLocation() {
        
        thumbnailImageView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(contentView)
            make.width.equalTo(thumbnailImageView.snp.height)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(thumbnailImageView.snp.right).offset(12)
            make.centerY.equalTo(contentView)
        }
        
        albumNumberLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(12)
            make.centerY.equalTo(contentView)
        }
        
        selectImageView.snp.makeConstraints { (make) in
            make.left.equalTo(albumNumberLabel.snp.right).offset(12)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize(width: 27, height: 27))
        }
        
        selectedLabel.snp.makeConstraints { (make) in
            make.center.equalTo(selectImageView.snp.center)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
