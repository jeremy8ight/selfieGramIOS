//
//  Theme.swift
//  Selfiegram
//
//  Created by Jeremy Barnes-Smith on 4/26/25.
//

import Foundation
import UIKit

extension UIFont {
    convenience init? (familyName: String, size: CGFloat = UIFont.systemFontSize, variantName: String? = nil) {
        
        guard let name = UIFont.familyNames
            .filter({$0.contains(familyName)})
            .flatMap({UIFont.fontNames(forFamilyName: $0)})
            .filter({variantName != nil ? $0.contains(variantName!) : true})
            .first else { return nil }
        
        self.init(name: name, size: size)
    }
}

struct Theme {
    static func apply() {
        guard let headerFont = UIFont(familyName: "Lobster", size: UIFont.systemFontSize * 2) else {
            NSLog("Failed to load header font")
            return
        }
        
        guard let primaryFont = UIFont(familyName: "Quicksand") else {
            NSLog("Failed to load application font")
            return
        }
        
        let tintColor = #colorLiteral(red: 0.56, green: 0.35, blue: 0.97, alpha: 1)
        
        UIApplication.shared.delegate?.window??.tintColor = tintColor
        
        let navBarLabel = UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        
        let barButton = UIBarButtonItem.appearance()
        
        let buttonLabel = UILabel.appearance(whenContainedInInstancesOf: [UIButton.self])
        
        let navBar = UINavigationBar.appearance()
        
        let label = UILabel.appearance()
        
        //theming the navigation bar
        navBar.titleTextAttributes = [.font: headerFont]
        
        //theming labels
        label.font = primaryFont
        
        //theming the buttons' text
        barButton.setTitleTextAttributes([.font: primaryFont], for: .normal)
        barButton.setTitleTextAttributes([.font: primaryFont], for: .highlighted)
        
        buttonLabel.font = primaryFont
    }
}
