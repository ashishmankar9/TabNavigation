//
//  ContentView.swift
//  TabNavigation
//
//  Created by Ashish Mankar on 15/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        StickyTabsScrollView()
    }
}

#Preview {
    ContentView()
}

struct SectionItem: Identifiable {
    let id: String
    let title: String
    let color: Color
}

struct StickyTabsScrollView: View {

    // MARK: - Data

    let sections: [SectionItem] = [
        .init(id: "overview", title: "Overview", color: .red),
        .init(id: "photos", title: "Photos", color: .blue),
        .init(id: "reviews", title: "Reviews", color: .green),
        .init(id: "pricing", title: "Pricing", color: .orange),
        .init(id: "faq", title: "FAQ", color: .purple),
        .init(id: "about", title: "About", color: .pink)
    ]

    // MARK: - State

    @State private var selectedTab: String = "overview"

    @Namespace private var animation
    
    @State private var isTabTapped = false

    var body: some View {

        ScrollViewReader { proxy in

            ScrollView {

                LazyVStack(
                    spacing: 0,
                    pinnedViews: [.sectionHeaders]
                ) {

                    Section {

                        ForEach(sections) { section in

                            ContentSection(section: section)
                                .id(section.id)

                                // Detect section position
                                .background(
                                    GeometryReader { geo in

                                        Color.clear
                                            .preference(
                                                key: SectionPreferenceKey.self,
                                                value: [
                                                    SectionPreferenceData(
                                                        id: section.id,
                                                        offset: geo.frame(in: .named("SCROLL")).minY
                                                    )
                                                ]
                                            )
                                    }
                                )
                        }

                    } header: {

                        StickyTabsView(
                            sections: sections,
                            selectedTab: $selectedTab,
                            animation: animation
                        ) { tappedSection in

                            isTabTapped = true

                                withAnimation(.easeInOut(duration: 0.35)) {

                                    selectedTab = tappedSection.id

                                    proxy.scrollTo(tappedSection.id, anchor: .top)

                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

                                    isTabTapped = false

                                }
                        }
                        .background(.white)
                    }
                }
            }
            .coordinateSpace(name: "SCROLL")

            // Update selected tab while scrolling
            .onPreferenceChange(SectionPreferenceKey.self) { preferences in
                guard !isTabTapped else { return }

                let visibleSection = preferences
                    .filter { $0.offset < 200 }
                    .sorted { abs($0.offset) < abs($1.offset) }
                    .first

                guard let visibleSection else { return }

                if selectedTab != visibleSection.id {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = visibleSection.id
                    }
                }
            }
        }
    }
}

// MARK: - Sticky Tabs

struct StickyTabsView: View {

    let sections: [SectionItem]

    @Binding var selectedTab: String

    var animation: Namespace.ID

    let onTap: (SectionItem) -> Void

    var body: some View {

        ScrollViewReader { tabProxy in

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 24) {

                    ForEach(sections) { section in

                        Button {

                            onTap(section)

                            withAnimation(.easeInOut(duration: 0.35)) {
                                tabProxy.scrollTo(section.id, anchor: .center)
                            }

                        } label: {

                            VStack(spacing: 8) {

                                Text(section.title)
                                    .fontWeight(
                                        selectedTab == section.id
                                        ? .semibold
                                        : .regular
                                    )
                                    .foregroundColor(
                                        selectedTab == section.id
                                        ? .black
                                        : .gray
                                    )

                                ZStack {

                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 3)

                                    if selectedTab == section.id {

                                        Rectangle()
                                            .fill(Color.black)
                                            .frame(height: 3)
                                            .matchedGeometryEffect(
                                                id: "underline",
                                                in: animation
                                            )
                                    }
                                }
                            }
                        }
                        .id(section.id)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 10)
            }
            .onChange(of: selectedTab) { _, newTab in
                withAnimation(.easeInOut(duration: 0.35)) {
                    tabProxy.scrollTo(newTab, anchor: .center)
                }
            }
        }
    }
}

// MARK: - Content Section

struct ContentSection: View {

    let section: SectionItem

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text(section.title)
                .font(.largeTitle.bold())

            ForEach(0..<10) { index in

                RoundedRectangle(cornerRadius: 16)
                    .fill(section.color.opacity(0.2))
                    .frame(height: 100)
                    .overlay(
                        Text("\\(section.title) Item \\(index + 1)")
                    )
            }
        }
        .padding()
    }
}

// MARK: - Preference Models

struct SectionPreferenceData: Equatable {

    let id: String
    let offset: CGFloat
}

struct SectionPreferenceKey: PreferenceKey {

    static var defaultValue: [SectionPreferenceData] = []

    static func reduce(
        value: inout [SectionPreferenceData],
        nextValue: () -> [SectionPreferenceData]
    ) {

        value.append(contentsOf: nextValue())
    }
}

// MARK: - Preview

#Preview {

    StickyTabsScrollView()
}
