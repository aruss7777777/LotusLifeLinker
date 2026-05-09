import SwiftUI
import PhotosUI
import UIKit

struct PlayerBoxStyle: Equatable {
    var backgroundColor: Color
    var fontColor: Color
    var isTextOutlined: Bool = false
    var backgroundImageData: Data? = nil
    var backgroundImageScale: CGFloat = 1
    var backgroundImageOffset: CGSize = .zero
}

extension Color {
    var inverseColor: Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return .white
        }

        return Color(red: 1 - red, green: 1 - green, blue: 1 - blue, opacity: alpha)
    }
}

struct OutlinedPlayerText: View {
    let text: String
    let font: Font
    let color: Color
    let isOutlined: Bool
    var minimumScaleFactor: CGFloat
    var usesMonospacedDigits: Bool = false

    private let outlineOffsets: [CGSize] = [
        CGSize(width: -2, height: -2),
        CGSize(width: 0, height: -2),
        CGSize(width: 2, height: -2),
        CGSize(width: -2, height: 0),
        CGSize(width: 2, height: 0),
        CGSize(width: -2, height: 2),
        CGSize(width: 0, height: 2),
        CGSize(width: 2, height: 2)
    ]

    var body: some View {
        ZStack {
            if isOutlined {
                ForEach(outlineOffsets.indices, id: \.self) { index in
                    formattedText
                        .foregroundStyle(color.inverseColor)
                        .offset(x: outlineOffsets[index].width, y: outlineOffsets[index].height)
                }
            }

            formattedText
                .foregroundStyle(color)
        }
        .lineLimit(1)
        .minimumScaleFactor(minimumScaleFactor)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var formattedText: Text {
        if usesMonospacedDigits {
            return Text(text)
                .font(font)
                .monospacedDigit()
        }

        return Text(text)
            .font(font)
    }
}

struct PlayerBackgroundView: View {
    let style: PlayerBoxStyle
    var imageRotation: Angle = .degrees(0)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                style.backgroundColor

                if let backgroundImageData = style.backgroundImageData,
                   let uiImage = UIImage(data: backgroundImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: imageFrameSize(for: geometry.size).width,
                            height: imageFrameSize(for: geometry.size).height
                        )
                        .rotationEffect(imageRotation)
                        .scaleEffect(max(style.backgroundImageScale, 1))
                        .offset(style.backgroundImageOffset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .overlay(style.backgroundColor.opacity(0.12))
                }
            }
            .clipped()
        }
    }

    private func imageFrameSize(for containerSize: CGSize) -> CGSize {
        guard isSidewaysRotation else {
            return containerSize
        }

        return CGSize(width: containerSize.height, height: containerSize.width)
    }

    private var isSidewaysRotation: Bool {
        let normalizedDegrees = abs(imageRotation.degrees.truncatingRemainder(dividingBy: 180))
        return abs(normalizedDegrees - 90) < 0.1
    }
}

struct PlayerCustomizationPanel: View {
    @Binding var playerStyles: [PlayerBoxStyle]
    @Binding var playerNames: [String]
    @Binding var isEditingBoxes: Bool
    let selectedPlayerIndex: Int
    @State private var selectedBackgroundPhoto: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 8) {
            Text("Edit Player \(selectedPlayerIndex + 1)")
                .font(.headline)

            Text("Tap a player box to select it")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView {
                VStack(spacing: 8) {
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
                        playerStyles[selectedPlayerIndex].isTextOutlined.toggle()
                    } label: {
                        HStack {
                            Image(systemName: playerStyles[selectedPlayerIndex].isTextOutlined ? "checkmark.square.fill" : "square")

                            Text("Outline Text")

                            Spacer()
                        }
                        .foregroundStyle(.black)
                        .contentShape(Rectangle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    PhotosPicker(selection: $selectedBackgroundPhoto, matching: .images) {
                        Text("Choose Background Image")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                    }
                    .background(Color.white.opacity(0.12))
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: selectedBackgroundPhoto) { _, newItem in
                        Task {
                            await importBackgroundImage(from: newItem)
                        }
                    }

                    if playerStyles[selectedPlayerIndex].backgroundImageData != nil {
                        imageAdjustmentSlider(
                            title: "Image Zoom",
                            value: Binding(
                                get: { Double(playerStyles[selectedPlayerIndex].backgroundImageScale) },
                                set: { playerStyles[selectedPlayerIndex].backgroundImageScale = CGFloat($0) }
                            ),
                            range: 1...3
                        )

                        imageAdjustmentSlider(
                            title: "Move Left / Right",
                            value: Binding(
                                get: { Double(playerStyles[selectedPlayerIndex].backgroundImageOffset.width) },
                                set: { playerStyles[selectedPlayerIndex].backgroundImageOffset.width = CGFloat($0) }
                            ),
                            range: -200...200
                        )

                        imageAdjustmentSlider(
                            title: "Move Up / Down",
                            value: Binding(
                                get: { Double(playerStyles[selectedPlayerIndex].backgroundImageOffset.height) },
                                set: { playerStyles[selectedPlayerIndex].backgroundImageOffset.height = CGFloat($0) }
                            ),
                            range: -200...200
                        )

                        Button {
                            playerStyles[selectedPlayerIndex].backgroundImageScale = 1
                            playerStyles[selectedPlayerIndex].backgroundImageOffset = .zero
                        } label: {
                            Text("Reset Image Fit")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .background(Color.white.opacity(0.12))
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button {
                            playerStyles[selectedPlayerIndex].backgroundImageData = nil
                            playerStyles[selectedPlayerIndex].backgroundImageScale = 1
                            playerStyles[selectedPlayerIndex].backgroundImageOffset = .zero
                        } label: {
                            Text("Remove Background Image")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .background(Color.white.opacity(0.12))
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.vertical, 2)
                .padding(.trailing, 2)
            }
            .frame(maxHeight: 198)

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
        .frame(width: 300, height: 340)
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

    private func imageAdjustmentSlider(title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.black)

            Slider(value: value, in: range)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func importBackgroundImage(from item: PhotosPickerItem?) async {
        guard playerStyles.indices.contains(selectedPlayerIndex),
              let item,
              let imageData = try? await item.loadTransferable(type: Data.self) else {
            return
        }

        await MainActor.run {
            playerStyles[selectedPlayerIndex].backgroundImageData = imageData
            playerStyles[selectedPlayerIndex].backgroundImageScale = 1
            playerStyles[selectedPlayerIndex].backgroundImageOffset = .zero
            selectedBackgroundPhoto = nil
        }
    }
}

struct ContentView: View {
    @State private var activeView: String = "MainMenu"
    @State private var previousView: String = "MainMenu"
    @State private var onePlayerStyles: [PlayerBoxStyle] = [
        PlayerBoxStyle(backgroundColor: .blue, fontColor: .white)
    ]
    @State private var onePlayerNames: [String] = ["Player 1"]
    @State private var onePlayerLives: [Int] = [40]
    @State private var isEditingOnePlayerBoxes: Bool = false
    @State private var twoPlayerStyles: [PlayerBoxStyle] = [
        PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .green, fontColor: .white)
    ]
    @State private var twoPlayerNames: [String] = ["Player 1", "Player 2"]
    @State private var twoPlayerLives: [Int] = [40, 40]
    @State private var isEditingTwoPlayerBoxes: Bool = false
    @State private var threePlayerStyles: [PlayerBoxStyle] = [
        PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black)
    ]
    @State private var threePlayerNames: [String] = ["Player 1", "Player 2", "Player 3"]
    @State private var threePlayerLives: [Int] = [40, 40, 40]
    @State private var isEditingThreePlayerBoxes: Bool = false
    @State private var fourPlayerStyles: [PlayerBoxStyle] = [
        PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .orange, fontColor: .black)
    ]
    @State private var fourPlayerNames: [String] = [
        "Player 1",
        "Player 2",
        "Player 3",
        "Player 4"
    ]
    @State private var fourPlayerLives: [Int] = [40, 40, 40, 40]
    @State private var isEditingFourPlayerBoxes: Bool = false
    @State private var fivePlayerStyles: [PlayerBoxStyle] = [
        PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .pink, fontColor: .black)
    ]
    @State private var fivePlayerNames: [String] = [
        "Player 1",
        "Player 2",
        "Player 3",
        "Player 4",
        "Player 5"
    ]
    @State private var fivePlayerLives: [Int] = [40, 40, 40, 40, 40]
    @State private var isEditingFivePlayerBoxes: Bool = false
    @State private var sixPlayerStyles: [PlayerBoxStyle] = [
        PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .pink, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .purple, fontColor: .white)
    ]
    @State private var sixPlayerNames: [String] = [
        "Player 1",
        "Player 2",
        "Player 3",
        "Player 4",
        "Player 5",
        "Player 6"
    ]
    @State private var sixPlayerLives: [Int] = [40, 40, 40, 40, 40, 40]
    @State private var isEditingSixPlayerBoxes: Bool = false
    @State private var eightPlayerStyles: [PlayerBoxStyle] = [
        PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .pink, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .purple, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .white, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .gray, fontColor: .white)
    ]
    @State private var eightPlayerNames: [String] = [
        "Player 1",
        "Player 2",
        "Player 3",
        "Player 4",
        "Player 5",
        "Player 6",
        "Player 7",
        "Player 8"
    ]
    @State private var eightPlayerLives: [Int] = [40, 40, 40, 40, 40, 40, 40, 40]
    @State private var isEditingEightPlayerBoxes: Bool = false
    @State private var keepScreenAwake: Bool = true
    
    private var displayedView: String {
        activeView == "InGameMenu" ? previousView : activeView
    }

    var body: some View {
        ZStack {
            if displayedView == "MainMenu" {
                MainMenu { selectedView in
                    activeView = selectedView
                }
            } else if displayedView == "OnePlayer" {
                OnePlayer(
                    playerLives: $onePlayerLives,
                    playerStyles: $onePlayerStyles,
                    playerNames: $onePlayerNames,
                    isEditingBoxes: $isEditingOnePlayerBoxes,
                    onInGameMenu: {
                        previousView = "OnePlayer"
                        activeView = "InGameMenu"
                    }
                )
            } else if displayedView == "TwoPlayer" {
                TwoPlayer(
                    playerLives: $twoPlayerLives,
                    playerStyles: $twoPlayerStyles,
                    playerNames: $twoPlayerNames,
                    isEditingBoxes: $isEditingTwoPlayerBoxes,
                    onInGameMenu: {
                        previousView = "TwoPlayer"
                        activeView = "InGameMenu"
                    }
                )
            } else if displayedView == "ThreePlayer" {
                ThreePlayer(
                    playerLives: $threePlayerLives,
                    playerStyles: $threePlayerStyles,
                    playerNames: $threePlayerNames,
                    isEditingBoxes: $isEditingThreePlayerBoxes,
                    onInGameMenu: {
                        previousView = "ThreePlayer"
                        activeView = "InGameMenu"
                    }
                )
            } else if displayedView == "FourPlayer" {
                FourPlayer(
                    playerLives: $fourPlayerLives,
                    playerStyles: $fourPlayerStyles,
                    playerNames: $fourPlayerNames,
                    isEditingBoxes: $isEditingFourPlayerBoxes,
                    onInGameMenu: {
                        previousView = "FourPlayer"
                        activeView = "InGameMenu"
                    }
                )
            } else if displayedView == "FivePlayer" {
                FivePlayer(
                    playerLives: $fivePlayerLives,
                    playerStyles: $fivePlayerStyles,
                    playerNames: $fivePlayerNames,
                    isEditingBoxes: $isEditingFivePlayerBoxes,
                    onInGameMenu: {
                        previousView = "FivePlayer"
                        activeView = "InGameMenu"
                    }
                )
            } else if displayedView == "SixPlayer" {
                SixPlayer(
                    playerLives: $sixPlayerLives,
                    playerStyles: $sixPlayerStyles,
                    playerNames: $sixPlayerNames,
                    isEditingBoxes: $isEditingSixPlayerBoxes,
                    onInGameMenu: {
                        previousView = "SixPlayer"
                        activeView = "InGameMenu"
                    }
                )
            } else if displayedView == "EightPlayer" {
                EightPlayer(
                    playerLives: $eightPlayerLives,
                    playerStyles: $eightPlayerStyles,
                    playerNames: $eightPlayerNames,
                    isEditingBoxes: $isEditingEightPlayerBoxes,
                    onInGameMenu: {
                        previousView = "EightPlayer"
                        activeView = "InGameMenu"
                    }
                )
            }

            if activeView == "InGameMenu" {
                InGameMenu(
                    onBackToMenu: {
                        activeView = previousView // Return to the previous view
                    },
                    onNavigateToMainMenu: {
                        if previousView == "OnePlayer" {
                            onePlayerLives = [40]
                            onePlayerStyles = [
                                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white)
                            ]
                            onePlayerNames = ["Player 1"]
                        } else if previousView == "TwoPlayer" {
                            twoPlayerLives = [40, 40]
                            twoPlayerStyles = [
                                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .green, fontColor: .white)
                            ]
                            twoPlayerNames = ["Player 1", "Player 2"]
                        } else if previousView == "ThreePlayer" {
                            threePlayerLives = [40, 40, 40]
                            threePlayerStyles = [
                                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black)
                            ]
                            threePlayerNames = ["Player 1", "Player 2", "Player 3"]
                        } else if previousView == "FourPlayer" {
                            fourPlayerLives = [40, 40, 40, 40]
                            fourPlayerStyles = [
                                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .orange, fontColor: .black)
                            ]
                            fourPlayerNames = [
                                "Player 1",
                                "Player 2",
                                "Player 3",
                                "Player 4"
                            ]
                        } else if previousView == "FivePlayer" {
                            fivePlayerLives = [40, 40, 40, 40, 40]
                            fivePlayerStyles = [
                                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .pink, fontColor: .black)
                            ]
                            fivePlayerNames = [
                                "Player 1",
                                "Player 2",
                                "Player 3",
                                "Player 4",
                                "Player 5"
                            ]
                        } else if previousView == "SixPlayer" {
                            sixPlayerLives = [40, 40, 40, 40, 40, 40]
                            sixPlayerStyles = [
                                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .pink, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .purple, fontColor: .white)
                            ]
                            sixPlayerNames = [
                                "Player 1",
                                "Player 2",
                                "Player 3",
                                "Player 4",
                                "Player 5",
                                "Player 6"
                            ]
                        } else if previousView == "EightPlayer" {
                            eightPlayerLives = [40, 40, 40, 40, 40, 40, 40, 40]
                            eightPlayerStyles = [
                                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .pink, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .purple, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .white, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .gray, fontColor: .white)
                            ]
                            eightPlayerNames = [
                                "Player 1",
                                "Player 2",
                                "Player 3",
                                "Player 4",
                                "Player 5",
                                "Player 6",
                                "Player 7",
                                "Player 8"
                            ]
                        }
                        activeView = "MainMenu" // Navigate to the Main Menu
		                    },
                    onResetGame: {
                        // Reset action. Since TwoPlayer manages its own state,
                        // this closure will be passed from TwoPlayer.
                    },
                    canEditPlayerBoxes: previousView != "MainMenu",
                    onStartEditingPlayerBoxes: {
                        if previousView == "OnePlayer" {
                            isEditingOnePlayerBoxes = true
                        } else if previousView == "TwoPlayer" {
                            isEditingTwoPlayerBoxes = true
                        } else if previousView == "ThreePlayer" {
                            isEditingThreePlayerBoxes = true
                        } else if previousView == "FourPlayer" {
                            isEditingFourPlayerBoxes = true
                        } else if previousView == "FivePlayer" {
                            isEditingFivePlayerBoxes = true
                        } else if previousView == "SixPlayer" {
                            isEditingSixPlayerBoxes = true
                        } else if previousView == "EightPlayer" {
                            isEditingEightPlayerBoxes = true
                        }
                        activeView = previousView
                    },
                    keepScreenAwake: $keepScreenAwake
                )
            }
        }
        .statusBarHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = keepScreenAwake
        }
        .onChange(of: keepScreenAwake) { _, newValue in
            UIApplication.shared.isIdleTimerDisabled = newValue
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
