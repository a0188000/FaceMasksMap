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

enum FaceMaskType {
    case adult
    case child
}

class MapViewController: UIViewController {
    
    private var viewModel: FaceMasksViewModel!
    private var faceMaskType: FaceMaskType = .adult
    private let mapView = MKMapView(frame: UIScreen.main.bounds)
    private var mapClusterCtrl = CCHMapClusterController()
    private var selectedClusterAnn: CCHMapClusterAnnotation?

    convenience init(locationFetch: LocationFetcher) {
        self.init()
        self.viewModel = FaceMasksViewModel(locationFetcher: locationFetch, controller: self)
        self.viewModel.locationFetcher.locationManager.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
        
        self.configureUI()
        self.configureMapClusterCtrl()
        self.viewModel.locationFetcher.askAuthorization()
    }

    private func configureUI() {
        self.setMapView()
    }
    
    private func setMapView() {
        self.mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "FaceMask")
        self.view.addSubview(mapView)
        
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
    }
    
    private func configureMapClusterCtrl() {
        self.mapClusterCtrl = CCHMapClusterController(mapView: self.mapView, {
            $0.maxZoomLevelForClustering = 19
            $0.minUniqueLocationsForClustering = 1
            $0.isDebuggingEnabled = false
            $0.cellSize = 100
            $0.delegate = self
        })
        
    }

    private func addAnnotation() {
        self.mapView.removeAnnotations(self.viewModel.faceMaskAnn)
        NSLog("Start")
        for feature in self.viewModel.features {
            guard let coordinate = feature.geometry.coordinate else { break }
            let ann = FaceMaskAnnotation(coordinate: coordinate, propertie: feature.properties, faceMaskType: self.faceMaskType)
            self.viewModel.faceMaskAnn.append(ann)
        }
        NSLog("End")
        self.mapClusterCtrl.addAnnotations(self.viewModel.faceMaskAnn) {

        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        self.viewModel.locationFetcher.locationManager.stopUpdatingLocation()
        self.didUpdateUserLocation(userLocation: newLocation)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: CCHMapClusterAnnotation.self) {
            var clusterAnnView = mapView.dequeueReusableAnnotationView(withIdentifier: "FaceMaskAnn") as? FaceMaskAnnotationView
            if clusterAnnView == nil {
                clusterAnnView = FaceMaskAnnotationView(annotation: annotation, reuseIdentifier: "FaceMaskAnn")
            } else {
                clusterAnnView?.annotation = annotation
            }

            let clusterAnn = annotation as! CCHMapClusterAnnotation
            clusterAnnView?.count = clusterAnn.annotations.count
            return clusterAnnView
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
        if view.isKind(of: FaceMaskAnnotationView.self) {
            guard let clusterAnn = view.annotation as? CCHMapClusterAnnotation else { return }
            if clusterAnn.annotations.count != 1 {
                self.mapViewDeselecte()
                self.selectedClusterAnn = clusterAnn
                if clusterAnn.annotations.count > 5 {
                    mapView.setRegion(MKCoordinateRegion(center: clusterAnn.coordinate, latitudinalMeters: 700, longitudinalMeters: 700), animated: true)
                } else {
                    let faceMaskAnn = clusterAnn.annotations
                        .compactMap { $0 as? FaceMaskAnnotation }
                    self.mapClusterCtrl.removeAnnotations(clusterAnn.annotations.map {$0}) {
                        self.mapView.addAnnotations(faceMaskAnn)
                    }
                }
                
            }
        } else {
//            guard
//                let faceMaskAnn = view.annotation as? FaceMaskAnnotation,
//                let propertie = faceMaskAnn.propertie
//            else { return }
//            self.addCalloutView(view: view, annotation: view.annotation as? FaceMaskAnnotation)
//            print(propertie.address)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.subviews.forEach {
            if $0 is FaceMaskCalloutView {
                $0.removeFromSuperview()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        mapView.selectedAnnotations.forEach { mapView.deselectAnnotation($0, animated: false) }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.mapViewDeselecte()
        
        let coordinate = CLLocationCoordinate2D(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude)
        var span = mapView.region.span
        if span.latitudeDelta < 0.002 {
            span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        } else if span.latitudeDelta > 0.003 {
            span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        }
        let region = MKCoordinateRegion(center: coordinate, span: span)
//        mapView.setRegion(region, animated: true)
    }
    
    func mapViewDeselecte() {
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
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, titleFor mapClusterAnnotation: CCHMapClusterAnnotation!) -> String! {
        let numAnnotations = mapClusterAnnotation.annotations.count
        let unit = numAnnotations > 1 ? "annotations" : "annotation"
        return "\(numAnnotations) \(unit)"
    }
    
    func mapClusterController(_ mapClusterController: CCHMapClusterController!, willReuse mapClusterAnnotation: CCHMapClusterAnnotation!) {
        guard let clusterAnnView = self.mapView.view(for: mapClusterAnnotation) as? FaceMaskAnnotationView else { return }
        clusterAnnView.count = mapClusterAnnotation.annotations.count
    }
}

extension MapViewController: ControllerManager {
    func didUpdateUserLocation(userLocation: CLLocation) {
        self.mapView.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
    
    func didUpdateData() {
        self.addAnnotation()
    }
}
