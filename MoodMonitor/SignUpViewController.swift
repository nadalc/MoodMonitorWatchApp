//
//  SignUpViewController.swift
//  SilverCloud
//
//  Created by Maria Ortega on 06/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

     // MARK: - Properties
     
     static let identifier = "SignUpViewController"
     
     // MARK: - Setup

     override func viewDidLoad() {
          super.viewDidLoad()
    }
    
    // MARK: - IBActions

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
