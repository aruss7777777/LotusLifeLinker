import SwiftUI

struct TwoPlayer: View {
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
                VStack(spacing: 0) {
                    verticalPlayerControl(for: 0, topChange: -1, bottomChange: 1)
                    verticalPlayerControl(for: 1, topChange: 1, bottomChange: -1)
                }

                VStack(spacing: 0) {
                    playerInfoCell(for: 0, rotation: .degrees(180))
                    playerInfoCell(for: 1, rotation: .degrees(0))
                }

                playerDividerOverlay

                if isEditingBoxes {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    playerSelectionOverlay
                    customizePanel
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
            .fill(playerStyles[playerIndex].backgroundColor)
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
            rotation: rotation
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func playerInfoView(name: String, life: Int, color: Color, rotation: Angle) -> some View {
        VStack(spacing: 8) {
            Text("\(life)")
                .font(.system(size: 110, weight: .regular, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

            Text(name)
                .font(.system(size: 26, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
        .allowsHitTesting(false)
        .foregroundStyle(color)
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
            selectionCell(for: 0)
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

struct TwoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        TwoPlayer(
            playerLives: .constant([40, 40]),
            playerStyles: .constant([
                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .green, fontColor: .white)
            ]),
            playerNames: .constant(["Player 1", "Player 2"]),
            isEditingBoxes: .constant(false)
        ) {
            // Example preview behavior for onInGameMenu
        }
    }
}
