//
//  StorageManager.swift
//  dafoma_4
//
//  VoltCase Local Storage Manager - App Store compliant offline storage
//

import Foundation

// MARK: - Storage Manager
class StorageManager: ObservableObject {
    @Published var cards: [ReferenceCardData] = []
    
    private let cardsKey = "voltcase_reference_cards"
    private let documentsURL: URL
    
    init() {
        // Get documents directory for file storage
        documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadCards()
    }
    
    // MARK: - Card Management
    func addCard(_ card: ReferenceCardData) {
        cards.append(card)
        saveCards()
    }
    
    func updateCard(_ card: ReferenceCardData) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
            saveCards()
        }
    }
    
    func deleteCard(_ card: ReferenceCardData) {
        cards.removeAll { $0.id == card.id }
        saveCards()
    }
    
    func toggleFavorite(for card: ReferenceCardData) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].toggleFavorite()
            saveCards()
        }
    }
    
    // MARK: - Filtering and Searching
    func cardsByCategory(_ category: String) -> [ReferenceCardData] {
        return cards.filter { $0.category == category }
    }
    
    func favoriteCards() -> [ReferenceCardData] {
        return cards.filter { $0.isFavorite }
    }
    
    func searchCards(query: String) -> [ReferenceCardData] {
        if query.isEmpty {
            return cards
        }
        
        return cards.filter { card in
            card.title.localizedCaseInsensitiveContains(query) ||
            card.content.localizedCaseInsensitiveContains(query) ||
            card.tags?.localizedCaseInsensitiveContains(query) == true
        }
    }
    
    // MARK: - Data Persistence
    private func saveCards() {
        do {
            let data = try JSONEncoder().encode(cards)
            let url = documentsURL.appendingPathComponent("\(cardsKey).json")
            try data.write(to: url)
        } catch {
            print("Failed to save cards: \(error)")
        }
    }
    
    private func loadCards() {
        do {
            let url = documentsURL.appendingPathComponent("\(cardsKey).json")
            let data = try Data(contentsOf: url)
            cards = try JSONDecoder().decode([ReferenceCardData].self, from: data)
        } catch {
            // If loading fails, load sample data for first launch
            cards = SampleData.sampleCards
            saveCards() // Save sample data for persistence
        }
    }
    
    // MARK: - Backup and Export
    func exportToJSON() -> URL? {
        do {
            let data = try JSONEncoder().encode(cards)
            let fileName = "voltcase_backup_\(dateFormatter.string(from: Date())).json"
            let url = documentsURL.appendingPathComponent(fileName)
            try data.write(to: url)
            return url
        } catch {
            print("Failed to export JSON: \(error)")
            return nil
        }
    }
    
    func exportToText() -> URL? {
        var textContent = "VoltCase Reference Cards Export\n"
        textContent += "Generated: \(dateFormatter.string(from: Date()))\n\n"
        
        for card in cards {
            textContent += "═══════════════════════════════════════\n"
            textContent += "TITLE: \(card.title)\n"
            textContent += "CATEGORY: \(card.category)\n"
            textContent += "FAVORITE: \(card.isFavorite ? "★" : "☆")\n"
            if let tags = card.tags {
                textContent += "TAGS: \(tags)\n"
            }
            textContent += "CREATED: \(dateFormatter.string(from: card.createdAt))\n"
            textContent += "UPDATED: \(dateFormatter.string(from: card.updatedAt))\n"
            textContent += "───────────────────────────────────────\n"
            textContent += "\(card.content)\n\n"
        }
        
        do {
            let fileName = "voltcase_backup_\(dateFormatter.string(from: Date())).txt"
            let url = documentsURL.appendingPathComponent(fileName)
            try textContent.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("Failed to export text: \(error)")
            return nil
        }
    }
    
    func importFromJSON(url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let importedCards = try JSONDecoder().decode([ReferenceCardData].self, from: data)
            
            // Add imported cards that don't already exist
            for importedCard in importedCards {
                if !cards.contains(where: { $0.id == importedCard.id }) {
                    cards.append(importedCard)
                }
            }
            
            saveCards()
            return true
        } catch {
            print("Failed to import JSON: \(error)")
            return false
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }
    
    // MARK: - Statistics
    var totalCards: Int {
        cards.count
    }
    
    var favoriteCount: Int {
        cards.filter { $0.isFavorite }.count
    }
    
    var categoryCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for card in cards {
            counts[card.category, default: 0] += 1
        }
        return counts
    }
} 