import SwiftUI

struct OnePlayer: View {
    @State private var life1: Int = 40
    @State private var color1: Color = .blue
    
    var onInGameMenu: () -> Void  // Closure to handle back navigation

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Button(action: {
                    life1 += 1
                }) {
                    VStack {
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(color1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {
                    life1 -= 1
                }) {
                    Text("")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(color1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

            VStack {
                Text("\(life1)")
                    .allowsHitTesting(false)
                    .font(.system(size: 150))
                
            }
            HStack{
                ColorPicker("", selection: $color1)
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

struct OnePlayer_Previews: PreviewProvider {
    static var previews: some View {
        OnePlayer {
            // Example preview behavior for onInGameMenu
        }
    }
}
