//
//  SelfieListViewConroller.swift
//  Selfiegram
//
//  Created by Jeremy Barnes-Smith on 4/25/25.
//

import Foundation
import UIKit

class SelfieListViewConroller: UITableViewController {
    
    // The list of photo objects we're going to deploy
    var selfies: [Selfie] = []
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the list of selfies form the selfie store
        do {
            // Get the list of photos, sorted by dae (newer first)
            selfies = try SelfieStore.shared.listSelfies()
                .sorted(by: {$0.created > $1.created})
        } catch let error {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
        
//        if let split = splitViewController {
//            let controllers = split.viewControllers
//            detailViewController = (controllers[controllers.count - 1] as? UINavigationController)?.topViewController as? DetailViewConroller
//        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let selfie = selfies[indexPath.row]
        cell.textLabel?.text = selfie.title
        
        return cell
    }
    
}
