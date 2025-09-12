//
//  StatusView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 01/09/25.
//

import SwiftUI

struct StatusView: View {
    var title: String
    var eventView: AnyView
    var date: Date
    var startTime: String
    var endTime: String
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading, spacing: 3){
                HStack {
                    Text(title)
                        .font(.headline)
                        .accessibilityLabel("Booking for: \(title)")
                    
                    Spacer()
                    
                    Text(date.toEnglishFormat())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("")
                        .accessibilityHint("On: \(date.toEnglishFormat())")
                }
                
                Text("\(startTime) - \(endTime) WIB")
                    .font(.headline)
                    .accessibilityLabel("From \(startTime) to \(endTime) WIB")
                
//                Text(event)
//                    .font(.footnote)
//                    .accessibilityLabel("Booking Event: \(event)")
                eventView
            
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(10)
        }
    }
}

#Preview {
    ApprovalsView()
}
