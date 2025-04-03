import SwiftUI

struct OutfitCard: View {
    let outfit: String
    let tryOnImage: UIImage?
    @State private var offset = CGSize.zero
    var onSwipe: (Bool) -> Void
    
    // MARK: - Computed Properties
    private var cardImage: some View {
        Group {
            if let tryOnImage = tryOnImage {
                Image(uiImage: tryOnImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(outfit)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.7)
        .cornerRadius(20)
    }
    
    private var overlaySymbols: some View {
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
    }
    
    // MARK: - Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                offset = gesture.translation
            }
            .onEnded { gesture in
                handleSwipe(with: gesture)
            }
    }
    
    private func handleSwipe(with gesture: DragGesture.Value) {
        withAnimation {
            let width = gesture.translation.width
            if width > 100 {
                offset.width = 1000
                onSwipe(true)
            } else if width < -100 {
                offset.width = -1000
                onSwipe(false)
            } else {
                offset = .zero
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            cardImage
                .overlay(overlaySymbols)
        }
        .offset(x: offset.width, y: 0)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(dragGesture)
    }
}

struct OutfitSwiperView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var tryOnService = TryOnService()
    @State private var outfits = ["outfit1", "outfit2", "outfit3"]
    @State private var acceptedOutfits: Set<String> = []
    @State private var tryOnImages: [String: UIImage] = [:] // Store try-on results
    
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
                        OutfitCard(
                            outfit: outfit,
                            tryOnImage: tryOnImages[outfit]
                        ) { accepted in
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
                
                // Action buttons with increased spacing
                HStack(spacing: 120) { // Increased spacing from 40 to 120
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
        .task {
            await generateTryOns()
        }
    }
    
    private func removeOutfit(_ outfit: String) {
        if let index = outfits.firstIndex(of: outfit) {
            outfits.remove(at: index)
        }
    }

    private func generateTryOns() async {
        guard let userPhoto = CameraManager.loadSavedImage() else { return }
        
        for outfit in outfits {
            guard let clothingImage = UIImage(named: outfit) else { continue }
            
            do {
                tryOnService.isLoading = true
                let tryOnImage = try await tryOnService.generateTryOn(
                    userPhoto: userPhoto,
                    clothingImage: clothingImage
                )
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    tryOnImages[outfit] = tryOnImage
                }
            } catch {
                print("Error generating try-on for \(outfit): \(error)")
            }
        }
        
        tryOnService.isLoading = false
    }
}