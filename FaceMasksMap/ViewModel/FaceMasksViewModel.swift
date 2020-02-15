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
    var favoritePharmacy: [RLM_Pharmacy] {
        return RLM_Manager.shared.fetch(type: RLM_Pharmacy.self)//.map { $0.id }
    }
    
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
        if self.favoritePharmacy.contains(where: { $0.id == propertie.id }) {
//            self.favoriteId.remove(at: index)
            self.deletePharmacy(propertie)
        } else {
//            self.favoriteId.append(propertie.id)
            self.addPharmacy(propertie)
        }
        self.faceMaskAnn[index].isFavorite = self.favoritePharmacy.contains(where: { $0.id == propertie.id })
        
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
    
    private func addPharmacy(_ propertie: Propertie) {
        let pharmacy = RLM_Pharmacy(propertie: propertie)
        RLM_Manager.shared.add(object: pharmacy, completionHandler: {
            
        }, failHandler: { error in
            print("新增藥局失敗: \(error.localizedDescription)")
        })
    }
    
    private func deletePharmacy(_ propertie: Propertie) {
        RLM_Manager.shared.delete(type: RLM_Pharmacy.self, primaryKey: propertie.id, completionHandler: {
            
        }, failHandler: { error in
            print("刪除藥局失敗: \(error.localizedDescription)")
        })
    }
}
