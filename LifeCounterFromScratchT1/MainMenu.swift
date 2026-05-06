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
            Color.cyan.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text("Players")
                    .font(.system(size: 50))
                
                
                HStack{
                    Button(action: {onMenuSelection("OnePlayer")}) {
                        Image("1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // You can adjust the size as needed
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button(action: {onMenuSelection("TwoPlayer")}) {
                        Image("2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // You can adjust the size as needed
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button(action: {onMenuSelection("ThreePlayer")}) {
                        Image("3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // You can adjust the size as needed
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                HStack{
                    Button(action: {onMenuSelection("FourPlayer")}) {
                        Image("4") // Replace with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // You can adjust the size as needed
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button(action: {onMenuSelection("FivePlayer")}) {
                        Image("5") // Replace with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // You can adjust the size as needed
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button(action: {onMenuSelection("SixPlayer")}) {
                        Image("6") // Replace with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // You can adjust the size as needed
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Button(action: {onMenuSelection("EightPlayer")}) {
                    Image("8") // Replace with your image name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100) // You can adjust the size as needed
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
           
              Spacer()
            }
        }
    }
}


//#Preview {
//    MainMenu()
//}
