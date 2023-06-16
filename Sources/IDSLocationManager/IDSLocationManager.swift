//
//  IDSLocationManager.swift
//  DVSSDKTest
//
//  Created by AKorotkov on 15.06.2023.
//

import Foundation
import CoreLocation

public class IDSLocationManager: NSObject, CLLocationManagerDelegate {
    public var lastLocation: CLLocation? {
        _lastLocation
    }
    public var lastLocationTime: CGFloat? = nil
    
    lazy private var locationManager: CLLocationManager = {
        let locManager = CLLocationManager()
        locManager.delegate = self
        return locManager
    }()
    
    public var permissionsAccepted: Bool {
        CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    public var permissionsDenied: Bool {
        CLLocationManager.authorizationStatus() == .denied
    }
    
    /**
     Required: Add NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription and NSLocationAlwaysAndWhenInUseUsageDescription to Info.plist
     */
    
    private var authorizationStatusBlock: ((CLAuthorizationStatus) -> Void)?
    public func requestPermissions(alwaysAuthorization: Bool, handler block: ((CLAuthorizationStatus) -> Void)?) {
        self.authorizationStatusBlock = block
        
        if alwaysAuthorization {
            self.locationManager.requestAlwaysAuthorization()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private var _lastLocation: CLLocation? = nil
    private var updateLocationBlock: ((CLLocation?, Error?) -> Void)?
    
    /**
     Required: Add NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription and NSLocationAlwaysAndWhenInUseUsageDescription to Info.plist
     */
    
    public func updateLocation(handler block: ((CLLocation?, Error?) -> Void)?) {
        self.updateLocationBlock = block
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.requestPermissions(alwaysAuthorization: false, handler: nil)
        }
        self.locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let block = self.authorizationStatusBlock, status != .notDetermined {
            block(status)
            self.authorizationStatusBlock = nil
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            self._lastLocation = locations.first
            self.lastLocationTime = CFAbsoluteTimeGetCurrent()
            
            if let block = self.updateLocationBlock {
                block(self._lastLocation, nil)
                self.updateLocationBlock = nil
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let block = self.updateLocationBlock {
            block(nil, error)
            self.updateLocationBlock = nil
        }
    }
}
