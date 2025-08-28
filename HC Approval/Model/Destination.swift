//
//  Destination.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct Destination: Codable, Identifiable {
    let destination_id: Int
    let destination_name: String
    let bc_id: Int
    
    var id: Int{destination_id}
}
