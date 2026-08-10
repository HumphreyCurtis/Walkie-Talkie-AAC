//
//  SymbolLibraryView.swift
//  Walkie Talkie AAC
//
//  Browse, search, and favourite symbols from the curated Mulberry set.
//  Selecting a symbol shows it on the outward display immediately.
//

import SwiftUI

struct SymbolLibraryView: View {
    @StateObject private var favorites = SymbolFavoritesStore()
    @State private var searchText = ""
    @State private var selectedSection: String? = nil
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 12)
    ]

    private var categories: [SymbolCategory] {
        if searchText.isEmpty {
            return SymbolLibrary.categories
        }
        let results = SymbolLibrary.search(query: searchText)
        var grouped: [String: [CommunicationSymbol]] = [:]
        for symbol in results {
            grouped[symbol.category, default: []].append(symbol)
        }
        return grouped.keys.sorted().map { SymbolCategory(name: $0, symbols: grouped[$0] ?? []) }
    }

    private var filteredSymbols: [CommunicationSymbol] {
        SymbolLibrary.search(query: searchText)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    if !searchText.isEmpty {
                        Section {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(filteredSymbols) { symbol in
                                    symbolCard(symbol)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    } else {
                        ForEach(categories) { category in
                            Section {
                                Text(category.name)
                                    .font(.appHeadline)
                                    .foregroundStyle(SignagePalette.concrete.color)
                                    .textCase(nil)
                                    .padding(.vertical, 4)
                                    .signageHeaderRow()

                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(category.symbols) { symbol in
                                        symbolCard(symbol)
                                            .id(symbol.id)
                                    }
                                }
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .signageSurface(chevrons: false)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search symbols...")
                .navigationTitle("Symbol Library")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                            .font(.appHeadline)
                    }
                }
            }
        }
    }

    private func symbolCard(_ symbol: CommunicationSymbol) -> some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(symbol.assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(SignagePalette.block(.light))
                    )

                if favorites.isFavorite(symbol.id) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(SignagePalette.amber.color)
                        .offset(x: -2, y: 2)
                }
            }

            Text(symbol.displayLabel)
                .font(.system(size: 10, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(.secondary)

            Button {
                favorites.toggle(symbol.id)
            } label: {
                Image(systemName: favorites.isFavorite(symbol.id) ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundStyle(favorites.isFavorite(symbol.id) ? SignagePalette.amber.color : SignagePalette.concrete.color)
            }
            .buttonStyle(.plain)
            .frame(height: 18)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            selectSymbol(symbol)
        }
    }

    private func selectSymbol(_ symbol: CommunicationSymbol) {
        NotificationCenter.default.post(
            name: .init("SymbolSelected"),
            object: nil,
            userInfo: ["assetName": symbol.assetName, "word": symbol.displayLabel]
        )
        dismiss()
    }
}

#Preview {
    SymbolLibraryView()
}