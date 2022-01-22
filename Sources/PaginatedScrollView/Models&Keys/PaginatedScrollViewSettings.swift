//
//  File.swift
//
//
//  Created by Aung Ko Min on 17/1/22.
//

import UIKit

public struct PaginatedScrollViewSettings {
    
    public var moreLoaderTreshold: CGFloat
    public var reloaderTreshold: CGFloat
    
    public static let defaultSettings = PaginatedScrollViewSettings(moreLoaderTreshold: 50, reloaderTreshold: 140)
}
