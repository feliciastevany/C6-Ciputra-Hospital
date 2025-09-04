//
//  StatusView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 01/09/25.
//

import SwiftUI

struct StatusView: View {
    var title: String
    var event: String
    var date: Date
    var startTime: String
    var endTime: String
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading, spacing: 3){
                HStack {
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(date.toEnglishFormat())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text("\(startTime) - \(endTime) WIB")
                    .font(.headline)
                
                Text(event)
                    .font(.footnote)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(14)
        }
    }
}
