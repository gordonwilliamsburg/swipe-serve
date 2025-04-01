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
            
            // Navigation buttons - only for non-welcome screens
            if navigationManager.onboardingStep != .welcome {
                HStack {
                    Button(action: {
                        navigationManager.previousOnboardingStep()
                    }) {
                        Text("Back")
                            .font(StyleSwipeTheme.bodyFont)
                            .foregroundColor(StyleSwipeTheme.primary)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        navigationManager.nextOnboardingStep()
                    }) {
                        Text("Next")
                            .font(StyleSwipeTheme.bodyFont)
                    }.outlinedButtonStyle()
                }
                .padding(.horizontal, StyleSwipeTheme.standardPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StyleSwipeTheme.background)
    }
}

struct WelcomeView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)
                
                Image("front_page_swipe_serve")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.8)
                    .clipped()
            }
            
            // Overlay content
            VStack {
                // Title
                VStack(spacing: -20) { // Changed from 10 to 0 for tighter text spacing
                    Text("Swipe")
                        .font(.system(size: 60, weight: .regular, design: .serif))
                        .foregroundColor(StyleSwipeTheme.primary)
                    Text("&")
                        .font(.system(size: 40, weight: .regular, design: .serif))
                        .foregroundColor(StyleSwipeTheme.primary)
                    Text("Serve")
                        .font(.system(size: 60, weight: .regular, design: .serif))
                        .foregroundColor(StyleSwipeTheme.primary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                Button(action: {
                    navigationManager.nextOnboardingStep()
                }) {
                    Text("Get Started")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                }
                .outlinedButtonStyle()
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
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