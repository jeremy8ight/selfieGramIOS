//
//  DetailViewController.swift
//  Selfiegram
//
//  Created by Jeremy Barnes-Smith on 4/25/25.
//

import Foundation
import UIKit

class SelfieDetailViewController: UIViewController {
    
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var selfieNameField: UITextField!
    
    var selfie: Selfie?
    
    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        guard let selfie = selfie else { return }

        
        //Ensure that we have references to the controls we need
        guard let selfieNameField = selfieNameField,
              let selfieImageView = selfieImageView,
              let dateCreatedLabel = dateCreatedLabel else {
            return
        }
        
        selfieNameField.text = selfie.title
        dateCreatedLabel.text = dateFormatter.string(from: selfie.created)
        selfieImageView.image = selfie.image
    }
}
