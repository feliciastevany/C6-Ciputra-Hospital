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
            Text(date.toEnglishFormat())
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack (alignment: .leading){
                HStack {
                    VStack (alignment: .leading){
                        Text(title)
                            .font(.title3.bold())
                        
                        Text("\(startTime) - \(endTime) WIB")
                            .font(.title3.bold())
                        
                        Text(event)
                            .font(.footnote.bold())
                    }
                    Spacer()
                }
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(14)
        }
    }
}
