//
//  XBSelectedAsset.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/28.
//  Copyright © 2019 Sky. All rights reserved.
//

import Photos
import Foundation

/// MARK - 选中资源实体
public struct XBSelectedAsset {
    
//    /// 选中Cell索引
//    let indexPath: IndexPath
    
    /// 资源
    let asset: PHAsset
    
    
    /// 初始化选中资源实体
    ///
    /// - Parameters:
    ///   - index: <#index description#>
    ///   - indexPath: <#indexPath description#>
    ///   - asset: <#asset description#>
    init(asset: PHAsset) {
//        self.indexPath = indexPath
        self.asset = asset
    }
}


// MARK: - Equatable
extension XBSelectedAsset: Equatable {
    
    public static func == (lhs: XBSelectedAsset, rhs: XBSelectedAsset) -> Bool {
        return lhs.asset == rhs.asset
    }
}
