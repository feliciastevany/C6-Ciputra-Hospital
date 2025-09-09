    //
    //  StaffOperationalCarVIew.swift
    //  HC Approval
    //
    //  Created by Wilbert Bryan on 09/09/25.
    //

    import SwiftUI

    struct staffOperationalCarDetail: Identifiable {
        let id = UUID()
        let name: String
        let capacity: Int
    }

    struct CarCardRow: View {
        let car: staffOperationalCarDetail
        var body: some View {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(car.name)
                        .font(.headline)
                    Text("Capacity: \(car.capacity)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(14)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        }
    }

    struct CarsScreen: View {
        @State private var cars: [staffOperationalCarDetail] = [
            .init(name: "Purbo", capacity: 7),
            .init(name: "Sahrul", capacity: 7),
        ]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(cars) { car in
                    NavigationLink {
                        StaffCarDetailView(name: car.name)
                    } label: {
                        CarCardRow(car: car)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(.systemGray6))
        }
    }

    struct StaffOperationalCarView: View {
        @AppStorage("loggedInUserId") var loggedInUserId: Int = 0
        @State private var goToProfil = false
        var body: some View{
            NavigationStack {
              VStack(spacing: 0) {
                // Header
                HStack {
                  Text("Operational Cars")
                    .font(.title).bold()
                  Spacer()
                  Button { print("Profile tapped") } label: {
                    Image(systemName: "person.crop.circle")
                      .resizable().frame(width: 32, height: 32)
                      .foregroundColor(.blue)
                  }
                  .navigationDestination(isPresented: $goToProfil) {
                    ProfilView(userId: loggedInUserId)
                  }
                }
                .padding(.top)
                .padding(.horizontal)
                
                // INI GANTI
                MeetingRoomsView()

                VStack {
                  HStack {
                    Text("Schedule").font(.title3).bold()
                    Spacer()
                  }
                  .padding(.top, 5)
                  .padding(.horizontal)

                  CarsScreen()
                }
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
              .background(Color(.systemGray6).ignoresSafeArea())
            }
        }
    }


    struct StaffOperationalCarView_Previews: PreviewProvider {
        static var previews: some View {
            StaffOperationalCarView()
        }
    }
