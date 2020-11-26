//
//  WelcomeLoginViewModel.swift
//  SilverCloud
//
//  Created by Maria Ortega on 06/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class WelcomeLoginViewModel: NSObject {

     // MARK: - Properties

     private weak var view: WelcomeLoginViewController?
     private var apiService = APIService()
     
     // MARK: - Init

     init(view: WelcomeLoginViewController) {
         self.view = view
     }
     
     // MARK: - Setup

     func retrieveRegions(completion: @escaping (Result<RegionList>) -> ()) {
          apiService.retrieveRegions { (response) in
               completion(response)
          }
     }
     
     // MARK: User status Manager
     
     func userAutoLoggedOut() -> Bool {
          return defaults.bool(forKey: isUserAutoLoggedOut)
     }
}
