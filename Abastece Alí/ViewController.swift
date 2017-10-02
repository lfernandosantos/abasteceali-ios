//
//  ViewController.swift
//  Abastece Alí
//
//  Created by Luiz Fernando dos Santos on 23/08/17.
//  Copyright © 2017 LFSantos. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import NotificationCenter
import UserNotifications


class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var imgEtanol: UIImageView!
    @IBOutlet weak var imgGas: UIImageView!
    @IBOutlet weak var imgGnv: UIImageView!
    @IBOutlet weak var mapView: MKMapView?
    @IBOutlet weak var mapIOS: UIButton!
    
    var nomes:[NSManagedObject] = []
    let indicatorLoading: UIActivityIndicatorView = UIActivityIndicatorView()
    let gerenciadorLocalizacao = CLLocationManager()
    var localizacao: CLLocationCoordinate2D?
    var postosDelegate: PostosDelegate?
    var lista: Array<PostoModel> = []
    var listaP: Array<Posto> = []
    var postoSelecionado: PostoModel?
    var managedContext: NSManagedObjectContext?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenButtons()
        
        configLocalizacao()

        mapView?.delegate = self
        postosDelegate = PostosDelegate(contexto: self)
        
        if let coordenada = localizacao{
            centralizar(coordenadas: coordenada)
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnMap))
        mapView?.addGestureRecognizer(gestureRecognizer)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    @IBAction func openIOSMaps(_ sender: Any) {
        if let posto = postoSelecionado{
            openOnMaps(posto: posto)
        }
    }
    func showLoadingIndicator(){
        indicatorLoading.center = view.center
        indicatorLoading.hidesWhenStopped = true
        indicatorLoading.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge

        view.alpha = 0.75
        view.addSubview(indicatorLoading)
        indicatorLoading.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopLoadingIndicator(){
        view.backgroundColor = .white
        view.alpha = 0.99
        self.indicatorLoading.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    @IBAction func searchWithGnv(_ sender: Any) {
        if let coordenada = localizacao{
            centralizar(coordenadas: coordenada)
            requestAPI(location: coordenada, gnv: true)
        }
    }
    
    func tapOnMap(gestureReconizer: UILongPressGestureRecognizer){
        hiddenButtons()
    }
    
    func hiddenButtons(){
        mapIOS.isHidden = true
        imgEtanol.isHidden = true
        imgGas.isHidden = true
        imgGnv.isHidden = true
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        hiddenButtons()
        guard let anotation = view.annotation as? PinPosto else{print("Não é PinPosto!"); return}
        
        for posto in lista{
            if(posto.id == anotation.id){
                postoSelecionado = posto
                openDetails(posto: posto)
                
            }
        }
    }
    
    func openDetails(posto: PostoModel){
        if let gnv = posto.gnv{
            if(gnv != "0"){
                imgGnv.isHidden = false
            }
        }
        if let etanol = posto.alcool{
            if(etanol != "0"){
                imgEtanol.isHidden = false
            }
        }
        
        imgGas.isHidden = false
        mapIOS.isHidden = false
    }
    
    
    func doModoOff() {
        
        //criar metodo getPostos no DAO
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Posto> = Posto.fetchRequest()
        
        do{
            let postos = try managedContext.fetch(fetchRequest)
            
            if(postos.count == 0){
                print("Sem postos cadastrados!")
                return
            }
            
            for posto in postos{
                //converter posto para postoModel e usar metodo addPostoAnotation
                addPostoOnMap(posto)
            }
            
        }catch let error as NSError{
            print("Erro  \(error) \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

 
    @IBAction func myLocation(_ sender: Any) {
        
        if let coordenada = localizacao{
            centralizar(coordenadas: coordenada)
            requestAPI(location: coordenada, gnv: false)
        }
        
    }
    
    func centralizar(coordenadas: CLLocationCoordinate2D){
        
        let area = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let regiao:MKCoordinateRegion = MKCoordinateRegionMake(coordenadas, area)
        mapView?.setRegion(regiao, animated: true)
        print("Localização \(coordenadas)")
    }

    func requestAPI(location: CLLocationCoordinate2D, gnv: Bool){
        
        showLoadingIndicator()
        print("do request")
        let cllatitude = location.latitude
        let cclongitude = location.longitude
        
        var stringUrl: String
        if gnv {
            stringUrl = "https://pure-brook-75560.herokuapp.com/api/postos/location?latitude=\(cllatitude)&longitude=\(cclongitude)&gnv=1"
        }else{
            stringUrl = "https://pure-brook-75560.herokuapp.com/api/postos/location?latitude=\(cllatitude)&longitude=\(cclongitude)"
        }
        guard let url = URL(string: stringUrl) else{
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: url){ (data, response, error) in
            if let response = response{
                print(response)
            }
            if let erro = error{
                
                if(erro.localizedDescription.contains("The Internet connection appears to be offline.")){
                    
                    self.doModoOff()
                    self.stopLoadingIndicator()
                }
            }
            if let data = data{
                print(data)
                print("---")
                
                do{
                    
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else{ print("Não foi possivel converter"); return}
                    
                    if let postos = json["postos"]{
                        
                        guard let postoNSArray = postos as? NSArray else{ print("Erro ao converter postos para NSArray!"); return}
                        
                        self.lista.removeAll()
                        for postoNS in postoNSArray{

                            guard let p = postoNS as? [String:AnyObject] else{ return}
                            
                            if p["posto"] != nil{
                                //capturando posto do JSON
                                
                                let dictionary = NSMutableDictionary()
                                dictionary.setValue(p["id"], forKey: "id")
                                dictionary.setValue(p["posto"], forKey: "posto")
                                dictionary.setValue(p["nome"], forKey: "nome")
                                dictionary.setValue(p["endereco"], forKey: "endereco")
                                dictionary.setValue(p["bairro"], forKey: "bairro")
                                dictionary.setValue(p["bandeira"], forKey: "bandeira")
                                dictionary.setValue(p["icone"], forKey: "icone")
                                dictionary.setValue(p["gasolina"], forKey: "gasolina")
                                dictionary.setValue(p["gnv"], forKey: "gnv")
                                dictionary.setValue(p["alcool"], forKey: "alcool")
                                dictionary.setValue(p["latitude"], forKey: "latitude")
                                dictionary.setValue(p["longitude"], forKey: "longitude")
                                dictionary.setValue(p["distancia"], forKey: "distancia")
                                dictionary.setValue(p["cidade"], forKey: "cidade")
                                dictionary.setValue(p["uf"], forKey: "uf")

                                if let postoDic = PostoModel(dictionary: dictionary){
                                   
                                    self.addPostoAnotation(postoDic)
                                    self.lista.append(postoDic)
                                    //self.postosDelegate?.salvaPosto(posto: posto)
                                }
                            }
                        }
                        self.stopLoadingIndicator()
                        
                    }
                    self.salvaPostos()
                    
                }catch{
                    self.stopLoadingIndicator()
                    print(error)
                }
            }
            }.resume()
    }
    

    func salvaPostos(){
        for posto in lista{
            postosDelegate?.salvaPosto(posto: posto)
        }
    }
    
    func addPostoAnotation(_ posto: PostoModel){
        
        let lat: CLLocationDegrees = CLLocationDegrees(posto.latitude!)!
        let lon: CLLocationDegrees = CLLocationDegrees(posto.longitude!)!
        
        let local = CLLocationCoordinate2DMake(lat, lon)
        let anotation = PinPosto( id: posto.id!, title: posto.posto!, subtitle: posto.endereco!, coordinate: local)
        mapView?.addAnnotation(anotation)
        
        //let pin = PinPosto( id: Int(posto.id), title: nomePosto, subtitle: end, coordinate: local)
    }
    
    func showPostosByLista(_ listaPostos: Array<PostoModel> ){
        
        if let anotations = mapView?.annotations{
            mapView?.removeAnnotations(anotations)
        }
        for posto in listaPostos{
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let postoIndex = posto.getPostoEntity(context: managedContext)
            
            // colocando posto no mapa
            self.addPostoOnMap(postoIndex)
        }
        stopLoadingIndicator()
    }
}


extension ViewController: CLLocationManagerDelegate{
    
    func configLocalizacao(){
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        print(locations.first)
        manager.pausesLocationUpdatesAutomatically = true
        guard let currentLocation = locations.first else{
            return
        }
        
        requestAPI(location: currentLocation.coordinate, gnv: false)
        
        localizacao = currentLocation.coordinate
        mapView?.userTrackingMode = .follow
    
    }
    
   // colocando posto no mapa
    func addPostoOnMap(_ posto: Posto){
        
        let local = getLocationByLatLon(lat: posto.lat, lon: posto.lon)
        
        guard let nomePosto = posto.posto else{
            print("Posto sem nome!")
            return
        }
        guard let end = posto.end else{
            print("Posto sem endereço!")
            return
        }
        
        let pin = PinPosto( id: Int(posto.id), title: nomePosto, subtitle: end, coordinate: local)
        
        let anotacao = MKPointAnnotation()
        anotacao.title = posto.posto
        anotacao.subtitle = posto.end
        anotacao.coordinate = local
        
        if let mapa = self.mapView{
            mapa.addAnnotation(pin)
        }
    }
    
    func getLocationByLatLon(lat: Double, lon: Double) -> CLLocationCoordinate2D{
        let lat: CLLocationDegrees = lat
        let lon: CLLocationDegrees = lon
        let local: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        
        return local
    }
    
    func openOnMaps(posto: PostoModel){
        let regionDistance:CLLocationDistance = 10000
        let local = getLocationByLatLon(lat: Double(posto.latitude!)!, lon: Double(posto.longitude!)!)
        let regionSpan = MKCoordinateRegionMakeWithDistance(local, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: local, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = posto.posto
        mapItem.openInMaps(launchOptions: options)
    }
}
