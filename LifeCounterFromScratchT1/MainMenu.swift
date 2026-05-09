import SwiftUI

struct WheelWedge: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadiusRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio

        var path = Path()
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )
        path.closeSubpath()

        return path
    }
}

struct MainMenu: View {
    var onMenuSelection: (String) -> Void

    @State private var wheelRotation: Double = 0
    @State private var dragStartAngle: Double?
    @State private var dragStartRotation: Double = 0

    private let playerCounts = Array(1...8)
    private let segmentDegrees: Double = 45

    private var selectedPlayerCount: Int {
        let index = positiveModulo(Int((-wheelRotation / segmentDegrees).rounded()), playerCounts.count)
        return playerCounts[index]
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color.cyan, Color.teal.opacity(0.75), Color.green.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    Text("Select number of players")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black)

                    wheelSelector(size: min(geometry.size.width * 0.86, 350))

                    Spacer(minLength: 0)
                }
                .padding(.top, 46)
                .padding(.horizontal, 18)
            }
        }
    }

    private func wheelSelector(size: CGFloat) -> some View {
        let labelRadius = size * 0.34

        return ZStack {
            Circle()
                .fill(Color.black.opacity(0.16))
                .overlay {
                    Circle()
                        .stroke(Color.black.opacity(0.22), lineWidth: 6)
                }
                .shadow(color: .black.opacity(0.18), radius: 12, y: 8)

            ForEach(playerCounts, id: \.self) { count in
                let centerAngle = Double(count - 1) * segmentDegrees
                let isSelected = count == selectedPlayerCount

                WheelWedge(
                    startAngle: .degrees(centerAngle - (segmentDegrees / 2) - 90 + wheelRotation),
                    endAngle: .degrees(centerAngle + (segmentDegrees / 2) - 90 + wheelRotation),
                    innerRadiusRatio: 0.42
                )
                .fill(isSelected ? Color.green : wedgeColor(for: count))
                .contentShape(
                    WheelWedge(
                        startAngle: .degrees(centerAngle - (segmentDegrees / 2) - 90 + wheelRotation),
                        endAngle: .degrees(centerAngle + (segmentDegrees / 2) - 90 + wheelRotation),
                        innerRadiusRatio: 0.42
                    )
                )
                .onTapGesture {
                    spinToPlayerCount(count)
                }
                .overlay {
                    WheelWedge(
                        startAngle: .degrees(centerAngle - (segmentDegrees / 2) - 90 + wheelRotation),
                        endAngle: .degrees(centerAngle + (segmentDegrees / 2) - 90 + wheelRotation),
                        innerRadiusRatio: 0.42
                    )
                    .stroke(Color.black.opacity(0.24), lineWidth: 2)
                }

                Text("\(count)")
                    .font(.system(size: isSelected ? 40 : 34, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .black)
                    .offset(y: -labelRadius)
                    .rotationEffect(.degrees(centerAngle + wheelRotation))
                    .allowsHitTesting(false)
            }

            Button {
                onMenuSelection(viewName(for: selectedPlayerCount))
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 20, weight: .black))

                    Text("START")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(width: size * 0.42, height: size * 0.42)
                .background(Color.green)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.9), lineWidth: 4)
                }
                .shadow(color: .black.opacity(0.25), radius: 8, y: 5)
            }
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    updateWheelRotation(with: value, size: size)
                }
                .onEnded { _ in
                    dragStartAngle = nil
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        wheelRotation = (wheelRotation / segmentDegrees).rounded() * segmentDegrees
                    }
                }
        )
    }

    private func wedgeColor(for count: Int) -> Color {
        count.isMultiple(of: 2) ? Color.white.opacity(0.76) : Color.yellow.opacity(0.62)
    }

    private func updateWheelRotation(with value: DragGesture.Value, size: CGFloat) {
        let center = CGPoint(x: size / 2, y: size / 2)
        let startAngle = angle(for: value.startLocation, center: center)
        let currentAngle = angle(for: value.location, center: center)

        if dragStartAngle == nil {
            dragStartAngle = startAngle
            dragStartRotation = wheelRotation
        }

        guard let dragStartAngle else {
            return
        }

        wheelRotation = dragStartRotation + currentAngle - dragStartAngle
    }

    private func spinToPlayerCount(_ count: Int) {
        guard let targetIndex = playerCounts.firstIndex(of: count) else {
            return
        }

        dragStartAngle = nil
        let targetRotation = -Double(targetIndex) * segmentDegrees
        let rotationsToTarget = ((targetRotation - wheelRotation) / segmentDegrees).rounded()

        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
            wheelRotation += rotationsToTarget * segmentDegrees
        }
    }

    private func angle(for point: CGPoint, center: CGPoint) -> Double {
        atan2(point.y - center.y, point.x - center.x) * 180 / .pi + 90
    }

    private func positiveModulo(_ value: Int, _ divisor: Int) -> Int {
        let remainder = value % divisor
        return remainder >= 0 ? remainder : remainder + divisor
    }

    private func viewName(for playerCount: Int) -> String {
        switch playerCount {
        case 1:
            return "OnePlayer"
        case 2:
            return "TwoPlayer"
        case 3:
            return "ThreePlayer"
        case 4:
            return "FourPlayer"
        case 5:
            return "FivePlayer"
        case 6:
            return "SixPlayer"
        case 7:
            return "SevenPlayer"
        default:
            return "EightPlayer"
        }
    }
}

#Preview {
    MainMenu { _ in }
}
