//
//  ExtensionPhotoViewController.swift
//  Virtual Tourist
//
//  Created by Jonathan Gerardo on 7/8/21.
//

import UIKit

extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
           
           
               let object = fetchedResultsController.object(at: indexPath)
               if object.photo == nil {
                   cell.imageView.image = UIImage(named: "placeholder")
                
                
                DispatchQueue.global().async { [self] in
                    FlickrAPI.downloadImages(imageURL: URL(string: photoURL[indexPath.row])!) { [self] data, error in
                           if let data = data {
                               cell.imageView.image = UIImage(data: data)
                               self.flickrPhotos[indexPath.row].photo = data
                               self.dataController.autoSaveViewContext()
                               if self.fetchedResultsController.fetchedObjects?.count == self.flickrPhotos.count {
                                   self.newCollectionButton.isEnabled = true
                               }
                           }
                       }
                   }
               }
           
           return cell
       }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataController.viewContext.delete(flickrPhotos[indexPath.row])
        try? self.dataController.viewContext.save()
        flickrPhotos.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        return CGSize(width: (bounds.width/2)-4, height: bounds.height/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
