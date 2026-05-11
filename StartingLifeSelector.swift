import SwiftUI

struct StartingLifeSelector: View {
    let playerCount: Int
    let onStartGame: (Int) -> Void
    let onCancel: () -> Void

    @State private var customLife: String = ""
    @State private var showingCustomInput: Bool = false
    @FocusState private var isInputFocused: Bool

    private let presetOptions = [20, 30, 40]

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Starting Life Total")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)

                    Text("\(playerCount) Player\(playerCount > 1 ? "s" : "")")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.textSecondary)
                }

                VStack(spacing: 18) {
                    HStack(spacing: 12) {
                        ForEach(presetOptions, id: \.self) { lifeTotal in
                            presetLifeButton(lifeTotal)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    customLifeSection
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 14) {
                    if showingCustomInput {
                        Button {
                            startCustomGame()
                        } label: {
                            Text("Next")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(canStartCustomGame ? Color.buttonPrimary : Color.gray.opacity(0.25))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!canStartCustomGame)
                    }

                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .padding(24)
            .frame(width: 340)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
        }
    }

    private func presetLifeButton(_ lifeTotal: Int) -> some View {
        Button {
            onStartGame(lifeTotal)
        } label: {
            Text("\(lifeTotal)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.appSecondary.opacity(0.18)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.appPrimary.opacity(0.35), lineWidth: 2)
                }
                .shadow(color: Color.appPrimary.opacity(0.12), radius: 8, y: 4)
        }
    }

    private var customLifeSection: some View {
        Button {
            showingCustomInput = true
            isInputFocused = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "keyboard")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.buttonPrimary)
                    .frame(width: 28)

                if showingCustomInput {
                    TextField("Custom life", text: $customLife)
                        .keyboardType(.numberPad)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                        .focused($isInputFocused)
                } else {
                    Text("Custom")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 62)
            .background(showingCustomInput ? Color.appSecondary.opacity(0.18) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(showingCustomInput ? Color.buttonPrimary.opacity(0.55) : Color.appPrimary.opacity(0.25), lineWidth: 2)
            }
        }
    }

    private var canStartCustomGame: Bool {
        guard let life = Int(customLife), life > 0, life <= 999 else {
            return false
        }

        return true
    }

    private func startCustomGame() {
        guard let life = Int(customLife), life > 0, life <= 999 else {
            return
        }

        onStartGame(life)
    }
}

#Preview {
    StartingLifeSelector(
        playerCount: 4,
        onStartGame: { life in
            print("Starting game with \(life) life")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}
