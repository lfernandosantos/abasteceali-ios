//: Playground - noun: a place where people can play

import UIKit

class BancaPoker{
    static var fichasNaBanca = 10_000
    static func distribuir(fichas fichasPerdidas: Int)->Int{
        let fichasAVender = min(fichasPerdidas, fichasNaBanca)
        fichasNaBanca -= fichasAVender
        
        return fichasAVender
    }
    
    static func receber(fichas: Int){
        fichasNaBanca += fichas
    }
    
}

class Jogador {
    
    var fichasJogador: Int
    init(fichas: Int) {
        fichasJogador = BancaPoker.distribuir(fichas: fichas)
    }
    func venceu(fichas: Int) {
        fichasJogador += BancaPoker.distribuir(fichas: fichas)
    }
    deinit {
        BancaPoker.receber(fichas: fichasJogador)
    }
}

var jogadorNumeroUm: Jogador? = Jogador(fichas: 100)

print("Novo Jogador com \(jogadorNumeroUm?.fichasJogador) fichas")
print("Temos \(BancaPoker.fichasNaBanca) fichas na banca" )
jogadorNumeroUm?.venceu(fichas: 2_000)

print("JogadorNumeroUm Ganhou 2000 fichas e agora tem \(jogadorNumeroUm?.fichasJogador) fichas")
print("A banca tem \(BancaPoker.fichasNaBanca) fichas")

jogadorNumeroUm = nil
print("JogadorNumeroUm Saiu")
print("A banca tem \(BancaPoker.fichasNaBanca)")


class Aluno{
    let nome: String
    init(nome: String) {
        self.nome = nome
    }
        var materia: Materia?
    deinit {
        print("nome \(nome) foi zerada" )
    }
}

class Materia{
    let nome: String
    init(nome: String) {
        self.nome = nome
    }
    weak var aluno: Aluno?
    deinit {
        print("Materia \(nome) foi zerada")
    }
}
var giovanni: Aluno?
var swift: Materia?

giovanni = Aluno(nome: "Giovanni")
swift = Materia(nome: "Top Av Swift")

giovanni?.materia = swift
swift?.aluno = giovanni

giovanni = nil
swift = nil
