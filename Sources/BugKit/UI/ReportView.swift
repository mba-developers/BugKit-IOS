//
//  ReportView.swift
//  BugKit
//
//  Created by Balavignesh on 03/12/25.
//

#if canImport(UIKit)
import SwiftUI
import UIKit
@available(iOS 14.0, *)
struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var description: String = ""
    @State private var attachments: [UIImage] = []
    
    var initialAttachment: UIImage?
    
    init(initialAttachment: UIImage?) {
        if let img = initialAttachment {
            _attachments = State(initialValue: [img])
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("We're here to help")) {
                    TextField("Your Email", text: $email)
                        .keyboardType(.emailAddress)
                    
                    TextEditor(text: $description)
                        .frame(height: 120)
                        .overlay(
                            Text("What went wrong?")
                                .foregroundColor(.gray)
                                .opacity(description.isEmpty ? 0.5 : 0)
                                .padding(.leading, 5),
                            alignment: .topLeading
                        )
                }
                
                Section(header: Text("Attachments")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(attachments, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .onTapGesture {

                                    }
                            }
                            
                            Button(action: {
                            }) {
                                VStack {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                                .frame(width: 80, height: 80)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: submitReport) {
                        Text("Submit Report")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Report an Issue")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func submitReport() {
        // Networking Logic (Using URLSession)
        NetworkManager.shared.uploadBug(email: email, desc: description, images: attachments) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
#endif
