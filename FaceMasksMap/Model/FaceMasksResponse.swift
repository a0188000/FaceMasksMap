//
//  FaceMasksResponse.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import Foundation

struct FaceMasksResponse: Codable {
    var type: String
    var features: [Feature]
}
