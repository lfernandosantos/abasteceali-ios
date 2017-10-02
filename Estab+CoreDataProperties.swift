//
//  Estab+CoreDataProperties.swift
//  Abastece Alí
//
//  Created by Luiz Fernando dos Santos on 16/09/17.
//  Copyright © 2017 LFSantos. All rights reserved.
//

import Foundation
import CoreData


extension Estab {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Estab> {
        return NSFetchRequest<Estab>(entityName: "Estab")
    }

    @NSManaged public var posto: String?
    @NSManaged public var endereco: String?
    @NSManaged public var id: Int16

}
