//
//  DynamicTextField.swift
//  MyChatGPT
//
//  Created by Dario Caric on 04.03.2023..
//

import SwiftUI

struct DynamicTextField: View {
    
    @State var question: String
    @State var messages = [Store.Message]()
    @State var items = [Int]()
    var callback: (String) -> Void
    @State var heightForInput: CGFloat

    init(question: String, messages: [Store.Message], items: [Int], heightForInput: CGFloat, callback: @escaping (String) -> Void) {
        self.question = question
        self.messages = messages
        self.items = items
        self.heightForInput = heightForInput
        self.callback = callback
    }

    private var store = Store()

    var body: some View {

        HStack {
            
            TextEditor(text: $question)
                .frame(height: heightForInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(uiColor: .systemGray5), lineWidth: 4)
                )
                .frame(width: UIScreen.main.bounds.size.width - 100)
                .padding()
                .font(Font.custom("Helvetica Neue", size: 15))
            
            Text(question)
                .frame(maxHeight: 56)
                .hidden()
                .font(Font.custom("Helvetica Neue", size: 15))
                .fixedSize(horizontal: false, vertical: true)
                .background(GeometryReader { proxy in
                    Color.clear
                        .onChange(of: question, perform: { value in
                            //print("height:\(proxy.size.height)")
                            heightForInput = proxy.size.height + 20.0
                            if heightForInput > 56 {
                                heightForInput = 56
                            }
                        })
                })
            
            Button(action: {
                if (question != "") {
                    // add new question
                    let identifier = UUID().uuidString
                    var oneMessage = Store.Message.init(messageBody: question, messageOriginMe: true, messageDate: Date(), messageId: UUID().uuidString)
                    messages.append(oneMessage)
                    store.saveMessages(messages: messages)
                    print("items: [\(items)]")

                    if (items.last == nil) { items.append(0) }
                    else { items.append(items.last! + 1) }

                    // add loading indicator
                    oneMessage = Store.Message.init(messageBody: "...", messageOriginMe: false, messageDate: Date(), messageId: UUID().uuidString)
                    messages = clearMessages(messages: messages)
                    messages.append(oneMessage)

                    items.append(items.last! + 1)
                    store.context(newQuestion: question) { (result: Result) in
                        switch result {
                        case .success(var text):
                            print("PRINT [\(text)]")
                            if (text == "") {
                                //response = "I already answered that"
                                callback("I already answered that")
                            } else {
                                //response = text
                                callback(text)
                                messages = clearMessages(messages: messages)
                                oneMessage = Store.Message.init(messageBody: text, messageOriginMe: false, messageDate: Date(), messageId: UUID().uuidString)
                                messages.append(oneMessage)
                                store.saveMessages(messages: messages)
                                question = ""
                                items.removeLast()
                                items.append(items.last! + 1)
                            }
                        case .failure(let error):
                            print("Error generating text: \(error)")
                        }
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
            }


    }
}

