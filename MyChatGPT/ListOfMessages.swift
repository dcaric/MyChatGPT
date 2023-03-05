//
//  ListOfMessages.swift
//  MyChatGPT
//
//  Created by Dario Caric on 05.03.2023..
//

import SwiftUI
import os

struct ListOfMessages: View {
    
    @Binding var messages: [Store.Message]
    @Binding var showingOptions: Bool
    @Binding var messegesToDelete: [String]
    
    var body: some View {
        ForEach(messages.indices, id: \.self) { rowIndex in
            HStack {
                
                // delete button on the left side of a row
                if (showingOptions) {
                    Button(action: {
                        if let indexOfDelMsg = messegesToDelete.firstIndex(of: messages[rowIndex].messageId) {
                            messegesToDelete.remove(at: indexOfDelMsg)
                            os_log("remove) rowIndex:\(rowIndex)  count:\(messegesToDelete.count)")
                        } else {
                            messegesToDelete.append(messages[rowIndex].messageId)
                            os_log("add) rowIndex:\(rowIndex)  count:\(messegesToDelete.count)")
                            os_log("messageId:\(messages[rowIndex].messageId)")
                        }
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
