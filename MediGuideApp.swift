import SwiftUI

@main
struct MediGuideApp: App {
    @StateObject private var viewModel = MediGuideViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
        }
    }
}
