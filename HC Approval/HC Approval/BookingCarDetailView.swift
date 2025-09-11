//
//  BookingCarDetailView.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 09/09/25.
//

import SwiftUI

struct BookingCarDetailView: View {
    @Environment(\.dismiss) var dismiss
    var bcId: Int
    
    @State private var booking: BookingCar?
    @State private var driver: Driver?
    @State private var destination: [Destination] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading...")
            } else if let booking = booking {
                Form {
                    Section(header: Text("Status")) {
                        Text(booking.bc_status)
                        if !booking.bc_decline_reason.isEmpty {
                            Text("Reason: \(booking.bc_decline_reason)")
//                                .foregroundColor(.red)
                        }
                    }
                    
                    Section(header: Text("Driver & Passenger Info")) {
                        Text(driver?.driver_name ?? "-")
                        Text("\(booking.bc_people) passengers")
                    }
                    
                    Section(header: Text("Booking")) {
                        HStack {
                            Text("Date")
                            Spacer()
                            Text(DateHelper.toDisplayFormat(booking.bc_date))
                        }
                        
                        HStack {
                            Text("Departure")
                            Spacer()
                            Text(booking.bc_start.formattedHourMinute)
                        }
                        
                        HStack {
                            Text("Arrival")
                            Spacer()
                            Text(booking.bc_end.formattedHourMinute)
                        }
                    }
                    
                    Section(header: Text("From")) {
                        Text(booking.bc_from)
                    }
                    
                    Section(header: Text("Destinations")) {
                        if !destination.isEmpty {
                            ForEach(destination) { dest in
                                Text(dest.destination_name)
                            }
                        } else {
                            Text("-")
                        }
                    }
                    
                    Section(header: Text("Description")) {
                        Text(booking.bc_desc.isEmpty ? "-" : booking.bc_desc)
                    }
                    
                }
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("No booking found")
            }
        }
        .navigationTitle("Booking Details")
        .onAppear {
            fetchBookingCar()
        }
    }
    
    func fetchBookingCar() {
        isLoading = true
        Task {
            do {
                // 1. Ambil booking car
                let bcResponse: [BookingCar] = try await SupabaseManager.shared.client
                    .from("bookings_car")
                    .select("*")
                    .eq("bc_id", value: bcId)
                    .execute()
                    .value
                
                guard let bookingCar = bcResponse.first else {
                    throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Booking tidak ditemukan"])
                }
                
                // 2. Ambil driver
                let driverResponse: [Driver] = try await SupabaseManager.shared.client
                    .from("drivers")
                    .select("*")
                    .eq("driver_id", value: bookingCar.driver_id)
                    .execute()
                    .value
                
                // 3. Ambil destinations
                let destinationIds: [Destination] = try await SupabaseManager.shared.client
                    .from("destinations")
                    .select("*")
                    .eq("bc_id", value: bookingCar.bc_id)
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.booking = bookingCar
                    self.driver = driverResponse.first
                    self.destination = destinationIds
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

extension String {
    var formattedHourMinute: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // coba format "HH:mm:ss" dulu
        formatter.dateFormat = "HH:mm:ss"
        if let date = formatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        
        // fallback kalau input cuma "HH:mm"
        formatter.dateFormat = "HH:mm"
        if let date = formatter.date(from: self) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        
        // fallback terakhir, kembalikan string asli
        return self
    }
}

//#Preview {
//    BookingCarDetailView()
//}
