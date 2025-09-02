//
//  PendingView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 01/09/25.
//

import SwiftUI

struct PendingView: View {
    var title: String
    var event: String
    var date: Date
    var startTime: String
    var endTime: String
    
    var body: some View {
        VStack (alignment: .leading){
            Text(title)
                .font(.title3.bold())
            
            Text(date.toEnglishFormat())
                .font(.subheadline)
            
            Text("\(startTime) - \(endTime) WIB")
                .font(.subheadline.bold())
            
            Text(event)
                .font(.footnote.bold())
            
            
            HStack {
                Button(action: {
                    print("button clicked")
                })  {
                    HStack {
                        Spacer ()
                        Image(systemName: "xmark")
                            .font(.headline.bold())
                        
                        Text("Decline")
                            .font(.headline.bold())
                        Spacer ()
                    }
                    .padding(.vertical, 10)
                    .background(Color(.systemRed))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Spacer()
                
                Button(action: {
                    print("button clicked")
                })  {
                    HStack {
                        Spacer ()
                        Image(systemName: "checkmark")
                            .font(.headline.bold())
                        
                        Text("Approve")
                            .font(.headline.bold())
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color(.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
