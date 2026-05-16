//
//  TopAnchorView.swift
//  TabNavigation
//
//  Created by Ashish Mankar on 16/05/26.
//

import SwiftUI

struct TopAnchorView: View {
    
    @State private var topmostIndex: Int = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(0..<1000) { index in
                        Text("Number: \(index)")
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: TopItemPreferenceKey.self,
                                            value: [TopItemData(index: index, minY: geo.frame(in: .named("SCROLL")).minY)]
                                        )
                                }
                            )
                    }
                }
            }
            .coordinateSpace(name: "SCROLL")
            .onPreferenceChange(TopItemPreferenceKey.self) { items in
                let topmost = items
                    .filter { $0.minY >= 0 }       // visible or below top edge
                    .min(by: { $0.minY < $1.minY }) // closest to top
                if let topmost {
                    topmostIndex = topmost.index
                }
            }
            .overlay {
                ZStack {
                    GeometryReader { geo in
                        (topmostIndex <= 5 ? Color.clear : Color.yellow)
                            .frame(height: geo.safeAreaInsets.top)
                            .edgesIgnoringSafeArea(.top)
                            .frame(maxHeight: .infinity, alignment: .top)
                        (topmostIndex <= 5 ? Color.clear : Color.yellow)
                            .frame(height: 100)
                            .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .animation(.easeInOut(duration: 0.2),
                               value: topmostIndex)
                }
            }
        }
    }
}

// MARK: - Preference Key

struct TopItemData: Equatable {
    let index: Int
    let minY: CGFloat
}

struct TopItemPreferenceKey: PreferenceKey {
    static var defaultValue: [TopItemData] = []
    
    static func reduce(value: inout [TopItemData], nextValue: () -> [TopItemData]) {
        value.append(contentsOf: nextValue())
    }
}

#Preview {
    TopAnchorView()
}
