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
                    }
                    .outlinedButtonStyle()
                    .disabled(navigationManager.onboardingStep == .stylePreferences && 
                             navigationManager.swipeImages.isEmpty)
                    .opacity(navigationManager.onboardingStep == .stylePreferences && 
                            navigationManager.swipeImages.isEmpty ? 0.5 : 1)
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
            Image("\(name)_cover")
                .resizable()
                .scaledToFill()
                .frame(width: (UIScreen.main.bounds.width - 48) / 2, // Account for padding and spacing
                       height: (UIScreen.main.bounds.width - 48) / 2) // Make it square
                .clipped()
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                )
            
            Text(name.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.system(size: 18, weight: .medium, design: .serif)) // Smaller font
                .foregroundColor(.white)
              
            if isSelected {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20)) // Slightly smaller checkmark
                            .padding(8) // Smaller padding
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
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var selectedAesthetics: Set<String> = []
    let aesthetics = ["biker", "corporate_goth", "old_money", "avant_garde"]
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Generate image names for selected aesthetics and randomize them
    private func generateRandomizedImageNames() -> [String] {
        // Collect all image names for selected aesthetics
        var allImages: [String] = []
        
        for aesthetic in selectedAesthetics {
            // Assuming each aesthetic has 5 images - adjust this number as needed
            for i in 1...5 {
                allImages.append("\(aesthetic)_\(i)")
            }
        }
        
        // Randomize the order
        return allImages.shuffled()
    }
    
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
                LazyVGrid(columns: columns, spacing: 16) {
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
                                    navigationManager.updateSwipeImages(generateRandomizedImageNames())
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