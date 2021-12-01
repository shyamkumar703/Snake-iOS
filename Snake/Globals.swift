//
//  Globals.swift
//  Snake
//
//  Created by Shyam Kumar on 11/14/21.
//

import Foundation
import UIKit

// GAME CONSTANTS
var score = 0
var ai = true

extension UIView {
    func constrainTo(view: UIView, margin: CGFloat = 0) {
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: margin).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: margin * -1).isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: margin * -1).isActive = true
    }
    
    func constrainToSafeArea(superview: UIView, margin: CGFloat = 0) {
        self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: margin).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: margin * -1).isActive = true
        self.leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor, constant: margin).isActive = true
        self.rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor, constant: margin * -1).isActive = true
    }
}
