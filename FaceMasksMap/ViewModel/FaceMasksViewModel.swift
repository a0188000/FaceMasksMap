//
//  FaceMasksViewModel.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit
import MapKit

class FaceMasksViewModel {
    
    var locationFetcher: LocationFetcher
    var controller: ControllerManager
    var features: [Feature] = []
    var faceMaskAnn: [FaceMaskAnnotation] = []
    var favoritePharmacy: [RLM_Pharmacy] =
            RLM_Manager.shared.fetch(type: RLM_Pharmacy.self)
                .map { $0.unmanagedCopy() }
                .sorted(by: { $0.id < $1.id })
        //.map { $0.id }
//    }
    
    init(locationFetcher: LocationFetcher, controller: ControllerManager) {
        self.locationFetcher = locationFetcher
        self.controller = controller
        self.fetchData()
    }
    
    func checkAnnotationFavoriteStatus(annotation: FaceMaskAnnotation?) {
        guard
            let index = self.faceMaskAnn.firstIndex(where: { $0.propertie?.id == annotation?.propertie?.id }),
            let propertie = self.faceMaskAnn[index].propertie
        else { return }
        if self.favoritePharmacy.contains(where: { $0.id == propertie.id }) {
            self.deletePharmacy(propertie)
        } else {
            self.addPharmacy(propertie)
        }
        self.faceMaskAnn[index].isFavorite = self.favoritePharmacy.contains(where: { $0.id == propertie.id })
    }
    
    func callPhoneToPharmacy(phoneNumber: String) {
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let callAction = UIAlertAction(title: "通話 \(phoneNumber)", style: .default) { (_) in
            guard let url = URL(string: "tel://\(phoneNumber)") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertSheet.addAction(callAction)
        alertSheet.addAction(cancelAction)
        (self.controller as? UIViewController)?.present(alertSheet, animated: true, completion: nil)
    }
    
    func navigationToPharmacy(coordinate: CLLocationCoordinate2D) {
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            
        }
        
    }
    
    private func fetchData(duration: TimeInterval = 30.0) {
        FaceMasksAPI.shared.getInfo { (response, error) in
            guard let response = response else { return }
            self.features = response.features
            DispatchQueue.main.async {
                self.controller.didUpdateData()
                let properties = self.favoritePharmacy.flatMap { pharmacy in
                    self.features.filter { $0.properties.id == pharmacy.id }
                }.map { $0.properties }.sorted(by: { $0.id < $1.id })
//                .map { RLM_Pharmacy(propertie: $0) }
                for (offset, propertie) in properties.enumerated() {
                    self.favoritePharmacy[offset].adult = propertie.adult
                    self.favoritePharmacy[offset].child = propertie.child
                }
                RLM_Manager.shared.update(objects: self.favoritePharmacy, completionHandler: nil, failHandler: nil)
//                RLM_Manager.shared.update(objects: rlm_Pharmacy, completionHandler: nil, failHandler: nil)
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
