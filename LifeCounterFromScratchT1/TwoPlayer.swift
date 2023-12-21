import SwiftUI

struct TwoPlayer: View {
    @State private var life1: Int = 40
    @State private var color1: Color = .blue
    
    @State private var life2: Int = 40
    @State private var color2: Color = .green
    
    var onInGameMenu: () -> Void  // Closure to handle back navigation

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Button(action: {
                    life1 -= 1
                }) {
                    VStack {
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(color1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {
                    life1 += 1
                }) {
                    Text("")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(color1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {
                    life2 += 1
                }) {
                    VStack {
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(color2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {
                    life2 -= 1
                }) {
                    Text("")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(color2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            VStack {
                Spacer()
                Text("\(life1)")
                    .allowsHitTesting(false)
                    .font(.system(size: 150))
                    .rotationEffect(.degrees(180))
                
                ColorPicker("", selection: $color1)
                Spacer()
                ColorPicker("", selection: $color2)
                Spacer()
                Text("\(life2)")
                    .allowsHitTesting(false)
                    .font(.system(size: 150))
                Spacer()
            }

            HStack {
                Button("+") {
                    onInGameMenu() // Show InGameMenu when "+" is tapped
                }
                .frame(maxWidth: 30, maxHeight: 30)
                .background(Color.black)
                Spacer()
            }
        }
        
    }
}

struct TwoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        TwoPlayer {
            // Example preview behavior for onInGameMenu
        }
    }
}
