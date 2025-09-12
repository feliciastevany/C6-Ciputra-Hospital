//
//  CarSheetType.swift
//  HC Approval
//
//  Created by Felicia Stevany Lewa on 10/09/25.
//

import Foundation

enum SheetType: Identifiable {
    case carbooking(BookingCarJoined)
    case carpool(BookingCarJoined)
    case roombooking(BookingRoomJoined)

    var id: Int {
        switch self {
        case .carbooking(let car): return car.bc_id
        case .carpool(let car): return car.bc_id
        case .roombooking(let room): return room.br_id
        }
    }
}
