import SwiftUI

struct PlayerBoxStyle: Equatable {
    var backgroundColor: Color
    var fontColor: Color
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
                    }
                )
            }
        }
        .statusBarHidden(true)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
