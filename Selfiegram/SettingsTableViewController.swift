//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Jeremy Barnes-Smith on 4/26/25.
//

import UIKit
import UserNotifications

enum SettingsKey : String {
    case saveLocation
}

class SettingsTableViewController: UITableViewController {
    
    private let notificationId = "SelfiegramReminder"
    
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    
    @IBAction func locationSwitchToggled(_ sender: Any) {
        // Update the setting in UserDefaults
        UserDefaults.standard.set(locationSwitch.isOn, forKey: SettingsKey.saveLocation.rawValue)
        
    }
    
    @IBAction func reminderSwitchToggled(_ sender: Any) {
        //Get the Notification Center.
        let current = UNUserNotificationCenter.current()
        
        switch reminderSwitch.isOn {
        case true:
            //Defines what kinds of notifications we send
            //in our case, a simple alert
            let notificationOptions : UNAuthorizationOptions = [.alert]
            
            //The switch was turned on
            //Ask permission to send notifications
            current.requestAuthorization(options: notificationOptions, completionHandler: {
                (granted, error) in
                if granted {
                    // We've been granted permission. Queue the notification.
                    self.addNotificationRequest()
                }
                
                //Call updateReminderSwitch
                //because we may have just learned that
                //we don't have permission to.
                self.updateReminderSwitch()
            })
        case false:
            //The switch was turned off.
            //Remove any pending notification request.
            current.removeAllPendingNotificationRequests()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        updateReminderSwitch()
    }
    
    func addNotificationRequest() {
        //Get the notification center
        let current = UNUserNotificationCenter.current()
        
        //Remove all existing notifications
        current.removeAllPendingNotificationRequests()
        
        //Prepare the notification content
        let content = UNMutableNotificationContent()
        content.title = "Take a selfie!"
        
        //Create data components to represent "10am" (without specifying the day)
        var components = DateComponents()
        components.setValue(10, for: Calendar.Component.hour)
        
        //A trigger that goes off at this time, every day
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        //Create the request
        let request = UNNotificationRequest(identifier: self.notificationId, content: content, trigger: trigger)
        
        // Add it to the Notification Center
        current.add(request) { (error) in
            self.updateReminderSwitch()
        }
    }
    
    func updateReminderSwitch() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
                
            case .authorized:
                UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
                    //We are active if the list of requests contains one
                    //thats got the correct identifier
                    let active = requests.filter({$0.identifier == self.notificationId}).count > 0
                    
                    //Our switch is enabled; its on if we found our pending notification
                    self.updateReminderUI(enabled: true, active: active)
                }
                
            case .denied:
                //If the user has denied permission, the switch is off and disabled
                self.updateReminderUI(enabled: false, active: false)
                
            case .notDetermined:
                //If the user hasn't been asked yet, the switch is enabled
                //but defaults to off
                self.updateReminderUI(enabled: true, active: false)
            case .provisional:
                break
            case .ephemeral:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func updateReminderUI(enabled: Bool, active: Bool) {
        OperationQueue.main.addOperation {
            self.reminderSwitch.isEnabled = enabled
            self.reminderSwitch.isOn = active
        }
    }
}
