import SwiftUI

struct PlayerBoxStyle: Equatable {
    var backgroundColor: Color
    var fontColor: Color
}

struct ContentView: View {
    @State private var activeView: String = "MainMenu"
    @State private var previousView: String = "MainMenu"
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
                OnePlayer {
                    previousView = "OnePlayer"
                    activeView = "InGameMenu"
                }
            } else if displayedView == "TwoPlayer" {
                TwoPlayer(onInGameMenu: {
                    previousView = "TwoPlayer"
                    activeView = "InGameMenu"
                })
            } else if displayedView == "ThreePlayer" {
                ThreePlayer(onInGameMenu: {
                    previousView = "ThreePlayer"
                    activeView = "InGameMenu"
                })
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
                FivePlayer(onInGameMenu: {
                    previousView = "FivePlayer"
                    activeView = "InGameMenu"
                })
            } else if displayedView == "SixPlayer" {
                SixPlayer(onInGameMenu: {
                    previousView = "SixPlayer"
                    activeView = "InGameMenu"
                })
            } else if displayedView == "EightPlayer" {
                EightPlayer(onInGameMenu: {
                    previousView = "EightPlayer"
                    activeView = "InGameMenu"
                })
            }

            if activeView == "InGameMenu" {
                InGameMenu(
                    onBackToMenu: {
                        activeView = previousView // Return to the previous view
                    },
                    onNavigateToMainMenu: {
                        if previousView == "FourPlayer" {
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
                        }
                        activeView = "MainMenu" // Navigate to the Main Menu
		                    },
                    onResetGame: {
                        // Reset action. Since TwoPlayer manages its own state,
                        // this closure will be passed from TwoPlayer.
                    },
                    canEditPlayerBoxes: previousView == "FourPlayer",
                    onStartEditingPlayerBoxes: {
                        isEditingFourPlayerBoxes = true
                        activeView = previousView
                    }
                )
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
