import SwiftUI

struct InGameMenu: View {
    var onBackToMenu: () -> Void
    var onNavigateToMainMenu: () -> Void
    var onResetGame: () -> Void
    var canEditPlayerBoxes: Bool = false
    var onStartEditingPlayerBoxes: (() -> Void)? = nil
    var onSaveGame: ((String) -> Void)? = nil
    var onChooseFirst: (() -> Void)? = nil
    var playerNames: [String] = []
    @Binding var commanderDamage: [[Int]]
    @Binding var poisonDamage: [Int]
    @Binding var showSpecialDamageDeaths: Bool
    @Binding var keepScreenAwake: Bool
    @State private var showingHomeConfirmation: Bool = false
    @State private var showingResetConfirmation: Bool = false
    @State private var showingSettings: Bool = false
    @State private var showingSaveGame: Bool = false
    @State private var showingCommanderDamage: Bool = false
    @State private var selectedCommanderDamageTarget: Int = 0
    @State private var saveName: String = ""
    @State private var showingSaveConfirmation: Bool = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .contentShape(Rectangle())

            VStack(spacing: 10) {
                if showingSaveGame {
                    saveGameContent
                } else if showingCommanderDamage {
                    commanderDamageContent
                } else if showingSettings {
                    settingsContent
                } else {
                    menuContent
                }
            }
            .padding(20)
            .frame(maxWidth: showingCommanderDamage ? 340 : 280)
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
        .alert("Are you sure this will reset scores?", isPresented: $showingResetConfirmation) {
            Button("No", role: .cancel) {
            }
            Button("Yes", role: .destructive) {
                onResetGame()
                onBackToMenu()
            }
        }
    }

    private var menuContent: some View {
        Group {
            HStack {
                Button {
                    showingHomeConfirmation = true
                } label: {
                    iconButton(systemImage: "house.fill")
                }

                Spacer()

                Text("Menu")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)

                Spacer()

                Button {
                    showingSettings = true
                } label: {
                    iconButton(systemImage: "gearshape.fill")
                }
            }

            if canEditPlayerBoxes {
                Button {
                    onStartEditingPlayerBoxes?()
                } label: {
                    menuRow(title: "Customize", systemImage: "pencil")
                }
            } else {
                menuRow(title: "Customize", systemImage: "pencil")
                    .foregroundStyle(.black.opacity(0.55))
                    .opacity(0.6)
            }

            Button {
                onChooseFirst?()
            } label: {
                menuRow(title: "Chooser", systemImage: "hand.point.up.fill")
            }

            Button {
                selectedCommanderDamageTarget = min(selectedCommanderDamageTarget, max(playerNames.count - 1, 0))
                showingCommanderDamage = true
            } label: {
                menuRow(title: "Special Damage", systemImage: "flame.fill")
            }

            Button {
                showingResetConfirmation = true
            } label: {
                menuRow(title: "Reset Score", systemImage: "arrow.counterclockwise")
            }

            Button {
                saveName = ""
                showingSaveGame = true
            } label: {
                menuRow(title: "Save Game", systemImage: "square.and.arrow.down.fill")
            }

            Button {
                onBackToMenu()
            } label: {
                menuRow(title: "Back", systemImage: "arrow.backward")
            }
        }
    }

    private var commanderDamageContent: some View {
        Group {
            Text("Special Damage")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            targetPicker

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(currentPlayerNames.indices, id: \.self) { sourceIndex in
                        if sourceIndex != selectedCommanderDamageTarget {
                            commanderDamageRow(from: sourceIndex, to: selectedCommanderDamageTarget)
                        }
                    }

                    poisonDamageRow(to: selectedCommanderDamageTarget)
                }
                .padding(.vertical, 2)
            }
            .frame(maxHeight: 260)

            Button {
                resetCommanderDamageForCurrentGame()
            } label: {
                menuRow(title: "Clear Damage", systemImage: "xmark.circle")
            }

            Button {
                showingCommanderDamage = false
            } label: {
                menuRow(title: "Back", systemImage: "arrow.backward")
            }
        }
        .onAppear {
            normalizeCommanderDamage()
        }
    }

    private var targetPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Damage to")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black.opacity(0.7))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(currentPlayerNames.indices, id: \.self) { index in
                        Button {
                            selectedCommanderDamageTarget = index
                        } label: {
                            Text(currentPlayerNames[index])
                                .font(.system(size: 15, weight: .semibold))
                                .lineLimit(1)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .foregroundStyle(selectedCommanderDamageTarget == index ? .white : .black)
                                .background(selectedCommanderDamageTarget == index ? Color.black : Color.white.opacity(0.14))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func commanderDamageRow(from sourceIndex: Int, to targetIndex: Int) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(currentPlayerNames[sourceIndex])
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)

                Text("dealt to \(currentPlayerNames[targetIndex])")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.black.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            damageAdjustButton(systemImage: "minus") {
                adjustCommanderDamage(from: sourceIndex, to: targetIndex, by: -1)
            }

            Text("\(commanderDamageValue(from: sourceIndex, to: targetIndex))")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(width: 38)

            damageAdjustButton(systemImage: "plus") {
                adjustCommanderDamage(from: sourceIndex, to: targetIndex, by: 1)
            }
        }
        .foregroundStyle(.black)
        .padding(.vertical, 9)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func poisonDamageRow(to targetIndex: Int) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Poison")
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)

                Text("on \(currentPlayerNames[targetIndex])")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.black.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            damageAdjustButton(systemImage: "minus") {
                adjustPoisonDamage(to: targetIndex, by: -1)
            }

            Text("\(poisonDamageValue(to: targetIndex))")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(width: 38)

            damageAdjustButton(systemImage: "plus") {
                adjustPoisonDamage(to: targetIndex, by: 1)
            }
        }
        .foregroundStyle(.black)
        .padding(.vertical, 9)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var settingsContent: some View {
        Group {
            Text("Settings")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            settingsToggleRow(title: "Keep Screen Awake", isOn: keepScreenAwake) {
                keepScreenAwake.toggle()
            }

            settingsToggleRow(title: "Show Special Damage Deaths", isOn: showSpecialDamageDeaths) {
                showSpecialDamageDeaths.toggle()
            }

            Button {
                showingSettings = false
            } label: {
                menuRow(title: "Back", systemImage: "arrow.backward")
            }
        }
    }

    private var saveGameContent: some View {
        Group {
            Text("Save Game")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            if showingSaveConfirmation {
                Text("Game Saved!")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.green)
                    .padding(.vertical, 8)
            } else {
                TextField("Enter save name", text: $saveName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 4)

                Button {
                    let nameToUse = saveName.trimmingCharacters(in: .whitespaces).isEmpty ? "Untitled Save" : saveName
                    onSaveGame?(nameToUse)
                    showingSaveConfirmation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        showingSaveConfirmation = false
                        showingSaveGame = false
                    }
                } label: {
                    menuRow(title: "Save", systemImage: "checkmark")
                }
            }

            Button {
                showingSaveGame = false
            } label: {
                menuRow(title: "Back", systemImage: "arrow.backward")
            }
        }
    }

    private func settingsToggleRow(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20, weight: .semibold))

                Text(title)
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
    }

    private func iconButton(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.black)
            .frame(width: 42, height: 42)
            .background(Color.white.opacity(0.14))
            .clipShape(Circle())
            .contentShape(Circle())
    }

    private func damageAdjustButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.22))
                .clipShape(Circle())
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

    private var currentPlayerNames: [String] {
        playerNames.isEmpty ? ["Player 1"] : playerNames
    }

    private func commanderDamageValue(from sourceIndex: Int, to targetIndex: Int) -> Int {
        guard commanderDamage.indices.contains(sourceIndex),
              commanderDamage[sourceIndex].indices.contains(targetIndex) else {
            return 0
        }

        return commanderDamage[sourceIndex][targetIndex]
    }

    private func poisonDamageValue(to targetIndex: Int) -> Int {
        guard poisonDamage.indices.contains(targetIndex) else {
            return 0
        }

        return poisonDamage[targetIndex]
    }

    private func adjustCommanderDamage(from sourceIndex: Int, to targetIndex: Int, by amount: Int) {
        normalizeCommanderDamage()

        guard sourceIndex != targetIndex,
              commanderDamage.indices.contains(sourceIndex),
              commanderDamage[sourceIndex].indices.contains(targetIndex) else {
            return
        }

        commanderDamage[sourceIndex][targetIndex] = max(0, commanderDamage[sourceIndex][targetIndex] + amount)
    }

    private func resetCommanderDamageForCurrentGame() {
        let count = currentPlayerNames.count
        commanderDamage = Array(repeating: Array(repeating: 0, count: count), count: count)
        poisonDamage = Array(repeating: 0, count: count)
    }

    private func adjustPoisonDamage(to targetIndex: Int, by amount: Int) {
        normalizePoisonDamage()

        guard poisonDamage.indices.contains(targetIndex) else {
            return
        }

        poisonDamage[targetIndex] = max(0, poisonDamage[targetIndex] + amount)
    }

    private func normalizeCommanderDamage() {
        let count = currentPlayerNames.count
        let normalized = (0..<count).map { source in
            (0..<count).map { target in
                guard source != target,
                      commanderDamage.indices.contains(source),
                      commanderDamage[source].indices.contains(target) else {
                    return 0
                }

                return max(0, commanderDamage[source][target])
            }
        }

        if normalized != commanderDamage {
            commanderDamage = normalized
        }

        normalizePoisonDamage()
    }

    private func normalizePoisonDamage() {
        let count = currentPlayerNames.count
        let normalized = (0..<count).map { index in
            guard poisonDamage.indices.contains(index) else {
                return 0
            }

            return max(0, poisonDamage[index])
        }

        if normalized != poisonDamage {
            poisonDamage = normalized
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
            onStartEditingPlayerBoxes: { print("edit player boxes") },
            playerNames: ["Player 1", "Player 2", "Player 3", "Player 4"],
            commanderDamage: .constant(Array(repeating: Array(repeating: 0, count: 4), count: 4)),
            poisonDamage: .constant(Array(repeating: 0, count: 4)),
            showSpecialDamageDeaths: .constant(true),
            keepScreenAwake: .constant(true)
        )
    }
}
