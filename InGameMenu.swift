import SwiftUI

struct InGameMenu: View {
    var onBackToMenu: () -> Void
    var onNavigateToMainMenu: () -> Void
    var onResetGame: () -> Void

    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
            VStack {
                Spacer()

                Text("Menu")
                    .font(.system(size: 72))
                    .foregroundColor(.white)

//                Button("Change Colors") {
//                    // Add action here
//                }
//                .foregroundColor(.white)
//                .padding()

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
            onResetGame: { print("game reset") }
        )
    }
}
