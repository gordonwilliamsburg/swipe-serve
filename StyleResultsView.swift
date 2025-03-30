import SwiftUI

struct StyleResultsView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            Text("Your Style Results")
                .font(StyleSwipeTheme.headlineFont)
                .foregroundColor(StyleSwipeTheme.primary)
                .padding(.top, 40)
            
            Spacer()
            
            // Style result placeholder
            VStack(spacing: 20) {
                Text("Your style is")
                    .font(StyleSwipeTheme.bodyFont)
                
                Text("MINIMAL ELEGANCE")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(StyleSwipeTheme.accent)
                
                Text("You prefer clean lines, subtle details, and timeless pieces that create a sophisticated look.")
                    .font(StyleSwipeTheme.bodyFont)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(StyleSwipeTheme.secondary)
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding()
            
            Spacer()
            
            // Reset button to start over
            Button(action: {
                navigationManager.reset()
            }) {
                Text("Try Again")
                    .font(StyleSwipeTheme.buttonFont)
                    .foregroundColor(StyleSwipeTheme.secondary)
                    .padding()
                    .background(StyleSwipeTheme.accent)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StyleSwipeTheme.background)
    }
}