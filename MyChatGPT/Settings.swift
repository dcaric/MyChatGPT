//
//  Settings.swift
//  MyChatGPT
//
//  Created by Dario Caric on 26.02.2023..
//

import SwiftUI

struct Settings: View {
    
    @State var openAiKey: String = ""
    @StateObject var store = Store()


    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    if store.readKey() {
                        Label("SAVED", systemImage: "key")
                    }
                }
               
                
                TextField("Write your OpenAi key", text: $openAiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 35)
                .cornerRadius(20)
                .foregroundColor(.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue, lineWidth: 4)
                )
                .padding()
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                            .padding(.leading)
                        
                        
                        Button("SAVE") {
                            store.saveKey(openAiKey: openAiKey)
                            hideKeyboard()
                            openAiKey = ""
                        }
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        
                        Button("CANCEL") {
                            hideKeyboard()
                            openAiKey = ""
                        }
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                
                        Spacer()
                            .padding(.trailing)
                    }
                }
            }
        }
        .onAppear {
            // this is not good, after optimization memeory is not up to date
//            store.optimizeHistory(completion: { (resutl: String) in
//                print("SUMMARIZED: \(resutl)")
//
//                UserDefaults.standard.set(resutl1, forKey: "conversation")
//            })
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
