import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var vm: MediGuideViewModel

    var body: some View {
        List {
            Section {
                if vm.results.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "text.magnifyingglass").font(.largeTitle)
                        Text("No matching information found").font(.headline)
                        Text("Try different or simpler keywords, or check that the PDF contains readable text.")
                            .font(.subheadline).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ForEach(vm.results) { result in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Page \(result.pageNumber)", systemImage: "doc.text")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.accentColor)
                                Spacer()
                                Text(result.matchedTerms.joined(separator: " • "))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text(highlighted(result.text, terms: result.matchedTerms))
                                .font(.body)
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                if !vm.results.isEmpty {
                    Text("\(vm.results.count) reference\(vm.results.count == 1 ? "" : "s") found for “\(vm.symptoms)”")
                }
            }

            Section {
                DisclaimerView()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Highlights matched keywords inside the snippet.
    private func highlighted(_ text: String, terms: [String]) -> AttributedString {
        var attributed = AttributedString(text)
        for term in terms {
            var start = text.startIndex
            while start < text.endIndex,
                  let range = text.range(of: term,
                                         options: [.caseInsensitive, .diacriticInsensitive],
                                         range: start..<text.endIndex) {
                if let attrRange = Range(range, in: attributed) {
                    attributed[attrRange].backgroundColor = Color.yellow.opacity(0.45)
                    attributed[attrRange].font = .body.bold()
                }
                start = range.upperBound
            }
        }
        return attributed
    }
}
