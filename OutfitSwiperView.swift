import SwiftUI

struct OutfitSwiperView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            Text("Outfit Swiper")
                .font(StyleSwipeTheme.headlineFont)
                .foregroundColor(StyleSwipeTheme.primary)
            
            Spacer()
            
            // Placeholder for swipe cards
            Text("Swipe cards will appear here")
                .font(StyleSwipeTheme.bodyFont)
            
            // Temporary button to move to results (will be replaced with swipe logic)
            Button(action: {
                navigationManager.navigate(to: .styleResults)
            }) {
                Text("See Results")
                    .font(StyleSwipeTheme.buttonFont)
                    .foregroundColor(StyleSwipeTheme.secondary)
                    .padding()
                    .background(StyleSwipeTheme.accent)
                    .clipShape(Capsule())
            }
            .padding(.top, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StyleSwipeTheme.background)
    }
}