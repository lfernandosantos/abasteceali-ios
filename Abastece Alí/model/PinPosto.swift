//
//  PinPosto.swift
//  Abastece Alí
//
//  Created by Luiz Fernando dos Santos on 21/09/17.
//  Copyright © 2017 LFSantos. All rights reserved.
//

import Foundation
import MapKit
class PinPosto: NSObject, MKAnnotation{
    var id: Int = 22
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(id: Int, title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
}
