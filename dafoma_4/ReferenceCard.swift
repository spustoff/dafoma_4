//
//  ReferenceCard.swift
//  dafoma_4
//
//  VoltCase Reference Card Models - App Store compliant data structures
//

import Foundation

// MARK: - Reference Card Data Struct
struct ReferenceCardData: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var category: String
    var isFavorite: Bool
    let createdAt = Date()
    var updatedAt = Date()
    var tags: String?
    
    init(title: String, content: String, category: String, isFavorite: Bool = false, tags: String? = nil) {
        self.title = title
        self.content = content
        self.category = category
        self.isFavorite = isFavorite
        self.tags = tags
        self.updatedAt = Date()
    }
    
    mutating func toggleFavorite() {
        isFavorite.toggle()
        updatedAt = Date()
    }
    
    mutating func updateContent(title: String, content: String, category: String, tags: String?) {
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.updatedAt = Date()
    }
}

// MARK: - Card Category Enum
enum CardCategory: String, CaseIterable, Codable {
    case errorCodes = "Error Codes"
    case setupInstructions = "Setup Instructions"
    case commandLine = "Command Line"
    case buildFlags = "Build Flags"
    case namingRules = "Naming Rules"
    case apiHeaders = "API Headers"
    case configurations = "Configurations"
    case troubleshooting = "Troubleshooting"
    case documentation = "Documentation"
    case quickReference = "Quick Reference"
    
    var icon: String {
        switch self {
        case .errorCodes: return "exclamationmark.triangle"
        case .setupInstructions: return "gear"
        case .commandLine: return "terminal"
        case .buildFlags: return "flag"
        case .namingRules: return "textformat"
        case .apiHeaders: return "network"
        case .configurations: return "slider.horizontal.3"
        case .troubleshooting: return "wrench"
        case .documentation: return "doc.text"
        case .quickReference: return "bolt"
        }
    }
    
    var color: String {
        switch self {
        case .errorCodes: return "#ff2c1f"
        case .setupInstructions: return "#1e90ff"
        case .commandLine: return "#ffc700"
        case .buildFlags: return "#ff2c1f"
        case .namingRules: return "#1e90ff"
        case .apiHeaders: return "#ffc700"
        case .configurations: return "#ff2c1f"
        case .troubleshooting: return "#1e90ff"
        case .documentation: return "#ffc700"
        case .quickReference: return "#ff2c1f"
        }
    }
}

// MARK: - Sample Data for Demo and Testing
struct SampleData {
    static let sampleCards: [ReferenceCardData] = [
        ReferenceCardData(
            title: "iOS Build Flags",
            content: "-DDEBUG=1\n-DLOG_LEVEL=2\n-fmodules\n-fcxx-modules\n\nUse for debugging iOS builds in Xcode",
            category: CardCategory.buildFlags.rawValue,
            isFavorite: true,
            tags: "ios,xcode,debug,build"
        ),
        ReferenceCardData(
            title: "Git Reset Commands",
            content: "git reset --soft HEAD~1  # Keep changes staged\ngit reset --mixed HEAD~1  # Unstage changes\ngit reset --hard HEAD~1   # Discard changes",
            category: CardCategory.commandLine.rawValue,
            isFavorite: false,
            tags: "git,version-control,reset"
        ),
        ReferenceCardData(
            title: "HTTP Status Codes",
            content: "200 OK - Success\n201 Created - Resource created\n400 Bad Request - Invalid request\n401 Unauthorized - Auth required\n404 Not Found - Resource missing\n500 Internal Server Error - Server error",
            category: CardCategory.errorCodes.rawValue,
            isFavorite: true,
            tags: "http,api,status,web"
        ),
        ReferenceCardData(
            title: "API Authentication Headers",
            content: "Authorization: Bearer <token>\nContent-Type: application/json\nX-API-Key: <key>\nAccept: application/json\nUser-Agent: VoltCase/1.0",
            category: CardCategory.apiHeaders.rawValue,
            isFavorite: false,
            tags: "api,auth,headers,http"
        ),
        ReferenceCardData(
            title: "Docker Commands",
            content: "docker build -t image:tag .\ndocker run -p 8080:80 image:tag\ndocker ps               # List containers\ndocker stop container_id\ndocker logs container_id",
            category: CardCategory.commandLine.rawValue,
            isFavorite: true,
            tags: "docker,containers,deployment"
        ),
        ReferenceCardData(
            title: "SwiftUI Debugging",
            content: "print(\"Debug: \\(value)\")\nlldb: po viewModel.state\nXcode: View Hierarchy Debugger\nPrint view body: print(Mirror(reflecting: self).children)",
            category: CardCategory.troubleshooting.rawValue,
            isFavorite: false,
            tags: "swiftui,debug,xcode,ios"
        ),
        ReferenceCardData(
            title: "JSON API Response Format",
            content: "{\n  \"data\": { ... },\n  \"status\": \"success\",\n  \"message\": \"Operation completed\",\n  \"timestamp\": \"2025-01-20T10:30:00Z\"\n}",
            category: CardCategory.documentation.rawValue,
            isFavorite: true,
            tags: "json,api,format,documentation"
        ),
        ReferenceCardData(
            title: "Naming Conventions",
            content: "Variables: camelCase\nConstants: UPPER_SNAKE_CASE\nClasses: PascalCase\nFiles: kebab-case.swift\nAPIs: snake_case endpoints",
            category: CardCategory.namingRules.rawValue,
            isFavorite: false,
            tags: "naming,conventions,coding,standards"
        )
    ]
}

 