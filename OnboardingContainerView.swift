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

struct AestheticCard: View {
    let name: String
    @Binding var isSelected: Bool
    
    var body: some View {
        ZStack {
            // Image from assets with full path
            Image("\(name)_cover")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.8 * 0.8) // 5:4 ratio
                .clipped()
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                )
            
            // Aesthetic name
            Text(name.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .foregroundColor(.white)
              
            // Selection indicator
            if isSelected {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .padding(12)
                    }
                    Spacer()
                }
            }
        }
        .cornerRadius(12)
        .shadow(radius: 5)
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

struct StylePreferencesView: View {
    @State private var selectedAesthetics: Set<String> = []
    let aesthetics = ["biker", "corporate_goth", "old_money"]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Your Style")
                .font(StyleSwipeTheme.headlineFont)
                .foregroundColor(StyleSwipeTheme.primary)
                .padding(.top, 40)
            
            Text("Select the aesthetics that inspire you")
                .font(StyleSwipeTheme.bodyFont)
                .foregroundColor(StyleSwipeTheme.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(aesthetics, id: \.self) { aesthetic in
                        AestheticCard(
                            name: aesthetic,
                            isSelected: Binding(
                                get: { selectedAesthetics.contains(aesthetic) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedAesthetics.insert(aesthetic)
                                    } else {
                                        selectedAesthetics.remove(aesthetic)
                                    }
                                }
                            )
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
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