import SwiftUI

struct EightPlayer: View {
    @State private var life1: Int = 40
    @State private var color1: Color = .blue
    
    @State private var life2: Int = 40
    @State private var color2: Color = .green
    
    @State private var life3: Int = 40
    @State private var color3: Color = .yellow
    
    @State private var life4: Int = 40
    @State private var color4: Color = .orange
    
    @State private var life5: Int = 40
    @State private var color5: Color = .pink
    
    @State private var life6: Int = 40
    @State private var color6: Color = .purple
    
    @State private var life7: Int = 40
    @State private var color7: Color = .white
    
    @State private var life8: Int = 40
    @State private var color8: Color = .gray
    
    var onInGameMenu: () -> Void  // Closure to handle back navigation

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0){
                    HStack(spacing: 0) {
                        //Button 1 and 2 life 1
                        Button(action: {life1 -= 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color1)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        Button(action: {life1 += 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color1)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        //Button 3 and 4 life 2
                        Button(action: {life2 += 1}) {Text("")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(color2)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        Button(action: {life2 -= 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color2)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                    }//End HStack
                    HStack(spacing: 0){
                        //Button 5 and 6 life 3
                        Button(action: {life3 -= 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color3)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        Button(action: {life3 += 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color3)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        //Button 7 and 8 life 4
                        Button(action: {life4 += 1}) {Text("")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(color4)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        Button(action: {life4 -= 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color4)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                    }//End HStack
                    
                    HStack(spacing: 0){
                        //Button 9 and 10 life 5
                        Button(action: {life5 -= 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color5)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        Button(action: {life5 += 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color5)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        //Button 11 and 12 life 6
                        Button(action: {life6 += 1}) {Text("")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(color6)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        Button(action: {life6 -= 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color6)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                    }//End HStack
                    
                    HStack(spacing: 0){
                        //Button 13 and 14 life 7
                        Button(action: {life7 -= 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color7)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        Button(action: {life7 += 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color7)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        //Button 15 and 16 life 8
                        Button(action: {life8 += 1}) {Text("")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(color8)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                        Button(action: {life8 -= 1}) {Text("")
                                .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                            .background(color8)}
                        .frame(maxWidth: geometry.size.width / 4, maxHeight: geometry.size.height / 3)
                    }//End HStack
                    
                    
                    
                }
                
                //Top Left
                HStack{VStack {
                        Text("\(life1)")
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(90))
                    }
                .frame(width: geometry.size.width, alignment: .leading)
                // Adjust the y offset to position the view in the top third
                .offset(x: geometry.size.width / 7, y: geometry.size.height / 3 - geometry.size.height / 1.35)
                }
                
                //Top Right
                HStack{VStack {
                        Text("\(life2)")
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(270))
                    }
                // Adjust the y offset to position the view in the top third
                .offset(x: geometry.size.width / 4, y: geometry.size.height / 3 - geometry.size.height / 1.35)
                }
                
                
                
                
                //Top Middle Left
                HStack{VStack {
                        Text("\(life3)")
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(90))
                    }
                .frame(width: geometry.size.width, alignment: .leading)
                .offset(x: geometry.size.width / 7, y: geometry.size.height / 3 - geometry.size.height / 2.17)
                }
                
                //Middle Top Right
                HStack{VStack {
                        Text("\(life4)")
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(270))
                    }
                .offset(x: geometry.size.width / 4, y: geometry.size.height / 3 - geometry.size.height / 2.17)
                }
                
                
                
                //Bottom Middle Right
                HStack{VStack {
                        Text("\(life6)")
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(270))
                }.offset(x: geometry.size.width / 4, y: geometry.size.height / 8)
                }
                
                //Bottom Middle Left
                HStack{VStack {
                        Text("\(life5)")
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(90))
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .offset(x: geometry.size.width / 7    , y: geometry.size.height / 8)
                }

                //Bottom Right
                HStack{VStack {
                        Text("\(life8)")
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(270))
                }.offset(x: geometry.size.width / 4, y: geometry.size.height / 2.60)
                }
                
                //Bottom Left
                HStack{VStack {
                        Text("\(life7)")
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(90))
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .offset(x: geometry.size.width / 7    , y: geometry.size.height / 2.60)
                }
                
                
                
                
//Color Changers
            VStack(spacing: 0){
                Spacer()
                Spacer()
                    HStack{
                        Spacer()
                            .frame(width: 150)
                        ColorPicker("", selection: $color1)
                        ColorPicker("", selection: $color2)
                        Spacer()
                            .frame(width: 160)
                    }
                    HStack{
                        Spacer()
                            .frame(width: 150)
                        ColorPicker("", selection: $color3)
                        ColorPicker("", selection: $color4)
                        Spacer()
                            .frame(width: 160)
                    }
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                    HStack{
                        Spacer()
                            .frame(width: 150)
                        ColorPicker("", selection: $color5)
                        ColorPicker("", selection: $color6)
                        Spacer()
                            .frame(width: 160)
                    }
                HStack{
                    Spacer()
                        .frame(width: 150)
                    ColorPicker("", selection: $color7)
                    ColorPicker("", selection: $color8)
                    Spacer()
                        .frame(width: 160)
                }
                Spacer()
                Spacer()

                }
                
                HStack {
                    Button("+") {
                        onInGameMenu() // Show InGameMenu when "+" is tapped
                    }
                    .frame(maxWidth: 30, maxHeight: 30)
                    .background(Color.black)
                }
            }
        }
    }
}

struct EightPlayer_Previews: PreviewProvider {
    static var previews: some View {
        EightPlayer {
            // Example preview behavior for onInGameMenu
        }
    }
}
