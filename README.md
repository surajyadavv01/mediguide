# MediGuide – PDF-Based Medicine Information & Symptom Guide
Team CareSync: Suraj Yadav(2502221530189) • Suraj Giri(2502221530188) • Vivek Kumar Bharti(2502221530209)
Mentor : Anjali Srivastava


Offline-first iOS app (SwiftUI + PDFKit). Upload a medicine-information PDF, enter symptoms,
and see matching passages from the document. Informational only – no diagnosis, no dosage advice.

## Run it
1. Open `MediGuide.xcodeproj` in Xcode 15.4 (or later).
2. Select the MediGuide target > Signing & Capabilities > pick your Team (only needed for a real device).
3. Choose an iPhone simulator and press Run (Cmd+R).
4. To test on the simulator: drag `SamplePDF/Sample_Medicine_Info.pdf` onto the simulator (it lands in Files),
   then tap Upload PDF and pick it. Try symptoms like `headache, fever`.

## Structure
- MediGuideApp.swift – app entry
- HomeView.swift – upload, symptom input, search (Home / PDF Selected / Symptom Input screens)
- ResultsView.swift – matching passages with highlighted keywords + disclaimer
- AboutView.swift – purpose, limitations, medical disclaimer
- PDFTextExtractor.swift – PDFKit text extraction
- MatchingEngine.swift – local keyword matching
- MediGuideViewModel.swift – app state

Minimum iOS: 16.0. Scanned/image-only PDFs need OCR (future enhancement).
