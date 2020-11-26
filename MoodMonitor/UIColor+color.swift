//
//  UIColor+color.swift
//  SilverCloud
//
//  Created by Maria Ortega on 06/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

extension UIColor {

     // MARK: - Init

     convenience init(hexString: String, alpha: CGFloat = 1.0) {
          let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
          let scanner = Scanner(string: hexString)
          if (hexString.hasPrefix("#")) {
               scanner.scanLocation = 1
          }
          var color: UInt32 = 0
          scanner.scanHexInt32(&color)
          let mask = 0x000000FF
          let r = Int(color >> 16) & mask
          let g = Int(color >> 8) & mask
          let b = Int(color) & mask
          let red   = CGFloat(r) / 255.0
          let green = CGFloat(g) / 255.0
          let blue  = CGFloat(b) / 255.0
          self.init(red:red, green:green, blue:blue, alpha:alpha)
     }
    
     // MARK: - App Color

     class func SCLightBlueColor() -> UIColor {
          return UIColor.init(hexString: "#0AB9EE")
     }
     
     class func SCBorderButtonColor() -> UIColor {
          return UIColor.init(hexString: "#F3F3F3")
     }
     
     class func SCDropShadowColor() -> UIColor {
          return UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
     }
     
     class func SCBackgroundColor() -> UIColor {
          return UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
     }
}
