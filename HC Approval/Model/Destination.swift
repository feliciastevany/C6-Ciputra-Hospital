//
//  Destination.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 28/08/25.
//

import Foundation

struct Destination: Codable, Identifiable {
    var destination_id: Int
    var destination_name: String
    var bc_id: Int
    
    var id: Int{destination_id}
}
