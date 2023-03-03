//
//  MessageBubble.swift
//  MyChatGPT
//
//  Created by Dario Caric on 03.03.2023..
//

import SwiftUI

struct MessageBubble: View {
    var text: String
    var messageDate: Date
    var isCurrentUser: Bool
    
    
    var body: some View {
        Group {
            if (isCurrentUser) {
                HStack {
                    Spacer()
                    VStack {
                        Text(text)
                            .padding()
                            .background(Color(uiColor: .systemBlue))
                            .foregroundColor(Color(uiColor: .white))
                            .clipShape(MessageBubbleShape(isCurrentUser: true))
                            .padding(5)
                        
                        Label(getDate(recDate: messageDate), systemImage: "calendar.badge.clock")
                        .labelStyle(.titleOnly)
                        .font(Font.custom("Helvetica Neue", size: 12))
                    }
                    .textSelection(.enabled)
                }
            } else {
                HStack {
                    if (text == "...") {
                        LoadingView()

                    } else {
                        VStack {
                            Text(text)
                                .padding()
                                .background(Color(uiColor: .lightGray))
                                .foregroundColor(Color(uiColor: .black))
                                .clipShape(MessageBubbleShape(isCurrentUser: false))
                                .padding(5)
                            
                            Label(getDate(recDate: messageDate), systemImage: "calendar.badge.clock")
                            .labelStyle(.titleOnly)
                            .font(Font.custom("Helvetica Neue", size: 12))
                        }
                        .textSelection(.enabled)
                    }
                    Spacer()
                }
            }
        }
    }
    

    func getDate(recDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d yyyy, HH:mm"
        return formatter.string(from: recDate)
    }
    

}

    

    
struct MessageBubbleShape: Shape {
    var isCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, isCurrentUser ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        return Path(path.cgPath)
    }
}


