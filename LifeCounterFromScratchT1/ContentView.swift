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
    @State private var isEditingFourPlayerBoxes: Bool = false

    var body: some View {
        VStack {
            if activeView == "MainMenu" {
                MainMenu { selectedView in
                    activeView = selectedView
                }
            }		 else if activeView == "OnePlayer" {
                OnePlayer {
                    previousView = "OnePlayer"
                    activeView = "InGameMenu"
                }
            } else if activeView == "TwoPlayer" {
                TwoPlayer(onInGameMenu: {
                    previousView = "TwoPlayer"
                    activeView = "InGameMenu"
                })
            } else if activeView == "ThreePlayer" {
                ThreePlayer(onInGameMenu: {
                    previousView = "ThreePlayer"
                    activeView = "InGameMenu"
                })
            }else if activeView == "FourPlayer" {
                FourPlayer(
                    playerStyles: $fourPlayerStyles,
                    playerNames: $fourPlayerNames,
                    isEditingBoxes: $isEditingFourPlayerBoxes,
                    onInGameMenu: {
                        previousView = "FourPlayer"
                        activeView = "InGameMenu"
                    }
                )
            }else if activeView == "FivePlayer" {
                FivePlayer(onInGameMenu: {
                    previousView = "FivePlayer"
                    activeView = "InGameMenu"
                })
            }else if activeView == "SixPlayer" {
                SixPlayer(onInGameMenu: {
                    previousView = "SixPlayer"
                    activeView = "InGameMenu"
                })
            }else if activeView == "EightPlayer" {
                EightPlayer(onInGameMenu: {
                    previousView = "EightPlayer"
                    activeView = "InGameMenu"
                })
            }

            // Present InGameMenu only when activeView is "InGameMenu"
            if activeView == "InGameMenu" {
                InGameMenu(
                    onBackToMenu: {
                        activeView = previousView // Return to the previous view
                    },
                    onNavigateToMainMenu: {
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
