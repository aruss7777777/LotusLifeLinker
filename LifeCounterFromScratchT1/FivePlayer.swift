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
                VStack(spacing: 0){
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(color5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button(action: {
                        life5 -= 1
                    }) {
                        Text("")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(color5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                
                
                VStack {
                    Spacer()
                    
                            HStack{
                            Spacer()
                            Text("\(life1)")
                                .frame(width: geometry.size.width / 4, height: 100)
                                .allowsHitTesting(false)
                                .font(.system(size: 75))
                                .rotationEffect(.degrees(90))
                        
                        Spacer()
                        Spacer()
                            Text("\(life2)")
                                .frame(width: geometry.size.width / 4, height: 100)
                                .allowsHitTesting(false)
                                .font(.system(size: 75))
                                .rotationEffect(.degrees(270))
                        Spacer()
                        
                    }
                    Spacer()
                    Spacer()
                    HStack{
                        Spacer()
                        Text("\(life3)")
                            .frame(width: geometry.size.width / 4, height: 100)
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(90))
                        Spacer()
                        Spacer()
                        Text("\(life4)")
                            .frame(width: geometry.size.width / 4, height: 100)
                            .allowsHitTesting(false)
                            .font(.system(size: 75))
                            .rotationEffect(.degrees(270))
                        Spacer()
                    }

                    Spacer()
                        .frame(height: 425)
                }
                
                VStack{
                    Spacer()
                        .frame(height: 350)
                    Text("\(life5)")
                        .frame(width: geometry.size.width / 4, height: 100)
                        .allowsHitTesting(false)
                        .font(.system(size: 75))
                }
                
                
                
                
                VStack{
                    HStack{
                        ColorPicker("", selection: $color1)
                        ColorPicker("", selection: $color2)
                    }
                    Spacer()
                        .frame(height: 1)
                    HStack{
                        ColorPicker("", selection: $color3)
                        ColorPicker("", selection: $color4)
                    }
                    Spacer()
                        .frame(height: 360)
                    ColorPicker("", selection: $color5)

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
}

struct FivePlayer_Previews: PreviewProvider {
    static var previews: some View {
        FivePlayer {
            // Example preview behavior for onInGameMenu
        }
    }
}
