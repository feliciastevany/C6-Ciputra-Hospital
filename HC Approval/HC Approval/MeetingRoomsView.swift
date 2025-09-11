//
//  MeetingRoomsView.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 01/09/25.
//

import SwiftUI

struct MeetingRoomsView: View {
    
    @State private var date = Date()
    @State private var capacity: Int = 1
    @State private var goToAvailable = false
    
    var body: some View {
        //        NavigationView {
        VStack (spacing: 10){
            VStack {
                DatePicker("Date", selection: $date, in: Date()..., displayedComponents: .date)
                
                Divider()
                
                HStack {
                    Text("Capacity")
                    Spacer()
                    Text("\(capacity)")
                        .frame(width: 30, alignment: .center)
                    Stepper("", value: $capacity, in: 1...500)
                        .labelsHidden()
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            
            NavigationLink(
                destination: AvailableRoomsView(date: DateHelper.toBackendFormat(date),capacity: Int(capacity) ?? 1),
                isActive: $goToAvailable) {
                    EmptyView()
                }
            
            Button(action: {
                goToAvailable = true
            }) {
                Text("Browse Rooms")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
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
        .background(Color(.systemGray6))
        //        }
    }
}

struct AvailableRoomsView: View {
    @State private var showSheet = true
    @StateObject private var vm = BookingSearchViewModel()
    var date: String
    var capacity: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text(DateHelper.toDisplayFormat(date))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(vm.availableRooms) { roomAvail in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(roomAvail.room.room_name)
                                .font(.headline)
                            Spacer()
                            Text("Capacity: \(roomAvail.room.room_capacity)")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        
                        let availableSlots = BookingTimeHelper.availableStartTimes(bookings: roomAvail.bookings)
                        
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
                                            destination: RoomDetailView(
                                                room: roomAvail.room,
                                                slot: TimeSlot(start: start, end: ""),
                                                date: date,
                                                bookings: roomAvail.bookings
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
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .navigationTitle("Available Rooms")
        .task {
            await vm.searchRoom(date: date, capacity: capacity)
        }
        .alert(item: Binding(
            get: { vm.errorMessage.map { ErrorWrapper(message: $0) } },
            set: { _ in vm.errorMessage = nil }
        )) { wrapper in
            Alert(title: Text("Info"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct RoomDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
    @State private var goToMyBooking = false // Variabel untuk kontrol navigasi
    
    var room: Room
    var slot: TimeSlot
    var date: String
    var bookings: [BookingRoom]
    
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var eventName: String = ""
    @State private var eventDesc: String = ""
    
    @State private var showUserPicker = false
    @State private var selectedUsers: [User] = []
    
    @State private var selectedProperties: [SelectedProperty] = []
    @State private var showPropertyPicker = false
    
    @State private var showSuccess = false
    
    private var availableTimeOptions: [String] {
        BookingTimeHelper.availableStartTimes(bookings: bookings)
    }
    
    private var validEndOptions: [String] {
        BookingTimeHelper.validEndTimes(startTime: startTime, bookings: bookings)
    }
    
    var body: some View {
        
        Form {
            Section(header: Text("Room Info")) {
                Text(room.room_name)
                Text("Capacity: \(room.room_capacity)")
            }
            
            Section(header: Text("Booking")) {
                HStack {
                    Text("Date")
                    Spacer()
                    //                    Text(DateHelper.formatDate(date))
                    //                }
                    Text(DateHelper.toDisplayFormat(date))
                }.frame(maxWidth: .infinity)
                
                Picker("Start Time", selection: $startTime) {
                    ForEach(availableTimeOptions, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                
                Picker("End Time", selection: $endTime) {
                    ForEach(validEndOptions, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                .disabled(startTime.isEmpty)
            }
            
            Section {
                TextField("Event", text: $eventName)
                TextField("Description", text: $eventDesc)
            }
            
            Section {
                HStack {
                    Text("Participant")
                    Spacer()
                    Button {
                        showUserPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                HStack {
                    let maxVisible = 5
                    ForEach(selectedUsers.prefix(maxVisible)) { user in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(user.user_name.initials)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            )
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                    }
                    
                    if selectedUsers.count > maxVisible {
                        let extra = selectedUsers.count - maxVisible
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("+\(extra)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            )
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                    } else if selectedUsers.isEmpty {
                        Text("No participants selected")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Properties")
                    Spacer()
                    Button {
                        showPropertyPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                if selectedProperties.isEmpty {
                    Text("No properties selected")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(selectedProperties) { sp in
                        HStack {
                            Text(sp.property.properties_name)
                            Spacer()
                            Text("x\(sp.quantity)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            
            
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
        .sheet(isPresented: $showUserPicker) {
            UserPickerView(selectedUsers: $selectedUsers)
        }
        .sheet(isPresented: $showPropertyPicker) {
            PropertyPickerView(selectedProperties: $selectedProperties)
        }
        NavigationLink(destination: MyBookings().navigationBarBackButtonHidden(true), isActive: $goToMyBooking) {
            EmptyView()
        }
        Button(action: {
            Task {
                await addBooking()
                goToMyBooking = true
            }
        }) {
            Text("Booking")
                .font(.headline.bold())
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .cornerRadius(8)
        .padding(.horizontal)
        
    }
    
    let bookingService = BookingService()
    
    func addBooking() async {
        let userId = loggedInUserId
        do {
            let booking = BookingRoomInsert(
                room_id: room.room_id,
                user_id: userId,
                br_event: eventName,
                br_date: date,
                br_start: startTime,
                br_end: endTime,
                br_desc: eventDesc,
                br_status: "Pending"
            )
            
            guard let created = try await BookingService.shared.createBookingRoom(booking) else { return }
            
            let picParticipant = ParticipantBr(
                user_id: userId,
                br_id: created.br_id,
                pic: true
            )
            
            let otherParticipants = selectedUsers.map { user in
                ParticipantBr(
                    user_id: user.user_id,
                    br_id: created.br_id,
                    pic: false
                )
            }
            
            try await BookingService.shared.addParticipants([picParticipant] + otherParticipants)
            
            try await BookingService.shared.addProperties(
                selectedProperties.map { BookingRoomDetail(properties_id: $0.property.properties_id, br_id: created.br_id, qty: $0.quantity) }
            )
            
            await MainActor.run {
                showSuccess = true
            }
            
        } catch {
            print("Error: \(error)")
        }
    }
    
}


struct RoomScheduleView: View {
    var room: Room
    var date: String
    var bookings: [BookingRoom]
    
    var body: some View {
        List {
            ForEach(bookings) { booking in
                VStack(alignment: .leading) {
                    Text(booking.br_event)
                        .font(.headline)
                    Text("\(booking.br_start) - \(booking.br_end)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("\(room.room_name) Schedule")
    }
}

#Preview {
    MeetingRoomsView()
}
