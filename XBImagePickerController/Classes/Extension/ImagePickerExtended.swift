//
//  ImagePickerExtended.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/5/21.
//  Copyright © 2019 Sky. All rights reserved.
//

import Foundation


/// ImagePickerExtended 扩展
public struct ImagePickerExtension<ExtendedType> {
    /// 存储任何扩展类型的类型或元类型
    let type: ExtendedType
    init(_ type: ExtendedType) {
        self.type = type
    }
}


/// ImagePickerExtended协议
public protocol ImagePickerExtended {
    associatedtype ExtendedType
    
    static var xb: ImagePickerExtension<ExtendedType>.Type { get set }
    var xb: ImagePickerExtension<ExtendedType> { get set }
}

public extension ImagePickerExtended {
    static var xb: ImagePickerExtension<Self>.Type {
        get { return ImagePickerExtension<Self>.self }
        set { }
    }
    
    var xb: ImagePickerExtension<Self> {
        get { return ImagePickerExtension(self) }
        set { }
    }
}
