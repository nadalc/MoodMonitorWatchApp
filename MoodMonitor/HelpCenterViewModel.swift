//
//  HelpCenterViewModel.swift
//  SilverCloud
//
//  Created by Maria Ortega on 03/09/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class HelpCenterViewModel: NSObject {

     // MARK: - Properties

     private weak var view: HelpCenterViewController?
     private let apiService = APIService()

     // MARK: - Init

     init(view: HelpCenterViewController) {
          self.view = view
     }
     
     // MARK: - Deeplink methods
     
     func searchContentSelected(in mappingData: AppMapping, url: String) -> Section? {
          if let section = mappingData.bottomNav.first(where: { !isURLEmpty(url: $0.url) && url.contains($0.url) }) {
               return section
          } else {
               return nil
          }
     }
     
     private func isURLEmpty(url: String) -> Bool {
         return url == "/"
     }

}
