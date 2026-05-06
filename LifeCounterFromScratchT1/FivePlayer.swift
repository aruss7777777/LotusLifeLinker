import SwiftUI

struct FivePlayer: View {
    
    
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
    
    var onInGameMenu: () -> Void  // Closure to handle back navigation
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GeometryReader { geometry in
                    VStack(spacing: 0){
                        //Life1 and Life2 HSTACK
                        HStack(spacing: 0) {
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
                        //Life3 and Life4 HSTACK
                        HStack(spacing: 0){
                            
                            Button(action: {
                                life3 -= 1
                            }) {
                                VStack {
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(color3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            Button(action: {
                                life3 += 1
                            }) {
                                Text("")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(color3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Button(action: {
                                life4 += 1
                            }) {
                                VStack {
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(color4)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            Button(action: {
                                life4 -= 1
                            }) {
                                Text("")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(color4)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                        }
                        
                        
                        
                        
                        Button(action: {
                            life5 += 1
                        }) {
                            VStack {
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: geometry.size.height / 6)
                            .background(color5)
                        }
                        .frame(maxWidth: .infinity, maxHeight: geometry.size.height / 6)
                        
                        Button(action: {
                            life5 -= 1}) {Text("")
                                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height / 6)
                                    .background(color5)
                            }
                            .frame(maxWidth: .infinity, maxHeight: geometry.size.height / 6)
                    }
                    
                    
                    VStack { //Top Left and Right Life Total Text
                        Spacer()
                            .frame(height: geometry.size.height / 12) // 1/4 of the screen's height
                        HStack{
                            Spacer()
                            Text("\(life1)")
                                .frame(width: geometry.size.width / 4, height: 150)
                                .allowsHitTesting(false)
                                .font(.system(size: geometry.size.width * 0.125))
                                .rotationEffect(.degrees(90))
                            
                            Spacer()
                            Spacer()
                            Text("\(life2)")
                                .frame(width: geometry.size.width / 4, height: 100)
                                .allowsHitTesting(false)
                                .font(.system(size: geometry.size.width * 0.125))
                                .rotationEffect(.degrees(270))
                            Spacer()
                            
                        }
                        
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(life3)")
                                .frame(width: geometry.size.width / 4, height: 100)
                                .allowsHitTesting(false)
                                .font(.system(size: geometry.size.width * 0.125))
                                .rotationEffect(.degrees(90))
                            Spacer()
                            Spacer()
                            Text("\(life4)")
                                .frame(width: geometry.size.width / 4, height: 100)
                                .allowsHitTesting(false)
                                .font(.system(size: geometry.size.width * 0.125))
                                .rotationEffect(.degrees(270))
                            Spacer()
                        }
                        Spacer()
                        
                    }
                    
                    VStack{
                        Spacer()
                            .frame(height: geometry.size.height / 1.3) // 1/4 of the screen's height
                        Text("\(life5)")
                            .frame(width: geometry.size.width / 1, height: 100)
                            .allowsHitTesting(false)
                            .font(.system(size: geometry.size.width * 0.275))
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    Button("+") {
                        onInGameMenu() // Show InGameMenu when "+" is tapped
                    }
                    .frame(maxWidth: 30, maxHeight: 30)
                    .background(Color.black)
                    Spacer()
                }
            }
            
            
                HStack{
                    Spacer()
                        .frame(width: geometry.size.width / 2.25) // 1/4 of the screen's height
                        .frame(height: geometry.size.height / 1.6) // 1/4 of the screen's height
                    ColorPicker("", selection: $color1)
                    ColorPicker("", selection: $color2)
                    Spacer()
                        .frame(width: geometry.size.width / 1) // 1/4 of the screen's height
                }
                HStack{
                    Spacer()
                        .frame(width: geometry.size.width / 2.25) // 1/4 of the screen's height
                        .frame(height: geometry.size.height / 1.4) // 1/4 of the screen's height
                    ColorPicker("", selection: $color3)
                    ColorPicker("", selection: $color4)
                    Spacer()
                        .frame(width: geometry.size.width / 1) // 1/4 of the screen's height

                }
            HStack{
                Spacer()
                    .frame(height: geometry.size.height / 0.725) // 1/4 of the screen's height
                ColorPicker("", selection: $color5)
                Spacer()
                    .frame(width: geometry.size.width / 2.075)

            }
            

            
            
            
        }
        
        
        
        
    }
    
    
    
}

struct FivePlayer_Previews: PreviewProvider {
    static var previews: some View {
        FivePlayer {
            // Example preview behavior for onInGameMenu
        }
    }
}
