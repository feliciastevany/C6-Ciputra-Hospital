//
//  ApprovalsView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 26/08/25.
//

import SwiftUI

struct ApprovalsView: View {
    @State private var selectedStatusIndex = 0
    @State private var selectedChooseIndex = 0
    let statusRequest: [String] = ["Pending", "Approved", "Declined", "Cancelled"]
    let chooseType: [String] = ["All", "Rooms", "Cars"]
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Booking Request")
                        .font(.title.bold())
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        print("Profile tapped")
                    }) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top)
                
                Picker("Status", selection: $selectedStatusIndex) {
                    ForEach(0..<statusRequest.count, id: \.self) { index in
                        Text(statusRequest[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top)
                
                
                HStack {
                    Spacer()
                    Picker("Choose", selection: $selectedChooseIndex) {
                        ForEach(0..<chooseType.count, id: \.self) { index in
                            Text(chooseType[index]).tag(index)
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack (spacing: 20) {
                    if selectedStatusIndex == 0 {
                        if selectedChooseIndex == 0 {
                            PendingView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB")
                        } else if selectedChooseIndex == 1 {
                            PendingView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB")
                        } else if selectedChooseIndex == 2 {
                            PendingView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB")
                            //                    VStack (alignment: .leading){
                            //                        Text("Room 1 - Budi (Human Capital)")
                            //                            .font(.title3.bold())
                            //
                            //                        Text("Rapat Keuangan 1")
                            //                            .font(.headline.bold())
                            //
                            //                        Text("Thu, 21 Agustus 2025")
                            //                            .font(.subheadline)
                            //
                            //                        Text("10:00 - 11:00 WIB")
                            //                            .font(.title3.bold())
                            //
                            //                        HStack {
                            //                            Button(action: {
                            //                                print("button clicked")
                            //                            })  {
                            //                                Text("Decline")
                            //                                    .font(.headline.bold())
                            //                                    .padding(.vertical, 10)
                            //                                    .padding(.horizontal, 50)
                            //                                    .background(Color.red)
                            //                                    .foregroundColor(.white)
                            //                                    .cornerRadius(20)
                            //                            }
                            //
                            //                            Button(action: {
                            //                                print("button clicked")
                            //                            })  {
                            //                                Text("Approve")
                            //                                    .font(.headline.bold())
                            //                                    .padding(.vertical, 10)
                            //                                    .padding(.horizontal, 50)
                            //                                    .background(Color.green)
                            //                                    .foregroundColor(.white)
                            //                                    .cornerRadius(20)
                            //                            }
                            //                        }
                            //                    }
                            //                    .padding()
                            //                    .background(Color(.white))
                            //                    .cornerRadius(15)
                            //                    .shadow(radius: 4)
                        }
                    }
                    if selectedStatusIndex == 1 {
                        if selectedChooseIndex == 0 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 1 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 2 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        
                    }
                    
                    if selectedStatusIndex == 2 {
                        if selectedChooseIndex == 0 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 1 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 2 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        
                    }
                    
                    if selectedStatusIndex == 3 {
                        if selectedChooseIndex == 0 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 1 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 2 {
                            StatusView(room: "Room 2 - Budi (Human Capital)", event: "Rapat Keuangan 1", date: "Thu, 21 Agustus 2025", time: "10:00 - 11:00 WIB", status: statusRequest[selectedStatusIndex])
                        }
                        
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGray6))
    }
}

func PendingView(room: String, event: String, date: String, time: String) -> some View {
    
    VStack (alignment: .leading){
        HStack {
            VStack (alignment: .leading){
                Text(room)
                    .font(.title3.bold())
                
                //        Text("\(event)\n\(date)\n\(time)")
                //            .font(.headline.bold())
                
                Text(date)
                    .font(.subheadline)
                
                Text(time)
                    .font(.title3.bold())
            }
            Spacer ()
        }
        
        HStack {
            Button(action: {
                print("button clicked")
            })  {
                Text("Decline")
                    .font(.headline.bold())
                    .padding(.vertical, 10)
//                    .padding(.horizontal, 50)
                    .frame(width: 160)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            Spacer()
            Button(action: {
                print("button clicked")
            })  {
                Text("Approve")
                    .font(.headline.bold())
                    .padding(.vertical, 10)
//                    .padding(.horizontal, 50)
                    .frame(width: 160)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
    }
    .padding(14)
    .background(Color(.systemBackground))
    .cornerRadius(14)
    .shadow(radius: 5, x:3, y:3)
}

func StatusView(room: String, event: String, date: String, time: String, status: String) -> some View {
    VStack (alignment: .leading){
        Text(room)
            .font(.title3.bold())
        
        Text(event)
            .font(.headline.bold())
        
        Text(date)
            .font(.subheadline)
            
        HStack {
            Text(time)
                .font(.title3.bold())
            Spacer()
            
            if status == "Approved" {
                Text(status)
                    .font(.title3.bold())
                    .foregroundColor(Color.green)
            } else if status == "Declined" {
                Text(status)
                    .font(.title3.bold())
                    .foregroundColor(Color.red)
            } else {
                Text(status)
                    .font(.title3.bold())
                    .foregroundColor(Color.orange)
            }
        }
        .padding(.top, 1)
    }
    .padding(14)
    .background(Color(.systemBackground))
    .cornerRadius(14)
    .shadow(radius: 5, x:3, y:3)
}

#Preview {
    ApprovalsView()
}

// Custom Segmented
//                HStack(spacing: 0) {
//                    ForEach(statuses.indices, id: \.self) { index in
//                        Text(statuses[index])
//                            .font(.subheadline)
//                            .foregroundColor(selectedStatusIndex == index ? .black : .black)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 6)
//                            .background(
//                                RoundedRectangle(cornerRadius: 30) // Ubah radius disini
//                                    .fill(selectedStatusIndex == index ? Color.white : Color.clear)
//                            )
//                            .onTapGesture {
//                                withAnimation {
//                                    selectedStatusIndex = index
//                                }
//                            }
//                    }
//                }
//                .padding(4)
//                .background(
//                    RoundedRectangle(cornerRadius: 30) // Background segmented
//                    //                    .stroke(Color.blue, lineWidth: 1)
//                        .fill(Color(.systemGray5))
//
//                )
