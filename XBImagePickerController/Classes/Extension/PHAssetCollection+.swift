//
//  PHAssetCollection+.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/28.
//  Copyright © 2019 Sky. All rights reserved.
//

import Photos
import Foundation


// MARK: - Extension PHAssetCollection
public extension PHAssetCollection {
    
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}
