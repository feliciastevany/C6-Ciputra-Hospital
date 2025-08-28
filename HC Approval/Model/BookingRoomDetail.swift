//
//  BookingRoomDetail.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct BookingRoomDetail: Codable, Identifiable {
    let properties_id: Int
    let br_id: Int
    let qty: Int
    
    var id: Int{br_id}
}
