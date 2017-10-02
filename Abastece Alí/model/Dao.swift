//
//  Dao.swift
//  Abastece Alí
//
//  Created by Luiz Fernando dos Santos on 17/09/17.
//  Copyright © 2017 LFSantos. All rights reserved.
//

import Foundation
import CoreData

class DAO{
    
    func verificaJaExistente(posto id: Int, contexto: NSManagedObjectContext) -> Bool{
        
        let fetchRequest: NSFetchRequest<Posto> = Posto.fetchRequest()
        let predicate = NSPredicate(format: "id ==%ld", id)
        fetchRequest.predicate = predicate
        
        do{
            let count = try contexto.count(for: fetchRequest)
            print( "Existem \(count) registros com esse id no BD!")
            if(count>0){
                return true
            }else{
                return false}
        }catch let error as NSError{
            print("Erro ao ler dados. \(error), \(error.userInfo)")
            return false
        }
        
    }
    func salvar(contexto: NSManagedObjectContext, posto: PostoModel){
       
        let fetchRequest: NSFetchRequest<Posto> = Posto.fetchRequest()
        let postoExistente = verificaJaExistente(posto: posto.id!, contexto: contexto)
        
        if(postoExistente){
            return
        }
        
        let postoASalvar = Posto(context: contexto)
        
        postoASalvar.id = Int64(posto.id!)
        postoASalvar.posto = posto.posto
        postoASalvar.end = posto.endereco
        postoASalvar.bairro = posto.bairro
        postoASalvar.bandeira = posto.bandeira
        postoASalvar.gas = posto.gasolina
        postoASalvar.gnv = posto.gnv
        postoASalvar.alcool = posto.alcool
        postoASalvar.lat = converteParaDouble(posto.latitude!)
        postoASalvar.lon = converteParaDouble(posto.longitude!)
        postoASalvar.cidade = posto.cidade
        postoASalvar.uf = posto.uf
        
        print("salvando posto \(postoASalvar.posto)")
        do{
            try contexto.save()
            print("Posto \(postoASalvar.posto) salvo!")
            
        }catch let error as NSError{
            print("erro ao salvar. \(error), \(error.userInfo)")
        }
    }
 
    func converteParaDouble(_ string: String) -> Double{
        var itemConvertido:Double = 0.0
        
        if(string != nil){
            itemConvertido = Double(string)!
        }
        
        return itemConvertido
    }
}
