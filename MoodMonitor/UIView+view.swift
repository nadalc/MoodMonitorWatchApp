//
//  UIView+view.swift
//  SilverCloud
//
//  Created by Maria Ortega on 08/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

enum CornerType {
     case top
     case bottom
     case all
     case none
}

extension UIView {

     func dropShadow(shadowColor: CGColor, shadowOpacity: Float, shadowRadius: CGFloat, onlySides: Bool) {
          layer.shadowColor = shadowColor
          layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
          layer.shadowOpacity = shadowOpacity
          layer.shadowRadius = shadowRadius

          if onlySides {
               let shadowRect: CGRect = bounds.insetBy(dx: 0, dy: -1)
               layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
          } else {
               layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
          }
     }
     
     func roundCorners(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: CGColor, cornerType: CornerType) {
          if #available(iOS 11.0, *) {
               layer.cornerRadius = cornerRadius
               layer.borderWidth = borderWidth
               layer.borderColor = borderColor
               switch cornerType {
               case .top:
                    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
               case .bottom:
                    layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
               case .all:
                    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
               default:
                    break
               }
          } else {
               var corners: UIRectCorner!
               switch cornerType {
               case .top:
                    corners = [.topLeft , .topRight]
               case .bottom:
                    corners = [.bottomLeft, .bottomRight]
               case .all:
                    corners = [.topLeft , .topRight, .bottomLeft, .bottomRight]
               default:
                    corners = nil
               }
               let maskPath = UIBezierPath(roundedRect: bounds,
                                        byRoundingCorners: corners,
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
               let maskLayer = CAShapeLayer()
               maskLayer.frame = bounds
               maskLayer.path = maskPath.cgPath
               layer.mask = maskLayer
               layer.borderWidth = borderWidth
               layer.borderColor = borderColor
          }
     }
     
     func roundTopCorners(radius: CGFloat){
         if #available(iOS 11.0, *) {
             clipsToBounds = true
             layer.cornerRadius = radius
             layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
         } else {
             let maskPath = UIBezierPath(roundedRect: bounds,
                                         byRoundingCorners: [.topLeft , .topRight],
                                         cornerRadii: CGSize(width: radius, height: radius))
             let maskLayer = CAShapeLayer()
             maskLayer.frame = bounds
             maskLayer.path = maskPath.cgPath
             layer.mask = maskLayer
         }
     }
     
     func fadeInOverlay(color: UIColor = UIColor.SCBackgroundColor(), delay: TimeInterval = 0.3) {
           UIView.animate(withDuration: 0.2, delay: delay, options:[], animations: {
               self.backgroundColor = color
           }, completion:nil)
       }
       
       func fadeOutOverlay(color: UIColor = UIColor.clear) {
           UIView.animate(withDuration: 0.1, delay: 0.0, options:[], animations: {
               self.backgroundColor = color
           }, completion: nil)
       }
     
     func clearOverlay(color: UIColor = UIColor.clear) {
          self.backgroundColor = color
     }
}
