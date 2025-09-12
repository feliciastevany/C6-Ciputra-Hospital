//
//  StaffMeetingRoomView.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 08/09/25.
//

import SwiftUI

struct staffMeetingRoomDetail: Identifiable {
    let id = UUID()
    let name: String
    let capacity: Int
}

struct RoomCardRow: View {
    let room: staffMeetingRoomDetail
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.headline)
                Text("Capacity: \(room.capacity)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(14)
        .background(.background) // looks like a card on systemGray6
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

struct RoomsScreen: View {
    @State private var rooms: [staffMeetingRoomDetail] = [
        .init(name: "Room 1", capacity: 15),
        .init(name: "Room 2", capacity: 15),
        .init(name: "Room 3", capacity: 25),
        .init(name: "Auditorium", capacity: 200),
        .init(name: "Hall", capacity: 100),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(rooms) { room in
                NavigationLink {
                    StaffRoomDetailView(name: room.name)
                } label: {
                    RoomCardRow(room: room)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct StaffMeetingRoomView: View {
    @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
    @State private var goToProfil = false
    var body: some View{
        ZStack{
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                //Header
                HStack {
                    Text("Meeting Rooms")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    Button(action: {
                        goToProfil = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                    }.navigationDestination(isPresented: $goToProfil) {
                        ProfilView(userId: loggedInUserId)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
                
                MeetingRoomsView()
                
                VStack {
                    HStack {
                        Text("Schedule")
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    .padding(.top, 5)
                    .padding(.horizontal)
                    
                    RoomsScreen()
                }
                
            }
        }
        .background(Color(.systemGray6))
        
    }
}


struct StaffMeetingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        StaffMeetingRoomView()
    }
}
