//
//  Propertie.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

struct Propertie: Codable {
    var id: String
    var name: String
    var phone: String
    var address: String
    var adult: Int
    var child: Int
    var updated: String
    var county: String
    var town: String
    var cunli: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, phone, address, updated, county, town, cunli
        case adult = "mask_adult"
        case child = "mask_child"
    }
}
