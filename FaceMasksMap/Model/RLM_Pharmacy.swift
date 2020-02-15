//
//  RLM_Pharmacy.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/15.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import RealmSwift

@objcMembers
class RLM_Pharmacy: Object {
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var phone: String = ""
    dynamic var address: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required init(propertie: Propertie) {
        self.id = propertie.id
        self.name = propertie.name
        self.phone = propertie.phone
        self.address = propertie.address
        super.init()
    }
    
//    required init(id: String, name: String, phone: String, address: String) {
//        self.id = id
//        self.name = name
//        self.phone = phone
//        self.address = address
//        super.init()
//    }

    required init() {
        super.init()
    }
}
