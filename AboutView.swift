import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Purpose") {
                    Text("MediGuide helps you quickly locate information inside a medicine-information PDF that you provide. Everything is processed locally on your device — no internet, account or backend is needed.")
                }
                Section("How it works") {
                    Text("1. Upload a PDF\n2. Enter symptoms or keywords\n3. MediGuide shows matching passages from your document")
                }
                Section("Limitations") {
                    Text("• Does not diagnose diseases\n• Does not determine dosage\n• Does not replace a doctor or pharmacist\n• Cannot guarantee a medicine is suitable for you\n• Scanned/image-only PDFs are not supported yet (OCR planned)")
                }
                Section("Medical disclaimer") {
                    Text("Results are informational only and come solely from the document you upload. Always consult a qualified healthcare professional before taking or changing any medicine.")
                        .foregroundStyle(.orange)
                }
                Section("Team CareSync") {
                    Text("Suraj Yadav • Suraj Giri • Vivek Kumar Bharti")
                }
            }
            .navigationTitle("About & Safety")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
