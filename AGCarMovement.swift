//
//  AGCarMovement.swift
//
//  Created by Aman Gangurde on 11/01/18.
//  Copyright © 2018 Aman Gangurde. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

extension Int
{
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint
{
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

@objc public protocol AGCarMovementDelegate
{
    func AGCarMovementMoved(_ Marker: GMSMarker)
}

public class AGCarMovement: NSObject
{
    public weak var delegate: AGCarMovementDelegate?
    public var duration: Float = 2.0
    
    public func AGCarMovement(marker: GMSMarker, oldCoordinate: CLLocationCoordinate2D, newCoordinate:CLLocationCoordinate2D, mapView: GMSMapView, bearing: Float)
    {
        let calBearing: Float = getHeadingForDirection(fromCoordinate: oldCoordinate, toCoordinate: newCoordinate)
        marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        marker.rotation = CLLocationDegrees(calBearing);
        marker.position = oldCoordinate;
        
        CATransaction.begin()
        CATransaction.setValue(duration, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock({() -> Void in
            marker.rotation = (Int(bearing) != 0) ? CLLocationDegrees(bearing) : CLLocationDegrees(calBearing)
        })
        
        //
        delegate?.AGCarMovementMoved(marker)
        
        marker.position = newCoordinate;
        marker.map = mapView;
        marker.rotation = CLLocationDegrees(calBearing);
        CATransaction.commit()
    }
    
    private func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float
    {
        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        return (degree >= 0) ? degree : (360 + degree)
    }
}
