import SwiftUI

struct InGameMenu: View {
    var onBackToMenu: () -> Void
    var onNavigateToMainMenu: () -> Void
    var onResetGame: () -> Void
    var canEditPlayerBoxes: Bool = false
    var onStartEditingPlayerBoxes: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
            VStack {
                Spacer()

                Text("Menu")
                    .font(.system(size: 72))
                    .foregroundColor(.white)

                if canEditPlayerBoxes {
                    Button("Customize") {
                        onStartEditingPlayerBoxes?()
                    }
                    .foregroundColor(.white)
                    .padding()
                } else {
                    Button("Customize") {
                    }
                    .foregroundColor(.white.opacity(0.4))
                    .padding()
                    .disabled(true)
                }

                Button("Main Menu") {
                    onNavigateToMainMenu()
                }
                .foregroundColor(.white)
                .padding()

                Button("Return") {
                    onBackToMenu()
                }
                .foregroundColor(.white)
                .padding()

//                Button("Reset") {
//                    onResetGame()
//                }
//                .foregroundColor(.white)
//                .padding()

                Spacer()
            }
        }
    }
}

struct InGameMenu_Previews: PreviewProvider {
    static var previews: some View {
        InGameMenu(
            onBackToMenu: { print("Return button tapped") },
            onNavigateToMainMenu: { print("Main Menu button tapped") },
            onResetGame: { print("game reset") },
            canEditPlayerBoxes: true,
            onStartEditingPlayerBoxes: { print("edit player boxes") }
        )
    }
}
