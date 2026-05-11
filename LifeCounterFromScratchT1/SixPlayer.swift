import SwiftUI

struct SixPlayer: View {
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
                    playerRow(leftPlayer: 0, rightPlayer: 1)
                    playerRow(leftPlayer: 2, rightPlayer: 3)
                    playerRow(leftPlayer: 4, rightPlayer: 5)
                }

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        playerInfoCell(for: 0, rotation: .degrees(90))
                        playerInfoCell(for: 1, rotation: .degrees(270))
                    }

                    HStack(spacing: 0) {
                        playerInfoCell(for: 2, rotation: .degrees(90))
                        playerInfoCell(for: 3, rotation: .degrees(270))
                    }

                    HStack(spacing: 0) {
                        playerInfoCell(for: 4, rotation: .degrees(90))
                        playerInfoCell(for: 5, rotation: .degrees(270))
                    }
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
            .ignoresSafeArea()
        }
        .onDisappear {
            stopRepeatingChange()
        }
    }

    private func playerRow(leftPlayer: Int, rightPlayer: Int) -> some View {
        HStack(spacing: 0) {
            horizontalPlayerControl(for: leftPlayer, leftChange: -1, rightChange: 1)
            horizontalPlayerControl(for: rightPlayer, leftChange: 1, rightChange: -1)
        }
    }

    private func horizontalPlayerControl(
        for playerIndex: Int,
        leftChange: Int,
        rightChange: Int
    ) -> some View {
        HStack(spacing: 0) {
            lifeControlArea(for: playerIndex, lifeChange: leftChange)
            lifeControlArea(for: playerIndex, lifeChange: rightChange)
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
        playerIndex.isMultiple(of: 2) ? .degrees(90) : .degrees(270)
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

    private func playerInfoView(
        name: String,
        life: Int,
        color: Color,
        isOutlined: Bool,
        rotation: Angle
    ) -> some View {
        VStack(spacing: 8) {
            OutlinedPlayerText(
                text: "\(life)",
                font: PlayerTextSizing.lifeFont(baseSize: 75),
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
                    .frame(width: 8)
                    .frame(maxHeight: .infinity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                Rectangle()
                    .fill(Color.black.opacity(0.42))
                    .frame(height: 8)
                    .frame(maxWidth: .infinity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 3)

                Rectangle()
                    .fill(Color.black.opacity(0.42))
                    .frame(height: 8)
                    .frame(maxWidth: .infinity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 2 / 3)

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

            HStack(spacing: 0) {
                selectionCell(for: 2)
                selectionCell(for: 3)
            }

            HStack(spacing: 0) {
                selectionCell(for: 4)
                selectionCell(for: 5)
            }
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
}

struct SixPlayer_Previews: PreviewProvider {
    static var previews: some View {
        SixPlayer(
            playerLives: .constant([40, 40, 40, 40, 40, 40]),
            playerStyles: .constant([
                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
                PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
                PlayerBoxStyle(backgroundColor: .pink, fontColor: .black),
                PlayerBoxStyle(backgroundColor: .purple, fontColor: .white)
            ]),
            playerNames: .constant([
                "Player 1",
                "Player 2",
                "Player 3",
                "Player 4",
                "Player 5",
                "Player 6"
            ]),
            isEditingBoxes: .constant(false)
        ) {
            // Example preview behavior for onInGameMenu
        }
    }
}
