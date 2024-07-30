//
//  WelcomeViewController.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 11/05/24.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text=userName
        
    }
    
    @IBAction func exploreAction(_ sender: Any) {
        performSegue(withIdentifier: "showExploreRegisterScreen", sender: self)
    }
    
    
    
}
