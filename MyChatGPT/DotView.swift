//
//  Dots.swift
//  MyChatGPT
//
//  Created by Dario Caric on 27.02.2023..
//

import Foundation
import SwiftUI


struct DotView: View {
    @State var delay: Double = 0 // 1.
    @State var scale: CGFloat = 0.5
    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .scaleEffect(scale)
            .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(delay), value: scale)
            .onAppear {
                withAnimation {
                    self.scale = 1
                }
            }
    }
}


struct LoadingView: View {
    var body: some View {
        HStack {
            DotView() // 1.
            DotView(delay: 0.2) // 2.
            DotView(delay: 0.4) // 3.
        }
    }
}
