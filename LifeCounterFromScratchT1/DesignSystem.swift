import SwiftUI

// Modern color scheme for the app
extension Color {
    // Primary brand colors - bright and modern
    static let appPrimary = Color(red: 0.4, green: 0.6, blue: 1.0) // Bright blue
    static let appSecondary = Color(red: 0.5, green: 0.8, blue: 0.95) // Light cyan
    static let appAccent = Color(red: 1.0, green: 0.7, blue: 0.3) // Warm orange
    
    // Menu colors - bright and vibrant
    static let menuBackground = Color(red: 0.95, green: 0.97, blue: 1.0) // Very light blue
    static let menuCard = Color.white
    static let menuCardShadow = Color.black.opacity(0.08)
    
    // Text colors
    static let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.2) // Dark blue-gray
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.5) // Medium gray
    
    // Button colors
    static let buttonPrimary = Color(red: 0.4, green: 0.6, blue: 1.0) // Bright blue
    static let buttonSecondary = Color(red: 0.5, green: 0.8, blue: 0.95) // Light cyan
    static let buttonDanger = Color(red: 1.0, green: 0.4, blue: 0.4) // Coral red
    static let buttonSuccess = Color(red: 0.3, green: 0.85, blue: 0.6) // Mint green
    
    // Pro colors
    static let proBadge = Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
    static let proBackground = Color(red: 1.0, green: 0.97, blue: 0.85) // Light gold
}

// Lotus symbol view that can be used as background
struct LotusSymbol: View {
    var size: CGFloat = 200
    var color: Color = .white.opacity(0.1)
    
    var body: some View {
        ZStack {
            // Center circle
            Circle()
                .fill(color)
                .frame(width: size * 0.25, height: size * 0.25)
            
            // Petals - 8 petals in a circle
            ForEach(0..<8) { index in
                Petal()
                    .fill(color)
                    .frame(width: size * 0.35, height: size * 0.6)
                    .offset(y: -size * 0.25)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
        .frame(width: size, height: size)
    }
}

// Single petal shape
struct Petal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create a petal shape using bezier curves
        path.move(to: CGPoint(x: width / 2, y: height))
        
        // Left curve
        path.addQuadCurve(
            to: CGPoint(x: width / 2, y: 0),
            control: CGPoint(x: 0, y: height * 0.4)
        )
        
        // Right curve
        path.addQuadCurve(
            to: CGPoint(x: width / 2, y: height),
            control: CGPoint(x: width, y: height * 0.4)
        )
        
        return path
    }
}

// Interactive lotus wheel petal - beautiful rounded petal shape!
struct LotusWheelPetal: Shape {
    let petalIndex: Int
    let totalPetals: Int
    let innerRadiusRatio: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio
        
        // Calculate angles for this petal
        let anglePerPetal = 360.0 / Double(totalPetals)
        let midAngle = Double(petalIndex) * anglePerPetal - 90
        let startAngle = midAngle - anglePerPetal / 2
        let endAngle = midAngle + anglePerPetal / 2
        
        var path = Path()
        
        // Extended petal tip for pointed end
        let petalTipRadius = outerRadius * 1.18
        
        // Start at inner edge (base of petal)
        path.move(to: pointOnCircle(center: center, radius: innerRadius, angle: startAngle))
        
        // Widen slightly as we go out
        let baseLeftOuter = pointOnCircle(center: center, radius: outerRadius * 0.88, angle: startAngle)
        path.addLine(to: baseLeftOuter)
        
        // Left curve - rounded side of petal going up to tip
        let leftControl1 = pointOnCircle(center: center, radius: outerRadius * 1.0, angle: startAngle + anglePerPetal * 0.2)
        let leftControl2 = pointOnCircle(center: center, radius: outerRadius * 1.12, angle: midAngle - anglePerPetal * 0.15)
        let tipPoint = pointOnCircle(center: center, radius: petalTipRadius, angle: midAngle)
        
        path.addCurve(to: tipPoint, control1: leftControl1, control2: leftControl2)
        
        // Right curve - rounded side coming back down from tip  
        let rightControl1 = pointOnCircle(center: center, radius: outerRadius * 1.12, angle: midAngle + anglePerPetal * 0.15)
        let rightControl2 = pointOnCircle(center: center, radius: outerRadius * 1.0, angle: endAngle - anglePerPetal * 0.2)
        let baseRightOuter = pointOnCircle(center: center, radius: outerRadius * 0.88, angle: endAngle)
        
        path.addCurve(to: baseRightOuter, control1: rightControl1, control2: rightControl2)
        
        // Line back to inner edge
        let innerEnd = pointOnCircle(center: center, radius: innerRadius, angle: endAngle)
        path.addLine(to: innerEnd)
        
        // Inner arc to close the petal
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: .degrees(endAngle),
            endAngle: .degrees(startAngle),
            clockwise: true
        )
        
        path.closeSubpath()
        return path
    }
    
    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let radians = angle * .pi / 180
        return CGPoint(
            x: center.x + radius * cos(radians),
            y: center.y + radius * sin(radians)
        )
    }
}

// Animated rotating lotus background
struct AnimatedLotusBackground: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Large lotus in center
            LotusSymbol(size: 300, color: .white.opacity(0.08))
                .rotationEffect(.degrees(rotation))
            
            // Smaller lotus offset
            LotusSymbol(size: 150, color: .white.opacity(0.05))
                .offset(x: -100, y: -150)
                .rotationEffect(.degrees(-rotation * 0.7))
            
            LotusSymbol(size: 150, color: .white.opacity(0.05))
                .offset(x: 100, y: 150)
                .rotationEffect(.degrees(-rotation * 0.7))
        }
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}
