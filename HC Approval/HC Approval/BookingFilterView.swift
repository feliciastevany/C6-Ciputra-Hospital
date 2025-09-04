//
//  formexampleview.swift
//  HC Approval
//
//  Created by Wilbert Bryan on 03/09/25.
//

import SwiftUI

struct BookingFilterView: View {
    @State private var selectedDate = Date()
    @State private var capacity = 1
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Text("Date")
                    Spacer()
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                }
                HStack {
                    Text("Capacity")
                    Spacer()
                    Stepper(value: $capacity, in: 1...10) {
                        Text("\(capacity)")
                            .frame(width: 30, alignment: .trailing)
                    }
                }
            }
            .frame(height: 140)
            .scrollDisabled(true)

            Button(action: {
                print("Browse tapped")
            }) {
                Text("Browse rooms")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
    
}

struct BookingFilterView_Previews: PreviewProvider {
    static var previews: some View {
        BookingFilterView()
    }
}
