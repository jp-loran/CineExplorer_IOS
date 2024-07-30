//
//  Helpers.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 11/05/24.
//

import Foundation
import UIKit

struct Helpers {

    static func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: email)
    }

    static func showAlert(title: String, message: String, on viewController: UIViewController, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        viewController.present(alert, animated: true)
    }}
