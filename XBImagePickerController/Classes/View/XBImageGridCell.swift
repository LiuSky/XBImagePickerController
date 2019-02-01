//
//  XBImageGridCell.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import SnapKit


/// MARK - XBImageGridCellDelegate
public protocol XBImageGridCellDelegate: NSObjectProtocol {
    
    /// 选择照片Cell
    ///
    /// - Parameters:
    ///   - cell: cell
    ///   - selectImageView: selectImageView
    ///   - selectPhotoButton: selectPhotoButton
    func selectPhoto(_ cell: XBImageGridCell, selectImageView: UIImageView, selectPhotoButton: UIButton)
}


/// MARK - XBImageGridCell
public class XBImageGridCell: UICollectionViewCell {
    
    /// 回调
    public weak var delegate: XBImageGridCellDelegate?
    
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
    
    /// 时间标签
    public var timer: String? {
        didSet {
            
            self.timerLabel.isHidden = true
            self.timerView.isHidden = true
            guard let temTimer = timer else {
                return
            }
            self.timerView.isHidden = false
            self.timerLabel.isHidden = false
            self.timerLabel.text = temTimer
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
    
    /// 时间View
    private lazy var timerView: UIView = {
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
        self.contentView.addSubview(timerView)
        self.timerView.addSubview(videoIcon)
        self.timerView.addSubview(timerLabel)
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
        
        self.timerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(16)
        }
        
        self.videoIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.timerView).offset(-17)
            make.centerY.equalTo(self.timerView)
            make.size.equalTo(CGSize(width: 17, height: 17))
        }
        
        self.timerLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.timerView)
            make.right.equalTo(-6)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - event
extension XBImageGridCell {
    
    /// 点击选择
    @objc private func eventForSelect(_ sender: UIButton) {
       
        self.delegate?.selectPhoto(self, selectImageView: self.selectImageView, selectPhotoButton: sender)
    }
}
