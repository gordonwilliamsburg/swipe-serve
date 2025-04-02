import SwiftUI

struct OutfitCard: View {
    let outfit: String // This will be your outfit image name
    @State private var offset = CGSize.zero
    @State private var color: Color = .clear
    
    var onSwipe: (Bool) -> Void
    
    var body: some View {
        ZStack {
            Image(outfit)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.6)
                .cornerRadius(20)
                .overlay(
                    ZStack {
                        // Reject symbol
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 100))
                            .opacity(Double(offset.width < 0 ? -offset.width / 50 : 0))
                        
                        // Accept symbol
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 100))
                            .opacity(Double(offset.width > 0 ? offset.width / 50 : 0))
                    }
                )
        }
        .offset(x: offset.width, y: 0)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    withAnimation {
                        let width = gesture.translation.width
                        if width > 100 {
                            offset.width = 1000
                            onSwipe(true) // Accepted
                        } else if width < -100 {
                            offset.width = -1000
                            onSwipe(false) // Rejected
                        } else {
                            offset = .zero
                        }
                    }
                }
        )
    }
}

struct OutfitSwiperView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var outfits = ["outfit1", "outfit2", "outfit3"] // Replace with your outfit images
    @State private var acceptedOutfits: Set<String> = []
    
    var body: some View {
        VStack {
            Text("Swipe Outfits")
                .font(StyleSwipeTheme.headlineFont)
                .foregroundColor(StyleSwipeTheme.primary)
                .padding(.top, 20)
            
            Spacer()
            
            if !outfits.isEmpty {
                ZStack {
                    ForEach(outfits.suffix(3), id: \.self) { outfit in
                        OutfitCard(outfit: outfit) { accepted in
                            withAnimation {
                                if accepted {
                                    acceptedOutfits.insert(outfit)
                                }
                                removeOutfit(outfit)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 40) {
                    // Reject button
                    Button(action: {
                        withAnimation {
                            if let last = outfits.last {
                                removeOutfit(last)
                            }
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    
                    // Accept button
                    Button(action: {
                        withAnimation {
                            if let last = outfits.last {
                                acceptedOutfits.insert(last)
                                removeOutfit(last)
                            }
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                }
                .padding(.bottom, 40)
            } else {
                // Show this when all cards are swiped
                VStack(spacing: 20) {
                    Text("All outfits reviewed!")
                        .font(StyleSwipeTheme.bodyFont)
                        .foregroundColor(StyleSwipeTheme.primary)
                    
                    Button(action: {
                        navigationManager.navigate(to: .styleResults)
                    }) {
                        Text("See Results")
                            .font(StyleSwipeTheme.bodyFont)
                    }.outlinedButtonStyle()
                }
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StyleSwipeTheme.background)
    }
    
    private func removeOutfit(_ outfit: String) {
        if let index = outfits.firstIndex(of: outfit) {
            outfits.remove(at: index)
        }
    }
}