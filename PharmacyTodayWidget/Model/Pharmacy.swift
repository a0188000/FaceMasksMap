//
//  Pharmacy.swift
//  PharmacyTodayWidget
//
//  Created by 沈維庭 on 2020/2/19.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import Foundation

struct Pharmacy: Codable {
    var id: String
    var address: String
    var name: String
    var adult: Int
    var child: Int
    var phone: String
    var updateTime: String
    
    enum CodingKeys: String, CodingKey {
        case id, address, name, adult, child, phone
        case updateTime = "update_time"
    }
}
