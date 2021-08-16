//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Jonathan Gerardo on 7/11/21.
//

import Foundation

class PhotosResponse: Codable {
    
    let photos: PhotosSecondLayer
    let stat: String
    
    enum CodingKeys: String, CodingKey {
        case photos
        case stat
    }
    
}

class PhotosSecondLayer: Codable {
    
    let photo: [Photos]
    
    enum CodingKeys: String, CodingKey {
        case photo
    }
    
}

class Photos: Codable {
    
    let id: String
    let urlN: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case urlN = "url_n"
    }
    
    init() {
        id = ""
        urlN = ""
    }
    
}
