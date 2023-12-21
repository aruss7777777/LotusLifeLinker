//
//  MainMenu.swift
//  LifeCounterFromScratchT1
//
//  Created by Alex Russello on 12/3/23.
//

import SwiftUI

import SwiftUI

struct MainMenu: View {
    var onMenuSelection: (String) -> Void  // Closure to handle menu selection

    var body: some View {
        ZStack{
            Color.green.edgesIgnoringSafeArea(.all)
            VStack {
                
                Text("Main Menu")
                    .font(.system(size: 50))
                
                
                Button(action: {onMenuSelection("OnePlayer")}) {Text("1 Player")
                        .font(.system(size: 25))

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
               
                Button(action: {onMenuSelection("TwoPlayer")}) {Text("2 Players")
                        .font(.system(size: 25))

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {onMenuSelection("ThreePlayer")}) {Text("3 Players")
                        .font(.system(size: 25))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {onMenuSelection("FourPlayer")}) {Text("4 Players")
                        .font(.system(size: 25))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {onMenuSelection("FivePlayer")}) {Text("5 Players")
                        .font(.system(size: 25))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {onMenuSelection("SixPlayer")}) {Text("6 Players")
                        .font(.system(size: 25))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {onMenuSelection("EightPlayer")}) {Text("8 Players")
                        .font(.system(size: 25))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)


                
            }
        }
    }
}


//#Preview {
//    MainMenu()
//}
