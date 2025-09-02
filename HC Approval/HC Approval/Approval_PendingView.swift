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
    
    var onApprove: () -> Void
    var onDecline: () -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 3){
            HStack {
                Text(title)
                    .font(.title3.bold())
                
                Spacer()
                
                Text(date.toEnglishFormat())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text("\(startTime) - \(endTime) WIB")
                .font(.title3.bold())
            
            Text(event)
                .font(.subheadline)
            
            HStack {
                Button(action: {
                    onDecline()
                    print("button declined")
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
                    onApprove()
                    print("button approved")
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
            .padding(.top, 10)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
