//
//  My Bookings.swift
//  HC Approval
//
//  Created by Graciella Michelle Siswoyo on 28/08/25.
//
import SwiftUI

struct MyBookings : View {
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
    @State private var goToProfil = false
    
    @State var bookingRoom: [BookingRoomJoined] = []
    @State var bookingCar: [BookingCarJoined] = []
    
    @State var segmentedControl = 0
    
    var groupedRooms: [Date: [BookingRoomJoined]] {
        Dictionary(grouping: bookingRoom, by: { $0.br_date })
    }

    var groupedCars: [Date: [BookingCarJoined]] {
        Dictionary(grouping: bookingCar, by: { $0.bc_date })
    }

    
    var body: some View {
        VStack {
            HStack {
                Text("My Bookings")
                    .font(.title.bold())
                    .accessibilityLabel("My list of bookings today")
                
                Spacer()
                
                Button(action: {
                    print("Profile tapped")
                    goToProfil = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(.systemBlue))
                        .accessibilityLabel("My Profile")
                }.navigationDestination(isPresented: $goToProfil) {
                    ProfilView(userId: loggedInUserId)
                }
            }
            .padding(.top)
            
            Picker("", selection: $segmentedControl){
                Text("Rooms").tag(0)
                    .accessibilityHint("Segmented control Rooms")
                Text("Cars").tag(1)
                    .accessibilityHint("Segmented control Cars")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 15)
            
            ScrollView {
                VStack (spacing: 15) {
                    if segmentedControl == 0 {
                        ForEach(groupedRooms.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(date.toEnglishFormat())")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                ForEach(groupedRooms[date] ?? [], id: \.bookId) { booking in
                                    BookingCard(
                                        title: booking.title,
                                        date: booking.br_date,
                                        event: booking.br_event,
                                        startTime: toHourMinute(booking.br_start),
                                        endTime: toHourMinute(booking.br_end),
                                        status: booking.br_status
                                    )
                                }
                            }
                        }
                    }
                    if segmentedControl == 1 {
                        ForEach(groupedCars.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(date.toEnglishFormat())")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                ForEach(groupedCars[date] ?? [], id: \.bookId) { booking in
                                    if booking.carpool_status == "Pending" {
                                        CarpoolCard(title: booking.title,
                                                    date: booking.bc_date,
                                                    event: booking.destination?.last?.destination_name ?? "Unknown",
                                                    startTime: toHourMinute(booking.bc_start),
                                                    endTime: toHourMinute(booking.bc_end),
                                                    status: booking.bc_status,
                                                    carpool_req_name: "hehe",
                                                    carpool_desc: "nebeng",
                                                    onApprove: {
                                            Task {
                                                try? await SupabaseManager.shared.updateCarpoolStatus(booking: booking, status: "Approved")
                                                await fetchMyBookings()
                                            }
                                        },
                                                    onDecline: {
                                            Task {
                                                try? await SupabaseManager.shared.updateCarpoolStatus(booking: booking, status: "Declined")
                                                await fetchMyBookings()
                                            }
                                        },
                                                    pressed: false)
                                    } else {
                                        BookingCard(title: booking.title,
                                                    date: booking.bc_date,
                                                    event: booking.destination?.last?.destination_name ?? "Unknown",
                                                    startTime: toHourMinute(booking.bc_start),
                                                    endTime: toHourMinute(booking.bc_end),
                                                    status: booking.bc_status)
                                    }
                                }
                            }
                        }
                    }
                }
                .task {
                    await fetchMyBookings()
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
    }
    func fetchMyBookings() async {
        do {
            let (rooms, cars) = try await SupabaseManager.shared.fetchBookings(for: loggedInUserId)
            DispatchQueue.main.async {
                self.bookingRoom = rooms
                self.bookingCar = cars
            }
            print("respones: ", rooms, cars)
        } catch {
            print("Error fetch my bookings:", error)
        }
    }
}

extension SupabaseManager {
    func updateCarpoolStatus(booking: any AnyBooking, status: String) async throws {
        if let roomBooking = booking as? BookingRoomJoined {
            try await client
                .from("bookings_room")
                .update(["carpool_status": status])
                .eq("br_id", value: roomBooking.br_id)
                .execute()
            print(status)
            
        } else if let carBooking = booking as? BookingCarJoined {
            try await client
                .from("bookings_car")
                .update(["carpool_status": status])
                .eq("bc_id", value: carBooking.bc_id)
                .execute()
            
            print(status)
        }
    }
}


#Preview {
    MyBookings()
}
//
////My Bookings Rooms
//struct Rooms: View {
//    let data: [Bookings] = [
//        Bookings(title: "MEETING ROOM 1", start: "08:00", stop: "09:00", event: "Rapat Keuangan 1", /*position: "Human Capital",*/ date: "Thu, 21 Aug 2025", status: "Approved"),
//        Bookings(title: "MEETING ROOM 2", start: "08:00", stop: "09:00", event: "Rapat Keuangan 2",  /*position: "Mentor"*/ date: "Thu, 21 Aug 2025", status: "Pending"),
//        Bookings(title: "MEETING ROOM 3", start: "08:00", stop: "09:00", event: "Rapat Keuangan 3",  /*position: "Mentor"*/ date: "Mon, 25 Aug 2025", status: "Declined"),
//        Bookings(title: "MEETING ROOM 2", start: "08:00", stop: "09:00", event: "Rapat Keuangan 3",  /*position: "Mentor"*/ date: "Tue, 26 Aug 2025", status: "Cancelled")
//    ]
//    
//    @State var segmentedControl = 0
//    
//    var body: some View {
//        
//        ScrollView {
//            
//            //            ZStack{
//            //                Color.white.edgesIgnoringSafeArea(.all)
//            
//            VStack(spacing: 20) {
//                ForEach(0..<data.count, id: \.self) { i in
//                    VStack (alignment: .leading) {
//                        if i != 0 {
//                            if data[i].date != data[i - 1].date {
//                                Text(data[i].date)
//                                    .font(.subheadline)
//                                    .foregroundStyle(.secondary)
//                            }
//                        }
//                        else {
//                            Text(data[i].date)
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                        }
//                        
//                        //                    HStack(spacing: 10) {
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text(data[i].title)
//                                .font(.title3.bold())
//                            Text("\(data[i].start)-\(data[i].stop)")
//                                .font(.title3.bold())
//                            HStack {
//                                Text(data[i].event)
//                                    .font(.footnote)
//                                Spacer ()
//                                if data[i].status == "Pending" {
//                                    Image(systemName: "clock")
//                                        .foregroundColor(Color(.systemOrange))
//                                    Text(data[i].status)
//                                        .font(.headline.bold())
//                                        .foregroundColor(Color(.systemOrange))
//                                } else if data[i].status == "Approved" {
//                                    Image(systemName: "checkmark")
//                                        .foregroundColor(Color(.systemGreen))
//                                    Text(data[i].status)
//                                        .font(.headline.bold())
//                                        .foregroundColor(Color(.systemGreen))
//                                } else if data[i].status == "Declined" {
//                                    Image(systemName: "xmark")
//                                        .foregroundColor(Color(.systemRed))
//                                    Text(data[i].status)
//                                        .font(.headline.bold())
//                                        .foregroundColor(Color(.systemRed))
//                                } else {
//                                    Image(systemName: "minus")
//                                        .foregroundColor(Color(.systemOrange))
//                                    Text(data[i].status)
//                                        .font(.headline.bold())
//                                        .foregroundColor(Color(.systemOrange))
//                                }
//                            }
//                        }
////                        Spacer()
////                        VStack(alignment: .trailing, spacing: 10) {
////                            Text("\(item.start)-\(item.stop)")
////                                .font(.headline.bold())
////                            Text(item.date)
////                                .font(.footnote)
////                        }
////                    }
//                    .padding(14)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.systemBackground))
//                    .cornerRadius(10)
//                    //                        .shadow(radius: 5, x: 3, y: 3)
//                }
//            }
//        }
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//            }
//        }
//    }
//
//
////My Bookings Cars
//struct Cars: View {
//    let data: [Bookings] = [
//        Bookings(title: "Car 1", start: "08:00", stop: "09:00", event: "Rapat Keuangan 1", /*position: "Human Capital",*/ date: "Thu, 21 Aug 2025", status: "Approved"),
//        Bookings(title: "Car 2", start: "08:00", stop: "09:00", event: "Rapat Keuangan 2",  /*position: "Mentor"*/ date: "Fri, 22 Aug 2025", status: "Pending")
//    ]
//    
//    let item: [Carpool] = [
//        Carpool(id: "0", car: "Car 1", depart: "10:00", arrive: "12:00", location: "📍 Universitas Ciputra", date: "Thu, 21 Aug 2025")
//    ]
//    
//    @State var segmentedControl = 0
//    var body: some View {
//        
//        ScrollView {
//            
//            ZStack{
//                //            Color.blue.edgesIgnoringSafeArea(.all)
//                VStack(spacing: 20) {
//                    
////                    VStack (alignment: .leading) {
////                        VStack (alignment: . leading) {
////                            
////                        }
////                    }
//                    Text("Carpool Request")
//                        .font(.title3.bold())
//                        .foregroundStyle(.secondary)
//                        .padding(.trailing, 200)
//                    
//                    ForEach(item) { item in
//                        VStack (alignment: .leading) {
//                //            HStack {
//                                VStack (alignment: .leading){
//                                    HStack {
//                                        Text(item.car)
//                                            .font(.title3.bold())
//                                        Spacer()
//                                        Text(item.date)
//                                            .font(.footnote)
//                                            .foregroundStyle(.secondary)
//                                    }
//                                    
//                                    //        Text("\(event)\n\(date)\n\(time)")
//                                    //            .font(.headline.bold())
//                                    
//                                    Text("\(item.depart)-\(item.arrive)")
//                                        .font(.title3.bold())
//                                    
//                                    Text(item.location)
//                                        .font(.footnote)
//                                    
//                                    //                Text(date)
//                                    //                    .font(.subheadline)
//                                    
//                                }
//                                //            .padding(.horizontal, 5)
//                                
//                                //            Spacer ()
//                //            }
//                            
//                            HStack {
//                                HStack {
//                                    Button(action: {
//                                        print("button clicked")
//                                    })  {
//                                        Image(systemName: "xmark")
//                                        Text("Decline")
//                                            .font(.headline.bold())
//                                    }
//                                    .padding(.vertical, 10)
//                                    //                    .padding(.horizontal, 50)
//                                    .frame(width: 160)
//                                    .background(Color(.systemRed))
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                                }
//                                Spacer()
//                                //                Spacer()
//                                
//                                HStack {
//                                    Button(action: {
//                                        print("button clicked")
//                                    })  {
//                                        Image(systemName: "checkmark")
//                                        Text("Approve")
//                                            .font(.headline.bold())
//                                    }
//                                    .padding(.vertical, 10)
//                                    //                    .padding(.horizontal, 50)
//                                    .frame(width: 160)
//                                    .background(Color(.systemBlue))
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                                }
//                            }
//                        }
//                    }
//                    .padding(14)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.systemBackground))
//                    .cornerRadius(10)
//                    
////                    .padding(14)
////                    .frame(maxWidth: .infinity, alignment: .leading)
////                    .background(Color(.systemBackground))
////                    .cornerRadius(10)
//////                    //    .shadow(radius: 5, x: 3, y: 3)
////                    .padding(.horizontal, 20)
//                    
//                    ForEach(0..<data.count, id: \.self) { i in
//                        VStack (alignment: .leading) {
//                            if i != 0 {
//                                if data[i].date != data[i - 1].date {
//                                    Text(data[i].date)
//                                        .font(.subheadline)
//                                        .foregroundStyle(.secondary)
//                                }
//                            }
//                            else {
//                                Text(data[i].date)
//                                    .font(.subheadline)
//                                    .foregroundStyle(.secondary)
//                            }
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text(data[i].title)
//                                    .font(.title3.bold())
//                                Text("\(data[i].start)-\(data[i].stop)")
//                                    .font(.title3.bold())
//                                HStack {
//                                    Text(data[i].event)
//                                        .font(.footnote)
//                                    Spacer ()
//                                    if data[i].status == "Pending" {
//                                        Image(systemName: "clock")
//                                            .foregroundColor(Color(.systemOrange))
//                                        Text(data[i].status)
//                                            .font(.headline.bold())
//                                            .foregroundColor(Color(.systemOrange))
//                                    } else if data[i].status == "Approved" {
//                                        Image(systemName: "checkmark")
//                                            .foregroundColor(Color(.systemGreen))
//                                        Text(data[i].status)
//                                            .font(.headline.bold())
//                                            .foregroundColor(Color(.systemGreen))
//                                    } else if data[i].status == "Declined" {
//                                        Image(systemName: "xmark")
//                                            .foregroundColor(Color(.systemRed))
//                                        Text(data[i].status)
//                                            .font(.headline.bold())
//                                            .foregroundColor(Color(.systemRed))
//                                    } else {
//                                        Image(systemName: "minus")
//                                            .foregroundColor(Color(.systemOrange))
//                                        Text(data[i].status)
//                                            .font(.headline.bold())
//                                            .foregroundColor(Color(.systemOrange))
//                                    }
//                                }
//                            }
//                            .padding(14)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(Color(.systemBackground))
//                            .cornerRadius(10)
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//            }
//        }
//    }
//}


