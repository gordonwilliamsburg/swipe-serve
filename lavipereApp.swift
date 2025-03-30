import SwiftUI

@main
struct lavipereApp: App {
    // Create an instance of our navigation manager
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(navigationManager)
        }
    }
}

// Main container view that handles navigation
struct MainView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        ZStack {
            // Display the current screen based on navigation state
            switch navigationManager.currentScreen {
            case .onboarding:
                OnboardingContainerView()
            case .photoCapture:
                PhotoCaptureView()
            case .outfitSwiper:
                OutfitSwiperView()
            case .styleResults:
                StyleResultsView()
            }
        }
    }
}