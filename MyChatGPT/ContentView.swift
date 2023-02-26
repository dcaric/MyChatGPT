//
//  ContentView.swift
//  MyChatGPT
//
//  Created by Dario Caric on 26.02.2023..
//

import SwiftUI

struct ContentView: View {
    
    @State var settings = Settings()
    @State var chat = ChatView()

    
    var body: some View {
        TabView {
            // TAB - 1
            ZStack {
                settings
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(1)
            .padding()
            
            
            // TAB - 2
            ZStack {
                chat
            }
            .tabItem {
                Label("Chat", systemImage: "character.bubble")
            }
            .tag(1)
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
