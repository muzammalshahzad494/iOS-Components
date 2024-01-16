//
//  ApiResponse.swift
//  CarArt
//
//  Created by Muzammal Shahzad on 6/6/23.
//

import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let status: Int
    let message: String?
    let data: T?
    let error: String?
}
