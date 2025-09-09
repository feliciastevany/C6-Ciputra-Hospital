//
//  MyBookings_CarpoolView.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 03/09/25.
//

import SwiftUI

struct CarpoolCard: View {
    let title: String
    let date: Date
    let event: String
    let startTime: String
    let endTime: String
    let status: String
    let carpool_req_name: String
    let carpool_desc: String
    
    var onApprove: () -> Void = { }
    var onDecline: () -> Void = { }
    
    var onDetails: () -> Void = { }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(Color(.systemBlue))
                    
                    Text(carpool_req_name)
                        .font(.subheadline)
                    
                }
                .lineLimit(1)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        onDecline()
                        print("button declined")
                    })  {
                        HStack(spacing: 3) {
                            Image(systemName: "xmark")
                                .font(.caption2.bold())
                            
                            Text("Decline")
                                .font(.caption2.bold())
                        }
                        .frame(width: 70)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 5)
                        .background(Color(.systemRed))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    
                    Button(action: {
                        onApprove()
                        print("button approved")
                    })  {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark")
                                .font(.caption2.bold())
                            
                            Text("Approve")
                                .font(.caption2.bold())
                        }
                        .frame(width: 70)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 5)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                }
            }
            .padding(.bottom, 7)
            Divider()
            
            VStack (alignment: .leading, spacing: 3){
                HStack {
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(date.toEnglishFormat())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Text("\(startTime) - \(endTime) WIB")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "location")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor)
                        .frame(width: 13, height: 13)
                    
                    Text(event)
                        .font(.footnote)
                    
                    Spacer()
                    
                    Button(action: {
                        onDetails()
                    }) {
                        Text("See Details")
                            .font(.footnote)
                            .foregroundStyle(Color(.systemBlue))
                        
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(Color(.systemBlue))
                    }
                }
            }
            .padding(.top, 7)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

struct BookingCarDetailView: View {
    let booking: BookingCarJoined
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Carpool Details")
                        .font(.title2.bold())
                    
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .foregroundStyle(Color(.systemBlue))
                    }
                }
                .padding(.vertical, 10)
                
                Text(booking.carpool_desc)
                    .font(.body)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    CarpoolCard(title: "Purbo", date: Date(), event: "Ciputra World", startTime: "09.30", endTime: "20.00", status: "Pending", carpool_req_name: "Angel", carpool_desc: "UC", onApprove: {
        print("Approved")
    }, onDecline: {
        print("Declined")
    }, onDetails: {
        print("Details")
    })
}
