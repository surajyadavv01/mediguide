import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @EnvironmentObject private var vm: MediGuideViewModel
    @State private var showImporter = false
    @State private var showAbout = false
    @State private var showResults = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    pdfCard
                    symptomCard
                    if let error = vm.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    searchButton
                    DisclaimerView()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("MediGuide")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAbout = true } label: { Image(systemName: "info.circle") }
                        .accessibilityLabel("About and safety")
                }
            }
            .navigationDestination(isPresented: $showResults) {
                ResultsView()
            }
            .sheet(isPresented: $showAbout) { AboutView() }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first { vm.loadPDF(from: url) }
                case .failure(let error):
                    vm.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.accentColor)
            Text("PDF-Based Medicine Information & Symptom Guide")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var pdfCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. Medicine document").font(.headline)

            if vm.isLoading {
                HStack { ProgressView(); Text("Reading PDF…") }
            } else if let name = vm.documentName {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text.fill").foregroundStyle(Color.accentColor)
                    VStack(alignment: .leading) {
                        Text(name).font(.subheadline).lineLimit(2)
                        Text("Ready • \(vm.pageCount) readable page\(vm.pageCount == 1 ? "" : "s")")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(role: .destructive) { vm.removeDocument() } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .accessibilityLabel("Remove document")
                }
            } else {
                Text("No PDF selected yet.").font(.subheadline).foregroundStyle(.secondary)
            }

            Button {
                showImporter = true
            } label: {
                Label(vm.hasDocument ? "Choose a different PDF" : "Upload PDF", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .cardStyle()
    }

    private var symptomCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2. Symptoms / keywords").font(.headline)
            TextField("e.g. headache, fever, cough", text: $vm.symptoms, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit { runSearch() }
            Text("Separate multiple symptoms with commas or spaces.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private var searchButton: some View {
        Button { runSearch() } label: {
            Label("Search in PDF", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!vm.canSearch || vm.isLoading)
    }

    private func runSearch() {
        if vm.search() { showResults = true }
    }
}

// MARK: - Shared styling

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct DisclaimerView: View {
    var body: some View {
        Label {
            Text("For information only. This app does not diagnose conditions, prescribe medicines or determine dosage. Always consult a doctor or pharmacist.")
                .font(.footnote)
        } icon: {
            Image(systemName: "stethoscope")
        }
        .foregroundStyle(.secondary)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
