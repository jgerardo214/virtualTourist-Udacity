//
//  PhotosProperties.swift
//  Virtual Tourist
//
//  Created by Jonathan Gerardo on 7/15/21.
//

import Foundation

struct PhotoResponse:Codable {
    
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [FlickrPhoto?]
    
}

struct FlickrPhoto: Codable {
    let id: String
    let server: String
    let secret: String
}







