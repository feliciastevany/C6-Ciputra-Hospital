//
//  CarpoolUpdate.swift
//  HC Approval
//
//  Created by Euginia Gabrielle on 16/09/25.
//
import Foundation

struct CarpoolUpdate: Encodable {
    let carpool_req: Bool
    let carpool_desc: String
    let carpool_status: String
    let carpool_req_id: Int
}
