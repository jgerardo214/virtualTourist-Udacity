//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Jonathan Gerardo on 6/28/21.
//

import Foundation
import MapKit
import CoreData
import UIKit

class PhotoViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImagesLabel: UILabel!

    
    
    
    var coordinate: CLLocationCoordinate2D!
    var flickrPhotos = [Photo]()
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var photoURL: [String] = []
    
    
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 20.0, bottom: 5.0, right: 20.0)
    let itemsPerRow: CGFloat = 3.0
    
    

    
    // fetches any saved photos 
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        if let pin = pin {
            let predicate = NSPredicate(format: "pin == %@", pin)
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch failed: \(error.localizedDescription)")
        }
    }
    
 
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setupFetchedResultsController()
        noImagesLabel.isHidden = true
        FlickrAPI.flickrGETSearchPhotos(lat: pin.latitude, lon: pin.longitude, completionHandler: getImagesFromFlickr(photos:error:))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This will make sure the pinned location stays in focus on the Map View of the PhotoViewController
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    func setMapView() {
        mapView.delegate = self
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        mapView.selectAnnotation(annotation, animated: true)
        
        let rectangleSide = 5000
        let region = MKCoordinateRegion( center: coordinate, latitudinalMeters: CLLocationDistance(exactly: rectangleSide)!, longitudinalMeters: CLLocationDistance(exactly: rectangleSide)!)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .systemTeal
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    

    
    
    func getImagesFromFlickr(photos: [FlickrPhoto?], error: Error?) {
        
        if error == nil {
            
            if photos.count != 0 {
                self.noImagesLabel.isHidden = true
                for photo in photos {
                    let image = Photo(context: self.dataController.viewContext)
                    image.pin = self.pin
                    flickrPhotos.append(image)
                    let url = FlickrAPI.Endpoints.getPhotoURL(photo!.server, photo!.id, photo!.secret)
                    photoURL.append(url.stringURL)
                    
                }
            } else {
                self.noImagesLabel.isHidden = false
                self.newCollectionButton.isEnabled = true
            }
        }
        self.collectionView.reloadData()
        try? dataController.viewContext.save()
        
       
        
        
        
    }
    

    
    
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        newCollectionButton.isEnabled = false
        flickrPhotos = []
        photoURL = []
        
        if let objects = fetchedResultsController.fetchedObjects {
            for object in objects {
                dataController.viewContext.delete(object)
            }
            dataController.autoSaveViewContext()
    
            
            FlickrAPI.flickrGETSearchPhotos(lat: pin.latitude, lon: pin.longitude, completionHandler: getImagesFromFlickr(photos:error:))
        }
    }
}
