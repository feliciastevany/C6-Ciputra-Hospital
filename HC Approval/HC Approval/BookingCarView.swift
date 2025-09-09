//
//  BookingCarView.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 03/09/25.
//

import SwiftUI

struct BookingCarView: View {
    @State private var date = Date()
    @State private var passengers: Int = 1
    @State private var goToAvailable = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker("Date", selection: $date, in: Date()..., displayedComponents: .date)
                
                HStack {
                    Text("Passengers")
                    Spacer()
                    Text("\(passengers)")
                        .frame(width: 30, alignment: .center)
                    Stepper("", value: $passengers, in: 1...500)
                        .labelsHidden()
                }
                
                NavigationLink(
                    destination: AvailableDriversView(date: DateHelper.toBackendFormat(date), passengers: passengers),
                    isActive: $goToAvailable) {
                        EmptyView()
                    }
                
                    Button("Browse Drivers") {
                        goToAvailable = true
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(3)
                    .background(Color.blue)
                    .cornerRadius(8)
                
//                Text("Schedule")
//                    .font(.headline)
//                    .padding(.horizontal)
//
//                List(rooms) { room in
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(room.name)
//                                .font(.body)
//                                .bold()
//                            Text("Capacity: \(room.capacity)")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.vertical, 4)
//                }
//                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationTitle("Cars")
        }
    }
}

struct AvailableDriversView: View {
    @State private var showSheet = true
    @StateObject private var vm = BookingSearchViewModel()
    var date: String
    var passengers: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text(DateHelper.toDisplayFormat(date))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(vm.availableDrivers) { driverAvail in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(driverAvail.driver.driver_name)
                                .font(.headline)
                        }
                        
//                        let availableSlots = BookingTimeHelper.availableStartTimes(bookings: driverAvail.bookings)
                        
                        let availableSlots = BookingTimeHelper.availableStartTimesIgnoringCancelled(bookings: driverAvail.bookings)
                        
                        if availableSlots.isEmpty {
                            Text("Tidak ada slot tersedia")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            // Horizontal scroll of slots
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(availableSlots, id: \.self) { start in
                                        NavigationLink(
                                            destination: CarDetailView(
                                                driver: driverAvail.driver,
                                                slot: TimeSlot(start: start, end: ""),
                                                date: date,
                                                passengers: passengers,
                                                bookings: driverAvail.bookings
                                            )
                                        ) {
                                            Text(start)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                        
//                        if driverAvail.availableSlots.isEmpty {
//                            Text("Tidak ada slot tersedia")
//                                .foregroundColor(.secondary)
//                                .padding(.vertical, 8)
//                        } else {
//                            // Horizontal scroll of slots
//                            ScrollView(.horizontal, showsIndicators: false) {
//                                HStack(spacing: 8) {
//                                    ForEach(driverAvail.availableSlots) { slot in
//                                        NavigationLink(
//                                            destination: CarDetailView(
//                                                driver: driverAvail.driver,
//                                                slot: slot,
//                                                date: date,
//                                                passengers: passengers,
//                                                bookings: driverAvail.bookings
//                                            )
//                                        ) {
//                                            Text(slot.start)
//                                                .padding(.vertical, 8)
//                                                .padding(.horizontal, 12)
//                                                .background(Color.blue)
//                                                .foregroundColor(.white)
//                                                .cornerRadius(8)
//                                        }
//                                    }
//                                }
//                            }
//                        }
                        
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .navigationTitle("Available Drivers")
        .task {
            await vm.searchDriver(date: date)
        }
        .alert(item: Binding(
            get: { vm.errorMessage.map { ErrorWrapper(message: $0) } },
            set: { _ in vm.errorMessage = nil }
        )) { wrapper in
            Alert(title: Text("Info"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
        }
    }
}

//struct CarDetailView: View {
//    @Environment(\.dismiss) private var dismiss
//    
//    var driver: Driver
//    var slot: TimeSlot
//    var date: String
//    var passengers: Int
//    var bookings: [BookingCar]
//    
//    @State private var startTime: String = ""
//    @State private var endTime: String = ""
//    @State private var goToSchedule = false
//    @State private var fromPlace = ""
//    @State private var destinations: [String] = []   // daftar tujuan
//    @State private var newDestination: String = ""   // input sementara
//    @State private var outingDesc = ""
//    
////    @State private var showUserPicker = false
////    @State private var selectedUsers: [User] = []
//    
////    @State private var selectedProperties: [SelectedProperty] = []
////    @State private var showPropertyPicker = false
//    
//    @State private var showSuccess = false
//    
//    private var availableTimeOptions: [String] {
//        BookingTimeHelper.availableStartTimes(bookings: bookings)
//    }
//    
//    private var validEndOptions: [String] {
//        BookingTimeHelper.validEndTimes(startTime: startTime, bookings: bookings)
//    }
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Driver & Passenger Info")) {
//                Text(driver.driver_name)
//                Text("\(passengers) passengers")
//            }
//            
//            Section(header: Text("Booking")) {
//                HStack {
//                    Text("Date")
//                    Spacer()
//                    Text(DateHelper.toDisplayFormat(date))
//                }.frame(maxWidth: .infinity)
//                
//                Picker("Departure", selection: $startTime) {
//                    ForEach(availableTimeOptions, id: \.self) { time in
//                        Text(time).tag(time)
//                    }
//                }
//                
//                Picker("Arrival", selection: $endTime) {
//                    ForEach(validEndOptions, id: \.self) { time in
//                        Text(time).tag(time)
//                    }
//                }.disabled(startTime.isEmpty)
//            }
//            
//            Section {
//                TextField("From", text: $fromPlace)
//            }
//            
//            Section(header: Text("Destinations")) {
//                ForEach(destinations, id: \.self) { dest in
//                    Text(dest)
//                }
//                .onDelete { indexSet in
//                    destinations.remove(atOffsets: indexSet)
//                }
//                
//                HStack {
//                    TextField("Add destination", text: $newDestination)
//                    Button(action: {
//                        if !newDestination.isEmpty {
//                            destinations.append(newDestination)
//                            newDestination = ""
//                        }
//                    }) {
//                        Image(systemName: "plus.circle.fill")
//                            .foregroundColor(.blue)
//                    }
//                }
//            }
//            
//            Section {
//                TextField("Description", text: $outingDesc)
//            }
//
//            
////            Section {
////                HStack {
////                    Text("Participant")
////                    Spacer()
////                    Button {
////                        showUserPicker = true
////                    } label: {
////                        Image(systemName: "plus")
////                    }
////                }
////                
////                HStack() {
////                    let maxVisible = 5
////                    ForEach(selectedUsers.prefix(maxVisible)) { user in
////                        Circle()
////                            .fill(Color.gray.opacity(0.3))
////                            .frame(width: 32, height: 32)
////                            .overlay(
////                                Text(user.user_name.initials)
////                                    .font(.caption)
////                                    .fontWeight(.semibold)
////                                    .foregroundColor(.black)
////                            )
////                            .overlay(
////                                Circle().stroke(Color.white, lineWidth: 2)
////                            )
////                    }
////
////                    if selectedUsers.count > maxVisible {
////                        let extra = selectedUsers.count - maxVisible
////                        Circle()
////                            .fill(Color.gray.opacity(0.3))
////                            .frame(width: 32, height: 32)
////                            .overlay(
////                                Text("+\(extra)")
////                                    .font(.caption)
////                                    .fontWeight(.semibold)
////                                    .foregroundColor(.black)
////                            )
////                            .overlay(
////                                Circle().stroke(Color.white, lineWidth: 2)
////                            )
////                    } else if selectedUsers.isEmpty {
////                        Text("No participants selected")
////                            .foregroundColor(.secondary)
////                    }
////                }
////            }
//            
//            Button("Booking") {
//                Task {
//                    await addBooking()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .frame(maxWidth: .infinity)
//        }
//        .navigationTitle("Booking Details")
//        .alert("Booking berhasil!", isPresented: $showSuccess) {
//            Button("OK") {
//                dismiss()
//            }
//        }
//        .onAppear {
//            if startTime.isEmpty {
//                startTime = slot.start // dari slot yg dipilih
//            }
//            if endTime.isEmpty, let last = validEndOptions.last {
//                endTime = last
//            }
//        }
////        .sheet(isPresented: $showUserPicker) {
////            UserPickerView(selectedUsers: $selectedUsers)
////        }
//    }
//    
//    let bookingService = BookingService()
//
//    func addBooking() async {
//        do {
//            let booking = BookingCarInsert(
//                user_id: 1,
//                driver_id: driver.driver_id,
//                bc_date: date,
//                bc_start: startTime,
//                bc_end: endTime,
//                bc_from: fromPlace,
//                bc_desc: outingDesc,
//                bc_people: passengers,
//                bc_status: "Pending",
//                carpool_req: false
//            )
//            
//            guard let created = try await BookingService.shared.createBookingCar(booking) else { return }
//            
////            try await BookingService.shared.addParticipants(
////                selectedUsers.map { Participant(user_id: $0.user_id, br_id: created.br_id, pic: false) }
////            )
//            
//            for dest in destinations {
//                let destinationInsert = DestinationInsert(destination_name: dest, bc_id: created.bc_id)
//                try await BookingService.shared.addDestinations(destinationInsert)
//            }
//            
//            await MainActor.run {
//                showSuccess = true
//            }
//            
//        } catch {
//            print("Error: \(error)")
//        }
//    }
//}

struct CarDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var driver: Driver
    var slot: TimeSlot
    var date: String
    var passengers: Int
    var bookings: [BookingCar]
    
    @State private var startTime: String = ""
    @State private var endTime: String = ""
//    @State private var goToSchedule = false
    @State private var outingDesc = ""
    
    @State private var from: String = ""
    @State private var destinations: [String] = [""]
    @State private var showSuccess = false
    
    private var availableTimeOptions: [String] {
        BookingTimeHelper.availableStartTimes(bookings: bookings)
    }
    
    private var validEndOptions: [String] {
        BookingTimeHelper.validEndTimes(startTime: startTime, bookings: bookings)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Driver & Passenger Info")) {
                Text(driver.driver_name)
                Text("\(passengers) passengers")
            }
            
            Section(header: Text("Booking")) {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(DateHelper.toDisplayFormat(date))
                }.frame(maxWidth: .infinity)
                
                Picker("Departure", selection: $startTime) {
                    ForEach(availableTimeOptions, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                
                Picker("Arrival", selection: $endTime) {
                    ForEach(validEndOptions, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }.disabled(startTime.isEmpty)
            }
            
            Section(header: Text("From")) {
                TextField("From", text: $from)
            }
            
            Section(header: Text("Destinations")) {
                ForEach(Array(destinations.enumerated()), id: \.offset) { index, dest in
                    HStack {
                        TextField("Destination \(index + 1)", text: $destinations[index])
                        if destinations.count > 1 {
                            Button(action: {
                                destinations.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Button(action: {
                    destinations.append("")
                }) {
                    Label("Add Destination", systemImage: "plus.circle.fill")
                }
            }
            
            Section {
                TextField("Description", text: $outingDesc)
            }
            
            Button("Booking") {
                Task {
                    await addBooking()
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Booking Details")
        .alert("Booking berhasil!", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        }
        .onAppear {
            if startTime.isEmpty {
                startTime = slot.start
            }
            if endTime.isEmpty, let last = validEndOptions.last {
                endTime = last
            }
        }
    }
    
    let bookingService = BookingService()

    func addBooking() async {
        do {
            // 1. Insert Booking Car
            let booking = BookingCarInsert(
                user_id: 1,
                driver_id: driver.driver_id,
                bc_date: date,
                bc_start: startTime,
                bc_end: endTime,
                bc_from: from,
                bc_desc: outingDesc,
                bc_people: passengers,
                bc_status: "Pending",
                carpool_req: false
            )
            
            guard let created = try await BookingService.shared.createBookingCar(booking) else { return }
            
            // 2. Insert Destinations
            let validDestinations = destinations
                .filter { !$0.isEmpty }
                .map { DestinationInsert(destination_name: $0, bc_id: created.bc_id) }
            
            if !validDestinations.isEmpty {
                _ = try await BookingService.shared.addDestinations(validDestinations)
            }
            
            await MainActor.run {
                showSuccess = true
            }
            
        } catch {
            print("Error: \(error)")
        }
    }
}


//struct CarScheduleView: View {
//    var room: Room
//    var date: String
//    var bookings: [BookingRoom]
//    
//    var body: some View {
//        List {
//            ForEach(bookings) { booking in
//                VStack(alignment: .leading) {
//                    Text(booking.br_event)
//                        .font(.headline)
//                    Text("\(booking.br_start) - \(booking.br_end)")
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//        .navigationTitle("\(room.room_name) Schedule")
//    }
//}

#Preview {
    BookingCarView()
}
