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
    dynamic var adult: Int = -1
    dynamic var child: Int = -1
    dynamic var sortId: Int = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required init(_ propertie: Propertie) {
        self.id = propertie.id
        self.name = propertie.name
        self.phone = propertie.phone
        self.address = propertie.address
        self.adult = propertie.adult
        self.child = propertie.child
        super.init()
    }
    
    required init(propertie: Propertie) {
        self.id = propertie.id
        self.name = propertie.name
        self.phone = propertie.phone
        self.address = propertie.address
        self.adult = propertie.adult
        self.child = propertie.child
        super.init()
    }

    required init() {
        super.init()
    }
}
