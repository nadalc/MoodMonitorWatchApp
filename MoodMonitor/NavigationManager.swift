//
//  NavigationManager.swift
//  SilverCloud
//
//  Created by Maria Ortega on 06/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class NavigationManager: NSObject {

     private static let storyboard = UIStoryboard(name: "Main", bundle: nil)
     
     class func loadSignUpVC(in view: WelcomeLoginViewController) {
          let howToSignUp = storyboard.instantiateViewController(withIdentifier: SignUpViewController.identifier) as! SignUpViewController
          howToSignUp.modalPresentationStyle = .overFullScreen
          view.present(howToSignUp, animated: true)
     }
     
     class func loadWelcomeVC(in view: UIViewController) {
          let loingVC = storyboard.instantiateViewController(withIdentifier: WelcomeLoginViewController.identifier) as! WelcomeLoginViewController
          let welcomeNavVC = UINavigationController(rootViewController: loingVC)
          welcomeNavVC.isNavigationBarHidden = true
          welcomeNavVC.modalPresentationStyle = .overFullScreen
          view.present(welcomeNavVC, animated: true)
     }
     
     class func loadHomeVC(in view: UIViewController) {
          let homeVC = storyboard.instantiateViewController(withIdentifier: HomeViewController.identifier) as! HomeViewController
          let homeNavVC = UINavigationController(rootViewController: homeVC)
          homeNavVC.isNavigationBarHidden = true
          homeNavVC.modalPresentationStyle = .custom
          homeNavVC.modalTransitionStyle = .crossDissolve
          view.present(homeNavVC, animated: true)
     }
     
     class func loadHelpVC(in view: HomeViewController, url: String?, data: AppMapping?) {
          let helpVC = storyboard.instantiateViewController(withIdentifier: HelpCenterViewController.identifier) as! HelpCenterViewController
          helpVC.delegate = view
          helpVC.setupView(url: url, mappingData: data)
          helpVC.modalPresentationStyle = .overFullScreen
          view.present(helpVC, animated: true)
     }
     
     class func loadPageListVC(in view: HomeViewController, data: PageListData) {
          let pageListVC = storyboard.instantiateViewController(withIdentifier: PageListViewController.identifier) as! PageListViewController
          pageListVC.delegate = view
          pageListVC.setupView(data: data)
          pageListVC.modalPresentationStyle = .overFullScreen
          view.present(pageListVC, animated: true)
     }
}
