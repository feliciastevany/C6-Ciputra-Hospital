////
////  CarpoolRequestListView.swift
////  HC Approval
////
////  Created by Graciella Michelle Siswoyo on 03/09/25.
////
//
//import SwiftUI
//
//struct CarpoolRequestListView: View {
//    
//    var item: [Carpool]
//    
//    var body: some View {
//        ForEach(item) { item in
//            VStack (alignment: .leading) {
//                
//                HStack(alignment: .center) {
//                    RequestUserData()
//                    
//                    Spacer()
//                    
//                    ActionButtons()
//                }
//                
//                Divider()
//                
//                VStack(spacing: 3) {
//                    HStack(alignment: .top) {
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text(item.car)
//                                .font(.headline.bold())
//                            
//                            
//                            Text("\(item.depart)-\(item.arrive)")
//                                .font(.headline.bold())
//                        }
//                            
//                        Spacer()
//                        
//                        VStack {
//                            Text(item.date)
//                                .font(.footnote)
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//                    HStack {
//                        HStack(alignment: .center) {
//                            Image(systemName: "location")
//                                .resizable()
//                                .scaledToFit()
//                                .foregroundColor(.accentColor)
//                                .frame(width: 13, height: 13)
//                            
//                            Text("Universitas Ciputra")
//                                .font(.footnote)
//                        }
//                        
//                        Spacer()
//                        
//                        Button {
//                            print("See details")
//                        } label: {
//                            HStack (spacing: 3) {
//                                Text("See details")
//                                Image(systemName: "chevron.right")
//                            }
//                            .font(.footnote)
//                            .foregroundColor(.accentColor)
//                        }
//                    }
//                }
//                
//            }
//        }
//        .padding(14)
//        .frame(maxWidth: .infinity)
//        .background(Color(.systemBackground))
//        .cornerRadius(10)
//    }
//    
//    struct RequestUserData: View {
//        let iconSize = 13.0
//        
//        var body: some View {
//            VStack(alignment: .leading, spacing: 4) {
//                HStack(alignment: .center) {
//                    Image(systemName: "person.crop.circle")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(.accentColor)
//                        .frame(width: iconSize, height: iconSize)
//                    
//                    Text("Graciella Siswoyo")
//                        .lineLimit(1)
//                }
//                
//                HStack(alignment: .center) {
//                    Image(systemName: "location")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundColor(.accentColor)
//                        .frame(width: iconSize, height: iconSize)
//                    
//                    Text("Denver Apartment")
//                        .lineLimit(1)
//                }
//            }
//            .font(.footnote)
//            .frame(minWidth: 120)
//        }
//    }
//    
//    struct ActionButtons: View {
//        private let buttonWidth = 70.0
//        private let cornerRadius = 6.0
//        private let xPadding = 6.0
//        private let yPadding = 10.0
//        private let innerSpacing = 3.0
//        
//        var body: some View {
//            HStack(spacing: 5) {
//                Button {
//                    print("Decline")
//                } label : {
//                    HStack(spacing: innerSpacing) {
//                        Image(systemName: "xmark")
//                        Text("Decline")
//                    }
//                    .frame(width: buttonWidth)
//                    .padding(.vertical, yPadding)
//                    .padding(.horizontal, xPadding)
//                    .background(Color(.systemRed))
//                    .cornerRadius(cornerRadius)
//                }
//                
//                Button {
//                    print("Approve")
//                } label: {
//                    HStack(spacing: innerSpacing) {
//                        Image(systemName: "checkmark")
//                        Text("Approve")
//                    }
//                    .frame(width: buttonWidth)
//                    .padding(.vertical, yPadding)
//                    .padding(.horizontal, xPadding)
//                    .background(Color(.systemBlue))
//                    .cornerRadius(cornerRadius)
//                }
//            }
//            .font(.caption2)
//            .bold()
//            .lineLimit(1)
//            .foregroundColor(Color(.white))
//        }
//    }
//}
//
//#Preview {
//    VStack {
//        CarpoolRequestListView(item: [Carpool(id: "1", car: "Car", depart: "Depart", arrive: "Arrive", location: "location", date: "Thu, 21 Aug 2025", requestor: "Gracie", to: "Cis")])
//    }
//    .frame(width: .infinity, height: 1000)
//    .background(Color.green)
//}
