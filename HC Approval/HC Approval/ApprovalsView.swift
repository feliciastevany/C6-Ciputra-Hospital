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
    let statuses: [String] = ["Pending", "Approved", "Declined", "Cancelled"]
    let choose: [String] = ["All", "Rooms", "Cars"]
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Booking Request")
                        .font(.title.bold())
//                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        print("Profile tapped")
                    }) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 35, height: 35) // lebih besar biar seimbang
                            .foregroundColor(Color(.systemBlue))
                        //                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top)
                //            .padding(.horizontal)
                
                HStack {
                    Spacer()
                    Picker("Choose", selection: $selectedChooseIndex) {
                        ForEach(0..<choose.count, id: \.self) { index in
                            Text(choose[index]).tag(index)
                        }
                    }
                                    .padding(.bottom, 3)
                }
                
                Picker("Status", selection: $selectedStatusIndex) {
                    ForEach(0..<statuses.count, id: \.self) { index in
                        Text(statuses[index]).tag(index)
                        //                        .font(.subheadline)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)
//                .pickerStyle(.segmented)
                //            .padding(.horizontal)
//                .padding(.top)
                //            .cornerRadius(50)
                
                //            HStack(spacing: 0) {
                //                ForEach(statuses.indices, id: \.self) { index in
                //                    Text(statuses[index])
                //                        .font(.subheadline)
                //                        .foregroundColor(selectedStatusIndex == index ? .black : .black)
                //                        .frame(maxWidth: .infinity)
                //                        .padding(.vertical, 6)
                //                        .background(
                //                            RoundedRectangle(cornerRadius: 30) // Ubah radius disini
                //                                .fill(selectedStatusIndex == index ? Color.white : Color.clear)
                //                        )
                //                        .onTapGesture {
                //                            withAnimation {
                //                                selectedStatusIndex = index
                //                            }
                //                        }
                //                }
                //            }
                //            .padding(4)
                //            .background(
                //                RoundedRectangle(cornerRadius: 30) // Background segmented
                ////                    .stroke(Color.blue, lineWidth: 1)
                //                    .fill(Color(.systemGray5))
                //                    
                //            )
            
              
            }
//            .padding(.horizontal)
            
            ScrollView {
                VStack {
                    if selectedStatusIndex == 0 {
                        if selectedChooseIndex == 0 {
                            PendingView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB")
                        } else if selectedChooseIndex == 1 {
                            PendingView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB")
                        } else if selectedChooseIndex == 2 {
                            PendingView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB")
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
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 1 {
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 2 {
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        
                    }
                    
                    if selectedStatusIndex == 2 {
                        if selectedChooseIndex == 0 {
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 1 {
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 2 {
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        
                    }
                    
                    if selectedStatusIndex == 3 {
                        if selectedChooseIndex == 0 {
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 1 {
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        if selectedChooseIndex == 2 {
                            StatusView(room: "Room 2", event: "Rapat Keuangan 1", date: "Thu, 21 Aug 2025", time: "10:00 - 11:00 WIB", status: statuses[selectedStatusIndex])
                        }
                        
                    }
                    
                    //                    Spacer()
                }
                .padding(5)
            }
        }
        .background(Color(.systemGray6))
        
    }
}

func PendingView(room: String, event: String, date: String, time: String) -> some View {

    VStack (alignment: .leading) {
        Text(date)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.leading, 20)
        
        VStack (alignment: .leading){
//            HStack {
                VStack (alignment: .leading){
                    Text(room)
                        .font(.title3.bold())
                    
                    //        Text("\(event)\n\(date)\n\(time)")
                    //            .font(.headline.bold())
                    
                    Text(time)
                        .font(.title3.bold())
                    
                    Text(event)
                        .font(.footnote)
                    
                    //                Text(date)
                    //                    .font(.subheadline)
                    
                }
                //            .padding(.horizontal, 5)
                
                //            Spacer ()
//            }
            
            HStack {
                HStack {
                    Button(action: {
                        print("button clicked")
                    })  {
                        Image(systemName: "xmark")
                        Text("Decline")
                            .font(.headline.bold())
                    }
                    .padding(.vertical, 10)
                    //                    .padding(.horizontal, 50)
                    .frame(width: 155)
                    .background(Color(.systemRed))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                Spacer()
                //                Spacer()
                
                HStack {
                    Button(action: {
                        print("button clicked")
                    })  {
                        Image(systemName: "checkmark")
                        Text("Approve")
                            .font(.headline.bold())
                    }
                    .padding(.vertical, 10)
                    //                    .padding(.horizontal, 50)
                    .frame(width: 155)
                    .background(Color(.systemBlue))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        
        .padding(14)
        //    .frame(width: 365)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        //    .shadow(radius: 5, x: 3, y: 3)
        .padding(.horizontal, 20)
    }
}

func StatusView(room: String, event: String, date: String, time: String, status: String) -> some View {
    
    VStack (alignment: .leading) {
        Text(date)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.leading, 20)
        VStack (alignment: .leading){
            Text(room)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(time)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            
            //        Text(date)
            //            .font(.subheadline)
            
//            HStack {
                Text(event)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)

//                Spacer()
                
//                if status == "Approved" {
//                    HStack {
//                        Image(systemName: "checkmark")
//                            .foregroundColor(Color(.systemGreen))
//                        Text(status)
//                            .font(.title3.bold())
//                            .foregroundColor(Color(.systemGreen))
//                    }
//                } else if status == "Declined" {
//                    HStack {
//                        Image(systemName: "xmark")
//                            .foregroundColor(Color(.systemRed))
//                        Text(status)
//                            .font(.title3.bold())
//                            .foregroundColor(Color(.systemRed))
//                    }
//                } else {
//                    HStack {
//                        Image(systemName: "minus")
//                            .foregroundColor(Color(.systemOrange))
//                        Text(status)
//                            .font(.title3.bold())
//                            .foregroundColor(Color(.systemOrange))
//                    }
//                }
//            }
//            .padding(.top, 1)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        //    .shadow(radius: 5, x: 3, y: 3)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ApprovalsView()
}
