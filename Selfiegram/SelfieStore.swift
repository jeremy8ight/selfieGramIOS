//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Jeremy Barnes-Smith on 4/24/25.
//

import Foundation
import UIKit.UIImage

class Selfie: Codable {
    //When it was created
    let created: Date
    
    // A unique ID, used to link this selfie to its image on disk
    let id: UUID
    // The name of the selfie
    var title = "New Selfie!"
    var image: UIImage? {
        get {
            return SelfieStore.shared.getImage(id: self.id)
        }
        set {
            try? SelfieStore.shared.setImage(id: self.id, image: newValue)
        }
    }
    
    init(title: String) {
        self.title = title
        // the current time
        self.created = Date()
        // a new UUID
        self.id = UUID()
    }
}

enum SelfieStoreError: Error {
    case cannotSaveImage(UIImage?)
}

final class SelfieStore {
    static let shared = SelfieStore()
    var documentsFolder: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    }
    private var imageCache: [UUID: UIImage] = [:]
    
    func getImage(id: UUID) -> UIImage? {
        //If this image is already in the cache, return it
        if let image = imageCache[id] {
            return image
        }
        
        //Figure out where this image should live
        let imageURL = self.documentsFolder.appendingPathComponent("\(id.uuidString)-image.jpg")
        
        // Get the data from this file; exit if we fail
        guard let imageData = try? Data(contentsOf: imageURL) else {
            return nil
        }
        
        // Get the image from this data; exit if we fail
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        
        // Store the loaded image in the cache for the next time
        imageCache[id] = image
        
        // Return the loaded image
        return image
    }
    
    func setImage(id: UUID, image: UIImage?) throws {
        /// Saves ann imafe to disk
        /// - paremeter id: the id of the selfe you want this image associated with
        /// - paramer image: the image you want saved
        /// - Throws: 'SelfieStoreObject' if it fails to save to disk
    
        // Figure out where the file would end up
        let fileName = "\(id.uuidString)-image.jpq"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        if let image = image {
            // We have an image to work with, so save it out.
            // Attempt to convert the image into JPEG data.
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                // Throw an error if this failed
                throw SelfieStoreError.cannotSaveImage(image)
            }
            
            // Attempt to write the data out
            try data.write(to: destinationURL)
        } else {
            // The image is nil, indicating that we want to remove the image
            
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        //Cache this image in memory. (If image is nil, this has the effect of
        //removing the entry from the cache directory
        imageCache[id] = image
    }
    
    func listSelfies() throws -> [Selfie] {
        // Get the list of files in the Documents directory
        let contents = try FileManager.default.contentsOfDirectory(at: self.documentsFolder, includingPropertiesForKeys: nil)
        
        // Get all files whose path extension is 'json'
        // load them as data, and decode them from JSON
        return try contents.filter{ $0.pathExtension == "json"}
            .map{try Data(contentsOf: $0)}
            .map{try JSONDecoder().decode(Selfie.self, from: $0)}
    }
    
    func delete(selfie: Selfie) throws {
        try delete(id: selfie.id)
    }
    
    func delete(id: UUID) throws {
        let selfieDataFileName = "\(id.uuidString).json"
        let imageFileName = "\(id.uuidString)-image.jpg"
        
        let selfieDataURL = self.documentsFolder.appendingPathComponent(selfieDataFileName)
        let imageURL = self.documentsFolder.appendingPathComponent(imageFileName)
        
        //Remove the two fiiles if they exist
        if FileManager.default.fileExists(atPath: selfieDataURL.path) {
            try FileManager.default.removeItem(at: selfieDataURL)
        }
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try FileManager.default.removeItem(at: imageURL)
        }
        
        //Wipe the image from the cache if its there
        imageCache[id] = nil
    }
    
    func load(id: UUID) -> Selfie? {
        let dataFileName = "\(id.uuidString).json"
        let dataURL = self.documentsFolder.appendingPathComponent(dataFileName)
        
        // Attempt to load the data in this file
        // and then attempt to convert the data into a Photo
        // and then return it
        // Return nil if any of these steps fail.
        if let data = try? Data(contentsOf: dataURL), let selfie = try? JSONDecoder().decode(Selfie.self, from: data) {
            return selfie
        } else {
            return nil
        }
    }
    
    func save(selfie: Selfie) throws {
        let selfieData = try JSONEncoder().encode(selfie)
        
        let fileName = "\(selfie.id.uuidString).json"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        try selfieData.write(to: destinationURL)
    }
}
