//
//  Declarative.swift
//  LienQuan
//
//  Created by 沈維庭 on 2020/1/30.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit
import CCHMapClusterController

protocol Declarative {
    init()
}

extension NSObject: Declarative { }

extension Declarative where Self: NSObject {
    init(_ configureHandler: (Self) -> Void) {
        self.init()
        configureHandler(self)
    }
}

extension Declarative where Self: UISegmentedControl {
    init(items: [Any]?, _ configureHandler: (Self) -> Void) {
        self.init(items: items)
        configureHandler(self)
    }
}

extension Declarative where Self: UICollectionView {
    init(layout: UICollectionViewFlowLayout, _ configureHandler: (Self) -> Void) {
        self.init(frame: .zero, collectionViewLayout: layout)
        configureHandler(self)
    }
}

extension Declarative where Self: UIButton {
    init(type: UIButton.ButtonType, _ configureHandler: (Self) -> Void) {
        self.init(type: type)
        configureHandler(self)
    }
}

extension Declarative where Self: CCHMapClusterController {
    init(mapView: MKMapView, _ configureHandler: (Self) -> Void) {
        self.init(mapView: mapView)
        configureHandler(self)
    }
}
