//
//  MyBookings_BookingCardView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 03/09/25.
//

import SwiftUI

struct BookingCard: View {
    let title: String
    let joinName: String
    let date: Date
    let event: String
    let startTime: String
    let endTime: String
    let status: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 3){
            HStack {
                Text(title)
                    .font(.headline)
                    .accessibilityLabel("Booking for: \(title)")
                
                Spacer()
                
                Text(joinName)
                    .font(.subheadline.italic())
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Carpool information: \(joinName)")
            }
                                    
            Text("\(startTime) - \(endTime) WIB")
                .font(.headline)
                .accessibilityLabel("From: \(startTime) to: \(endTime) WIB")

            HStack {
                Text(event)
                    .font(.footnote)
                    .accessibilityLabel("Booking event: \(event)")
                Spacer()
                
                statusView(status: status)
                    .accessibilityLabel("Booking Status: \(status)")

            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        
    }
    
    
    private func statusView(status: String) -> some View {
        let color: Color
        let systemImage: String

        switch status {
        case "Pending":
            color = Color(.systemGray2)
            systemImage = "clock"
        case "Approved":
            color = Color(.systemBlue)
            systemImage = "checkmark"
        case "Declined":
            color = Color(.systemRed)
            systemImage = "xmark"
        default:
            color = Color(.systemOrange)
            systemImage = "minus"
        }

        return Label(status, systemImage: systemImage)
            .font(.subheadline.bold())
            .foregroundColor(color)
            .accessibilityLabel(status)
    }
}

#Preview {
    BookingCard(title: "Meeting Room 1", joinName: "Diana",date: Date(), event: "Rapat Keuangan 1", startTime: "08.00", endTime: "10.00", status: "Approved")
}
