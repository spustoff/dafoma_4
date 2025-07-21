//
//  ExportView.swift
//  dafoma_4
//
//  VoltCase Export View - App Store compliant backup and export
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject var storageManager: StorageManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    @State private var exportStatus = ""
    @State private var showingImportPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        statsSection
                        exportSection
                        importSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
            .background(Color.voltBackground)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VoltButton(title: "CLOSE", style: .secondary) {
                    dismiss()
                }
                
                Spacer()
                
                Text("EXPORT DATA")
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                    .foregroundColor(.voltYellow)
                
                Spacer()
                
                // Placeholder for symmetry
                Color.clear
                    .frame(width: 80, height: 40)
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Stats Section
    var statsSection: some View {
        VStack(spacing: 16) {
            Text("DATA OVERVIEW")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(.voltYellow)
            
            VStack(spacing: 12) {
                statRow(title: "Total Cards", value: "\(storageManager.totalCards)")
                statRow(title: "Favorites", value: "\(storageManager.favoriteCount)")
                statRow(title: "Categories Used", value: "\(storageManager.categoryCounts.count)")
                
                if !storageManager.cards.isEmpty {
                    let oldestCard = storageManager.cards.min(by: { $0.createdAt < $1.createdAt })
                    if let oldest = oldestCard {
                        statRow(title: "Oldest Card", value: formatDate(oldest.createdAt))
                    }
                    
                    let newestCard = storageManager.cards.max(by: { $0.createdAt < $1.createdAt })
                    if let newest = newestCard {
                        statRow(title: "Newest Card", value: formatDate(newest.createdAt))
                    }
                }
            }
        }
    }
    
    // MARK: - Export Section
    var exportSection: some View {
        VStack(spacing: 16) {
            Text("EXPORT OPTIONS")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(.voltYellow)
            
            VStack(spacing: 12) {
                exportOptionCard(
                    title: "JSON Format",
                    description: "Machine-readable format for importing back into VoltCase",
                    icon: "doc.badge.gearshape",
                    color: .voltBlue
                ) {
                    exportToJSON()
                }
                
                exportOptionCard(
                    title: "Text Format",
                    description: "Human-readable format for documentation or sharing",
                    icon: "doc.text",
                    color: .voltPrimary
                ) {
                    exportToText()
                }
            }
            
            if !exportStatus.isEmpty {
                Text(exportStatus)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.voltYellow)
                    .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Import Section
    var importSection: some View {
        VStack(spacing: 16) {
            Text("IMPORT OPTIONS")
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(.voltYellow)
            
            VStack(spacing: 12) {
                importOptionCard(
                    title: "Import JSON",
                    description: "Import cards from a VoltCase JSON backup file",
                    icon: "square.and.arrow.down",
                    color: .voltYellow
                ) {
                    showingImportPicker = true
                }
            }
            
            Text("⚠️ Import will add new cards without replacing existing ones")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Helper Views
    func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.voltYellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.voltSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    func exportOptionCard(title: String, description: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(description)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Spacer()
                
                VoltButton(title: "EXPORT", style: .primary, action: action)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.voltSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    func importOptionCard(title: String, description: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(description)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Spacer()
                
                VoltButton(title: "SELECT FILE", style: .primary, action: action)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.voltSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Export Functions
    private func exportToJSON() {
        exportStatus = "Exporting..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = storageManager.exportToJSON() {
                DispatchQueue.main.async {
                    self.shareURL = url
                    self.showingShareSheet = true
                    self.exportStatus = "JSON export ready!"
                }
            } else {
                DispatchQueue.main.async {
                    self.exportStatus = "Export failed. Please try again."
                }
            }
        }
        
        // Clear status after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            exportStatus = ""
        }
    }
    
    private func exportToText() {
        exportStatus = "Exporting..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = storageManager.exportToText() {
                DispatchQueue.main.async {
                    self.shareURL = url
                    self.showingShareSheet = true
                    self.exportStatus = "Text export ready!"
                }
            } else {
                DispatchQueue.main.async {
                    self.exportStatus = "Export failed. Please try again."
                }
            }
        }
        
        // Clear status after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            exportStatus = ""
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            let success = storageManager.importFromJSON(url: url)
            exportStatus = success ? "Import successful!" : "Import failed. Please check the file format."
            
            // Clear status after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                exportStatus = ""
            }
            
        case .failure:
            exportStatus = "Import failed. Please try again."
            
            // Clear status after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                exportStatus = ""
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportView()
        .environmentObject(StorageManager())
} 