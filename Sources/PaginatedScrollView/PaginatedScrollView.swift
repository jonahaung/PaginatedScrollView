//
//  ScrollViewOffset.swift
//  MyBike
//
//  Created by Aung Ko Min on 23/12/21.
//

import SwiftUI

public struct PaginatedScrollView<Content: View>: View {
    
    @Environment(\.reload) public var reloadAction: ReloadAction?
    private var canRefresh: Bool { reloadAction != nil }
    @Environment(\.loadMore) public var loadMoreAction: LoadMoreAction?
    private var canLoadMore: Bool { loadMoreAction != nil }
    
    @StateObject private var manager = PaginatedScrollViewManager(settings: .defaultSettings)
    
    private let content: () -> Content
    public init(settings: PaginatedScrollViewSettings = .defaultSettings, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
    
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack {
                    if canRefresh {
                        if manager.isLoading {
                            ProgressView()
                        } else {
                            ProgressView("", value: manager.isLoading ? 100 : manager.reloader.progressValue, total: 100.00)
                                .labelsHidden()
                        }
                    }
                    
                    content()
                    
                    if canLoadMore && manager.moreLoader.canLoadMore {
                        ProgressView()
                    }
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .frame(width: geometry.size.width)
                .background(Color(uiColor: .groupTableViewBackground).frame(height: 99999999))
                .anchorPreference(key: PaginatedScrollViewKey.PreKey.self, value: .bounds) {
                    guard (canRefresh || canLoadMore && manager.canreturn) && !manager.isLoading else { return nil }
                    let frame = geometry[$0]
                    let top = frame.minY
                    let bottom = frame.maxY - geometry.size.height
                    return PaginatedScrollViewKey.PreData(top: top, bottom: bottom)
                }
            }
            .onPreferenceChange(PaginatedScrollViewKey.PreKey.self) { data in
                guard let data = data, !manager.isLoading else { return }
                if data.position == .top {
                    refresh(data: data)
                } else {
                    loadMore(data: data)
                }
            }
        }
    }
    
    
    private func refresh(data: PaginatedScrollViewKey.PreData) {
        guard data.isAtTop else { return }
        guard let action = reloadAction, manager.reloader.canRefresh(for: data.top) else { return }
        Task {
            manager.isLoading = true
            await action()
            manager.reloader.reset()
            manager.moreLoader.canLoadMore = true
            withAnimation {
                manager.isLoading = false
            }
        }
    }
    
    private func loadMore(data: PaginatedScrollViewKey.PreData) {
        guard data.isAtBottom else { return }
        guard manager.moreLoader.canLoadMore, let action = loadMoreAction else { return }
        Task {
            manager.isLoading = true
            await action($manager.moreLoader.canLoadMore)
            manager.isLoading = false
        }
    }
}
