//
//  MyBookings_BookingCardView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 03/09/25.
//

import SwiftUI

struct BookingCard: View {
    let title: String
    let date: Date
    let event: String
    let startTime: String
    let endTime: String
    let status: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 3){
//            HStack {
                Text(title)
                    .font(.title3.bold())
                
//                Spacer()
//                
//                Text(date.toEnglishFormat())
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//            }
            
            Text("\(startTime) - \(endTime) WIB")
                .font(.title3.bold())
            
            HStack {
                Text(event)
                    .font(.subheadline)
                
                Spacer()
                
                statusView(status: status)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func statusView(status: String) -> some View {
        switch status {
        case "Pending":
            Image(systemName: "clock")
                .foregroundColor(Color(.systemOrange))
            Text(status)
                .font(.headline.bold())
                .foregroundColor(Color(.systemOrange))
        case "Approved":
            Image(systemName: "checkmark")
                .foregroundColor(Color(.systemGreen))
            Text(status)
                .font(.headline.bold())
                .foregroundColor(Color(.systemGreen))
        case "Declined":
            Image(systemName: "xmark")
                .foregroundColor(Color(.systemRed))
            Text(status)
                .font(.headline.bold())
                .foregroundColor(Color(.systemRed))
        default:
            Image(systemName: "minus")
                .foregroundColor(Color(.systemOrange))
            Text(status)
                .font(.headline.bold())
                .foregroundColor(Color(.systemOrange))
        }
    }
}

