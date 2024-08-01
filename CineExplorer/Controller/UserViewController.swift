import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SDWebImage
class UserViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userBirthday: UILabel!
    @IBOutlet weak var logout: UIButton!
    
    let imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.layer.masksToBounds = true
        userImage.contentMode = .scaleAspectFill
        
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
            
            if let imageUrl = dbUser["imageUrl"] as? String, let url = URL(string: imageUrl) {
                self.userImage.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultUser"))
            }
        
        }
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImage.layer.cornerRadius = userImage.frame.height / 2
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
            uploadImageToFirebase(image: editedImage)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userImage.image = originalImage
            uploadImageToFirebase(image: originalImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func uploadImageToFirebase(image: UIImage) {
         guard let user = user else { return }
         
         let storageRef = storage.reference().child("profile_images/\(user.uid).png")
         guard let imageData = image.pngData() else { return }
         
         storageRef.putData(imageData, metadata: nil) { (metadata, error) in
             if let error = error {
                 print("Error uploading image: \(error.localizedDescription)")
                 return
             }
             
             storageRef.downloadURL { (url, error) in
                 if let error = error {
                     print("Error getting download URL: \(error.localizedDescription)")
                     return
                 }
                 
                 if let downloadURL = url?.absoluteString {
                     self.saveUserProfileImageUrl(url: downloadURL)
                 }
             }
         }
     }
    
    
    private func saveUserProfileImageUrl(url: String) {
        guard let user = user else { return }
        
        let currentUserQuery = db.collection("User")
            .whereField("userId", isEqualTo: user.uid)
        
        currentUserQuery.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error querying user document: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            if let document = documents.first {
                let docId = document.documentID
                self.db.collection("User").document(docId).updateData(["imageUrl": url]) { error in
                    if let error = error {
                        print("Error updating profile image URL: \(error.localizedDescription)")
                    } else {
                        print("Profile image URL updated successfully")
                    }
                }
            } else {
                let newUser: [String: Any] = [
                    "userId": user.uid,
                    "imageUrl": url
                ]
                
                self.db.collection("User").addDocument(data: newUser) { error in
                    if let error = error {
                        print("Error creating new user document: \(error.localizedDescription)")
                    } else {
                        print("New user document created with profile image URL")
                    }
                }
            }
        }
    }

}
