////
////  My Bookings.swift
////  HC Approval
////
////  Created by Graciella Michelle Siswoyo on 28/08/25.
////
//import SwiftUI
//
//struct MyBookings : View {
//    @State var segmentedControl = 0
//    
//    var body: some View {
//        
//        VStack {
//            
//            HStack {
//                Text("My Bookings")
//                    .font(.title.bold())
//                    .accessibilityLabel("My list of bookings today")
//                
//                Spacer()
//                
//                Image(systemName: "person.crop.circle")
//                    .resizable()
//                    .frame(width: 35, height: 35)
//                    .foregroundStyle(Color(.systemBlue))
//                    .accessibilityLabel("My Profile")
//            }
//            .padding(.horizontal, 20)
//            .padding(.top)
//            
//            Picker("", selection: $segmentedControl){
//                Text("Rooms").tag(0)
//                    .accessibilityHint("Segmented control Rooms")
//                Text("Cars").tag(1)
//                    .accessibilityHint("Segmented control Cars")
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding(.horizontal, 20)
//            .padding(.bottom, 15)
//            
//            if segmentedControl == 0 {
//                Rooms()
//            }
//            if segmentedControl == 1 {
//                Cars()
//            }
//            
//        }
//        .background(Color(.systemGray6))
//    }
//}
//
//#Preview {
//    MyBookings()
//}
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
//    @State var segmentedControl = 0
//    var body: some View {
//        
//        ScrollView {
//            
//            ZStack{
//                //            Color.blue.edgesIgnoringSafeArea(.all)
//                VStack(spacing: 20) {
//                    
//                    VStack (alignment: .leading) {
//                        VStack (alignment: . leading) {
//                            
//                        }
//                    }
//                    
//                    ForEach(data) { item in
//                        VStack (alignment: .leading) {
//                //            HStack {
//                                VStack (alignment: .leading){
//                                    Text("\(item.title)")
//                                        .font(.title3.bold())
//                                    
//                                    //        Text("\(event)\n\(date)\n\(time)")
//                                    //            .font(.headline.bold())
//                                    
//                                    Text("\(item.start)-\(item.stop)")
//                                        .font(.title3.bold())
//                                    
//                                    Text("\(item.status)")
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
//                                    .frame(width: 155)
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
//                                    .frame(maxWidth: .infinity)
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
//
//
