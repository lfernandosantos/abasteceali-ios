//
//  Posto+CoreDataProperties.swift
//  Abastece Alí
//
//  Created by Luiz Fernando dos Santos on 16/09/17.
//  Copyright © 2017 LFSantos. All rights reserved.
//

import Foundation
import CoreData


extension Posto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Posto> {
        return NSFetchRequest<Posto>(entityName: "Posto")
    }

    @NSManaged public var id: Int64
    @NSManaged public var posto: String?
    @NSManaged public var end: String?
    @NSManaged public var bairro: String?
    @NSManaged public var bandeira: String?
    @NSManaged public var gas: String?
    @NSManaged public var gnv: String?
    @NSManaged public var alcool: String?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var cidade: String?
    @NSManaged public var uf: String?

}
