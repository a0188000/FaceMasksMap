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
    var faceMasksType: FaceMasksType = .adult
    var features: [Feature] = []
    var faceMaskAnn: [FaceMaskAnnotation] = []
    var favoritePharmacy: [RLM_Pharmacy] = RLM_Manager.shared.fetch(type: RLM_Pharmacy.self).sorted(by: { $0.id < $1.id })
//    }
    
    init(locationFetcher: LocationFetcher, controller: ControllerManager) {
        self.locationFetcher = locationFetcher
        self.controller = controller
        self.fetchData()
        
        RLM_Manager.shared.fetch(type: RLM_Pharmacy.self).forEach {
            self.favoritePharmacy.append($0.unmanagedCopy())
        }
        self.favoritePharmacy = self.favoritePharmacy.sorted(by: { $0.id < $1.id })
        
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.fetchData), userInfo: nil, repeats: true)
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
        self.favoritePharmacy = RLM_Manager.shared.fetch(type: RLM_Pharmacy.self)
                .map { $0.unmanagedCopy() }
                .sorted(by: { $0.id < $1.id })
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
    
    func navigationToPharmacy(coordinate: CLLocationCoordinate2D, pharmacyName: String? = nil) {
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving") else { return }
            let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let googleAction = UIAlertAction(title: "Google地圖導航", style: .default) { (_) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            let appleAction = UIAlertAction(title: "Apple地圖導航", style: .default) { (_) in
                self.openAppleMap(coordinate: coordinate, pharmacyName: pharmacyName)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertSheet.addAction(googleAction)
            alertSheet.addAction(appleAction)
            alertSheet.addAction(cancelAction)
            (self.controller as? UIViewController)?.present(alertSheet, animated: true, completion: nil)
        } else {
            self.openAppleMap(coordinate: coordinate, pharmacyName: pharmacyName)
        }
    }
    
    func changedFaceMasksType(type: FaceMasksType) {
        self.faceMasksType = type
        self.configureFackMasksAnnotation()
    }
    
    private func configureFackMasksAnnotation() {
        self.faceMaskAnn = []
        for feature in self.features {
            guard let coordinate = feature.geometry.coordinate else { break }
            let ann = FaceMaskAnnotation(coordinate: coordinate, propertie: feature.properties, faceMaskType: self.faceMasksType)
            self.faceMaskAnn.append(ann)
        }
    }
    
    private func openAppleMap(coordinate: CLLocationCoordinate2D, pharmacyName: String?) {
        let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan:regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = pharmacyName
        mapItem.openInMaps(launchOptions: options)
    }
    
    @objc private func fetchData() {
        FaceMasksAPI.shared.getInfo { (response, error) in
            guard let response = response else { return }
            print("Hola.")
            self.features = response.features
            self.configureFackMasksAnnotation()
            DispatchQueue.main.async {
                self.controller.didUpdateData()
                let properties = self.favoritePharmacy.flatMap { pharmacy in
                    self.features.filter { $0.properties.id == pharmacy.id }
                }.map { $0.properties }.sorted(by: { $0.id < $1.id })
                let copyFavPharmacy = self.favoritePharmacy.map { $0.unmanagedCopy() }
                for (offset, propertie) in properties.enumerated() {
                    copyFavPharmacy[offset].adult = propertie.adult
                    copyFavPharmacy[offset].child = propertie.child
                }
                self.favoritePharmacy = copyFavPharmacy
                RLM_Manager.shared.update(objects: self.favoritePharmacy, completionHandler: nil, failHandler: nil)
                
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
