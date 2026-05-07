import SwiftUI

struct InGameMenu: View {
    var onBackToMenu: () -> Void
    var onNavigateToMainMenu: () -> Void
    var onResetGame: () -> Void
    var canEditPlayerBoxes: Bool = false
    var onStartEditingPlayerBoxes: (() -> Void)? = nil
    @State private var showingHomeConfirmation: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 10) {
                Text("Menu")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)

                if canEditPlayerBoxes {
                    Button {
                        onStartEditingPlayerBoxes?()
                    } label: {
                        menuRow(title: "Customize")
                    }
                } else {
                    menuRow(title: "Customize")
                        .foregroundStyle(.black.opacity(0.55))
                        .opacity(0.6)
                }

                Button {
                    showingHomeConfirmation = true
                } label: {
                    menuRow(title: "Home", systemImage: "house.fill")
                }

                Button {
                    onBackToMenu()
                } label: {
                    menuRow(title: "Back", systemImage: "arrow.backward")
                }

//                Button("Reset") {
//                    onResetGame()
//                }
//                .foregroundColor(.white)
//                .padding()
            }
            .padding(20)
            .frame(maxWidth: 280)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(radius: 18)
        }
        .alert("Are you sure this will reset scores?", isPresented: $showingHomeConfirmation) {
            Button("No", role: .cancel) {
            }
            Button("Yes", role: .destructive) {
                onNavigateToMainMenu()
            }
        }
    }

    private func menuRow(title: String, systemImage: String? = nil) -> some View {
        HStack(spacing: 10) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
            }

            Text(title)
                .font(.system(size: 20, weight: .semibold))
        }
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
