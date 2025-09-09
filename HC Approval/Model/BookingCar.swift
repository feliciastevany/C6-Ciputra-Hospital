//
//  BookingCar.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct BookingCar: Codable, Identifiable {

    var bc_id: Int
    var user_id: Int
    var driver_id: Int
    var bc_date: String
    var bc_start: String
    var bc_end: String
    var bc_from: String
    var bc_desc: String
    var bc_people: Int
    var bc_status: String
    var bc_decline_reason: String
    var carpool_req: Bool
    var carpool_desc: String
    var carpool_status: String
    var created_at: Date
  
    var id: Int{bc_id}
}
