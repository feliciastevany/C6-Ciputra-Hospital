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
            Text(title)
                .font(.headline)
            Text("\(startTime) - \(endTime) WIB")
                .font(.headline)
            
            HStack {
                Text(event)
                    .font(.footnote)
                
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
                .foregroundColor(Color(.systemGray2))
            Text(status)
                .font(.subheadline.bold())
                .foregroundColor(Color(.systemGray2))
        case "Approved":
            Image(systemName: "checkmark")
                .foregroundColor(Color(.systemBlue))
            Text(status)
                .font(.subheadline.bold())
                .foregroundColor(Color(.systemBlue))
        case "Declined":
            Image(systemName: "xmark")
                .foregroundColor(Color(.systemRed))
            Text(status)
                .font(.subheadline.bold())
                .foregroundColor(Color(.systemRed))
        default:
            Image(systemName: "minus")
                .foregroundColor(Color(.systemOrange))
            Text(status)
                .font(.subheadline.bold())
                .foregroundColor(Color(.systemOrange))
        }
    }
}

