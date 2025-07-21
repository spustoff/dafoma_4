//
//  AddCardView.swift
//  dafoma_4
//
//  VoltCase Add Card View - Apple HIG compliant form for creating cards
//

import SwiftUI

struct AddCardView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedCategory = CardCategory.quickReference
    @State private var tags = ""
    @State private var isFavorite = false
    
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
        .navigationTitle("New Card")
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
        let newCard = ReferenceCardData(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory.rawValue,
            isFavorite: isFavorite,
            tags: tags.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tags.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        storageManager.addCard(newCard)
        dismiss()
    }
}

#Preview {
    AddCardView()
        .environmentObject(StorageManager())
} 
