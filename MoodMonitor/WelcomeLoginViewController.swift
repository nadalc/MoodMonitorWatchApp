//
//  WelcomeLoginViewController.swift
//  SilverCloud
//
//  Created by Maria Ortega on 01/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class WelcomeLoginViewController: UIViewController {
    
     // MARK: - IBOutlets

     @IBOutlet weak var loginButton: UIButton! {
          didSet {
               loginButton.layer.cornerRadius = 8.0
               loginButton.layer.borderWidth = 3.0
               loginButton.layer.borderColor = UIColor.SCLightBlueColor().cgColor
          }
     }
     
     @IBOutlet weak var signUpButton: UIButton! {
          didSet {
               let atributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                               .font: UIFont.Regular(18.0),
                                                               .foregroundColor: UIColor.SCLightBlueColor()]
               signUpButton.setAttributedTitle(NSAttributedString(string: "How to sign up", attributes: atributes), for: .normal)
          }
     }
     
     // MARK: - Properties

     static let identifier = "WelcomeLoginViewController"
     private var viewModel: WelcomeLoginViewModel!
     private var regionData: RegionList!
     
     // MARK: - Setups

     override func viewDidLoad() {
          super.viewDidLoad()
          viewModel = WelcomeLoginViewModel(view: self)
     }
     
     override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          retrieveRegions(completion: { _ in })
     }
     
     private func retrieveRegions(completion: @escaping (Bool) -> ()) {
          viewModel.retrieveRegions { (response) in
               switch response {
               case .success(let regionList):
                    self.regionData = regionList
                    completion(true)
               case .failure(_):
                    self.showErrorAlert(title: "Sorry!", message: "Regions couldn't been retrieved.")
                    completion(false)
               }
          }
     }
    
    // MARK: - IBActions
     
    @IBAction func goToHowSignUp(_ sender: Any) {
          NavigationManager.loadSignUpVC(in: self)
    }
     
    @IBAction func doLogin(_ sender: Any) {
          if viewModel.userAutoLoggedOut() {
               NavigationManager.loadHomeVC(in: self)
          } else {
               retrieveRegions { (result) in
                    if result {
                         self.performSegue(withIdentifier: "showRegionList", sender: nil)
                    }
               }
          }
    }
    
    // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "showRegionList" {
               let regionList = segue.destination as! RegionListViewController
               regionList.regionData = regionData
          }
     }
     
     override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
          return self.regionData != nil && !viewModel.userAutoLoggedOut()
     }
     
     private func showErrorAlert(title: String, message: String) {
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
          alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: { (_) in
               self.retrieveRegions(completion: { _ in })
          }))
          self.present(alert, animated: true, completion: nil)
     }
}
