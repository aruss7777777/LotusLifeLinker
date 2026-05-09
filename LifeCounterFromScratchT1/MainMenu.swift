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

struct PlayerLayoutOption: Identifiable {
    let title: String
    let viewName: String
    let leftCount: Int
    let rightCount: Int?
    let bottomCount: Int?

    var id: String {
        viewName
    }
}

struct MainMenu: View {
    var onMenuSelection: (String) -> Void
    var savedGames: [SavedGame] = []
    var onLoadGame: ((SavedGame) -> Void)? = nil
    var onDeleteGame: ((UUID) -> Void)? = nil
    var onChooseFirst: (() -> Void)? = nil

    @State private var wheelRotation: Double = 0
    @State private var dragStartAngle: Double?
    @State private var dragStartRotation: Double = 0
    @State private var selectedThreePlayerLayout: String = "ThreePlayer"
    @State private var selectedFivePlayerLayout: String = "FivePlayer"
    @State private var selectedSevenPlayerLayout: String = "SevenPlayer"
    @State private var showingSavedGames: Bool = false

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
                    colors: [Color(red: 0.05, green: 0.08, blue: 0.2), Color(red: 0.08, green: 0.12, blue: 0.32)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 14) {
                    Text("Select Players")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)

                    let wheelSize = min(geometry.size.width * 0.78, 310)
                    wheelSelector(size: wheelSize)

                    // Fixed-height container so the wheel doesn't shift
                    ZStack {
                        if let layoutOptions = selectedLayoutOptions {
                            layoutOptionView(layoutOptions)
                        }
                    }
                    .frame(height: 170)

                    Spacer(minLength: 0)

                    Button {
                        onChooseFirst?()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.point.up.fill")
                                .font(.system(size: 16, weight: .semibold))

                            Text("Choose First")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                    }
                    .padding(.bottom, savedGames.isEmpty ? 30 : 8)

                    if !savedGames.isEmpty {
                        Button {
                            showingSavedGames = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 16, weight: .semibold))

                                Text("Load Game")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(red: 0.85, green: 0.7, blue: 0.25), lineWidth: 2)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 18)

                if showingSavedGames {
                    savedGamesOverlay
                }
            }
        }
    }

    private var savedGamesOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showingSavedGames = false
                }

            VStack(spacing: 0) {
                HStack {
                    Text("Saved Games")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        showingSavedGames = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)

                if savedGames.isEmpty {
                    Text("No saved games")
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.vertical, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(savedGames) { game in
                                savedGameRow(game)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(maxHeight: 400)
                }
            }
            .frame(maxWidth: 340)
            .background(Color(red: 0.1, green: 0.14, blue: 0.3))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.4), radius: 20)
        }
    }

    private func savedGameRow(_ game: SavedGame) -> some View {
        Button {
            onLoadGame?(game)
            showingSavedGames = false
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("\(game.playerLives.count)P  \u{2022}  \(game.date.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Button {
                    onDeleteGame?(game.id)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                        .foregroundStyle(.red.opacity(0.8))
                        .padding(8)
                        .contentShape(Rectangle())
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func wheelSelector(size: CGFloat) -> some View {
        let labelRadius = size * 0.34

        return ZStack {
            Circle()
                .fill(Color(red: 0.12, green: 0.16, blue: 0.35))
                .overlay {
                    Circle()
                        .stroke(Color(red: 0.85, green: 0.7, blue: 0.25), lineWidth: 6)
                }
                .shadow(color: .black.opacity(0.4), radius: 12, y: 8)

            ForEach(playerCounts, id: \.self) { count in
                let centerAngle = Double(count - 1) * segmentDegrees
                let isSelected = count == selectedPlayerCount

                WheelWedge(
                    startAngle: .degrees(centerAngle - (segmentDegrees / 2) - 90 + wheelRotation),
                    endAngle: .degrees(centerAngle + (segmentDegrees / 2) - 90 + wheelRotation),
                    innerRadiusRatio: 0.42
                )
                .fill(isSelected ? Color(red: 0.85, green: 0.7, blue: 0.25) : wedgeColor(for: count))
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
                    .stroke(Color(red: 0.15, green: 0.25, blue: 0.55), lineWidth: 2)
                }

                Text("\(count)")
                    .font(.system(size: isSelected ? 40 : 34, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? .white : Color(red: 0.1, green: 0.15, blue: 0.3))
                    .offset(y: -labelRadius)
                    .rotationEffect(.degrees(centerAngle + wheelRotation))
                    .allowsHitTesting(false)
            }

            Button {
                onMenuSelection(selectedViewName)
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 20, weight: .black))

                    Text("START")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(width: size * 0.42, height: size * 0.42)
                .background(Color(red: 0.85, green: 0.7, blue: 0.25))
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color(red: 1.0, green: 0.9, blue: 0.55), lineWidth: 4)
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

    private var selectedViewName: String {
        if selectedPlayerCount == 3 {
            return selectedThreePlayerLayout
        }

        if selectedPlayerCount == 5 {
            return selectedFivePlayerLayout
        }

        if selectedPlayerCount == 7 {
            return selectedSevenPlayerLayout
        }

        return viewName(for: selectedPlayerCount)
    }

    private var selectedLayoutOptions: [PlayerLayoutOption]? {
        switch selectedPlayerCount {
        case 3:
            return [
                PlayerLayoutOption(title: "Classic", viewName: "ThreePlayer", leftCount: 2, rightCount: nil, bottomCount: 1),
                PlayerLayoutOption(title: "2 / 1 Split", viewName: "ThreePlayerSplit", leftCount: 2, rightCount: 1, bottomCount: nil)
            ]
        case 5:
            return [
                PlayerLayoutOption(title: "Classic", viewName: "FivePlayer", leftCount: 2, rightCount: 2, bottomCount: 1),
                PlayerLayoutOption(title: "3 / 2 Split", viewName: "FivePlayerSplit", leftCount: 3, rightCount: 2, bottomCount: nil)
            ]
        case 7:
            return [
                PlayerLayoutOption(title: "Classic", viewName: "SevenPlayer", leftCount: 3, rightCount: 3, bottomCount: 1),
                PlayerLayoutOption(title: "4 / 3 Split", viewName: "SevenPlayerSplit", leftCount: 4, rightCount: 3, bottomCount: nil)
            ]
        default:
            return nil
        }
    }

    private func layoutOptionView(_ options: [PlayerLayoutOption]) -> some View {
        HStack(spacing: 12) {
            ForEach(options) { option in
                layoutButton(option)
            }
        }
        .frame(maxWidth: 330)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    private func layoutButton(_ option: PlayerLayoutOption) -> some View {
        let isSelected = selectedViewName == option.viewName

        return Button {
            selectLayout(option.viewName)
        } label: {
            VStack(spacing: 6) {
                Text(option.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))

                layoutIllustration(option)
            }
            .foregroundStyle(.white)
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color(red: 0.85, green: 0.7, blue: 0.25).opacity(0.78) : Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(red: 0.85, green: 0.7, blue: 0.25) : Color.white.opacity(0.3), lineWidth: isSelected ? 3 : 1)
            }
        }
    }

    private func layoutIllustration(_ option: PlayerLayoutOption) -> some View {
        Group {
            switch option.viewName {
            case "ThreePlayer":
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        miniCell(label: "1", rotation: .degrees(90))
                        miniCell(label: "2", rotation: .degrees(270))
                    }

                    miniCell(label: "3", rotation: .degrees(0))
                }

            case "ThreePlayerSplit":
                HStack(spacing: 2) {
                    VStack(spacing: 2) {
                        miniCell(label: "1", rotation: .degrees(90))
                        miniCell(label: "3", rotation: .degrees(90))
                    }

                    miniCell(label: "2", rotation: .degrees(270))
                }

            case "FivePlayer":
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        miniCell(label: "1", rotation: .degrees(90))
                        miniCell(label: "2", rotation: .degrees(270))
                    }

                    HStack(spacing: 2) {
                        miniCell(label: "3", rotation: .degrees(90))
                        miniCell(label: "4", rotation: .degrees(270))
                    }

                    miniCell(label: "5", rotation: .degrees(0))
                }

            case "FivePlayerSplit":
                HStack(spacing: 2) {
                    VStack(spacing: 2) {
                        miniCell(label: "1", rotation: .degrees(90))
                        miniCell(label: "3", rotation: .degrees(90))
                        miniCell(label: "5", rotation: .degrees(90))
                    }

                    VStack(spacing: 2) {
                        miniCell(label: "2", rotation: .degrees(270))
                        miniCell(label: "4", rotation: .degrees(270))
                    }
                }

            case "SevenPlayer":
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        miniCell(label: "1", rotation: .degrees(90))
                        miniCell(label: "2", rotation: .degrees(270))
                    }

                    HStack(spacing: 2) {
                        miniCell(label: "3", rotation: .degrees(90))
                        miniCell(label: "4", rotation: .degrees(270))
                    }

                    HStack(spacing: 2) {
                        miniCell(label: "5", rotation: .degrees(90))
                        miniCell(label: "6", rotation: .degrees(270))
                    }

                    miniCell(label: "7", rotation: .degrees(0))
                }

            case "SevenPlayerSplit":
                HStack(spacing: 2) {
                    VStack(spacing: 2) {
                        miniCell(label: "1", rotation: .degrees(90))
                        miniCell(label: "3", rotation: .degrees(90))
                        miniCell(label: "5", rotation: .degrees(90))
                        miniCell(label: "7", rotation: .degrees(90))
                    }

                    VStack(spacing: 2) {
                        miniCell(label: "2", rotation: .degrees(270))
                        miniCell(label: "4", rotation: .degrees(270))
                        miniCell(label: "6", rotation: .degrees(270))
                    }
                }

            default:
                EmptyView()
            }
        }
        .frame(height: 120)
    }

    private func miniCell(label: String, rotation: Angle) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.white.opacity(0.2))
            .overlay {
                Text(label)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .rotationEffect(rotation)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(2)
            }
    }

    private func miniCell(label: String) -> some View {
        miniCell(label: label, rotation: .degrees(0))
    }

    private func selectLayout(_ viewName: String) {
        switch selectedPlayerCount {
        case 3:
            selectedThreePlayerLayout = viewName
        case 5:
            selectedFivePlayerLayout = viewName
        case 7:
            selectedSevenPlayerLayout = viewName
        default:
            break
        }
    }

    private func wedgeColor(for count: Int) -> Color {
        count.isMultiple(of: 2) ? Color(white: 0.82) : Color(white: 0.9)
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
