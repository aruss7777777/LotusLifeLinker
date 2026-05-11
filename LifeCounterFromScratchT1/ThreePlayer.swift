import SwiftUI

struct ThreePlayer: View {
    private struct PressedControl: Equatable {
        let playerIndex: Int
        let lifeChange: Int
    }

    @Binding var playerLives: [Int]
    @Binding var playerStyles: [PlayerBoxStyle]
    @Binding var playerNames: [String]
    @Binding var isEditingBoxes: Bool
    @State private var selectedPlayerIndex: Int = 0
    @State private var pressedControl: PressedControl?
    @State private var repeatTimer: Timer?
    @State private var holdStartDate: Date?
    var onInGameMenu: () -> Void
    var specialDamageDeaths: [Bool] = []

    var body: some View {
        GeometryReader { _ in
            ZStack {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        rotatedPlayerControl(for: 0, rotation: .degrees(90))
                        rotatedPlayerControl(for: 1, rotation: .degrees(270))
                    }

                    verticalPlayerControl(for: 2, topChange: 1, bottomChange: -1)
                }

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        playerInfoCell(for: 0, rotation: .degrees(90))
                        playerInfoCell(for: 1, rotation: .degrees(270))
                    }

                    playerInfoCell(for: 2, rotation: .degrees(0))
                }

                playerDividerOverlay

                if isEditingBoxes {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    playerSelectionOverlay
                    PlayerCustomizationPanel(
                        playerStyles: $playerStyles,
                        playerNames: $playerNames,
                        isEditingBoxes: $isEditingBoxes,
                        selectedPlayerIndex: selectedPlayerIndex
                    )
                }

                if !isEditingBoxes {
                    lotusMenuButton
                }
            }
            .ignoresSafeArea()
        }
        .onDisappear {
            stopRepeatingChange()
        }
    }

    private func horizontalPlayerControl(for playerIndex: Int, leftChange: Int, rightChange: Int) -> some View {
        HStack(spacing: 0) {
            lifeControlArea(for: playerIndex, lifeChange: leftChange)
            lifeControlArea(for: playerIndex, lifeChange: rightChange)
        }
    }

    private func verticalPlayerControl(for playerIndex: Int, topChange: Int, bottomChange: Int) -> some View {
        VStack(spacing: 0) {
            lifeControlArea(for: playerIndex, lifeChange: topChange)
            lifeControlArea(for: playerIndex, lifeChange: bottomChange)
        }
    }

    @ViewBuilder
    private func rotatedPlayerControl(for playerIndex: Int, rotation: Angle) -> some View {
        if abs(rotation.degrees - 90) < 0.1 {
            horizontalPlayerControl(for: playerIndex, leftChange: -1, rightChange: 1)
        } else if abs(rotation.degrees - 270) < 0.1 {
            horizontalPlayerControl(for: playerIndex, leftChange: 1, rightChange: -1)
        } else {
            verticalPlayerControl(for: playerIndex, topChange: 1, bottomChange: -1)
        }
    }

    private func lifeControlArea(for playerIndex: Int, lifeChange: Int) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onLongPressGesture(
                minimumDuration: 0.35,
                maximumDistance: .infinity,
                pressing: { isPressing in
                    if isPressing {
                        beginPress(for: playerIndex, lifeChange: lifeChange)
                    } else {
                        finishPress(for: playerIndex, lifeChange: lifeChange)
                    }
                },
                perform: {
                    startRepeatingChange(for: playerIndex, lifeChange: lifeChange)
                }
            )
    }

    private func backgroundRotation(for playerIndex: Int) -> Angle {
        switch playerIndex {
        case 0:
            return .degrees(90)
        case 1:
            return .degrees(270)
        default:
            return .degrees(0)
        }
    }

    private func playerInfoCell(for playerIndex: Int, rotation: Angle) -> some View {
        let isDeadFromSpecialDamage = specialDamageDeaths.indices.contains(playerIndex) && specialDamageDeaths[playerIndex]

        return playerInfoView(
            name: playerNames[playerIndex],
            life: playerLives[playerIndex],
            color: playerStyles[playerIndex].fontColor,
            isOutlined: playerStyles[playerIndex].isTextOutlined || isDeadFromSpecialDamage,
            rotation: rotation
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                PlayerBackgroundView(style: playerStyles[playerIndex], imageRotation: rotation)
                SpecialDamageDeathBackground(isDead: isDeadFromSpecialDamage, rotation: rotation)
            }
        }
        .allowsHitTesting(false)
    }

    private func playerInfoView(name: String, life: Int, color: Color, isOutlined: Bool, rotation: Angle) -> some View {
        VStack(spacing: 8) {
            OutlinedPlayerText(
                text: "\(life)",
                font: PlayerTextSizing.lifeFont(baseSize: 90),
                color: color,
                isOutlined: isOutlined,
                minimumScaleFactor: 0.45,
                usesMonospacedDigits: true
            )

            OutlinedPlayerText(
                text: name,
                font: PlayerTextSizing.nameFont(baseSize: 24),
                color: color,
                isOutlined: isOutlined,
                minimumScaleFactor: 0.6
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .allowsHitTesting(false)
        .rotationEffect(rotation)
    }

    private var customizePanel: some View {
        VStack(spacing: 8) {
            Text("Edit Player \(selectedPlayerIndex + 1)")
                .font(.headline)

            Text("Tap a player box to select it")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(
                "Player Name",
                text: Binding(
                    get: { playerNames[selectedPlayerIndex] },
                    set: { playerNames[selectedPlayerIndex] = $0 }
                )
            )
            .textFieldStyle(.roundedBorder)

            colorPickerRow(
                title: "Font Color",
                selection: Binding(
                    get: { playerStyles[selectedPlayerIndex].fontColor },
                    set: { playerStyles[selectedPlayerIndex].fontColor = $0 }
                )
            )

            colorPickerRow(
                title: "Background Color",
                selection: Binding(
                    get: { playerStyles[selectedPlayerIndex].backgroundColor },
                    set: { playerStyles[selectedPlayerIndex].backgroundColor = $0 }
                )
            )

            Button {
                isEditingBoxes = false
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
            }
            .background(Color.black)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .frame(maxWidth: 300)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func colorPickerRow(title: String, selection: Binding<Color>) -> some View {
        ColorPicker(selection: selection, supportsOpacity: false) {
            Text(title)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity)
    }

    private func beginPress(for playerIndex: Int, lifeChange: Int) {
        let control = PressedControl(playerIndex: playerIndex, lifeChange: lifeChange)

        guard pressedControl != control else {
            return
        }

        repeatTimer?.invalidate()
        repeatTimer = nil
        pressedControl = control
        holdStartDate = Date()
    }

    private func finishPress(for playerIndex: Int, lifeChange: Int) {
        let control = PressedControl(playerIndex: playerIndex, lifeChange: lifeChange)
        let shouldApplySingleTap = pressedControl == control && repeatTimer == nil

        if shouldApplySingleTap {
            handleTap(for: playerIndex, lifeChange: lifeChange)
        }

        stopRepeatingChange()
    }

    private func startRepeatingChange(for playerIndex: Int, lifeChange: Int) {
        guard !isEditingBoxes else {
            return
        }

        let control = PressedControl(playerIndex: playerIndex, lifeChange: lifeChange)
        guard pressedControl == control else {
            return
        }

        repeatTimer?.invalidate()
        handleTap(for: playerIndex, lifeChange: lifeChange)

        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { _ in
            guard pressedControl == control else {
                stopRepeatingChange()
                return
            }

            let multiplier = holdIncrementMultiplier()
            handleTap(for: playerIndex, lifeChange: lifeChange * multiplier)
        }
    }

    private func handleTap(for playerIndex: Int, lifeChange: Int) {
        if isEditingBoxes {
            stopRepeatingChange()
            selectedPlayerIndex = playerIndex
            return
        }

        guard playerLives.indices.contains(playerIndex) else {
            return
        }

        playerLives[playerIndex] += lifeChange
    }

    private func stopRepeatingChange() {
        repeatTimer?.invalidate()
        repeatTimer = nil
        pressedControl = nil
        holdStartDate = nil
    }

    private func holdIncrementMultiplier() -> Int {
        guard let holdStartDate else {
            return 1
        }

        let holdDuration = Date().timeIntervalSince(holdStartDate)

        if holdDuration >= 15 {
            return 100
        }

        if holdDuration >= 5 {
            return 10
        }

        return 1
    }

    private var playerDividerOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.42))
                    .frame(width: 8, height: geometry.size.height / 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 4)

                Rectangle()
                    .fill(Color.black.opacity(0.42))
                    .frame(height: 8)
                    .frame(maxWidth: .infinity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                Rectangle()
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 2)
                    .ignoresSafeArea()
            }
            .shadow(color: .black.opacity(0.25), radius: 4)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var playerSelectionOverlay: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                selectionCell(for: 0)
                selectionCell(for: 1)
            }

            selectionCell(for: 2)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func selectionCell(for playerIndex: Int) -> some View {
        Rectangle()
            .fill(Color.clear)
            .overlay {
                if selectedPlayerIndex == playerIndex {
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.white, lineWidth: 6)
                        .padding(12)
                }
            }
    }

    private var lotusMenuButton: some View {
        Button {
            stopRepeatingChange()
            onInGameMenu()
        } label: {
            Image("LotusSymbol")
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.black.opacity(0.2), lineWidth: 1)
                }
        }
        .shadow(radius: 4)
    }
}

struct ThreePlayer_Previews: PreviewProvider {
    static var previews: some View {
        ThreePlayer(
            playerLives: .constant([40, 40, 40]),
            playerStyles: .constant([
                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black)
            ]),
            playerNames: .constant(["Player 1", "Player 2", "Player 3"]),
            isEditingBoxes: .constant(false)
        ) {
            // Example preview behavior for onInGameMenu
        }
    }
}
