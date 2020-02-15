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
    var favoriteId: [String] = []
    
    
    init(locationFetcher: LocationFetcher, controller: ControllerManager) {
        self.locationFetcher = locationFetcher
        self.controller = controller
        self.fetchData()
    }
    
    func reloadData() {
        FaceMasksAPI.shared.getInfo { (response, error) in
            
        }
    }
    
    func checkAnnotationFavoriteStatus(annotation: FaceMaskAnnotation?) {
        guard
            let index = self.faceMaskAnn.firstIndex(where: { $0.propertie?.id == annotation?.propertie?.id }),
            let propertie = self.faceMaskAnn[index].propertie
        else { return }
        if self.favoriteId.contains(propertie.id) {
            self.favoriteId.remove(at: index)
        } else {
            self.favoriteId.append(propertie.id)
        }
        self.faceMaskAnn[index].isFavorite = self.favoriteId.contains(propertie.id)
        
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
