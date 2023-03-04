//
//  ChatView.swift
//  MyChatGPT
//
//  Created by Dario Caric on 26.02.2023..
//

import SwiftUI
import AVFoundation
import Foundation
import os

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    @Binding var scrollPosition: CGFloat
    
    init(scrollPosition: Binding<CGFloat>) {
        _scrollPosition = scrollPosition
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollPosition = scrollView.contentOffset.y
    }
}


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
    @State private var deleteOngoing: Bool = false
    @State private var questionAsked: Bool = false

    @State private var scrollPosition: CGFloat = 0

    
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

                                    var newMessages = [Store.Message]()
                                    for message in messages {
                                        print("*** message: \(message)")
                                        var delete: Bool = false
                                        if (messegesToDelete.contains(message.messageId)) {
                                            print("Message to delete id: \(message.messageId)")
                                            delete = true
                                        }
                                        if (!delete) {
                                            newMessages.append(message)
                                        }
                                    }
                                    messages = newMessages
                                    store.saveMessages(messages: messages)
                                    deleteOngoing = true
                                    loadValues()
                                } else {
                                    store.deleteHistory()
                                    historyList = [String]()
                                    messages = [Store.Message]()
                                    store.saveMessages(messages: messages)
                                    deleteOngoing = true
                                    loadValues()
                                }
                            }
                        )
                    )
                        
                }
                
                
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(messages.indices, id: \.self) { rowIndex in
                                HStack {
                                    
                                    // delete button on the left side of a row
                                    if (showingOptions) {
                                        Button(action: {
                                            //withAnimation(.easeInOut(duration: 4)) {
                                                if let indexOfDelMsg = messegesToDelete.firstIndex(of: messages[rowIndex].messageId) {
                                                    messegesToDelete.remove(at: indexOfDelMsg)
                                                    os_log("remove) rowIndex:\(rowIndex)  count:\(messegesToDelete.count)")
                                                } else {
                                                    messegesToDelete.append(messages[rowIndex].messageId)
                                                    os_log("add) rowIndex:\(rowIndex)  count:\(messegesToDelete.count)")
                                                    os_log("messageId:\(messages[rowIndex].messageId)")
                                                }
                                            //}
                                        }) {
                                            HStack {
                                                if messegesToDelete.contains(messages[rowIndex].messageId) {
                                                    Image(systemName: "checkmark.circle.fill")
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
                                    
                                    MessageBubble(text: messages[rowIndex].messageBody, messageDate: messages[rowIndex].messageDate, isCurrentUser: messages[rowIndex].messageOriginMe)
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: messages[rowIndex].messageOriginMe ? .trailing : .leading)
                                .animation(.easeInOut(duration: 0.3), value: showingOptions)
                                .transition(.slide)

                                
                            }
                        }
                    }
                    //HStack {
                    //    Button("Last!") { withAnimation { scrollProxy.scrollTo(items.last!) } }
                    //}
                    //.onTapGesture(count: 1) {
                    //    hideKeyboard()
                    //}
                    .onChange(of: items, perform: { _ in
                        if (!deleteOngoing && items.last != nil) { scrollProxy.scrollTo(items.last!) }
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

                                let tempQuestion: String = question
                                //question = ""
                                items.append(items.last! + 1)
                                store.context(newQuestion: tempQuestion) { (result: Result) in
                                    switch result {
                                    case .success(let text):
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
        deleteOngoing = false
    }
    
    
    func getDate(recDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d yyyy, HH:mm"
        return formatter.string(from: recDate)
    }
    
    func findScrollView() -> UIScrollView? {
        // recursively search the view hierarchy for a UIScrollView
        func find(in view: UIView) -> UIScrollView? {
            if let scrollView = view as? UIScrollView {
                return scrollView
            } else {
                for subview in view.subviews {
                    if let scrollView = find(in: subview) {
                        return scrollView
                    }
                }
                return nil
            }
        }
        return find(in: UIApplication.shared.windows.first?.rootViewController?.view ?? UIView())
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


