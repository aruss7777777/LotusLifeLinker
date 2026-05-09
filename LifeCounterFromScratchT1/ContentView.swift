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

// MARK: - Save/Load Models

struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(_ color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

struct SavedPlayerStyle: Codable {
    var backgroundColor: CodableColor
    var fontColor: CodableColor
    var isTextOutlined: Bool
    var backgroundImageData: Data?
    var backgroundImageScale: Double
    var backgroundImageOffsetWidth: Double
    var backgroundImageOffsetHeight: Double

    init(from style: PlayerBoxStyle) {
        self.backgroundColor = CodableColor(style.backgroundColor)
        self.fontColor = CodableColor(style.fontColor)
        self.isTextOutlined = style.isTextOutlined
        self.backgroundImageData = style.backgroundImageData
        self.backgroundImageScale = Double(style.backgroundImageScale)
        self.backgroundImageOffsetWidth = Double(style.backgroundImageOffset.width)
        self.backgroundImageOffsetHeight = Double(style.backgroundImageOffset.height)
    }

    var toPlayerBoxStyle: PlayerBoxStyle {
        PlayerBoxStyle(
            backgroundColor: backgroundColor.color,
            fontColor: fontColor.color,
            isTextOutlined: isTextOutlined,
            backgroundImageData: backgroundImageData,
            backgroundImageScale: CGFloat(backgroundImageScale),
            backgroundImageOffset: CGSize(width: backgroundImageOffsetWidth, height: backgroundImageOffsetHeight)
        )
    }
}

struct SavedGame: Codable, Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let viewName: String
    let playerLives: [Int]
    let playerNames: [String]
    let playerStyles: [SavedPlayerStyle]
}

struct GameSaveManager {
    private static var saveFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("savedGames.json")
    }

    static func loadAll() -> [SavedGame] {
        guard let data = try? Data(contentsOf: saveFileURL),
              let games = try? JSONDecoder().decode([SavedGame].self, from: data) else {
            return []
        }
        return games.sorted { $0.date > $1.date }
    }

    static func save(_ game: SavedGame) {
        var games = loadAll()
        games.insert(game, at: 0)
        writeAll(games)
    }

    static func delete(_ id: UUID) {
        var games = loadAll()
        games.removeAll { $0.id == id }
        writeAll(games)
    }

    private static func writeAll(_ games: [SavedGame]) {
        guard let data = try? JSONEncoder().encode(games) else { return }
        try? data.write(to: saveFileURL)
    }
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
    @State private var sevenPlayerStyles: [PlayerBoxStyle] = [
        PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .pink, fontColor: .black),
        PlayerBoxStyle(backgroundColor: .purple, fontColor: .white),
        PlayerBoxStyle(backgroundColor: .white, fontColor: .black)
    ]
    @State private var sevenPlayerNames: [String] = [
        "Player 1",
        "Player 2",
        "Player 3",
        "Player 4",
        "Player 5",
        "Player 6",
        "Player 7"
    ]
    @State private var sevenPlayerLives: [Int] = [40, 40, 40, 40, 40, 40, 40]
    @State private var isEditingSevenPlayerBoxes: Bool = false
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
    @State private var savedGames: [SavedGame] = []
    
    private var displayedView: String {
        activeView == "InGameMenu" ? previousView : activeView
    }

    var body: some View {
        ZStack {
            if displayedView == "MainMenu" {
                MainMenu(
                    onMenuSelection: { selectedView in
                        activeView = selectedView
                    },
                    savedGames: savedGames,
                    onLoadGame: { game in
                        loadGame(game)
                    },
                    onDeleteGame: { id in
                        GameSaveManager.delete(id)
                        savedGames = GameSaveManager.loadAll()
                    }
                )
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
            } else if displayedView == "ThreePlayerSplit" {
                ThreePlayerSplit(
                    playerLives: $threePlayerLives,
                    playerStyles: $threePlayerStyles,
                    playerNames: $threePlayerNames,
                    isEditingBoxes: $isEditingThreePlayerBoxes,
                    onInGameMenu: {
                        previousView = "ThreePlayerSplit"
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
            } else if displayedView == "FivePlayerSplit" {
                FivePlayerSplit(
                    playerLives: $fivePlayerLives,
                    playerStyles: $fivePlayerStyles,
                    playerNames: $fivePlayerNames,
                    isEditingBoxes: $isEditingFivePlayerBoxes,
                    onInGameMenu: {
                        previousView = "FivePlayerSplit"
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
            } else if displayedView == "SevenPlayer" {
                SevenPlayer(
                    playerLives: $sevenPlayerLives,
                    playerStyles: $sevenPlayerStyles,
                    playerNames: $sevenPlayerNames,
                    isEditingBoxes: $isEditingSevenPlayerBoxes,
                    onInGameMenu: {
                        previousView = "SevenPlayer"
                        activeView = "InGameMenu"
                    }
                )
            } else if displayedView == "SevenPlayerSplit" {
                SevenPlayerSplit(
                    playerLives: $sevenPlayerLives,
                    playerStyles: $sevenPlayerStyles,
                    playerNames: $sevenPlayerNames,
                    isEditingBoxes: $isEditingSevenPlayerBoxes,
                    onInGameMenu: {
                        previousView = "SevenPlayerSplit"
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
                        } else if previousView == "ThreePlayer" || previousView == "ThreePlayerSplit" {
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
                        } else if previousView == "FivePlayer" || previousView == "FivePlayerSplit" {
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
                        } else if previousView == "SevenPlayer" || previousView == "SevenPlayerSplit" {
                            sevenPlayerLives = [40, 40, 40, 40, 40, 40, 40]
                            sevenPlayerStyles = [
                                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .orange, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .pink, fontColor: .black),
                                PlayerBoxStyle(backgroundColor: .purple, fontColor: .white),
                                PlayerBoxStyle(backgroundColor: .white, fontColor: .black)
                            ]
                            sevenPlayerNames = [
                                "Player 1",
                                "Player 2",
                                "Player 3",
                                "Player 4",
                                "Player 5",
                                "Player 6",
                                "Player 7"
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
                        } else if previousView == "ThreePlayer" || previousView == "ThreePlayerSplit" {
                            isEditingThreePlayerBoxes = true
                        } else if previousView == "FourPlayer" {
                            isEditingFourPlayerBoxes = true
                        } else if previousView == "FivePlayer" || previousView == "FivePlayerSplit" {
                            isEditingFivePlayerBoxes = true
                        } else if previousView == "SixPlayer" {
                            isEditingSixPlayerBoxes = true
                        } else if previousView == "SevenPlayer" || previousView == "SevenPlayerSplit" {
                            isEditingSevenPlayerBoxes = true
                        } else if previousView == "EightPlayer" {
                            isEditingEightPlayerBoxes = true
                        }
                        activeView = previousView
                    },
                    onSaveGame: { name in
                        saveCurrentGame(name: name)
                    },
                    keepScreenAwake: $keepScreenAwake
                )
            }
        }
        .statusBarHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = keepScreenAwake
            savedGames = GameSaveManager.loadAll()
        }
        .onChange(of: keepScreenAwake) { _, newValue in
            UIApplication.shared.isIdleTimerDisabled = newValue
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    private func currentLives() -> [Int] {
        switch previousView {
        case "OnePlayer": return onePlayerLives
        case "TwoPlayer": return twoPlayerLives
        case "ThreePlayer", "ThreePlayerSplit": return threePlayerLives
        case "FourPlayer": return fourPlayerLives
        case "FivePlayer", "FivePlayerSplit": return fivePlayerLives
        case "SixPlayer": return sixPlayerLives
        case "SevenPlayer", "SevenPlayerSplit": return sevenPlayerLives
        case "EightPlayer": return eightPlayerLives
        default: return []
        }
    }

    private func currentNames() -> [String] {
        switch previousView {
        case "OnePlayer": return onePlayerNames
        case "TwoPlayer": return twoPlayerNames
        case "ThreePlayer", "ThreePlayerSplit": return threePlayerNames
        case "FourPlayer": return fourPlayerNames
        case "FivePlayer", "FivePlayerSplit": return fivePlayerNames
        case "SixPlayer": return sixPlayerNames
        case "SevenPlayer", "SevenPlayerSplit": return sevenPlayerNames
        case "EightPlayer": return eightPlayerNames
        default: return []
        }
    }

    private func currentStyles() -> [PlayerBoxStyle] {
        switch previousView {
        case "OnePlayer": return onePlayerStyles
        case "TwoPlayer": return twoPlayerStyles
        case "ThreePlayer", "ThreePlayerSplit": return threePlayerStyles
        case "FourPlayer": return fourPlayerStyles
        case "FivePlayer", "FivePlayerSplit": return fivePlayerStyles
        case "SixPlayer": return sixPlayerStyles
        case "SevenPlayer", "SevenPlayerSplit": return sevenPlayerStyles
        case "EightPlayer": return eightPlayerStyles
        default: return []
        }
    }

    private func saveCurrentGame(name: String) {
        let game = SavedGame(
            id: UUID(),
            name: name,
            date: Date(),
            viewName: previousView,
            playerLives: currentLives(),
            playerNames: currentNames(),
            playerStyles: currentStyles().map { SavedPlayerStyle(from: $0) }
        )
        GameSaveManager.save(game)
        savedGames = GameSaveManager.loadAll()
    }

    private func loadGame(_ game: SavedGame) {
        let styles = game.playerStyles.map { $0.toPlayerBoxStyle }
        let viewName = game.viewName

        switch viewName {
        case "OnePlayer":
            onePlayerLives = game.playerLives
            onePlayerNames = game.playerNames
            onePlayerStyles = styles
        case "TwoPlayer":
            twoPlayerLives = game.playerLives
            twoPlayerNames = game.playerNames
            twoPlayerStyles = styles
        case "ThreePlayer", "ThreePlayerSplit":
            threePlayerLives = game.playerLives
            threePlayerNames = game.playerNames
            threePlayerStyles = styles
        case "FourPlayer":
            fourPlayerLives = game.playerLives
            fourPlayerNames = game.playerNames
            fourPlayerStyles = styles
        case "FivePlayer", "FivePlayerSplit":
            fivePlayerLives = game.playerLives
            fivePlayerNames = game.playerNames
            fivePlayerStyles = styles
        case "SixPlayer":
            sixPlayerLives = game.playerLives
            sixPlayerNames = game.playerNames
            sixPlayerStyles = styles
        case "SevenPlayer", "SevenPlayerSplit":
            sevenPlayerLives = game.playerLives
            sevenPlayerNames = game.playerNames
            sevenPlayerStyles = styles
        case "EightPlayer":
            eightPlayerLives = game.playerLives
            eightPlayerNames = game.playerNames
            eightPlayerStyles = styles
        default:
            break
        }

        activeView = viewName
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
