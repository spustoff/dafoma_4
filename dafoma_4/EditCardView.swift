//
//  EditCardView.swift
//  dafoma_4
//
//  VoltCase Edit Card View - Apple HIG compliant form for editing cards
//

import SwiftUI

struct EditCardView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.dismiss) private var dismiss
    
    let card: ReferenceCardData
    
    @State private var title: String
    @State private var content: String
    @State private var selectedCategory: CardCategory
    @State private var tags: String
    @State private var isFavorite: Bool
    
    init(card: ReferenceCardData) {
        self.card = card
        self._title = State(initialValue: card.title)
        self._content = State(initialValue: card.content)
        self._selectedCategory = State(initialValue: CardCategory.allCases.first { $0.rawValue == card.category } ?? .quickReference)
        self._tags = State(initialValue: card.tags ?? "")
        self._isFavorite = State(initialValue: card.isFavorite)
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        Form {
            Section("Basic Information") {
                VStack(alignment: .leading, spacing: VoltSpacing.xs) {
                    Text("Title")
                        .font(.voltCallout)
                        .foregroundColor(.voltSecondaryLabel)
                    
                    TextField("Enter card title", text: $title)
                        .font(.voltBody)
                }
                .listRowSeparator(.hidden)
                
                VStack(alignment: .leading, spacing: VoltSpacing.xs) {
                    Text("Category")
                        .font(.voltCallout)
                        .foregroundColor(.voltSecondaryLabel)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(CardCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .listRowSeparator(.hidden)
                
                VStack(alignment: .leading, spacing: VoltSpacing.xs) {
                    Text("Tags")
                        .font(.voltCallout)
                        .foregroundColor(.voltSecondaryLabel)
                    
                    TextField("comma, separated, tags", text: $tags)
                        .font(.voltBody)
                }
                .listRowSeparator(.hidden)
            }
            
            Section("Content") {
                VStack(alignment: .leading, spacing: VoltSpacing.xs) {
                    Text("Content")
                        .font(.voltCallout)
                        .foregroundColor(.voltSecondaryLabel)
                    
                    TextEditor(text: $content)
                        .font(.voltBody)
                        .frame(minHeight: 120)
                }
                .listRowSeparator(.hidden)
            }
            
            Section("Options") {
                Toggle(isOn: $isFavorite) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Add to Favorites")
                            .font(.voltBody)
                    }
                }
                .toggleStyle(.switch)
            }
        }
        .navigationTitle("Edit Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveCard()
                }
                .disabled(!isFormValid)
            }
        }
    }
    
    // MARK: - Actions
    private func saveCard() {
        var updatedCard = card
        updatedCard.updateContent(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory.rawValue,
            tags: tags.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tags.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        if updatedCard.isFavorite != isFavorite {
            updatedCard.isFavorite = isFavorite
            updatedCard.updatedAt = Date()
        }
        
        storageManager.updateCard(updatedCard)
        dismiss()
    }
}

struct EditCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditCardView(card: SampleData.sampleCards[0])
                .environmentObject(StorageManager())
        }
    }
} 
