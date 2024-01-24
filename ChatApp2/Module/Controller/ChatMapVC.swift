//
//  ChatMapViewController.swift
//  ChatApp2
//
//  Created by Fırat AKBULUT on 16.01.2024.
//

import UIKit
import GoogleMaps

protocol ChatMapVCDelegate: AnyObject{
    func didTapLocation(lat: String, lon: String)
}

class ChatMapVC: UIViewController{
    //MARK: - Properties
    
    private let mapView = GMSMapView()
    private var location: CLLocationCoordinate2D?
    private lazy var marker = GMSMarker()
    
    weak var delegate: ChatMapVCDelegate?
    
    private lazy var sendLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Location", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .red.withAlphaComponent(0.6)
        button.setDimensions(height: 50, width: 150)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleSendLocationButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
    }
    
    //MARK: - Actions
    
    @objc func handleSendLocationButton(){
        guard let lat = location?.latitude else{return}
        guard let lon = location?.longitude else{return}
        delegate?.didTapLocation(lat: String(lat), lon: String(lon))
    }
    
    //MARK: - Helpers
    
    private func configureUI(){
        title = "Select Location"
       
        view.addSubview(mapView)
        view.backgroundColor = .white

        mapView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(sendLocationButton)
        sendLocationButton.centerX(inView: view)
        sendLocationButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 20)
    }
    
    private func configureMapView(){
        FLocationManager.shared.start { info in
            self.location = CLLocationCoordinate2DMake(info.latitude ?? 0.0, info.longitude ?? 0.0)
            self.mapView.delegate = self
            self.mapView.isMyLocationEnabled = true
            self.mapView.settings.myLocationButton = true
            guard let location = self.location else{return}
            self.updateCamera(location: location)
            FLocationManager.shared.stop()
        }
    }
    
    func updateCamera(location: CLLocationCoordinate2D){
        self.location = location
        self.mapView.camera = GMSCameraPosition(target: location, zoom: 15)
        self.mapView.animate(toLocation: location)
        
        ///add marker
        marker.map = nil
        marker = GMSMarker(position: location)
        marker.map = mapView
    }
}

//MARK: - GMSMapViewDelegate

extension ChatMapVC: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        updateCamera(location: coordinate)
    }
}
