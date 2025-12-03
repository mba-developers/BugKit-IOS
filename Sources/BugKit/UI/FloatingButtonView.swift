//
//  FloatingButtonView.swift
//  BugKit
//
//  Created by Balavignesh on 03/12/25.
//

import SwiftUI

@available(iOS 13.0, macOS 11.0, *)
struct FloatingButtonView: View {
    var onTap: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var accumulatedOffset = CGSize.zero
    
    var body: some View {
        Image(systemName: "ladybug.fill")
            .resizable()
            .padding(12)
            .background(Color.white)
            .foregroundColor(.blue) // Brand Color
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .shadow(radius: 5)
            .offset(x: offset.width, y: offset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = CGSize(
                            width: accumulatedOffset.width + gesture.translation.width,
                            height: accumulatedOffset.height + gesture.translation.height
                        )
                    }
                    .onEnded { gesture in
                        // Snap to Edge Logic
                        // Note: UIScreen is iOS only. Ideally wrap logic or use GeometryReader for cross-platform
                        #if os(iOS)
                        let screenWidth = UIScreen.main.bounds.width
                        let buttonX = offset.width + (screenWidth - 80) // Absolute X
                        
                        let finalX: CGFloat
                        if buttonX < screenWidth / 2 {
                            finalX = -((screenWidth - 80)) + 20 // Snap Left
                        } else {
                            finalX = 0 // Snap Right (Original position)
                        }
                        
                        withAnimation(.spring()) {
                            offset.width = finalX
                        }
                        accumulatedOffset = offset
                        #endif
                    }
            )
            .onTapGesture {
                onTap()
            }
    }
}
