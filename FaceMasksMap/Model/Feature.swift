//
//  Feature.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import Foundation

struct Feature: Codable {
    var type: String
    var properties: Propertie
    var geometry: Geometry
}
