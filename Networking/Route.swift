//
//  Route.swift
//  CarArt
//
//  Created by Muzammal Shahzad on 6/6/23.
//

import Foundation

enum Route {
    static let baseUrl = "https://2355-182-176-87-220.ngrok-free.app/api/users"
    
    case registerUser
    case loginUser
    case otp_verification
    
    var description: String {
        switch self {
        case .registerUser:
            return "/categories"
        case .loginUser:
            return "/user_login"
        case .otp_verification:
            return "/otp_verification"
        }
    }
}
