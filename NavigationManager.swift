import SwiftUI

// Define the app screens
enum AppScreen {
    case onboarding
    case photoCapture
    case outfitSwiper
    case styleResults
}

// Define the onboarding steps
enum OnboardingStep {
    case welcome
    case stylePreferences
    case readyForPhoto
}

// Main navigation manager class
class NavigationManager: ObservableObject {
    @Published var currentScreen: AppScreen = .onboarding
    @Published var onboardingStep: OnboardingStep = .welcome
    @Published var swipeImages: [String] = []
    @Published var selectedAesthetics: [String] = []
    @Published var styleAnalysis: [StyleComposition] = []

    func setStyleAnalysis(_ analysis: [StyleComposition]) {
        styleAnalysis = analysis
    }
    
    func updateSwipeImages(_ images: [String]) {
        swipeImages = images
    }
    // Navigate to a specific screen
    func navigate(to screen: AppScreen) {
        currentScreen = screen
    }
    
    // Navigate to next onboarding step
    func nextOnboardingStep() {
        switch onboardingStep {
        case .welcome:
            onboardingStep = .stylePreferences
        case .stylePreferences:
            // Only proceed if there are selected aesthetics
            if !swipeImages.isEmpty {
                onboardingStep = .readyForPhoto
            }
        case .readyForPhoto:
            // Correct the flow: go to photo capture first
            currentScreen = .photoCapture  // This was previously going straight to .outfitSwiper
        }
    }
    
    // Navigate back in onboarding
    func previousOnboardingStep() {
        switch onboardingStep {
        case .stylePreferences:
            onboardingStep = .welcome
        case .readyForPhoto:
            onboardingStep = .stylePreferences
        default:
            break // Already at first step
        }
    }
    
    // Reset navigation to start
    func reset() {
        currentScreen = .onboarding
        onboardingStep = .welcome
    }
}