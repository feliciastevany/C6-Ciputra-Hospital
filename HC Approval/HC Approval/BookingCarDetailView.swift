////
////  BookingCarDetailView.swift
////  HC Approval
////
////  Created by Euginia Gabrielle on 09/09/25.
////
//
//import SwiftUI
//
//struct BookingCarDetailView: View {
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
//    @State private var outingDesc = ""
//    
//    @State private var from: String = ""
//    @State private var destinations: [String] = [""]
//    @State private var showSuccess = false
//    
//    private var availableTimeOptions: [String] {
//        BookingTimeHelper.availableStartTimesIgnoringCancelled(bookings: bookings)
//    }
//    
//    private var validEndOptions: [String] {
//        BookingTimeHelper.validEndTimesIgnoringCancelled(startTime: startTime, bookings: bookings)
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
//            Section(header: Text("From")) {
//                TextField("From", text: $from)
//            }
//            
//            Section(header: Text("Destinations")) {
//                ForEach(Array(destinations.enumerated()), id: \.offset) { index, dest in
//                    HStack {
//                        TextField("Destination \(index + 1)", text: $destinations[index])
//                        if destinations.count > 1 {
//                            Button(action: {
//                                destinations.remove(at: index)
//                            }) {
//                                Image(systemName: "minus.circle.fill")
//                                    .foregroundColor(.red)
//                            }
//                        }
//                    }
//                }
//                
//                Button(action: {
//                    destinations.append("")
//                }) {
//                    Label("Add Destination", systemImage: "plus.circle.fill")
//                }
//            }
//            
//            Section {
//                TextField("Description", text: $outingDesc)
//            }
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
//    }
//}
//
//#Preview {
//    BookingCarDetailView()
//}
