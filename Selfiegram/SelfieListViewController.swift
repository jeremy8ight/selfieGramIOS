//
//  SelfieListViewConroller.swift
//  Selfiegram
//
//  Created by Jeremy Barnes-Smith on 4/25/25.
//

import Foundation
import UIKit
import CoreLocation

class SelfieListViewController: UITableViewController {
    
    // The list of photo objects we're going to deploy
    var selfies: [Selfie] = []
    var lastLocation : CLLocation?
    let locationManager = CLLocationManager()

    let timeIntervalFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    func showError(message: String) {
        // Create an alert controller, with the message we received
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        // Add an action to it - it wont do anything, but
        // doing this means that will have a button to dismiss it
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        // Show the alert and its message
        self.present(alert, animated: true, completion: nil)
    }
    
    //called after the user has seleced a photo
    func newSelfieTaken(image: UIImage) {
        //Create a new image
        let newSelfie = Selfie(title: "New Selfie")
        
        //Store the image
        newSelfie.image = image
        
        if let location = self.lastLocation {
            newSelfie.position = Selfie.Coordinate(location: location)
        }
        
        //Attempt to save the photo
        do {
            try SelfieStore.shared.save(selfie: newSelfie)
        } catch let error {
            showError(message: "Can't save photo: \(error)")
            return
        }
        

        //Insert this photo into this view controller's list
        selfies.insert(newSelfie, at: 0)
        
        //Update the table view to show the new photo
        tableView.insertRows(at: [IndexPath(row: 0, section:0)], with: .automatic)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
        
        //load the list of selfies form the selfie store
        do {
            // Get the list of photos, sorted by dae (newer first)
            selfies = try SelfieStore.shared.listSelfies()
                .sorted(by: {$0.created > $1.created})
        } catch let error {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
        
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reload all data in the table view
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let selfie = selfies[indexPath.row]
                
                if let controller = segue.destination as? SelfieDetailViewController {
                    controller.selfie = selfie
                    
                }
            }
        }
    }
    
    @objc func createNewSelfie() {
        // Clear the last location, so that this next image doesn't
        // end up with an out-of-date location
        lastLocation = nil
        
        // Handle our authorization status
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            // We either don't have permission, or the user is
            // not permittedto use location services at all
            // Give up at this point
            return
        case .notDetermined:
            // We don't know if we have permission or not. Ask for it.
            locationManager.requestWhenInUseAuthorization()
        default:
            // We have permission; nothing to do here
            break
        }
        // Request a one-time location update
        locationManager.requestLocation()
        
    
        //Create a new image picker
        let imagePicker = UIImagePickerController()
        
        //If a camera is available, use it; otherwise use the photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            
            //If the front-facing camera is available, use that
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .rear
            } else {
                imagePicker.sourceType = .photoLibrary
            }
            
            // We want this object to be notified when the user takes a photo
            imagePicker.delegate = self
            
            //Present the image picker
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Get a cell from the table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Get a selfie and use it to configure the cell
        let selfie = selfies[indexPath.row]
        
        //Set up the main label
        cell.textLabel?.text = selfie.title
        
        //Set up its time ago sublabel
        if let interval = timeIntervalFormatter.string(from: selfie.created, to: Date()) {
            cell.detailTextLabel?.text = "\(interval) ago"
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        //Show the selfie image to the left of the cell
        cell.imageView?.image = selfie.image
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        // If this was a deletion, we have deleting to do
        if editingStyle == .delete {
            
            //Get the object from the content array
            let selfieToRemove = selfies[indexPath.row]
            
            // Attempt to delete the selfie
            do {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                
                //remove it from that array
                selfies.remove(at: indexPath.row)
                
                //Remove the entry form the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                let title = selfieToRemove.title
                showError(message: "Failed to delete \(title).")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

extension SelfieListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //called when the user cancels selecting an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //called when the user has finished selecting an image
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
            guard let image = info[UIImagePickerController.InfoKey.editedImage] as?  UIImage ?? info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                let message = "Couldn't get a picture from the image picker!"
                showError(message: message)
                return
            }
            
            self.newSelfieTaken(image: image)
            
            self.dismiss(animated: true, completion: nil)
    }
}

extension SelfieListViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updating my location from the manager")
        self.lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: error.localizedDescription)
    }
}
