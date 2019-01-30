//
//  XBImageGroupCell.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/29.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit


/// MARK - XBImageGroupCell
open class XBImageGroupCell: UITableViewCell {

    /// 资源唯一标示
    public var representedAssetIdentifier: String!
    
    /// Cell唯一标示
    public static var identifier = "XBImageGroupCell"
    
    /// 缩略图
    public var thumbnailImage: UIImage! {
        didSet {
            self.thumbnailImageView.image = thumbnailImage
        }
    }
    
    /// 相册名称
    public var albumName: String? {
        didSet {
            self.nameLabel.text = albumName
        }
    }
    
    /// 相册数量
    public var albumCount: String? {
        didSet {
            self.albumNumberLabel.text = albumCount
        }
    }
    
    /// 选中图标
    public var photoSelImage: UIImage! {
        didSet {
            self.selectImageView.image = photoSelImage
        }
    }
    
    /// 选中索引
    public var selectedIndex: Int = 0 {
        didSet {
            self.selectedLabel.text = "\(selectedIndex)"
            if selectedIndex > 0 {
                self.selectImageView.isHidden = false
                self.selectedLabel.isHidden = false
            } else {
                self.selectedLabel.isHidden = true
                self.selectImageView.isHidden = true
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
        self.configView()
        self.configLocation()
    }
    
    
    /// 配置View
    private func configView() {
        self.contentView.addSubview(thumbnailImageView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(albumNumberLabel)
        self.contentView.addSubview(selectImageView)
        self.contentView.addSubview(selectedLabel)
    }
    
    /// 配置位置
    private func configLocation() {
        
        self.thumbnailImageView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self.contentView)
            make.width.equalTo(self.thumbnailImageView.snp.height)
        }
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.thumbnailImageView.snp.right).offset(12)
            make.centerY.equalTo(self.contentView)
        }
        
        self.albumNumberLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel.snp.right).offset(12)
            make.centerY.equalTo(self.contentView)
        }
        
        self.selectImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.albumNumberLabel.snp.right).offset(12)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 27, height: 27))
        }
        
        self.selectedLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.selectImageView.snp.center)
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
