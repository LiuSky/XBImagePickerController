//
//  ImageGridCell.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import SnapKit


/// MARK - ImageGridCellDelegate
public protocol ImageGridCellDelegate: NSObjectProtocol {
    
    /// 选择照片Cell
    ///
    /// - Parameters:
    ///   - cell: cell
    ///   - selectImageView: selectImageView
    ///   - selectPhotoButton: selectPhotoButton
    func selectPhoto(_ cell: ImageGridCell, selectImageView: UIImageView, selectPhotoButton: UIButton)
}


/// MARK - ImageGridCell
public class ImageGridCell: UICollectionViewCell {
    
    /// 回调
    public weak var delegate: ImageGridCellDelegate?
    
    /// Cell唯一标示
    public static var identifier = "XBGridCell"
    
    /// 资源唯一标示
    public var representedAssetIdentifier: String!
    
    /// 缩略图
    public var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    /// 实况图标
    public var livePhotoBadgeImage: UIImage? {
        didSet {
            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }
    
    /// 选中图标
    public var photoSelImage: UIImage! {
        didSet {
            selectImageView.image = photoSelImage
        }
    }
    
    /// 未选中图标
    public var photoDefImage: UIImage! {
        didSet {
            selectImageView.image = photoDefImage
        }
    }
    
    
    /// 选中索引
    public var selectedIndex: Int = 0 {
        didSet {
            selectedLabel.text = "\(selectedIndex)"
            if selectedIndex > 0 {
                selectedLabel.isHidden = false
                selectImageView.image = photoSelImage
            } else {
               selectedLabel.isHidden = true
               selectImageView.image = photoDefImage
            }
        }
    }
    
    /// 时间标签
    public var timer: String? {
        didSet {
            
            timerLabel.isHidden = true
            footView.isHidden = true
            guard let temTimer = timer else {
                return
            }
            footView.isHidden = false
            timerLabel.isHidden = false
            timerLabel.text = temTimer
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
    
    /// 底部View
    private lazy var footView: UIView = {
        let temView = UIView()
        temView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return temView
    }()
    
    /// 视频小图标
    private lazy var videoIcon: UIImageView = {
        let temView = UIImageView()
        temView.image = UIImage(named: "video_icon")
        return temView
    }()
    
    /// 视频时间标签
    private lazy var timerLabel: UILabel = {
        let temLabel = UILabel()
        temLabel.textColor = UIColor.white
        temLabel.textAlignment = .right
        temLabel.font = UIFont.systemFont(ofSize: 12)
        return temLabel
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.white
        configView()
        configLocation()
    }
    
    /// 配置View
    private func configView() {
        contentView.addSubview(imageView)
        contentView.addSubview(livePhotoBadgeImageView)
        contentView.addSubview(selectButton)
        contentView.addSubview(selectImageView)
        contentView.addSubview(selectedLabel)
        contentView.addSubview(footView)
        footView.addSubview(videoIcon)
        footView.addSubview(timerLabel)
    }
    
    /// 配置位置
    private func configLocation() {
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        livePhotoBadgeImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(contentView)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
        
        selectButton.snp.makeConstraints { (make) in
            make.right.top.equalTo(contentView)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        selectImageView.snp.makeConstraints { (make) in
            make.right.top.equalTo(contentView)
            make.size.equalTo(CGSize(width: 27, height: 27))
        }
        
        selectedLabel.snp.makeConstraints { (make) in
            make.center.equalTo(selectImageView.snp.center)
        }
        
        footView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(contentView)
            make.height.equalTo(16)
        }
        
        videoIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(footView).offset(-17)
            make.centerY.equalTo(footView)
            make.size.equalTo(CGSize(width: 17, height: 17))
        }
        
        timerLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(footView)
            make.right.equalTo(-6)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - event
extension ImageGridCell {
    
    /// 点击选择
    @objc private func eventForSelect(_ sender: UIButton) {
       
        self.delegate?.selectPhoto(self, selectImageView: self.selectImageView, selectPhotoButton: sender)
    }
}
