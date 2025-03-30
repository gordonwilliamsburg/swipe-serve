
import SwiftUI

struct PhotoCaptureView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            Text("Photo Capture")
                .font(StyleSwipeTheme.headlineFont)
                .foregroundColor(StyleSwipeTheme.primary)
            
            Spacer()
            
            // Camera placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 400)
                .overlay(
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(StyleSwipeTheme.primary.opacity(0.5))
                )
            
            Spacer()
            
            // Capture button
            Button(action: {
                // Proceed to outfit swiper screen
                navigationManager.navigate(to: .outfitSwiper)
            }) {
                ZStack {
                    Circle()
                        .fill(StyleSwipeTheme.accent)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .stroke(StyleSwipeTheme.secondary, lineWidth: 3)
                        .frame(width: 70, height: 70)
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StyleSwipeTheme.background)
    }
}