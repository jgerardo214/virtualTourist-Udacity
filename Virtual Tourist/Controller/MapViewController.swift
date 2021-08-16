//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Jonathan Gerardo on 6/27/21.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pin] = []
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var pinnedLocation: Pin!
    
    
    
    
    func setupFetchResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects?.count == 0 {
                print("No pins found on map")
            } else {
                let pins = fetchedResultsController.fetchedObjects!
                var placePins = [MKPointAnnotation()]
                for pin in pins {
                    let placePin = MKPointAnnotation()
                    placePin.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
                    placePins.append(placePin)
                }
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(placePins)
                }
                
            }
        } catch {
            fatalError("The fetch could not be peformed:\(error.localizedDescription)")
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self 
        
        // code for pinning a location with a long press
        let gestureRecongnizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecongnizer.delegate = self
        mapView.addGestureRecognizer(gestureRecongnizer)
        
        // storing the Core Data for each pinned location
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            mapView.removeAnnotations(mapView.annotations)
            addAnnotations()
        }
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupFetchResultsController()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    @objc func handleTap(gestureRecongizer: UIGestureRecognizer) {
        if gestureRecongizer.state == UIGestureRecognizer.State.began {
            let location = gestureRecongizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            mapView.setCenter(mapView.centerCoordinate, animated: true)
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            
            dataController.autoSaveViewContext()
            try? fetchedResultsController.performFetch()
            
            
        }
    }
    
    
    
    func addAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let photoVC = self.storyboard!.instantiateViewController(withIdentifier: "PhotoVC") as? PhotoViewController
        photoVC?.coordinate = view.annotation?.coordinate
        
        
        if let pinnedLat = view.annotation?.coordinate.latitude,
           let pinnedLong = view.annotation?.coordinate.longitude,
           let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                if pin.latitude == pinnedLat && pin.longitude == pinnedLong {
                    
                    photoVC?.pin = pin
                    dataController.autoSaveViewContext()
                }
            }
            
        }
        
        photoVC?.dataController = dataController
        self.present(photoVC!, animated: true, completion: nil)
    }
}









