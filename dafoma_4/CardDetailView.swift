//
//  CardDetailView.swift
//  dafoma_4
//
//  VoltCase Card Detail View - Apple HIG compliant card viewer
//

import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.dismiss) private var dismiss
    
    let card: ReferenceCardData
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var categoryInfo: CardCategory? {
        CardCategory.allCases.first { $0.rawValue == card.category }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VoltSpacing.lg) {
                // Header Section
                VStack(alignment: .leading, spacing: VoltSpacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: VoltSpacing.xxs) {
                            Text(card.title)
                                .font(.voltLargeTitle)
                                .foregroundColor(.voltPrimaryLabel)
                                .multilineTextAlignment(.leading)
                            
                            if let categoryInfo = categoryInfo {
                                HStack(spacing: VoltSpacing.xs) {
                                    Image(systemName: categoryInfo.icon)
                                        .font(.voltCallout)
                                        .foregroundColor(.voltSecondary)
                                    
                                    Text(card.category)
                                        .font(.voltCallout)
                                        .foregroundColor(.voltSecondaryLabel)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: toggleFavorite) {
                            Image(systemName: card.isFavorite ? "star.fill" : "star")
                                .font(.voltTitle2)
                                .foregroundColor(card.isFavorite ? .yellow : .voltTertiaryLabel)
                                .scaleEffect(card.isFavorite ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: card.isFavorite)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(card.isFavorite ? "Remove from favorites" : "Add to favorites")
                    }
                }
                .padding(.horizontal, VoltSpacing.md)
                
                Divider()
                    .padding(.horizontal, VoltSpacing.md)
                
                // Content Section
                VStack(alignment: .leading, spacing: VoltSpacing.md) {
                    Text("Content")
                        .font(.voltHeadline)
                        .foregroundColor(.voltPrimaryLabel)
                    
                    Text(card.content)
                        .font(.voltBody)
                        .foregroundColor(.voltPrimaryLabel)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, VoltSpacing.md)
                
                // Tags Section
                if let tags = card.tags, !tags.isEmpty {
                    VStack(alignment: .leading, spacing: VoltSpacing.sm) {
                        Text("Tags")
                            .font(.voltHeadline)
                            .foregroundColor(.voltPrimaryLabel)
                        
                        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 3), alignment: .leading, spacing: VoltSpacing.xs) {
                            ForEach(tagArray, id: \.self) { tag in
                                Text(tag)
                                    .font(.voltCaption)
                                    .foregroundColor(.voltSecondaryLabel)
                                    .padding(.horizontal, VoltSpacing.sm)
                                    .padding(.vertical, VoltSpacing.xxs)
                                    .background(
                                        Capsule()
                                            .fill(.voltTertiaryBackground)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, VoltSpacing.md)
                }
                
                Divider()
                    .padding(.horizontal, VoltSpacing.md)
                
                // Metadata Section
                VStack(alignment: .leading, spacing: VoltSpacing.sm) {
                    Text("Details")
                        .font(.voltHeadline)
                        .foregroundColor(.voltPrimaryLabel)
                    
                    VStack(spacing: VoltSpacing.sm) {
                        metadataRow(title: "Created", value: formatDate(card.createdAt))
                        metadataRow(title: "Updated", value: formatDate(card.updatedAt))
                        metadataRow(title: "Category", value: card.category)
                    }
                }
                .padding(.horizontal, VoltSpacing.md)
                
                // Action Buttons
                VStack(spacing: VoltSpacing.sm) {
                    VoltButton(title: "Edit Card", style: .secondary) {
                        showingEditSheet = true
                    }
                    
                    VoltButton(title: "Delete Card", style: .secondary, isDestructive: true) {
                        showingDeleteAlert = true
                    }
                }
                .padding(.horizontal, VoltSpacing.md)
                
                // Bottom spacing
                Spacer(minLength: VoltSpacing.xxl)
            }
        }
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditCardView(card: card)
                    .environmentObject(storageManager)
            }
        }
        .alert("Delete Card", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                storageManager.deleteCard(card)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(card.title)'? This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Views
    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.voltCallout)
                .foregroundColor(.voltSecondaryLabel)
            
            Spacer()
            
            Text(value)
                .font(.voltCallout)
                .foregroundColor(.voltPrimaryLabel)
        }
        .padding(.horizontal, VoltSpacing.sm)
        .padding(.vertical, VoltSpacing.xs)
        .background(.voltTertiaryBackground)
        .cornerRadius(VoltRadius.sm)
    }
    
    // MARK: - Actions
    private func toggleFavorite() {
        storageManager.toggleFavorite(for: card)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardDetailView(card: SampleData.sampleCards[0])
                .environmentObject(StorageManager())
        }
    }
} 