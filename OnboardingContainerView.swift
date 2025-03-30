import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            // Show different content based on onboarding step
            switch navigationManager.onboardingStep {
            case .welcome:
                WelcomeView()
            case .stylePreferences:
                StylePreferencesView()
            case .readyForPhoto:
                ReadyForPhotoView()
            }
            
            // Navigation buttons
            HStack {
                // Back button (hidden on first step)
                if navigationManager.onboardingStep != .welcome {
                    Button(action: {
                        navigationManager.previousOnboardingStep()
                    }) {
                        Text("Back")
                            .font(StyleSwipeTheme.buttonFont)
                            .foregroundColor(StyleSwipeTheme.primary)
                            .padding()
                    }
                }
                
                Spacer()
                
                // Next button
                Button(action: {
                    navigationManager.nextOnboardingStep()
                }) {
                    Text("Next")
                        .font(StyleSwipeTheme.buttonFont)
                        .foregroundColor(StyleSwipeTheme.secondary)
                        .padding()
                        .background(StyleSwipeTheme.accent)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, StyleSwipeTheme.standardPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StyleSwipeTheme.background)
    }
}

// Placeholder for the Welcome screen
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("StyleSwipe")
                .font(StyleSwipeTheme.headlineFont)
                .foregroundColor(StyleSwipeTheme.primary)
            
            Text("Discover your fashion style through our interactive experience")
                .font(StyleSwipeTheme.bodyFont)
                .foregroundColor(StyleSwipeTheme.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Image(systemName: "tshirt.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(StyleSwipeTheme.accent)
        }
        .padding()
    }
}

// Placeholder for style preferences screen
struct StylePreferencesView: View {
    var body: some View {
        Text("Style Preferences")
            .font(StyleSwipeTheme.headlineFont)
            .foregroundColor(StyleSwipeTheme.primary)
    }
}

// Placeholder for final onboarding screen
struct ReadyForPhotoView: View {
    var body: some View {
        Text("Ready to take your photo")
            .font(StyleSwipeTheme.headlineFont)
            .foregroundColor(StyleSwipeTheme.primary)
    }
}