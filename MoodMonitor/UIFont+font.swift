//
//  UIFont+font.swift
//  SilverCloud
//
//  Created by Maria Ortega on 06/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

let kFontRegular = "OpenSans-Regular"
let kFontBold = "OpenSans-Bold"

extension UIFont {

     // MARK - Generic fonts

     class func Regular(_ size: CGFloat) -> UIFont {
          return UIFont(name: kFontRegular, size: size)!
     }
     
     class func Bold(_ size: CGFloat) -> UIFont {
          return UIFont(name: kFontBold, size: size)!
     }
}
