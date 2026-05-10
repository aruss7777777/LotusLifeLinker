import SwiftUI

struct ThreePlayerSplit: View {
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

    var body: some View {
        GeometryReader { _ in
            ZStack {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        verticalPlayerControl(for: 0, topChange: 1, bottomChange: -1)
                        verticalPlayerControl(for: 2, topChange: 1, bottomChange: -1)
                    }

                    verticalPlayerControl(for: 1, topChange: 1, bottomChange: -1)
                }

                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        playerInfoCell(for: 0, rotation: .degrees(90))
                        playerInfoCell(for: 2, rotation: .degrees(90))
                    }

                    playerInfoCell(for: 1, rotation: .degrees(270))
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

    private func verticalPlayerControl(for playerIndex: Int, topChange: Int, bottomChange: Int) -> some View {
        VStack(spacing: 0) {
            lifeControlArea(for: playerIndex, lifeChange: topChange)
            lifeControlArea(for: playerIndex, lifeChange: bottomChange)
        }
    }

    private func lifeControlArea(for playerIndex: Int, lifeChange: Int) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        beginInteraction(for: playerIndex, lifeChange: lifeChange)
                    }
                    .onEnded { _ in
                        stopRepeatingChange()
                    }
            )
    }

    private func playerInfoCell(for playerIndex: Int, rotation: Angle) -> some View {
        playerInfoView(
            name: playerNames[playerIndex],
            life: playerLives[playerIndex],
            color: playerStyles[playerIndex].fontColor,
            isOutlined: playerStyles[playerIndex].isTextOutlined,
            rotation: rotation
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PlayerBackgroundView(style: playerStyles[playerIndex], imageRotation: rotation))
        .allowsHitTesting(false)
    }

    private func playerInfoView(name: String, life: Int, color: Color, isOutlined: Bool, rotation: Angle) -> some View {
        VStack(spacing: 8) {
            OutlinedPlayerText(
                text: "\(life)",
                font: .system(size: 84, weight: .regular, design: .rounded),
                color: color,
                isOutlined: isOutlined,
                minimumScaleFactor: 0.45,
                usesMonospacedDigits: true
            )

            OutlinedPlayerText(
                text: name,
                font: .system(size: 24, weight: .semibold),
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

    private func beginInteraction(for playerIndex: Int, lifeChange: Int) {
        let control = PressedControl(playerIndex: playerIndex, lifeChange: lifeChange)

        if pressedControl == control {
            return
        }

        pressedControl = control
        holdStartDate = Date()
        handleTap(for: playerIndex, lifeChange: lifeChange)

        guard !isEditingBoxes else {
            return
        }

        repeatTimer?.invalidate()
        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { _ in
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
                    .frame(width: geometry.size.width / 2, height: 8)
                    .position(x: geometry.size.width / 4, y: geometry.size.height / 2)

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
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                selectionCell(for: 0)
                selectionCell(for: 2)
            }

            selectionCell(for: 1)
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
