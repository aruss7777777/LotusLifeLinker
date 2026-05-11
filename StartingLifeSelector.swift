import SwiftUI

struct StartingLifeSelector: View {
    let playerCount: Int
    let onStartGame: (Int) -> Void
    let onCancel: () -> Void
    
    @State private var selectedLife: Int? = 40
    @State private var customLife: String = ""
    @State private var showingCustomInput: Bool = false
    @FocusState private var isInputFocused: Bool
    
    private let presetOptions = [20, 30, 40]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Starting Life Total")
                        .font(.title.bold())
                        .foregroundStyle(.black)
                    
                    Text("\(playerCount) Player\(playerCount > 1 ? "s" : "")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Preset Options
                VStack(spacing: 12) {
                    ForEach(presetOptions, id: \.self) { lifeTotal in
                        Button {
                            selectedLife = lifeTotal
                            showingCustomInput = false
                            customLife = ""
                        } label: {
                            HStack {
                                Text("\(lifeTotal)")
                                    .font(.title2.bold())
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                if selectedLife == lifeTotal && !showingCustomInput {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(selectedLife == lifeTotal && !showingCustomInput ? Color.blue.opacity(0.1) : Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    // Custom Option
                    Button {
                        showingCustomInput = true
                        selectedLife = nil
                        isInputFocused = true
                    } label: {
                        HStack {
                            if showingCustomInput {
                                TextField("Enter life total", text: $customLife)
                                    .keyboardType(.numberPad)
                                    .font(.title2.bold())
                                    .foregroundStyle(.black)
                                    .focused($isInputFocused)
                                    .frame(maxWidth: 150)
                            } else {
                                Text("Custom")
                                    .font(.title2.bold())
                                    .foregroundStyle(.black)
                            }
                            
                            Spacer()
                            
                            if showingCustomInput && !customLife.isEmpty {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            } else if !showingCustomInput {
                                Image(systemName: "keyboard")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(showingCustomInput ? Color.blue.opacity(0.1) : Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        startGame()
                    } label: {
                        Text("Start Game")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canStartGame ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!canStartGame)
                    
                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(width: 320)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear {
            // Default to 40
            selectedLife = 40
        }
    }
    
    private var canStartGame: Bool {
        if showingCustomInput {
            guard let life = Int(customLife), life > 0, life <= 999 else {
                return false
            }
            return true
        } else {
            return selectedLife != nil
        }
    }
    
    private func startGame() {
        let lifeTotal: Int
        
        if showingCustomInput {
            guard let life = Int(customLife), life > 0, life <= 999 else {
                return
            }
            lifeTotal = life
        } else {
            guard let selected = selectedLife else {
                return
            }
            lifeTotal = selected
        }
        
        onStartGame(lifeTotal)
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
