//
//  ChatView.swift
//  MyChatGPT
//
//  Created by Dario Caric on 26.02.2023..
//

import SwiftUI
import AVFoundation
import Foundation

struct ChatView: View {
    
    @State private var historyList = [String]()
    @State private var messages = [Store.Message]()
    @State private var tableHeight : CGFloat = .infinity
    @State private var heightForInput: CGFloat = 30
    @State private var question: String = ""
    @State private var store = Store()
    @State private var response: String = ""
    @State private var loadedOnce: Bool = true
    @State private var showsAlert = false
    @State private var loading = DotView()
    @State private var items = [Int]()
    @State private var showingOptions = false
    @State private var messegesToDelete = [String]()

    
    var body: some View {

        ZStack {
            VStack {
                HStack {
                    Spacer()
                    
                    Label("ChatGPT", systemImage: "brain.head.profile")
                        .font(Font.custom("Helvetica Neue", size: 30))
                    
                    Spacer()
                    Spacer()

                    Button(action: {
                        //store.deleteHistory()
                        //historyList = [String]()
                        showsAlert = true
                        
                    }) {
                        HStack {
                            Image(systemName: "trash")
                        }
                    }
                    .padding(.pi*3)
                    .foregroundColor(.white)
                    .background(Color(uiColor: .systemBlue))
                    .cornerRadius(.infinity)
                    
                    
                    Button(action: {
                        //store.deleteHistory()
                        //historyList = [String]()
                        showingOptions = !showingOptions
                        messegesToDelete = [String]()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.bubble")
                        }
                    }
                    .padding(.pi*3)
                    .foregroundColor(.white)
                    .background(Color(uiColor: .systemBlue))
                    .cornerRadius(.infinity)
                    
                    Spacer()
                }
                .alert(isPresented: $showsAlert) {
                    var title = "Delete all chat history"
                    if (showingOptions) {
                        title = "Delete selected"
                    }
                    return Alert(
                        title: Text(title),
                        message: Text(""),
                        primaryButton: .default(
                            Text("Cancel"),
                            action: {
                                showsAlert = false
                                showingOptions = false

                            }
                        ),
                        secondaryButton: .destructive(
                            Text("Delete"),
                            action: {
                                showsAlert = false
                                if (showingOptions) {
                                    showingOptions = false
                                    items = [Int]()
                                    items.append(0)

                                    var newMessages = [Store.Message]()
                                    newMessages = messages
                                    for message in messages {
                                        print("*** message: \(message)")

                                        if let index = messegesToDelete.firstIndex(of: message.messageId) {
                                            print("foound at inde: \(index)")
                                            newMessages.remove(at: index)
                                        }
                                    }
                                    messages = [Store.Message]()
                                    for message in newMessages {
                                        print("message: \(message)")

                                        messages.append(message)
                                        items.append(items.last! + 1)
                                    }
                                    store.saveMessages(messages: messages)
                                } else {
                                    store.deleteHistory()
                                    historyList = [String]()
                                    items = [Int]()
                                    messages = [Store.Message]()
                                    store.saveMessages(messages: messages)
                                    loadValues()
                                }
                            }
                        )
                    )
                        
                }
                
                
                ScrollViewReader { scrollProxy in
                    ScrollView (.vertical, showsIndicators: false, content: {
                        ForEach(messages.indices, id: \.self) { rowIndex in
                            HStack {
                                
                                // delete button on the left side of a row
                                if (showingOptions) {
                                    Button(action: {
                                        if let indexOfDelMsg = messegesToDelete.firstIndex(of: messages[rowIndex].messageId) {
                                            messegesToDelete.remove(at: indexOfDelMsg)
                                        } else {
                                            messegesToDelete.append(messages[rowIndex].messageId)
                                        }
                                    }) {
                                        HStack {
                                            if (rowIndex <= messegesToDelete.count && messegesToDelete.count > 0) {
                                                if let msgToDel = messegesToDelete[rowIndex] {
                                                    if (msgToDel == messages[rowIndex].messageId) {
                                                        Image(systemName: "checkmark.circle.fill")
                                                    }
                                                }
                                            } else {
                                                Image(systemName: "circle")
                                            }
                                        }
                                    }
                                    .padding(.pi*2)
                                    .foregroundColor(Color(uiColor: .systemGray))
                                    //.background(Color(uiColor: .systemGray))
                                    .cornerRadius(.infinity)
                                    
                                    Spacer()
                                }
                                
                                                                
                                if (messages[rowIndex].messageOriginMe) {
                                    Spacer()
                                        .frame(width: 10)
                                    VStack {
                                        Text(messages[rowIndex].messageBody)
                                            .padding()
                                            .frame(alignment: .trailing)
                                            .background(Color(uiColor: .systemBlue))
                                            .foregroundColor(Color(uiColor: .white))
                                            .cornerRadius(16)
                                            .font(Font.custom("Helvetica Neue", size: 20))
    
                                                                            
                                        Label(getDate(recDate: messages[rowIndex].messageDate), systemImage: "calendar.badge.clock")
                                            .labelStyle(.titleOnly)
                                            .font(Font.custom("Helvetica Neue", size: 12))
                                    }
                                    .textSelection(.enabled)
                                    
                                } else {
                                    if (messages[rowIndex].messageBody == "...") {
                                        LoadingView()

                                    } else {
                                        VStack {
                                            Text(messages[rowIndex].messageBody)
                                                .padding()
                                                .background(Color(uiColor: .lightGray))
                                                .foregroundColor(Color(uiColor: .black))
                                                .cornerRadius(16)
                                                .font(Font.custom("Helvetica Neue", size: 20))
                                            
                                            Label(getDate(recDate: messages[rowIndex].messageDate), systemImage: "calendar.badge.clock")
                                                .labelStyle(.titleOnly)
                                                .font(Font.custom("Helvetica Neue", size: 12))
                                        }
                                        .textSelection(.enabled)
                                    }
                                    Spacer()
                                        .frame(width: 10)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: messages[rowIndex].messageOriginMe ? .trailing : .leading)

                            
                        }
                    })
                    //HStack {
                    //    Button("Last!") { withAnimation { scrollProxy.scrollTo(items.last!) } }
                    //}
                    //.onTapGesture(count: 1) {
                    //    hideKeyboard()
                    //}
                    .onChange(of: items, perform: { _ in
                        if (items.last != nil) { scrollProxy.scrollTo(items.last!) }
                    })
                }
                .padding(.all)

                Group {

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
                                            response = "I already answered that"
                                        } else {
                                            response = text
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
            _ = store.zipHistory()

        }
        .onAppear {
            print("READ HISTORY loadedOnce: \(loadedOnce)")
            
            if (loadedOnce) {
                loadedOnce = false
                loadValues()
            }
        }
        .onChange(of: historyList, perform: { value in

            
        })
    }
    
    func loadValues() {
        messages = store.readMessages()
        messages = clearMessages(messages: messages)
        print("READ HISTORY count:\(messages.count)")
        var count = 0;
        for message in messages {
            print("message: \(message.messageBody)")
            items.append(count)
            count += 1
        }
    }
    
    
    func getDate(recDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d yyyy, HH:mm"
        return formatter.string(from: recDate)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

func clearMessages(messages: [Store.Message]) -> [Store.Message] {
    var messagesFixed = [Store.Message]()
    for message in messages {
        if message.messageBody != "..." {
            messagesFixed.append(message)
        }
    }
    return messagesFixed
}


