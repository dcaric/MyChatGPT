//
//  ChatView.swift
//  MyChatGPT
//
//  Created by Dario Caric on 26.02.2023..
//

import SwiftUI

struct ChatView: View {
    
    @State var historyList = [String]()
    @State var tableHeight : CGFloat = .infinity
    @State var heightForInput: CGFloat = 30
    @State var question: String = ""
    @State var store = Store()
    @State var response: String = ""
    @State var loadedOnce: Bool = true
    
    @State var items = [Int]()
    
    //@State var  historyList = ["dario", "ok"]

    var body: some View {
        ZStack {
            VStack {
                Label("ChatGPT", systemImage: "brain.head.profile")
                    .font(Font.custom("Helvetica Neue", size: 30))
                
                
                ScrollViewReader { scrollProxy in
                    ScrollView (.vertical, showsIndicators: false, content: {
                        ForEach(historyList.indices, id: \.self) { rowIndex in
                            HStack {
                                    if (rowIndex % 2 == 1) {
                                        Text(historyList[rowIndex])
                                            .padding()
                                            .frame(alignment:  .leading )
                                            .background(Color(uiColor: .lightGray))
                                            .foregroundColor(Color(uiColor: .black))
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
                    })
                    .onTapGesture(count: 1) {
                        hideKeyboard()
                        //tableHeight = 20
                    }
                    .onChange(of: items, perform: { _ in
                        scrollProxy.scrollTo(items.last!)
                    })
                }
                .padding(.all)

                Group {

                    HStack {
                        
                        TextEditor(text: $question)
                            .frame(height: heightForInput)
                            //.cornerRadius(20)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(uiColor: .systemGray5), lineWidth: 4)
                            )
                            .frame(width: UIScreen.main.bounds.size.width - 120)
                            .padding(.all)
                            .font(Font.custom("Helvetica Neue", size: 15))
                        
                        Text(question)
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
                        
                        Button(action: {
                            historyList.append(question)
                            historyList.append("...")
                            if (items.count > 0) {
                                items.append(items.last! + 1)
                            }
                            store.context(newQuestion: question) { (result: Result) in
                                switch result {
                                case .success(var text):
                                    print("PRINT [\(text)]")
                                    if (text == "") {
                                        response = "I already answered that"
                                    } else {
                                        //loadedOnce = true
                                        text = text.replacingOccurrences(of: "\n", with: "")
                                        text = text.replacingOccurrences(of: "$#$", with: "")
                                        text = text.replacingOccurrences(of: "SENTENCE_END", with: "")
                                        response = text

                                        historyList.removeLast()
                                        historyList.append(text)
                                        question = ""
                                        if (items.count > 0) {
                                            items.append(items.last! + 1)
                                        }
                                    }
                                case .failure(let error):
                                    print("Error generating text: \(error)")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.up")
                            }
                        }
                        .padding(.pi*3)
                        .foregroundColor(.white)
                        .background(Color(uiColor: .systemBlue))
                        .cornerRadius(.infinity)
                        
                        }
                        .onAppear() {
                            UITextField.appearance().clearButtonMode = .whileEditing
                            //tableHeight = 200
                        }

                    

                    
                    }

            }
        }
        .onTapGesture(count: 1) {
            hideKeyboard()
        }
        .tabItem {
            Label("Chat", systemImage: "character.bubble")
        }
        .tag(2)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            print("READ HISTORY")
            _ = store.readHistory()

        }
        .onAppear {
            print("READ HISTORY loadedOnce: \(loadedOnce)")
            if (loadedOnce) {
                loadedOnce = false
                print("READ HISTORY")
                let wholeConversation = store.readHistory()
                let  wholeConversationList = wholeConversation.components(separatedBy: "SENTENCE_END")
                var count = 0;
                for item in wholeConversationList {
                    let subItem = item.components(separatedBy: "$#$")
                    if (subItem.count == 2) {
                        historyList.append(subItem[0])
                        items.append(count)
                        count += 1
                        historyList.append(subItem[1])
                        items.append(count)
                        count += 1
                    }
                }
            }
        }
        .onChange(of: historyList, perform: { value in

            
        })
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
