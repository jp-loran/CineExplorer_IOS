//
//  RegisterViewController.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 11/05/24.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var birthdayField: UIDatePicker!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        guard let name = nameField.text, !name.isEmpty else {
            Helpers.showAlert(title: "Información incompleta", message: "El nombre es requerido", on:self)
            return
        }
               
        guard let lastName = lastNameField.text, !lastName.isEmpty else {
            Helpers.showAlert(title: "Información incompleta", message: "El apellido es requerido", on:self)
            return
        }
       
        guard let email = emailField.text, !email.isEmpty else {
            Helpers.showAlert(title: "Información incompleta", message: "El correo electrónico es requerido",on:self)
            return
        }
       
        if !Helpers.isValidEmail(email) {
            Helpers.showAlert(title: "Formato incorrecto", message: "Por favor, ingresa un email válido.",on:self)
            return
        }
       
        guard let password = passwordField.text, !password.isEmpty else {
            Helpers.showAlert(title: "Información incompleta", message: "La contraseña es requerida",on:self)
            return
        }
       
        let selectedDate = birthdayField.date
      
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let dateString = dateFormatter.string(from: selectedDate)
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    Helpers.showAlert(title: "Error al registrar", message: error.localizedDescription, on: self)
                }
                return
            }

            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    Helpers.showAlert(title: "Error al registrar", message: "No se pudo obtener la información del usuario", on: self)
                }
                return
            }

            DispatchQueue.main.async {
                
                self.db.collection("User").addDocument(data: [
                    "userId": user.uid,
                    "name": name,
                    "lastName": lastName,
                    "email": email,
                    "birthday": dateString
                ]){error in
                    if let error = error{
                        print("Error adding docuemnt: \(error)")
                    }else{
                        let snackBar = SnackBar(message: "Registration successful")
                        snackBar.show(in: self.view)
                        self.performSegue(withIdentifier: "showWelcomeScreen", sender: self)
                    }
                }
            }
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.performSegue(withIdentifier: "backToLoginSegue", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWelcomeScreen" {
            if let destinationVC = segue.destination as? WelcomeViewController,
               let name = nameField.text, !name.isEmpty {
                destinationVC.userName = name
            }
        }
    }
    
    
    
}
