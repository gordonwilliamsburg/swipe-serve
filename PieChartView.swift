import SwiftUI

struct PieSlice: Shape {
    let startAngle: Double
    let endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: .degrees(startAngle - 90),
                   endAngle: .degrees(endAngle - 90),
                   clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

struct PieChartView: View {
    let compositions: [StyleComposition]
    
    var body: some View {
        ZStack {
            ForEach(compositions) { composition in
                ZStack {
                    PieSlice(
                        startAngle: startAngle(for: composition),
                        endAngle: endAngle(for: composition)
                    )
                    .fill(composition.color)
                    
                    // Add percentage text
                    GeometryReader { geometry in
                        Text("\(Int(round(composition.percentage)))%")
                            .font(StyleSwipeTheme.bodyFont)
                            .foregroundColor(.white)
                            .position(
                                percentagePosition(
                                    for: composition,
                                    in: geometry.size
                                )
                            )
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
    
    private func startAngle(for composition: StyleComposition) -> Double {
        let index = compositions.firstIndex(where: { $0.id == composition.id }) ?? 0
        return compositions.prefix(index).reduce(0) { $0 + $1.percentage } * 3.6
    }
    
    private func endAngle(for composition: StyleComposition) -> Double {
        startAngle(for: composition) + (composition.percentage * 3.6)
    }
    
    private func percentagePosition(for composition: StyleComposition, in size: CGSize) -> CGPoint {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 4 // Position text halfway between center and edge
        
        // Calculate the angle for the middle of the slice
        let startAngle = startAngle(for: composition)
        let endAngle = endAngle(for: composition)
        let midAngle = startAngle + (endAngle - startAngle) / 2
        
        // Convert angle to radians and adjust for the -90 degree offset
        let angleInRadians = (midAngle - 90) * .pi / 180
        
        // Calculate position
        let x = center.x + radius * cos(angleInRadians)
        let y = center.y + radius * sin(angleInRadians)
        
        return CGPoint(x: x, y: y)
    }
}