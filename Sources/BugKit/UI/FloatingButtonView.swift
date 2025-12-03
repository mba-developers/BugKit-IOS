//
//  FloatingButtonView.swift
//  BugKit
//
//  Created by Balavignesh on 03/12/25.
//

import SwiftUI

#if canImport(UIKit)
@available(iOS 13.0, *)
struct FloatingButtonView: View {
    // Just the UI. No drag logic here.
    var body: some View {
        Image(systemName: "ladybug.fill")
            .resizable()
            .padding(12)
            .background(Color.white)
            .foregroundColor(.blue)
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .shadow(radius: 4)
    }
}
#endif
