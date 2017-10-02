//
//  Controler.swift
//  Abastece Alí
//
//  Created by Luiz Fernando dos Santos on 23/09/17.
//  Copyright © 2017 LFSantos. All rights reserved.
//

import Foundation

protocol Controller {
    
    protocol View {
        func loadPostos(_postos: PostoModel)
    }
    
    protocol Presenter {
        func getPostos()
    }
}
