//
//  MapViewController.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CCHMapClusterController

protocol ControllerManager: class {
    func didUpdateUserLocation(userLocation: CLLocation)
    func didUpdateData()
}

enum FaceMasksType {
    case adult
    case child
}

class MapViewController: UIViewController {
    
    private var viewModel: FaceMasksViewModel!
    private let mapView = MKMapView(frame: UIScreen.main.bounds)
    private var calloutView: FaceMaskCalloutView?
    private var mapClusterCtrl = CCHMapClusterController()
    private var selectedClusterAnn: CCHMapClusterAnnotation?
    private var selectedAnn: MKAnnotation?
    private var selectedAnnView: FaceMasksBaseAnnotationView? {
        willSet {
            self.selectedAnnView?.subviews.forEach { if $0 is FaceMaskCalloutView { $0.removeFromSuperview() } }
        }
    }
    private var segmentedCtrl = UISegmentedControl(items: ["成人", "兒童"])
    private var locationButton: UIButton!
    
    private var isMoveToSelecteAnn: Bool = false
    private var isFirst: Bool = true

    convenience init(locationFetch: LocationFetcher) {
        self.init()
        self.viewModel = FaceMasksViewModel(locationFetcher: locationFetch, controller: self)
        self.viewModel.locationFetcher.locationManager.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
        self.title = "特約藥局地圖"
        self.configureUI()
        self.configureMapClusterCtrl()
        self.viewModel.locationFetcher.askAuthorization()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.locationButton.layer.cornerRadius = self.locationButton.bounds.height / 2
    }

    private func configureUI() {
        self.setNavigationBarItem()
        self.setMapView()
        self.setSegmentedCtrl()
        self.setLocationButton()
    }
    
    private func setNavigationBarItem() {
        let favoriteButtonItem = UIBarButtonItem(customView: UIButton(type: .system, {
            $0.setTitle("收藏藥局", for: .normal)
            $0.addTarget(self, action: #selector(self.goFavoriteButtonPressed(_:)), for: .touchUpInside)
        }))
        self.navigationItem.rightBarButtonItem = favoriteButtonItem
    }
    
    private func setMapView() {
        if #available(iOS 11.0, *) {
            self.mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "FaceMask")
        } else {
            // Fallback on earlier versions
            
        }
        self.view.addSubview(mapView)
        
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
    }
    
    private func setSegmentedCtrl() {
        self.segmentedCtrl.backgroundColor = .gray
        self.segmentedCtrl.selectedSegmentIndex = 0
        self.segmentedCtrl.addTarget(self, action: #selector(self.segmentedCtrlValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(segmentedCtrl)
        self.segmentedCtrl.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.topMargin).offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    private func setLocationButton() {
        self.locationButton = UIButton {
            $0.setImage(UIImage(named: "location-arrow"), for: .normal)
            $0.addTarget(self, action: #selector(self.locationButtonPressed(_:)), for: .touchUpInside)
        }
        
        self.view.addSubview(locationButton)
        self.locationButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(self.view.snp_bottomMargin).offset(-16)
        }
    }
    
    private func configureMapClusterCtrl() {
        self.mapClusterCtrl = CCHMapClusterController(mapView: self.mapView, {
            $0.maxZoomLevelForClustering = 16
            $0.minUniqueLocationsForClustering = 1
            $0.isDebuggingEnabled = false
            $0.cellSize = 100
            $0.delegate = self
        })
    }

    private func addAnnotation() {
        self.mapView.removeAnnotations(self.viewModel.faceMaskAnn)
//        self.viewModel.faceMaskAnn = []
//        for feature in self.viewModel.features {
//            guard let coordinate = feature.geometry.coordinate else { break }
//            let ann = FaceMaskAnnotation(coordinate: coordinate, propertie: feature.properties, faceMaskType: .adult)
//            self.viewModel.faceMaskAnn.append(ann)
//        }
        self.mapClusterCtrl.addAnnotations(self.viewModel.faceMaskAnn) { }
    }
    
    private func addCalloutView(view: MKAnnotationView, annotation: FaceMaskAnnotation) {
        let isFavorite = self.viewModel.favoritePharmacy.contains(where: { $0.id == annotation.propertie?.id })
        let calloutView = FaceMaskCalloutView(annotation: annotation, isFavorite: isFavorite)
        calloutView.alpha = 0
        
        self.calloutView = calloutView
        self.calloutView?.delegate = self
        self.view.addSubview(calloutView)
        
        calloutView.snp.makeConstraints { (make) in
            make.width.equalTo(260)
            make.bottom.equalTo(self.view.snp.centerY).offset(-32)
            make.centerX.equalToSuperview()
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.calloutView?.alpha = 1
        })
    }
    
    @objc private func goFavoriteButtonPressed(_ sender: UIButton) {
        let ctrl = FavoriteViewController {
            $0.viewModel = self.viewModel
            $0.delegate = self
        }
        self.present(UINavigationController(rootViewController: ctrl), animated: true, completion: {
            if !self.isMoveToSelecteAnn {
                self.calloutView?.removeFromSuperview()
                self.calloutView = nil
                self.selectedAnn = nil
//                self.selectedAnnView = nil
            }
        })
    }
    
    @objc private func segmentedCtrlValueChanged(_ ctrl: UISegmentedControl) {
        self.reductionToClusterAnnotation()
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapClusterCtrl.removeAnnotations(self.viewModel.faceMaskAnn) {

        }
        self.viewModel.changedFaceMasksType(type: ctrl.selectedSegmentIndex == 0 ? .adult : .child)
        self.addAnnotation()
        
        self.calloutView?.removeFromSuperview()
        self.calloutView = nil
        self.selectedAnn = nil
        self.selectedAnnView = nil
    }
    
    @objc private func locationButtonPressed(_ sender: UIButton) {
        self.viewModel.locationFetcher.askAuthorization()
    }
    
    private func configureFaceMaskAnnotationView(mapView: MKMapView, annotation: MKAnnotation) -> FaceMaskAnnotationView? {
        var clusterAnnView = mapView.dequeueReusableAnnotationView(withIdentifier: "FaceMaskAnn") as? FaceMaskAnnotationView
        if clusterAnnView == nil {
            clusterAnnView = FaceMaskAnnotationView(annotation: annotation, reuseIdentifier: "FaceMaskAnn")
        } else {
            clusterAnnView?.annotation = annotation
        }

        let clusterAnn = annotation as! CCHMapClusterAnnotation
        clusterAnnView?.count = clusterAnn.annotations.count
        clusterAnnView?.uniqueLocation = clusterAnn.isUniqueLocation()
        return clusterAnnView
    }
    
    private func moveMapViewCamera(mapView: MKMapView, view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        let sRect = mapView.convert(annotation.coordinate, toPointTo: mapView)
        let centerCoordinate = mapView.convert(sRect, toCoordinateFrom: mapView)
        let centerPoint = MKMapPoint(centerCoordinate)
        var rect = mapView.visibleMapRect
        rect.origin.x = centerPoint.x - rect.size.width * 0.5
        rect.origin.y = centerPoint.y - rect.size.height * 0.5
        DispatchQueue.main.async {
            mapView.setVisibleMapRect(rect, animated: true)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        self.viewModel.locationFetcher.stopUpdatingLocation()
        self.didUpdateUserLocation(userLocation: newLocation)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: CCHMapClusterAnnotation.self) {
            return self.configureFaceMaskAnnotationView(mapView: mapView, annotation: annotation)
        } else if annotation.isEqual(self.mapView.userLocation) {
            return nil
        } else {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "FaceMask") as? SingleAnnotationView
            if view == nil {
                view = SingleAnnotationView(annotation: annotation, reuseIdentifier: "FaceMask")
            } else {
                view?.annotation = annotation
            }
            view?.propertie = (annotation as? FaceMaskAnnotation)?.propertie
            return view
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.calloutView?.removeFromSuperview()
        self.calloutView = nil
        self.isMoveToSelecteAnn = true
        if view.isKind(of: FaceMaskAnnotationView.self) {
            guard let clusterAnn = view.annotation as? CCHMapClusterAnnotation else { return }
            if clusterAnn.annotations.count != 1 {
                self.reductionToClusterAnnotation()
                self.selectedClusterAnn = clusterAnn
                if clusterAnn.annotations.count > 5 {
                    self.reductionToClusterAnnotation()
                    mapView.setRegion(MKCoordinateRegion(center: clusterAnn.coordinate, latitudinalMeters: 700, longitudinalMeters: 700), animated: true)
                } else {
                    self.moveMapViewCamera(mapView: mapView, view: view)
                    let faceMaskAnn = clusterAnn.annotations
                        .compactMap { $0 as? FaceMaskAnnotation }
                    self.mapClusterCtrl.removeAnnotations(clusterAnn.annotations.map {$0}) { self.mapView.addAnnotations(faceMaskAnn) }
                }
            } else {
                guard let ann = clusterAnn.annotations.first as? FaceMaskAnnotation else { return }
                self.selectedAnn = ann
                self.selectedAnnView = view as? FaceMasksBaseAnnotationView
                self.moveMapViewCamera(mapView: mapView, view: view)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.addCalloutView(view: view, annotation: ann)
                    self.isMoveToSelecteAnn = false
                }
            }
        } else {
            guard let ann = view.annotation as? FaceMaskAnnotation else { return }
            self.selectedAnn = ann
            self.selectedAnnView = view as? FaceMasksBaseAnnotationView
            self.moveMapViewCamera(mapView: mapView, view: view)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { 
                self.addCalloutView(view: view, annotation: ann)
                self.isMoveToSelecteAnn = false
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.subviews.forEach { if $0 is FaceMaskCalloutView { $0.removeFromSuperview() } }
        self.calloutView?.removeFromSuperview()
        self.calloutView = nil
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if !self.isMoveToSelecteAnn {
            self.calloutView?.removeFromSuperview()
            self.calloutView = nil
//            self.selectedAnn = nil
//            self.selectedAnnView = nil
        }
    }
    
    func reductionToClusterAnnotation() {
        guard let clusterAnn = self.selectedClusterAnn else { return }
        clusterAnn.annotations
            .compactMap { $0 as? FaceMaskAnnotation }
            .forEach { self.mapView.removeAnnotation($0) }
        self.mapClusterCtrl
            .addAnnotations(clusterAnn.annotations.compactMap { $0 }) {

        }
        self.selectedClusterAnn = nil
    }
}

extension MapViewController: CCHMapClusterControllerDelegate {
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willReuse mapClusterAnnotation: CCHMapClusterAnnotation!) {
        guard let clusterAnnView = self.mapView.view(for: mapClusterAnnotation) as? FaceMaskAnnotationView else { return }
        clusterAnnView.count = mapClusterAnnotation.annotations.count
        clusterAnnView.uniqueLocation = mapClusterAnnotation.isUniqueLocation()
    }
}

extension MapViewController: FaceMasksCalloutViewDelegate {
    func favoriteButtonPressed(at button: UIButton, buttonType type: FaceMaskCalloutView.ButtonType, annotation: FaceMaskAnnotation?) {
        guard
            let annotation = annotation,
            let propertie = annotation.propertie
        else { return }
        switch type {
        case .favorite:
            self.viewModel.checkAnnotationFavoriteStatus(annotation: annotation)
            button.isSelected = !button.isSelected
        case .navigation:
            self.viewModel.navigationToPharmacy(coordinate: annotation.coordinate, pharmacyName: annotation.propertie?.name)
        case .phoneCall:
            self.viewModel.callPhoneToPharmacy(phoneNumber: propertie.phone)
        }
    }
}

extension MapViewController: FavoriteViewControllerDelegate {
    func didSelectedFavoritePharmacy(pharmacyId: String) {
        guard let ann = self.viewModel.faceMaskAnn.first(where: { $0.propertie?.id == pharmacyId }) else { return }
        self.mapClusterCtrl.selectAnnotation(ann, andZoomToRegionWithLatitudinalMeters: 500, longitudinalMeters: 500)
    }
}

extension MapViewController: ControllerManager {
    func didUpdateUserLocation(userLocation: CLLocation) {
        self.calloutView?.removeFromSuperview()
        self.calloutView = nil
        self.mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
    }
    
    func didUpdateData() {
        if self.isFirst {
            self.addAnnotation()
            self.isFirst = false
        }
    }
}
