import Foundation
import SwiftUI

@MainActor
final class MediGuideViewModel: ObservableObject {
    @Published var documentName: String?
    @Published var pageCount: Int = 0
    @Published var symptoms: String = ""
    @Published var results: [MatchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var pages: [PDFPageText] = []

    var hasDocument: Bool { !pages.isEmpty }
    var canSearch: Bool {
        hasDocument && !MatchingEngine.keywords(from: symptoms).isEmpty
    }

    /// Loads and extracts a PDF picked with the document picker.
    func loadPDF(from url: URL) {
        isLoading = true
        errorMessage = nil
        let name = url.lastPathComponent

        Task {
            do {
                let extracted = try await Task.detached(priority: .userInitiated) { () -> [PDFPageText] in
                    let accessing = url.startAccessingSecurityScopedResource()
                    defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                    return try PDFTextExtractor.extract(from: url)
                }.value

                pages = extracted
                pageCount = extracted.count
                documentName = name
                results = []
            } catch {
                pages = []
                pageCount = 0
                documentName = nil
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func removeDocument() {
        pages = []
        pageCount = 0
        documentName = nil
        results = []
    }

    /// Runs the local keyword matching. Returns true when the results screen should open.
    func search() -> Bool {
        errorMessage = nil
        guard hasDocument else {
            errorMessage = "Please upload a medicine-information PDF first."
            return false
        }
        guard !MatchingEngine.keywords(from: symptoms).isEmpty else {
            errorMessage = "Please enter at least one symptom or keyword."
            return false
        }
        results = MatchingEngine.search(symptoms: symptoms, in: pages)
        return true
    }
}
