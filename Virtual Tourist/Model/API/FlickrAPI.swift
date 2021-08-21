//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Jonathan Gerardo on 6/27/21.
//

import Foundation
import UIKit
import MapKit


class FlickrAPI {
    
    static let apiKey: String = "ab4fbc590be5123a40e321e3418d26ae"
    
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let apiKeyParam = "&api_key=\(FlickrAPI.apiKey)"
        
        
        case searchPhotos(latitude: Double, longitude: Double)
        case getPhotoURL(String, String, String)
       
        
        var stringURL: String {
            switch self {
            case .searchPhotos(let latitude, let longitude):
                       return
                        Endpoints.base + Endpoints.apiKeyParam + "&lat=\(latitude)" + "&lon=\(longitude)" + "&page=\(Int.random(in: 1...10))per_page=18&format=json&nojsoncallback=1"
                
            case .getPhotoURL(let server, let id, let secret):
            return
                "https://live.staticflickr.com/\(server)/\(id)_\(secret)_c.jpg"
            
            }
        }
        var url: URL {
            return URL(string: stringURL)!
        }
    }
    
    
    
    
    class func sendGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void ){
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                //po String(data: data, encoding: .utf8)!
                DispatchQueue.main.async {
                    completionHandler(responseObject,nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    
    class func downloadImages(imageURL: URL, completionHandler: @escaping (Data?, Error?) -> Void) {
        
    
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    
    
    class func flickrGETSearchPhotos(lat: Double, lon: Double, completionHandler: @escaping ([FlickrPhoto?], Error?) -> Void ) {
        
        
        sendGETRequest(url: Endpoints.searchPhotos(latitude: lat, longitude: lon).url, response: PhotoResponse.self) { (response, error) in
            if let response = response {
                
                completionHandler(response.photos.photo, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
}
