//
//  File.swift
//  
//
//  Created by Aung Ko Min on 17/1/22.
//

import UIKit

public struct PaginatedScrollViewSettings {
    
    public let moreLoaderTreshold: CGFloat
    public let reloaderTreshold: CGFloat
    public let atTopPercent: CGFloat
    public let atBottomPercent: CGFloat
    public let preferenceChangeTimeInterval: Int64
    
    public static let defaultSettings = PaginatedScrollViewSettings(moreLoaderTreshold: 50, reloaderTreshold: 140, atTopPercent: 1.0, atBottomPercent: 0.01, preferenceChangeTimeInterval: 30)
}
