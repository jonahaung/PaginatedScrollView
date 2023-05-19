import SwiftUI

@available(iOS 16.0, *)
public typealias _AsyncAction = (@Sendable () async -> Void)
@available(iOS 16.0, *)
struct LoadMoreKey: EnvironmentKey {
    static let defaultValue: _AsyncAction? = nil
}
@available(iOS 16.0, *)
extension EnvironmentValues {
    var loadMore: _AsyncAction? {
        get { self[LoadMoreKey.self] }
        set { self[LoadMoreKey.self] = newValue }
    }
}
@available(iOS 16.0, *)
extension PaginatedScrollView {
    public func moreLoadable(action: @escaping _AsyncAction) -> some View {
        environment(\.loadMore, action)
    }
}

@available(iOS 16.0, *)
public struct PaginatedScrollView<Content: View>: View {
    enum LoadingState: Hashable {
        case ready, starting, ended
    }
    @ViewBuilder private let content: () -> Content
    private var canLoadMore: Binding<Bool>
    @Environment(\.loadMore) public var loadMoreAction: _AsyncAction?
    @State private var state = LoadingState.ended
    @Namespace private var scrollAreaID

    public init(canLoadMore: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.canLoadMore = canLoadMore
    }

    public var body: some View {
        ScrollView {
            content()
                .saveBounds(viewId: scrollAreaID)

            if canLoadMore.wrappedValue {
                ProgressView()
                    .padding()
            }
        }
        .retrieveBounds(viewId: scrollAreaID) { rect in
            didUpdateVisibleRect(rect)
        }
        .coordinateSpace(name: scrollAreaID)
        .scrollContentBackground(.visible)
    }

    private func didUpdateVisibleRect(_ value: CGRect?) {
        guard let value, state == .ready else {
            if state == .ended {
                updateState(.ready)
            }
            return
        }
        let screenHeight = UIScreen.main.bounds.height
        let nearBottom = value.maxY - screenHeight < 0
        guard nearBottom else { return }
        Task {
            updateState(.starting)
            await loadMoreAction?()
            updateState(.ended)
        }
    }

    func updateState(_ newValue: LoadingState) {
        state = newValue
    }
}

@available(iOS 16.0, *)
struct SaveBoundsPrefData: Equatable {
    let viewId: AnyHashable
    let bounds: CGRect
}
@available(iOS 16.0, *)
struct SaveSizePrefData: Equatable {
    let viewId: String
    let size: CGSize
}
@available(iOS 16.0, *)
struct SaveBoundsPrefKey: PreferenceKey {
    static var defaultValue: [SaveBoundsPrefData] = []
    static func reduce(value: inout [SaveBoundsPrefData], nextValue: () -> [SaveBoundsPrefData]) {
        value.append(contentsOf: nextValue())
    }
}
@available(iOS 16.0, *)
struct SaveSizePrefKey: PreferenceKey {
    static var defaultValue: [SaveSizePrefData]? = nil
    static func reduce(value: inout [SaveSizePrefData]?, nextValue: () -> [SaveSizePrefData]?) {
        guard let next = nextValue() else { return }
        value?.append(contentsOf: next)
    }
}


@available(iOS 16.0, *)
extension View {
    public func saveBounds(viewId: AnyHashable, coordinateSpace: CoordinateSpace = .global) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(key: SaveBoundsPrefKey.self, value: [SaveBoundsPrefData(viewId: viewId, bounds: proxy.frame(in: coordinateSpace))])
        })
    }

    public func retrieveBounds(viewId: AnyHashable, _ rect: Binding<CGRect>) -> some View {
        onPreferenceChange(SaveBoundsPrefKey.self) { preferences in
            let preference = preferences.first(where: { $0.viewId == viewId })
            if let preference {
                rect.wrappedValue = preference.bounds
            }
        }
    }
    public func retrieveBounds(viewId: AnyHashable, _ completion: @escaping (CGRect) -> Void) -> some View {
        onPreferenceChange(SaveBoundsPrefKey.self) { preferences in
            let preference = preferences.first(where: { $0.viewId == viewId })
            if let preference {
                completion(preference.bounds)
            }
        }
    }

    public func saveSize(viewId: String?, coordinateSpace: CoordinateSpace = .local) -> some View {
        Group {
            if let viewId = viewId {
                self.background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: SaveSizePrefKey.self, value: [SaveSizePrefData(viewId: viewId, size: proxy.size)])
                    }
                )
            } else {
                self
            }
        }
    }

    public func retrieveSize(viewId: String?, _ rect: Binding<CGSize?>) -> some View {
        Group {
            if let viewId = viewId {
                onPreferenceChange(SaveSizePrefKey.self) { preferences in
                    DispatchQueue.main.async {
                        guard let preferences = preferences else {
                            return
                        }
                        let p = preferences.first(where: { $0.viewId == viewId })
                        rect.wrappedValue = p?.size
                    }
                }
            } else {
                self
            }
        }
    }
}
