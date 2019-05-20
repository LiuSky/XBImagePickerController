//
//  XBImagePickerConfiguration.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/30.
//  Copyright © 2019 Sky. All rights reserved.
//

import Photos
import Foundation


/// MARK - ImagePickerConfiguration
public struct XBImagePickerConfiguration {

    public static var shared: XBImagePickerConfiguration = XBImagePickerConfiguration()
    
    public init() {}
    
    /// 对照片排序，按修改时间升序，默认是false。如果设置为true,最新的照片会显示在最后面
    public var sortAscendingByModificationDate: Bool = false
    
    /// 允许选择资源类型(默认所有)
    public var libraryMediaType: XBLibraryMediaType = XBLibraryMediaType.all
    
    /// 相册分组列表控制器配置
    public var groupTableView = XBConfigImageGroupTableView()
    
    /// 相册集合列表控制器配置
    public var gridView = XBConfigGridView()
    
    
}


/// 资源类型
///
/// - all: 所有
/// - image: 图片
/// - video: 视屏
public enum XBLibraryMediaType: Int, CustomStringConvertible {
    
    case all
    case image
    case video
    
    /// description
    public var description: String {
        switch self {
        case .all:
            return "所有资源"
        case .image:
            return "图片"
        case .video:
            return "视频"
        }
    }
}


/// MARK - 相册分组控制器 配置
public struct XBConfigImageGroupTableView {
    
    /// 行高(默认70)
    public var rowHeight: CGFloat = 70
    
    /// 选中图标
    public var photoSelImage = #imageLiteral(resourceName: "photoSelImage")
}



/// MARK - 相册集合列表控制器 配置
public struct XBConfigGridView {
    
    
    /// 一行显示几个(默认4个)
    public var numberOfColumns = 4
    
    /// 默认行间距(默认1)
    public var minimumLineSpacing = 2
    
    /// 默认列间距(默认1)
    public var minimumInteritemSpacing = 2
    
    /// 内间距
    public var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    /// 选择最大数量(默认9)
    public var selectMaxNumber = 9
    
    /// 选中图标
    public var photoSelImage = #imageLiteral(resourceName: "photoSelImage")
    
    /// 未选中图标
    public var photoDefImage = #imageLiteral(resourceName: "photoDefImage")
}
