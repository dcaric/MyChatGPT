//
//  ChatView.swift
//  MyChatGPT
//
//  Created by Dario Caric on 26.02.2023..
//

import SwiftUI

struct ChatView: View {
    
    @State var historyList = [String]()
    @State var tableHeight : CGFloat = 20
    @State var heightForInput: CGFloat = 30
    @State var question: String = ""
    @State var store = Store()
    @State var response: String = ""

    var body: some View {
        ZStack {
            VStack {
                NavigationView {
                    List {
                        ForEach(historyList.indices, id: \.self) { rowIndex in
                            HStack {
                                if (rowIndex % 2 == 1 ) {
                                    Text(historyList[rowIndex])
                                        .padding()
                                        .frame(alignment:  .leading )
                                        .background(Color(uiColor: .lightGray))
                                        .foregroundColor(Color(uiColor: .white))
                                        .cornerRadius(16)
                                        .font(Font.custom("Helvetica Neue", size: 20))
                                    Spacer()
                                        .frame(width: 10)
                                        .padding()
                                } else {
                                    Spacer()
                                        .frame(width: 10)
                                        .padding()
                                    Text(historyList[rowIndex])
                                        .padding()
                                        .frame(alignment: .trailing)
                                        .background(Color(uiColor: .systemBlue))
                                        .foregroundColor(Color(uiColor: .white))
                                        .cornerRadius(16)
                                        .font(Font.custom("Helvetica Neue", size: 20))
                                }
                               
                            }
                            .frame(maxWidth: .infinity, alignment: rowIndex % 2 == 1 ? .leading : .trailing)

                        }

                    }
                    //.background(.blue)
                    .navigationTitle("ChatGPT")
                    .listRowSeparator(.hidden)
                    //.scrollContentBackground(.hidden)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in

                    }
                    .onTapGesture(count: 1) {
                        hideKeyboard()
                        tableHeight = 20
                    }
                    .onChange(of: historyList) { _ in
                        
                    }
                }
                
                
                Spacer()
                    .frame(height: tableHeight)

                
                Group {
                    ZStack {
                        //Spacer()
                        
                        TextEditor(text: $question)
                            .frame(height: heightForInput)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(uiColor: .systemGray5), lineWidth: 4)
                            )
                            .frame(width: 380)
                            .font(Font.custom("Helvetica Neue", size: 15))
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                        .padding()
                                    Button("SEND") {
                                        //hideKeyboard()
                                        historyList.append(question)
                                        historyList.append("...")
                                        store.context(newQuestion: question) { (result: Result) in
                                            switch result {
                                            case .success(let text):
                                                print("PRINT [\(text)]")
                                                if (text == "") {
                                                    response = "I already answered that"
                                                } else {
                                                    response = text
                                                    historyList.removeLast()
                                                    historyList.append(text)
                                                }
                                            case .failure(let error):
                                                print("Error generating text: \(error)")
                                            }
                                        }
                                    }
                                    .frame(alignment: .trailing)
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                }
                            }
                        
                        Text(question)
                            //.frame(width: 400)
                            .frame(maxHeight: 56)
                            .hidden()
                            .font(Font.custom("Helvetica Neue", size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                            .background(GeometryReader { proxy in
                                Color.clear
                                    .onChange(of: question, perform: { value in
                                        print("height:\(proxy.size.height)")
                                        heightForInput = proxy.size.height + 20.0
                                        if heightForInput > 56 {
                                            heightForInput = 56
                                        }
                                    })
                            })
                    }
                    .onAppear() {
                        UITextField.appearance().clearButtonMode = .whileEditing
                        
                    }

                } // Group 2

            }
            
        }
        .tabItem {
            Label("Chat", systemImage: "character.bubble")
        }
        .tag(2)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in

        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
