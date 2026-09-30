import Foundation
import PDFKit

struct PDFPageText {
    let pageNumber: Int   // 1-based
    let text: String
}

enum PDFExtractionError: LocalizedError {
    case cannotOpen
    case noReadableText

    var errorDescription: String? {
        switch self {
        case .cannotOpen:
            return "The selected file could not be opened as a PDF."
        case .noReadableText:
            return "No readable text was found. This may be a scanned/image-only PDF (OCR is not supported in this version)."
        }
    }
}

enum PDFTextExtractor {
    /// Reads text from every page of the PDF using PDFKit. Runs fully offline.
    static func extract(from url: URL) throws -> [PDFPageText] {
        guard let document = PDFDocument(url: url) else {
            throw PDFExtractionError.cannotOpen
        }

        var pages: [PDFPageText] = []
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index),
                  let raw = page.string else { continue }
            let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                pages.append(PDFPageText(pageNumber: index + 1, text: text))
            }
        }

        if pages.isEmpty { throw PDFExtractionError.noReadableText }
        return pages
    }
}
