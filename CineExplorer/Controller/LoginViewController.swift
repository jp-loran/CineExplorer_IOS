//
//  LoginViewController.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 10/05/24.
//

import UIKit
import CoreData
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let manager = MovieServiceManager()

    var storedMovies: [Movie] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
           view.endEditing(true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        guard let username = userField.text, !username.isEmpty else {
            Helpers.showAlert(title: "Información incompleta", message: "Ingresa un email", on: self)
            return
        }
        
        if !Helpers.isValidEmail(username) {
            Helpers.showAlert(title: "Formato incorrecto", message: "Por favor, ingresa un email válido.", on: self)
                return
        }
        
        guard let password = passwordField.text, !password.isEmpty else {
            Helpers.showAlert(title: "Información incompleta", message: "Ingresa la contraseña", on: self)
            return
        }
        
        Auth.auth().signIn(withEmail: username, password: password) { authResult, error in
            if let error = error {
                Helpers.showAlert(title: "Error", message: error.localizedDescription, on: self)
                print("Error: \(error.localizedDescription)")
            } else {
                print("User signed in successfully")
                let userInfo = Auth.auth().currentUser
                UserDefaults.standard.set(userInfo?.email, forKey: "userEmail")
                self.performSegue(withIdentifier: "showExploreScreen", sender: self)
            }
        }
    }
    
    @IBAction func registerAction(_ sender: Any) {
        performSegue(withIdentifier: "showRegisterScreen", sender: self)
    }
    
}
