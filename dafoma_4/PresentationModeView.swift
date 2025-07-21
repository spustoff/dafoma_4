//
//  PresentationModeView.swift
//  dafoma_4
//
//  VoltCase Presentation Mode - App Store compliant fullscreen viewer
//

import SwiftUI

struct PresentationModeView: View {
    let cards: [ReferenceCardData]
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if cards.isEmpty {
                emptyStateView
            } else {
                cardPresentationView
                
                if showControls {
                    controlsOverlay
                }
            }
        }
        .onAppear {
            hideControlsAfterDelay()
        }
        .onTapGesture {
            toggleControls()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        previousCard()
                    } else if value.translation.width < -100 {
                        nextCard()
                    }
                }
        )
    }
    
    // MARK: - Empty State
    var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "star")
                .font(.system(size: 64))
                .foregroundColor(.yellow)
            
            Text("NO FAVORITES")
                .font(.system(size: 24, weight: .black, design: .monospaced))
                .foregroundColor(.white)
            
            Text("Add cards to favorites to use presentation mode")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            VoltButton(title: "CLOSE", style: .primary) {
                dismiss()
            }
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Card Presentation
    var cardPresentationView: some View {
        let currentCard = cards[currentIndex]
        
        return VStack(spacing: 32) {
            // Category Badge
            HStack {
                if let category = CardCategory.allCases.first(where: { $0.rawValue == currentCard.category }) {
                    HStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .font(.system(size: 16))
                        
                        Text(category.rawValue.uppercased())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.voltPrimary)
                    )
                }
                
                Spacer()
            }
            
            // Title
            Text(currentCard.title)
                .font(.system(size: 32, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            // Content
            ScrollView {
                Text(currentCard.content)
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
            }
            .frame(maxHeight: 400)
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 60)
    }
    
    // MARK: - Controls Overlay
    var controlsOverlay: some View {
        VStack {
            // Top Controls
            HStack {
                VoltButton(title: "CLOSE", style: .secondary) {
                    dismiss()
                }
                
                Spacer()
                
                Text("\(currentIndex + 1) / \(cards.count)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.voltPrimary)
                
                Spacer()
                
                VoltButton(title: "HIDE", style: .primary) {
                    hideControls()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Bottom Navigation
            HStack(spacing: 40) {
                Button(action: previousCard) {
                    VStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(currentIndex > 0 ? .voltBlue : .gray)
                        
                        Text("PREV")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(currentIndex > 0 ? .voltBlue : .gray)
                    }
                }
                .disabled(currentIndex == 0)
                
                Spacer()
                
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<min(cards.count, 5), id: \.self) { index in
                        let displayIndex = getDisplayIndex(for: index)
                        Circle()
                            .fill(displayIndex == currentIndex ? Color.voltYellow : Color.gray)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Spacer()
                
                Button(action: nextCard) {
                    VStack(spacing: 8) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(currentIndex < cards.count - 1 ? .voltBlue : .gray)
                        
                        Text("NEXT")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(currentIndex < cards.count - 1 ? .voltBlue : .gray)
                    }
                }
                .disabled(currentIndex == cards.count - 1)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Helper Functions
    private func nextCard() {
        if currentIndex < cards.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
            hideControlsAfterDelay()
        }
    }
    
    private func previousCard() {
        if currentIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex -= 1
            }
            hideControlsAfterDelay()
        }
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        
        if showControls {
            hideControlsAfterDelay()
        }
    }
    
    private func hideControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls = false
        }
    }
    
    private func hideControlsAfterDelay() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            hideControls()
        }
    }
    
    private func getDisplayIndex(for index: Int) -> Int {
        // For pagination display when more than 5 cards
        if cards.count <= 5 {
            return index
        }
        
        let halfRange = 2
        let start = max(0, min(currentIndex - halfRange, cards.count - 5))
        return start + index
    }
}

struct PresentationModeView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationModeView(cards: SampleData.sampleCards.filter { $0.isFavorite })
    }
} 
