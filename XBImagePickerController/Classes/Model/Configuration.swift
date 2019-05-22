//
//  Configuration.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/30.
//  Copyright © 2019 Sky. All rights reserved.
//

import UIKit
import Photos
import Foundation


/// MARK - 配置
public struct Configuration {

    public static var shared: Configuration = Configuration()
    
    /// 对照片排序，按修改时间升序，默认是false。如果设置为true,最新的照片会显示在最后面
    public var sort: Bool = false
    
    /// 允许选择资源类型(默认所有)
    public var libraryMediaType: LibraryMediaType = LibraryMediaType.all
    
    /// 相册分组配置
    public var groupConfig = GroupConfiguration()
    
    /// 相册集合列表控制器配置
    public var gridConfig = GridConfiguration()
    
    /// 引导说明(当访问照片库权限被拒绝的时候文案说明)
    public var guideTip: String = "请在iPhone的\"设置-隐私-照片\"选项中,\r允许xxxApp访问你的手机相册"
    
    public init() {}
}


/// 资源类型
///
/// - all: 所有
/// - image: 图片
/// - video: 视频
public enum LibraryMediaType: Int, CustomStringConvertible {
    
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


/// MARK - 相册分组控制器配置
public struct GroupConfiguration {
    
    /// 行高(默认70)
    public var rowHeight: CGFloat = 70
    
    /// 选中图标
    public var photoSelImage = #imageLiteral(resourceName: "photoSelImage")
}



/// MARK - 相册集合列表控制器 配置
public struct GridConfiguration {
    
    
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
