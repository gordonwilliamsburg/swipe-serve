import SwiftUI // Add this if not already present

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

struct PieChartView: View { // Add ': View' here
    let compositions: [StyleComposition]
    
    var body: some View {
        ZStack {
            ForEach(compositions) { composition in
                PieSlice(
                    startAngle: startAngle(for: composition),
                    endAngle: endAngle(for: composition)
                )
                .fill(composition.color)
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
}