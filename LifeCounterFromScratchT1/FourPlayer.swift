import SwiftUI

struct FourPlayer: View {
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
    var onInGameMenu: () -> Void  // Closure to handle back navigation

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0){
                    HStack(spacing: 0) {
                        lifeControlArea(for: 0, lifeChange: -1)
                        
                        lifeControlArea(for: 0, lifeChange: 1)
                        
                        lifeControlArea(for: 1, lifeChange: 1)
                        
                        lifeControlArea(for: 1, lifeChange: -1)
                    }
                    HStack(spacing: 0){
                        
                        lifeControlArea(for: 2, lifeChange: -1)
                        
                        lifeControlArea(for: 2, lifeChange: 1)
                        lifeControlArea(for: 3, lifeChange: 1)
                        
                        lifeControlArea(for: 3, lifeChange: -1)
                        
                    }
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
                        onInGameMenu() // Show InGameMenu when "+" is tapped
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

    private func backgroundRotation(for playerIndex: Int) -> Angle {
        playerIndex.isMultiple(of: 2) ? .degrees(90) : .degrees(270)
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
                font: .system(size: 75, weight: .regular, design: .rounded),
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

        switch playerIndex {
        case 0...3:
            playerLives[playerIndex] += lifeChange
        default:
            break
        }
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
                selectionQuadrant(for: 0)
                selectionQuadrant(for: 1)
            }

            HStack(spacing: 0) {
                selectionQuadrant(for: 2)
                selectionQuadrant(for: 3)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func selectionQuadrant(for playerIndex: Int) -> some View {
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

struct FourPlayer_Previews: PreviewProvider {
    static var previews: some View {
        FourPlayer(
            playerLives: .constant([40, 40, 40, 40]),
            playerStyles: .constant([
                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
                PlayerBoxStyle(backgroundColor: .orange, fontColor: .black)
            ]),
            playerNames: .constant([
                "Player 1",
                "Player 2",
                "Player 3",
                "Player 4"
            ]),
            isEditingBoxes: .constant(false)
        ) {
            // Example preview behavior for onInGameMenu
        }
    }
}
