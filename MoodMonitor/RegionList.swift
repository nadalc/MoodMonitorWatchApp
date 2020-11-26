//
//  RegionList.swift
//  SilverCloud
//
//  Created by Maria Ortega on 06/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

struct RegionList: Codable {
     var regions: [Region]
     var services: [Region]
     
     enum CodingKeys: String, CodingKey {
          case regions
          case services
     }
}

struct Region: Codable {
     var domain: String
     var name: String
     var oauth: Bool
     var enableMobileNavigation: Bool
     
     enum CodingKeys: String, CodingKey {
          case domain
          case name
          case oauth
          case enableMobileNavigation = "enableMobileNativeNavigation"
     }
}
