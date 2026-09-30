import Foundation

struct MatchResult: Identifiable {
    let id = UUID()
    let pageNumber: Int
    let text: String
    let matchedTerms: [String]   // stems used for highlighting
    let score: Int
}

enum MatchingEngine {

    private static let stopWords: Set<String> = [
        "the", "and", "with", "have", "has", "had", "for", "from", "since", "very",
        "some", "also", "bit", "little", "feel", "feeling", "felt", "my", "am",
        "are", "was", "were", "not", "but", "you", "your", "his", "her", "their"
    ]

    /// Splits the user's symptom text into searchable keywords.
    static func keywords(from input: String) -> [String] {
        let parts = input
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
        var seen = Set<String>()
        var result: [String] = []
        for part in parts where part.count >= 3 && !stopWords.contains(part) {
            if seen.insert(part).inserted { result.append(part) }
        }
        return result
    }

    /// Very light stemming so "headaches" matches "headache", "coughing" matches "cough".
    static func stem(_ word: String) -> String {
        for suffix in ["ing", "es", "s"] {
            if word.hasSuffix(suffix), word.count - suffix.count >= 4 {
                return String(word.dropLast(suffix.count))
            }
        }
        return word
    }

    /// Groups PDF lines into readable sentence-like chunks.
    static func chunks(from pages: [PDFPageText]) -> [(page: Int, text: String)] {
        var output: [(Int, String)] = []
        for page in pages {
            var current = ""
            func flush() {
                let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count >= 8 { output.append((page.pageNumber, trimmed)) }
                current = ""
            }
            for line in page.text.components(separatedBy: .newlines) {
                let l = line.trimmingCharacters(in: .whitespaces)
                if l.isEmpty { flush(); continue }
                current += (current.isEmpty ? "" : " ") + l
                if current.count > 300 || l.hasSuffix(".") || l.hasSuffix(":") { flush() }
            }
            flush()
        }
        return output
    }

    /// Compares symptom keywords against the extracted PDF text (fully local).
    static func search(symptoms: String, in pages: [PDFPageText], limit: Int = 50) -> [MatchResult] {
        let stems = keywords(from: symptoms).map(stem)
        guard !stems.isEmpty else { return [] }

        var results: [MatchResult] = []
        for chunk in chunks(from: pages) {
            let haystack = chunk.text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            var matched: [String] = []
            var occurrences = 0
            for term in stems {
                let count = haystack.components(separatedBy: term).count - 1
                if count > 0 {
                    matched.append(term)
                    occurrences += count
                }
            }
            if !matched.isEmpty {
                results.append(MatchResult(
                    pageNumber: chunk.page,
                    text: chunk.text,
                    matchedTerms: matched,
                    score: matched.count * 10 + occurrences
                ))
            }
        }

        return Array(
            results
                .sorted { $0.score != $1.score ? $0.score > $1.score : $0.pageNumber < $1.pageNumber }
                .prefix(limit)
        )
    }
}
