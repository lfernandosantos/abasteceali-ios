//
//  PostosDelegate.swift
//  Abastece Alí
//
//  Created by Luiz Fernando dos Santos on 17/09/17.
//  Copyright © 2017 LFSantos. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import UserNotifications

class PostosDelegate {
    
    var contexto: UIViewController
    
    
    init(contexto: UIViewController) {
        self.contexto = contexto
    }
    
    func salvaPosto(posto: PostoModel){
            
            guard let appDelegate = UIApplication
              .shared.delegate as? AppDelegate else{
                    return
            }
        
        
        let managedContext = appDelegate
            .persistentContainer
            .viewContext
        
        DAO().salvar(contexto: managedContext, posto: posto)
        
    }
    
}
