//
//  VoltCaseDesign.swift
//  dafoma_4
//
//  VoltCase Design System - Apple HIG compliant design
//  Native iOS design patterns and components
//

import SwiftUI

// MARK: - Apple Design System Colors
extension Color {
    // Primary colors using system palette
    static let voltPrimary = Color.accentColor
    static let voltSecondary = Color.blue
    static let voltBlue = Color.blue
    static let voltYellow = Color.yellow
    static let voltSuccess = Color.green
    static let voltWarning = Color.orange
    static let voltDanger = Color.red
    
    // Background colors
    static let voltBackground = Color(UIColor.systemBackground)
    static let voltSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let voltTertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // Label colors
    static let voltPrimaryLabel = Color(UIColor.label)
    static let voltSecondaryLabel = Color(UIColor.secondaryLabel)
    static let voltTertiaryLabel = Color(UIColor.tertiaryLabel)
    
    // Grouped background colors
    static let voltGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let voltSecondaryGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let voltTertiaryGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)
}

// MARK: - ShapeStyle Extensions
extension ShapeStyle where Self == Color {
    static var voltPrimary: Color { Color.voltPrimary }
    static var voltSecondary: Color { Color.voltSecondary }
    static var voltBlue: Color { Color.voltBlue }
    static var voltYellow: Color { Color.voltYellow }
    static var voltSuccess: Color { Color.voltSuccess }
    static var voltWarning: Color { Color.voltWarning }
    static var voltDanger: Color { Color.voltDanger }
    
    // Background colors
    static var voltBackground: Color { Color.voltBackground }
    static var voltSecondaryBackground: Color { Color.voltSecondaryBackground }
    static var voltTertiaryBackground: Color { Color.voltTertiaryBackground }
    
    // Label colors
    static var voltPrimaryLabel: Color { Color.voltPrimaryLabel }
    static var voltSecondaryLabel: Color { Color.voltSecondaryLabel }
    static var voltTertiaryLabel: Color { Color.voltTertiaryLabel }
}

// MARK: - Typography System
extension Font {
    // Apple's type hierarchy
    static let voltLargeTitle = Font.largeTitle.weight(.bold)
    static let voltTitle = Font.title.weight(.semibold)
    static let voltTitle2 = Font.title2.weight(.medium)
    static let voltTitle3 = Font.title3.weight(.medium)
    static let voltHeadline = Font.headline
    static let voltSubheadline = Font.subheadline
    static let voltBody = Font.body
    static let voltCallout = Font.callout
    static let voltFootnote = Font.footnote
    static let voltCaption = Font.caption
    static let voltCaption2 = Font.caption2
}

// MARK: - Spacing System (8pt grid)
struct VoltSpacing {
    static let xxxs: CGFloat = 2    // 2pt
    static let xxs: CGFloat = 4     // 4pt
    static let xs: CGFloat = 8      // 8pt
    static let sm: CGFloat = 12     // 12pt
    static let md: CGFloat = 16     // 16pt
    static let lg: CGFloat = 20     // 20pt
    static let xl: CGFloat = 24     // 24pt
    static let xxl: CGFloat = 32    // 32pt
    static let xxxl: CGFloat = 40   // 40pt
}

// MARK: - Corner Radius System
struct VoltRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let round: CGFloat = 50
}

// MARK: - Native iOS Components
struct VoltButton: View {
    let title: String
    let style: VoltButtonStyle
    let action: () -> Void
    let isDestructive: Bool
    
    init(title: String, style: VoltButtonStyle = .primary, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isDestructive = isDestructive
        self.action = action
    }
    
    enum VoltButtonStyle {
        case primary, secondary, tertiary, plain
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.voltHeadline)
                    .fontWeight(.medium)
                Spacer()
            }
        }
        .buttonStyle(VoltButtonStyleImpl(style: style, isDestructive: isDestructive))
    }
}

struct VoltButtonStyleImpl: ButtonStyle {
    let style: VoltButton.VoltButtonStyle
    let isDestructive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, VoltSpacing.md)
            .padding(.vertical, VoltSpacing.sm)
            .background(backgroundColor(for: style, pressed: configuration.isPressed))
            .foregroundColor(foregroundColor(for: style))
            .cornerRadius(VoltRadius.sm)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func backgroundColor(for style: VoltButton.VoltButtonStyle, pressed: Bool) -> Color {
        switch style {
        case .primary:
            return isDestructive ? .voltDanger : .voltPrimary
        case .secondary:
            return .voltSecondaryBackground
        case .tertiary:
            return .voltTertiaryBackground
        case .plain:
            return .clear
        }
    }
    
    private func foregroundColor(for style: VoltButton.VoltButtonStyle) -> Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .tertiary:
            return isDestructive ? .voltDanger : .voltPrimary
        case .plain:
            return isDestructive ? .voltDanger : .voltPrimary
        }
    }
}

struct VoltCard: View {
    let title: String
    let content: String
    let category: String
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavorite: () -> Void
    
    var categoryInfo: CardCategory? {
        CardCategory.allCases.first { $0.rawValue == category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: VoltSpacing.sm) {
            // Header with title and favorite button
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: VoltSpacing.xxs) {
                    Text(title)
                        .font(.voltHeadline)
                        .foregroundColor(.voltPrimaryLabel)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let categoryInfo = categoryInfo {
                        HStack(spacing: VoltSpacing.xxs) {
                            Image(systemName: categoryInfo.icon)
                                .font(.voltCaption)
                                .foregroundColor(.voltSecondary)
                            
                            Text(category)
                                .font(.voltCaption)
                                .foregroundColor(.voltSecondaryLabel)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.voltBody)
                        .foregroundColor(isFavorite ? .yellow : .voltTertiaryLabel)
                        .scaleEffect(isFavorite ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
                }
                .buttonStyle(.plain)
            }
            
            // Content preview
            Text(content)
                .font(.voltCallout)
                .foregroundColor(.voltSecondaryLabel)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(VoltSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: VoltRadius.md)
                .fill(.voltSecondaryBackground)
                .shadow(
                    color: .black.opacity(0.05),
                    radius: isFavorite ? 4 : 2,
                    x: 0,
                    y: isFavorite ? 2 : 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: VoltRadius.md)
                .stroke(isFavorite ? .yellow.opacity(0.3) : .clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(category). \(isFavorite ? "Favorited" : "Not favorited")")
        .accessibilityHint("Double tap to view details")
        .accessibilityAction(named: isFavorite ? "Remove from favorites" : "Add to favorites") {
            onFavorite()
        }
    }
}

struct VoltCategoryChip: View {
    let category: CardCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: VoltSpacing.xxs) {
                Image(systemName: category.icon)
                    .font(.voltCaption)
                
                Text(category.rawValue)
                    .font(.voltCaption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .voltSecondaryLabel)
            .padding(.horizontal, VoltSpacing.sm)
            .padding(.vertical, VoltSpacing.xs)
            .background(
                Capsule()
                    .fill(isSelected ? .voltPrimary : .voltTertiaryBackground)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category.rawValue)
        .accessibilityHint(isSelected ? "Selected category" : "Tap to filter by this category")
    }
}

struct VoltSectionHeader: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: VoltSpacing.xxs) {
            Text(title)
                .font(.voltTitle2)
                .fontWeight(.bold)
                .foregroundColor(.voltPrimaryLabel)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.voltSubheadline)
                    .foregroundColor(.voltSecondaryLabel)
            }
        }
    }
}

// MARK: - ViewModifiers
struct VoltCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.voltSecondaryBackground)
            .cornerRadius(VoltRadius.md)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

extension View {
    func voltCard() -> some View {
        modifier(VoltCardStyle())
    }
    
    func voltSection() -> some View {
        self
            .listRowBackground(Color.voltGroupedBackground)
            .listRowSeparator(.hidden)
    }
} 