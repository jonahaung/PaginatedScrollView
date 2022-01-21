//
//  CustomScrollViewManager.swift
//  MyBike
//
//  Created by Aung Ko Min on 11/1/22.
//

import Foundation

@MainActor
public class PaginatedScrollViewManager: ObservableObject {
    
    @Published var reloader = Refresher()
    @Published var moreLoader = MoreLoader()
    @Published var isLoading = false

    // Timing
    private var lastTimestamp: Int64 = 0
    private var minInterval = Int64(60)
    
    var canreturn: Bool {
        let currentTimeStamp = Int64(Date().timeIntervalSince1970 * 1000)
        if lastTimestamp == 0 {
            lastTimestamp = currentTimeStamp
            return false
        }
        
        if currentTimeStamp - lastTimestamp >= minInterval {
            lastTimestamp = currentTimeStamp
            return true
        }
        return false
    }
    
    init(settings: PaginatedScrollViewSettings = .defaultSettings) {
        reloader.threshold = settings.reloaderTreshold
        moreLoader.threshold = settings.moreLoaderTreshold
    }
}
