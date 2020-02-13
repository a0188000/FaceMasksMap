//
//  FaceMasksViewModel.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

class FaceMasksViewModel {
    
    var locationFetcher: LocationFetcher
    var controller: ControllerManager
    var features: [Feature] = []
    var faceMaskAnn: [FaceMaskAnnotation] = []
    
    init(locationFetcher: LocationFetcher, controller: ControllerManager) {
        self.locationFetcher = locationFetcher
        self.controller = controller
        self.fetchData()
    }
    
    func reloadData() {
        FaceMasksAPI.shared.getInfo { (response, error) in
            
        }
    }
    
    private func fetchData(duration: TimeInterval = 30.0) {
        FaceMasksAPI.shared.getInfo { (response, error) in
            guard let response = response else { return }
            print(response.features.count)
            self.features = response.features
            DispatchQueue.main.async {
                self.controller.didUpdateData()
            }
        }
    }
    
    private func configureAnnotation() {
        self.faceMaskAnn = []
    }
}
