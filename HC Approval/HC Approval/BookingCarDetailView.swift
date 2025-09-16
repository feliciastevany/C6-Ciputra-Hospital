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
    
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
    
    @State private var booking: BookingCar?
    @State private var driver: Driver?
    @State private var destination: [Destination] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Buat request carpool
    @State private var showCarpoolSheet = false
    @State private var carpoolDesc: String = ""
    @State private var isSubmitting = false
    @State private var showCancelCarpoolAlert = false
    
    // Cancel booking
    @State private var showCancelBookingAlert = false
//    @State private var showCancelBookingReasonSheet = false
//    @State private var bcDeclineReason: String = ""
    
    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading...")
            } else if let booking = booking {
                Form {
                    Section(header: Text("Status")) {
                        Text(booking.bc_status)
                        if booking.bc_status == "Declined" {
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
                    
                    // tombol Request Carpool
                    if loggedInUserId != booking.user_id {
                        Section(header: Text("Carpool Request")) {
                            if booking.carpool_req && loggedInUserId == booking.carpool_req_id && booking.carpool_status != "Cancelled" && booking.carpool_status != "Declined" {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Status:")
                                        
                                        if booking.carpool_status == "Pending" {
                                            Text("\(booking.carpool_status)")
                                                .foregroundColor(Color(.systemGray2))
                                        } else if booking.carpool_status == "Approved" {
                                            Text("\(booking.carpool_status)")
                                                .foregroundColor(Color(.systemBlue))
                                        } else if booking.carpool_status == "Declined" {
                                            Text("\(booking.carpool_status)")
                                                .foregroundColor(Color(.systemRed))
                                        }
                                    }
                                    
                                    if !booking.carpool_desc.isEmpty {
                                        Text("Desc: \(booking.carpool_desc)")
                                            .foregroundColor(.secondary)
                                            .padding(.bottom, 10)
                                    }
                                    
                                    Button(role: .destructive) {                                        
                                      showCancelCarpoolAlert = true
                                    } label: {
                                        Text("Cancel Request")
                                            .foregroundStyle(Color(.systemBackground))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 5)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .alert("Cancel Carpool", isPresented: $showCancelCarpoolAlert) {
                                        Button("Yes", role: .destructive) {
                                            Task {
                                                await cancelCarpool()
                                            }
                                        }
                                        .foregroundColor(.primary)
                                        Button("No", role: .cancel) { }
                                            .foregroundColor(.red)
                                    } message: {
                                        Text("Are you sure you want to cancel this carpool request?")
                                    }
                                }
                            } else {
                                Section {
                                    if booking.carpool_req && loggedInUserId != booking.carpool_req_id {
                                        Text("Someone has already requested a carpool for this booking")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Button(action: {
                                        Task {
                                            showCarpoolSheet = true
                                        }
                                    }) {
                                            Text("Request Carpool")
                                                .foregroundStyle(Color(.systemBackground))
                                                .font(.headline.bold())
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 5)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .cornerRadius(10)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                    .disabled(booking.carpool_req && booking.carpool_req_id != loggedInUserId)
                                }
                            }
                        }
                    } else if booking.bc_status != "Cancelled" && booking.bc_status != "Declined" && booking.user_id == loggedInUserId {
                        // cancel booking
                        Section {
                            Button(role: .destructive) {
                                showCancelBookingAlert = true
//                                showCancelBookingReasonSheet = true
                            } label: {
                                Text("Cancel Booking")
                                    .foregroundStyle(Color(.systemBackground))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 5)
                            }
                            .buttonStyle(.borderedProminent)
                            .cornerRadius(10)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .alert("Cancel Booking", isPresented: $showCancelBookingAlert) {
                                Button("Yes", role: .destructive) {
                                    Task {
                                        await cancelBookingCar()
                                    }
                                }
                                .foregroundColor(.primary)
                                Button("No", role: .cancel) { }
                                    .foregroundColor(.red)
                            } message: {
                                Text("Are you sure you want to cancel this booking request?")
                            }
                        }
                    }
                    
                }
                .foregroundColor(.secondary)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Back") {
                            dismiss()
                        }
                        .foregroundColor(Color(.systemBlue))
                    }
                }
                .navigationTitle("Booking Details")
                .sheet(isPresented: $showCarpoolSheet) {
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                        }
                        .overlay(
                            Text("Request Carpool")
                                .font(.headline)
                        )
                        .overlay(
                            Button(action: {
                                print("close pressed")
                                showCarpoolSheet = false
                                carpoolDesc = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(.systemGray2))
                                    .frame(width: 25, height: 25)
                            },
                            alignment: .trailing
                        )
                        
                        TextField("Enter description...", text: $carpoolDesc)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        if isSubmitting {
                            ProgressView()
                        }
                        
                        Button("Submit") {
                            print("pressed")
                            Task {
                                await requestCarpool()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(carpoolDesc.isEmpty || isSubmitting)
                    }
                    .padding()
                    .presentationDetents([.height(220)])
                }
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("No booking found")
            }
        }

        .onAppear {
            fetchBookingCar()
        }
    }
    
    // MARK: Fetch booking
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
    
    // MARK: Request Carpool
    func requestCarpool() async {
        guard let booking = booking else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        let updatePayload = CarpoolUpdate(
            carpool_req: true,
            carpool_desc: carpoolDesc,
            carpool_status: "Pending",
            carpool_req_id: loggedInUserId
        )
        
        do {
            let response = try await SupabaseManager.shared.client
                .from("bookings_car")
                .update(updatePayload)
                .eq("bc_id", value: booking.bc_id)
                .select() // penting untuk ambil hasil update
                .execute()
            
//            let updated: Void = response.value
//            print("Updated rows: \(updated)") // cek di Xcode console
            
            // Refresh booking
            fetchBookingCar()
            
            DispatchQueue.main.async {
                showCarpoolSheet = false
                carpoolDesc = ""
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: Cancel Carpool
    func cancelCarpool() async {
        guard let booking = booking else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        let updatePayload = CarpoolUpdate(
            carpool_req: false,
            carpool_desc: "",
            carpool_status: "", // atau "none"
            carpool_req_id: loggedInUserId
        )
        
        do {
            try await SupabaseManager.shared.client
                .from("bookings_car")
                .update(updatePayload)
                .eq("bc_id", value: booking.bc_id)
                .execute()
            
            // Refresh data setelah cancel
            fetchBookingCar()
            
            DispatchQueue.main.async {
                dismiss()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: Cancel Booking
    func cancelBookingCar() async {
        guard let booking = booking else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            try await SupabaseManager.shared.client
                .from("bookings_car")
                .update(["bc_status": "Cancelled", "carpool_status": "Cancelled"])
                .eq("bc_id", value: booking.bc_id)
                .execute()
            
            print("Booking car cancelled")
            
            fetchBookingCar()
            
            DispatchQueue.main.async {
                dismiss()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

}

#Preview{
    BookingCarDetailView(bcId: 8)
}
//extension String {
//    var formattedHourMinute: String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        
//        // coba format "HH:mm:ss" dulu
//        formatter.dateFormat = "HH:mm:ss"
//        if let date = formatter.date(from: self) {
//            let displayFormatter = DateFormatter()
//            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
//            displayFormatter.dateFormat = "HH:mm"
//            return displayFormatter.string(from: date)
//        }
//        
//        // fallback kalau input cuma "HH:mm"
//        formatter.dateFormat = "HH:mm"
//        if let date = formatter.date(from: self) {
//            let displayFormatter = DateFormatter()
//            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
//            displayFormatter.dateFormat = "HH:mm"
//            return displayFormatter.string(from: date)
//        }
//        
//        // fallback terakhir, kembalikan string asli
//        return self
//    }
//}

//#Preview {
//    BookingCarDetailView()
//}
