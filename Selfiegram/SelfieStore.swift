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
    
    func getImage(id: UUID) -> UIImage? {
        return nil
    }
    
    func setImage(id: UUID, image: UIImage?) throws {
        throw SelfieStoreError.cannotSaveImage(image)
    }
    
    func listSelfies() throws -> [Selfie] {
        return []
    }
    
    func delete(id: UUID) throws {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    func load(id: UUID) -> Selfie? {
        return nil
    }
    
    func save(selfie: Selfie) throws {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
}
