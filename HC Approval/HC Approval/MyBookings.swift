//
//  MyBookings.swift
//  HC Approval
//
//  Created by Graciella Michelle Siswoyo on 28/08/25.
//
import SwiftUI

struct MyBookings : View {
    @State var segmentedControl = 0
    
    @State var bookingRoom: [BookingRoomJoined] = []
    @State var bookingCar: [BookingCarJoined] = []
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("My Bookings")
                    .font(.title.bold())
                    .accessibilityLabel("My List of Bookings")
                
                Spacer()
                
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color(.systemBlue))
                    .accessibilityLabel("My Profile")
            }
            .padding(.horizontal)
            .padding(.top)
            
            Picker("", selection: $segmentedControl){
                Text("Rooms").tag(0)
                    .accessibilityHint("List of Room Bookings")
                Text("Cars").tag(1)
                    .accessibilityHint("List of Car Bookings")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom, 15)
            
            if segmentedControl == 0 {
                Rooms()
            }
            if segmentedControl == 1 {
                Cars()
            }
            
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    MyBookings()
}

//My Bookings Rooms
struct Rooms: View {
    let data: [Bookings] = [
        Bookings(title: "Meeting Room 1", start: "08:00", stop: "09:00", event: "Rapat Keuangan 1", /*position: "Human Capital",*/ date: "Thu, 21 Aug 2025", status: "Approved"),
        Bookings(title: "Meeting Room 2", start: "08:00", stop: "09:00", event: "Rapat Keuangan 2",  /*position: "Mentor"*/ date: "Thu, 21 Aug 2025", status: "Pending"),
        Bookings(title: "Meeting Room 3", start: "08:00", stop: "09:00", event: "Rapat Keuangan 3",  /*position: "Mentor"*/ date: "Mon, 25 Aug 2025", status: "Declined"),
        Bookings(title: "Meeting Room 2", start: "08:00", stop: "09:00", event: "Rapat Keuangan 3",  /*position: "Mentor"*/ date: "Tue, 26 Aug 2025", status: "Cancelled")
    ]
    
    @State var segmentedControl = 0
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 15) {
                ForEach(0..<data.count, id: \.self) { i in
                    VStack (alignment: .leading) {
                        if i != 0 {
                            if data[i].date != data[i - 1].date {
                                Text(data[i].date)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        else {
                            Text(data[i].date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(data[i].title)
                                .font(.headline.bold())
                            Text("\(data[i].start)-\(data[i].stop)")
                                .font(.headline.bold())
                            HStack {
                                Text(data[i].event)
                                    .font(.footnote)
                                Spacer ()
                                if data[i].status == "Pending" {
                                    Image(systemName: "clock")
                                        .foregroundColor(Color(.systemGray2))
                                    Text(data[i].status)
                                        .font(.subheadline.bold())
                                        .foregroundColor(Color(.systemGray2))
                                        .accessibilityLabel("Booking Status, Pending")
                                } else if data[i].status == "Approved" {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(.systemBlue))
                                    Text(data[i].status)
                                        .font(.subheadline.bold())
                                        .foregroundColor(Color(.systemBlue))
                                        .accessibilityLabel(Text("Booking Status, Approved"))
                                } else if data[i].status == "Declined" {
                                    Image(systemName: "xmark")
                                        .foregroundColor(Color(.systemRed))
                                    Text(data[i].status)
                                        .font(.subheadline.bold())
                                        .foregroundColor(Color(.systemRed))
                                        .accessibilityLabel(Text("Booking Status, Declined"))
                                } else {
                                    Image(systemName: "minus")
                                        .foregroundColor(Color(.systemOrange))
                                    Text(data[i].status)
                                        .font(.subheadline.bold())
                                        .foregroundColor(Color(.systemOrange))
                                        .accessibilityLabel(Text("Booking Status, Cancelled"))
                                }
                            }
                        }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                }
            }
        }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
    }


//My Bookings Cars
struct Cars: View {
    let data: [Bookings] = [
        Bookings(title: "Car 1", start: "08:00", stop: "09:00", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", status: "Approved"),
        Bookings(title: "Car 2", start: "08:00", stop: "09:00", event: "Rapat Keuangan 2", date: "Fri, 22 Aug 2025", status: "Approved"),
        Bookings(title: "Car 2", start: "10:00", stop: "12:00", event: "Rapat Keuangan 2", date: "Fri, 22 Aug 2025", status: "Pending")
    ]
    
    let item: [Carpool] = [
        Carpool(id: "0", car: "Car 1", depart: "10:00", arrive: "12:00", location: "📍 Universitas Ciputra", date: "Thu, 21 Aug 2025", requestor: "Budi", to: "Denver Apartment")
    ]
    
    @State var segmentedControl = 0
    var body: some View {
        
        ScrollView {
            
            ZStack{
                VStack(alignment: .leading, spacing: 15) {
                    
                    Text("Carpool Request")
                        .font(.headline.bold())
                
                    CarpoolRequestListView(item: item)
                
                    Spacer()
                    
                    Text("Processed Bookings")
                        .font(.headline.bold())
                    
                    ForEach(0..<data.count, id: \.self) { i in
                        VStack (alignment: .leading) {
                            if i != 0 {
                                if data[i].date != data[i - 1].date {
                                    Text(data[i].date)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            else {
                                Text(data[i].date)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(data[i].title)
                                    .font(.headline.bold())
                                Text("\(data[i].start)-\(data[i].stop)")
                                    .font(.headline.bold())
                                HStack {
                                    Text(data[i].event)
                                        .font(.footnote)
                                    Spacer ()
                                    if data[i].status == "Pending" {
                                        Image(systemName: "clock")
                                            .foregroundColor(Color(.systemGray2))
                                        Text(data[i].status)
                                            .font(.subheadline.bold())
                                            .foregroundColor(Color(.systemGray2))
                                            .accessibilityLabel("Booking Status, Pending")
                                    } else if data[i].status == "Approved" {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(.systemBlue))
                                        Text(data[i].status)
                                            .font(.subheadline.bold())
                                            .foregroundColor(Color(.systemBlue))
                                            .accessibilityLabel("Booking Status, Approved")
                                    } else if data[i].status == "Declined" {
                                        Image(systemName: "xmark")
                                            .foregroundColor(Color(.systemRed))
                                        Text(data[i].status)
                                            .font(.subheadline.bold())
                                            .foregroundColor(Color(.systemRed))
                                            .accessibilityLabel(Text("Booking Status, Declined"))
                                    } else {
                                        Image(systemName: "minus")
                                            .foregroundColor(Color(.systemOrange))
                                        Text(data[i].status)
                                            .font(.subheadline.bold())
                                            .foregroundColor(Color(.systemOrange))
                                            .accessibilityLabel(Text("Booking Status, Cancelled"))
                                    }
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
    }
}


