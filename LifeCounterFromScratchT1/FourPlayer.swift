import SwiftUI

struct FourPlayer: View {
    @State private var life1: Int = 40
    @State private var life2: Int = 40
    @State private var life3: Int = 40
    @State private var life4: Int = 40
    @Binding var playerStyles: [PlayerBoxStyle]
    @Binding var playerNames: [String]
    @Binding var isEditingBoxes: Bool
    @State private var selectedPlayerIndex: Int = 0
    var onInGameMenu: () -> Void  // Closure to handle back navigation

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0){
                    HStack(spacing: 0) {
                        Button(action: {
                            handleTap(for: 0, lifeChange: -1)
                        }) {
                            VStack {
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(playerStyles[0].backgroundColor)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Button(action: {
                            handleTap(for: 0, lifeChange: 1)
                        }) {
                            Text("")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(playerStyles[0].backgroundColor)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Button(action: {
                            handleTap(for: 1, lifeChange: 1)
                        }) {
                            VStack {
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(playerStyles[1].backgroundColor)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Button(action: {
                            handleTap(for: 1, lifeChange: -1)
                        }) {
                            Text("")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(playerStyles[1].backgroundColor)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    HStack(spacing: 0){
                        
                        Button(action: {
                            handleTap(for: 2, lifeChange: -1)
                        }) {
                            VStack {
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(playerStyles[2].backgroundColor)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Button(action: {
                            handleTap(for: 2, lifeChange: 1)
                        }) {
                            Text("")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(playerStyles[2].backgroundColor)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Button(action: {
                            handleTap(for: 3, lifeChange: 1)
                        }) {
                            VStack {
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(playerStyles[3].backgroundColor)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Button(action: {
                            handleTap(for: 3, lifeChange: -1)
                        }) {
                            Text("")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(playerStyles[3].backgroundColor)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    }
                }
                
                
                
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        VStack{
                            playerInfoView(
                                name: playerNames[0],
                                life: life1,
                                width: geometry.size.width / 4,
                                color: playerStyles[0].fontColor,
                                rotation: .degrees(90)
                            )
                        }
                        Spacer()
                        Spacer()
                        VStack{
                            playerInfoView(
                                name: playerNames[1],
                                life: life2,
                                width: geometry.size.width / 4,
                                color: playerStyles[1].fontColor,
                                rotation: .degrees(270)
                            )
                        }
                        Spacer()
                    }
                    
                    
                    
                    Spacer()
                    Spacer()
                    HStack{
                        Spacer()
                        playerInfoView(
                            name: playerNames[2],
                            life: life3,
                            width: geometry.size.width / 4,
                            color: playerStyles[2].fontColor,
                            rotation: .degrees(90)
                        )
                        
                        Spacer()
                        Spacer()
                        playerInfoView(
                            name: playerNames[3],
                            life: life4,
                            width: geometry.size.width / 4,
                            color: playerStyles[3].fontColor,
                            rotation: .degrees(270)
                        )
                        
                        Spacer()
                    }
                    Spacer()
                    
                    
                }

                if isEditingBoxes {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)

                    playerSelectionHighlight(in: geometry)

                    VStack {
                        Spacer()

                        VStack(spacing: 14) {
                            Text("Edit Player \(selectedPlayerIndex + 1)")
                                .font(.headline)

                            Text("Tap a player box to select it")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField(
                                "Player Name",
                                text: Binding(
                                    get: { playerNames[selectedPlayerIndex] },
                                    set: { playerNames[selectedPlayerIndex] = $0 }
                                )
                            )
                            .textFieldStyle(.roundedBorder)

                            ColorPicker(
                                "Font Color",
                                selection: Binding(
                                    get: { playerStyles[selectedPlayerIndex].fontColor },
                                    set: { playerStyles[selectedPlayerIndex].fontColor = $0 }
                                )
                            )

                            ColorPicker(
                                "Background Color",
                                selection: Binding(
                                    get: { playerStyles[selectedPlayerIndex].backgroundColor },
                                    set: { playerStyles[selectedPlayerIndex].backgroundColor = $0 }
                                )
                            )

                            Button("Done") {
                                isEditingBoxes = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.black)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(20)
                        .frame(maxWidth: 320)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.bottom, 32)
                    }
                }
                
                Button {
                    onInGameMenu() // Show InGameMenu when "+" is tapped
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Circle())
                }
                .shadow(radius: 4)
            }
        }
    }

    private func playerInfoView(
        name: String,
        life: Int,
        width: CGFloat,
        color: Color,
        rotation: Angle
    ) -> some View {
        VStack(spacing: 8) {
            Text("\(life)")
                .font(.system(size: 75))

            Text(name)
                .font(.system(size: 24, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(width: width, height: 130)
        .allowsHitTesting(false)
        .foregroundStyle(color)
        .rotationEffect(rotation)
    }

    private func handleTap(for playerIndex: Int, lifeChange: Int) {
        if isEditingBoxes {
            selectedPlayerIndex = playerIndex
            return
        }

        switch playerIndex {
        case 0:
            life1 += lifeChange
        case 1:
            life2 += lifeChange
        case 2:
            life3 += lifeChange
        case 3:
            life4 += lifeChange
        default:
            break
        }
    }

    @ViewBuilder
    private func playerSelectionHighlight(in geometry: GeometryProxy) -> some View {
        let halfWidth = geometry.size.width / 2
        let halfHeight = geometry.size.height / 2
        let positions = [
            CGPoint(x: halfWidth / 2, y: halfHeight / 2),
            CGPoint(x: halfWidth + (halfWidth / 2), y: halfHeight / 2),
            CGPoint(x: halfWidth / 2, y: halfHeight + (halfHeight / 2)),
            CGPoint(x: halfWidth + (halfWidth / 2), y: halfHeight + (halfHeight / 2))
        ]

        RoundedRectangle(cornerRadius: 24)
            .stroke(Color.white, lineWidth: 6)
            .frame(width: halfWidth - 20, height: halfHeight - 20)
            .position(positions[selectedPlayerIndex])
            .allowsHitTesting(false)
    }
}

struct FourPlayer_Previews: PreviewProvider {
    static var previews: some View {
        FourPlayer(
            playerStyles: .constant([
                PlayerBoxStyle(backgroundColor: .blue, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .green, fontColor: .white),
                PlayerBoxStyle(backgroundColor: .yellow, fontColor: .black),
                PlayerBoxStyle(backgroundColor: .orange, fontColor: .black)
            ]),
            playerNames: .constant([
                "Player 1",
                "Player 2",
                "Player 3",
                "Player 4"
            ]),
            isEditingBoxes: .constant(false)
        ) {
            // Example preview behavior for onInGameMenu
        }
    }
}
