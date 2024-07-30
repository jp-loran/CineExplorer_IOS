import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth
class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userBirthday: UILabel!
    @IBOutlet weak var logout: UIButton!
    
    let imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImage.layer.cornerRadius = userImage.frame.height / 2
        
        userImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openCamera))
        userImage.addGestureRecognizer(tapGesture)
        
        let currentUserQuery = db.collection("User")
            .whereField("userId", isEqualTo: user?.uid ?? "")
        
        currentUserQuery.getDocuments{ querySnapshot, error in
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            guard let dbUser = documents.first?.data() else {
                print("No documents found")
                return
            }
            
            self.userName.text = dbUser["name"] as? String
            self.userEmail.text = dbUser["email"] as? String
            self.userBirthday.text = dbUser["birthday"] as? String
        
        }
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    @objc func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            present(imagePicker, animated: true, completion: nil)
        } else {
            Helpers.showAlert(title: "Error", message: "Camera not available", on: self)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
            do {
                   try Auth.auth().signOut()
                   performSegue(withIdentifier: "logoutSegue", sender: self)
               } catch let signOutError as NSError {
                   Helpers.showAlert(title: "Error", message: "Error signing out: \(signOutError.localizedDescription)", on: self)
               }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            userImage.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userImage.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
