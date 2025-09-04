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
    
    var pressed: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack (alignment: .leading){
                    HStack (spacing: 4){
                        VStack (spacing: 3) {
                            Image(systemName: "person.crop.circle")
                            
                            Image(systemName: "mappin")
                        }
                        
                        VStack (alignment: .leading, spacing: 3){
                            Text(carpool_req_name)
                                .font(.footnote)
                            
                            Text(carpool_desc)
                                .font(.footnote)
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        onDecline()
                        print("button declined")
                    })  {
                        HStack {
                            Image(systemName: "xmark")
                                .font(.footnote.bold())
                            
                            Text("Decline")
                                .font(.footnote.bold())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color(.systemRed))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        onApprove()
                        print("button approved")
                    })  {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.footnote.bold())
                            
                            Text("Approve")
                                .font(.footnote.bold())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            Divider()
            
            VStack (alignment: .leading){
//                HStack {
                    Text(title)
                        .font(.title3.bold())
                    
//                    Spacer()
//                    
//                    Text(date.toEnglishFormat())
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                    
//                }
                
                Text("\(startTime) - \(endTime) WIB")
                    .font(.title3.bold())
                
                HStack {
                    Image(systemName: "mappin")
                    
                    Text(event)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button(action: {
//                        pressed = true
                    }) {
                        Text("See Details")
                            .font(.caption)
                            .foregroundStyle(Color(.systemBlue))
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
