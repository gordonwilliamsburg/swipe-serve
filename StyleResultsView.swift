import SwiftUI

struct StyleResultsView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            Text("Your Style Analysis")
                .font(StyleSwipeTheme.headlineFont)
                .foregroundColor(StyleSwipeTheme.primary)
                .padding(.top, 40)
            
            if !navigationManager.styleAnalysis.isEmpty {
                // Pie Chart
                PieChartView(compositions: navigationManager.styleAnalysis)
                    .frame(height: 250)
                    .padding()
                
                // Legend
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(navigationManager.styleAnalysis) { composition in
                        HStack {
                            Circle()
                                .fill(composition.color)
                                .frame(width: 20, height: 20)
                            
                            Text(composition.aesthetic)
                                .font(StyleSwipeTheme.bodyFont)
                            
                            Spacer()
                            
                            Text("\(Int(round(composition.percentage)))%")
                                .font(StyleSwipeTheme.bodyFont)
                                .foregroundColor(StyleSwipeTheme.accent)
                        }
                    }
                }
                .padding()
                .background(StyleSwipeTheme.secondary)
                .cornerRadius(20)
                .padding()
            } else {
                Text("No outfits were selected")
                    .font(StyleSwipeTheme.bodyFont)
                    .foregroundColor(StyleSwipeTheme.primary)
                    .padding()
            }
            
            Spacer()
            
            Button(action: {
                navigationManager.reset()
            }) {
                Text("Try Again")
                    .font(StyleSwipeTheme.bodyFont)
            }.outlinedButtonStyle()
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StyleSwipeTheme.background)
    }
}