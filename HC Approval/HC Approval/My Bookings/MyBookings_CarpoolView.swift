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
                                .scaledToFit()
                                .frame(width: 13, height: 13)
                            
                            Image(systemName: "location")
                                .scaledToFit()
                                .frame(width: 13, height: 13)
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
                                .font(.caption2.bold())
                            
                            Text("Decline")
                                .font(.caption2.bold())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 6)
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
                                .font(.caption2.bold())
                            
                            Text("Approve")
                                .font(.caption2.bold())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 6)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            Divider()
            
            VStack (alignment: .leading){
                HStack {
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(date.toEnglishFormat())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                }
                
                Text("\(startTime) - \(endTime) WIB")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "location")
                    
                    Text(event)
                        .font(.footnote)
                    
                    Spacer()
                    
                    Button(action: {
//                        pressed = true
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
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
