//
//  XBGridCell.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import SnapKit


/// MARK - XBGridCellDelegate
public protocol XBGridCellDelegate: NSObjectProtocol {
    
    /// 选择照片Cell
    ///
    /// - Parameters:
    ///   - cell: cell
    ///   - selectImageView: selectImageView
    ///   - selectPhotoButton: selectPhotoButton
    func selectPhoto(_ cell: XBGridCell, selectImageView: UIImageView, selectPhotoButton: UIButton)
}



/// MARK - XBGridCell
public class XBGridCell: UICollectionViewCell {
    
    /// 回调
    public weak var delegate: XBGridCellDelegate?
    
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
    
    /// 实况图标
    public var livePhotoBadgeImage: UIImage? {
        didSet {
            self.livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }
    
    /// 选中图标
    public var photoSelImage: UIImage! {
        didSet {
            self.selectImageView.image = photoSelImage
        }
    }
    
    /// 未选中图标
    public var photoDefImage: UIImage! {
        didSet {
            self.selectImageView.image = photoDefImage
        }
    }
    
    
    /// 选中索引
    public var selectedIndex: Int = 0 {
        didSet {
            self.selectedLabel.text = "\(selectedIndex)"
            if selectedIndex > 0 {
                self.selectedLabel.isHidden = false
                self.selectImageView.image = self.photoSelImage
            } else {
               self.selectedLabel.isHidden = true
               self.selectImageView.image = self.photoDefImage
            }
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
    
    /// 选择按钮
    private lazy var selectButton: UIButton = {
        let temButton = UIButton(type: .custom)
        temButton.backgroundColor = UIColor.clear
        temButton.addTarget(self, action: #selector(eventForSelect), for: .touchUpInside)
        return temButton
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
        self.contentView.addSubview(selectButton)
        self.contentView.addSubview(selectImageView)
        self.contentView.addSubview(selectedLabel)
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
        
        self.selectButton.snp.makeConstraints { (make) in
            make.right.top.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        self.selectImageView.snp.makeConstraints { (make) in
            make.right.top.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 27, height: 27))
        }
        
        self.selectedLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.selectImageView.snp.center)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - event
extension XBGridCell {
    
    /// 点击选择
    @objc private func eventForSelect(_ sender: UIButton) {
       
        self.delegate?.selectPhoto(self, selectImageView: self.selectImageView, selectPhotoButton: sender)
    }
}
