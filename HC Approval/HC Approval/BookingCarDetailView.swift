//
//  BookingCarDetailView.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 09/09/25.
//

import SwiftUI

struct BookingCarDetailView: View {
    var booking: BookingCarJoined
    
    var body: some View {
        Form {
            Section(header: Text("Driver & Passenger Info")) {
                Text(booking.driver?.driver_name ?? "-")
                Text("\(booking.bc_people) passengers")
            }
            
            Section(header: Text("Booking")) {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(booking.bc_date.toSimpleFormat())
                }
                
                HStack {
                    Text("Departure")
                    Spacer()
                    Text(booking.bc_start)
                }
                
                HStack {
                    Text("Arrival")
                    Spacer()
                    Text(booking.bc_end)
                }
            }
            
            Section(header: Text("From")) {
                Text(booking.bc_from)
            }
            
            Section(header: Text("Destinations")) {
                if let destinations = booking.destination, !destinations.isEmpty {
                    ForEach(destinations) { dest in
                        Text(dest.destination_name)
                    }
                } else {
                    Text("-")
                }
            }
            
            Section(header: Text("Description")) {
                Text(booking.bc_desc.isEmpty ? "-" : booking.bc_desc)
            }
            
            Section(header: Text("Status")) {
                Text(booking.bc_status)
                if !booking.bc_decline_reason.isEmpty {
                    Text("Reason: \(booking.bc_decline_reason)")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Booking Details")
    }
}


//#Preview {
//    BookingCarDetailView()
//}
