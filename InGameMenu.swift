import SwiftUI

struct InGameMenu: View {
    var onBackToMenu: () -> Void
    var onNavigateToMainMenu: () -> Void
    var onResetGame: () -> Void
    var canEditPlayerBoxes: Bool = false
    var onStartEditingPlayerBoxes: (() -> Void)? = nil
    @Binding var keepScreenAwake: Bool
    @State private var showingHomeConfirmation: Bool = false
    @State private var showingSettings: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 10) {
                if showingSettings {
                    settingsContent
                } else {
                    menuContent
                }
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

    private var menuContent: some View {
        Group {
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
                showingSettings = true
            } label: {
                menuRow(title: "Settings", systemImage: "gearshape.fill")
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
        }
    }

    private var settingsContent: some View {
        Group {
            Text("Settings")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Button {
                keepScreenAwake.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: keepScreenAwake ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20, weight: .semibold))

                    Text("Keep Screen Awake")
                        .font(.system(size: 18, weight: .semibold))

                    Spacer()
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
            }

            Button {
                showingSettings = false
            } label: {
                menuRow(title: "Back", systemImage: "arrow.backward")
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
            onStartEditingPlayerBoxes: { print("edit player boxes") },
            keepScreenAwake: .constant(true)
        )
    }
}
