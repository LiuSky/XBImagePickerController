//
//  TimeInterval+.swift
//  XBImagePickerController
//
//  Created by xiaobin liu on 2019/1/31.
//  Copyright © 2019 Sky. All rights reserved.
//

import Foundation


// MARK: - 扩展TimeInterval
public extension TimeInterval {
    
    /// 时间秒字符串
    var timeSecString: String {
        
        if Int(self.rounded()) > 3600 {
            
            let hour: Int = Int(self.rounded()) / 3600
            let seconds: Int = Int(self.rounded()) % 3600 / 60
            let minutes: Int = Int(self.rounded()) % 3600 % 60
            return String(format: "%02ld:%02ld:%02ld", hour, minutes, seconds)
            
        } else {
            
            let seconds: Int = Int(self.rounded()) % 60
            let minutes: Int = Int(self.rounded()) / 60
            return String(format: "%02ld:%02ld", minutes, seconds)
        }
    }
}
