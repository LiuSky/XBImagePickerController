//
//  ViewController.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/25.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import SnapKit

/// MARK - 添加照片
final class ViewController: UIViewController {

    /// Layout
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let temFlowLayout = UICollectionViewFlowLayout()
        let spacing: CGFloat = CGFloat(4 - 1) * 4
        let width = (UIScreen.main.bounds.size.width - spacing - 4 - 4)/4
        temFlowLayout.itemSize = CGSize(width: width, height: width)
        temFlowLayout.minimumLineSpacing = CGFloat(4)
        temFlowLayout.minimumInteritemSpacing = 4
        temFlowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return temFlowLayout
    }()
    
    /// 列表
    private lazy var collectionView: UICollectionView = {
        
        let temColl = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.flowLayout)
        temColl.backgroundColor = UIColor.white
        temColl.dataSource = self
        temColl.delegate = self
        temColl.register(ViewControllerCell.self, forCellWithReuseIdentifier: "ViewControllerCell")
        return temColl
    }()
    
    /// 添加按钮
    private lazy var rightButton = UIBarButtonItem(title: "添加", style: UIBarButtonItem.Style.done, target: self, action: #selector(push))
    
    public var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.rightButton
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    
    /// 跳转
    @objc private func push() {
        
        var configuration = Configuration()
        configuration.libraryMediaType = .all
        
        let na = ImagePickerController(configuration: configuration)
        na.pickerDelegate = self
        self.present(na, animated: true, completion: nil)
    }
}


// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewControllerCell", for: indexPath) as! ViewControllerCell
        cell.imageView.image = self.images[indexPath.row]
        return cell
    }
    
    
}


// MARK: - <#UICollectionViewDelegate#>
extension ViewController: UICollectionViewDelegate {
    
}


// MARK: - XBImageGridViewController
extension ViewController: ImagePickerControllerDelegate {
    
    func imagePickerDidFinished(_ picker: ImagePickerController, images: [UIImage]) {
        self.images = images
        self.collectionView.reloadData()
    }
    
    
    func imagePickerDidCancel(_ picker: ImagePickerController) {
        debugPrint(picker)
    }
}



/// UICollectionViewCell
final class ViewControllerCell: UICollectionViewCell {
    
    public lazy var imageView: UIImageView = {
        let temImageView = UIImageView()
        temImageView.contentMode = .scaleAspectFill
        temImageView.clipsToBounds = true
        return temImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
