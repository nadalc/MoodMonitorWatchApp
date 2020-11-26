//
//  ServicesHeaderViewCell.swift
//  SilverCloud
//
//  Created by Maria Ortega on 07/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class ServicesHeaderViewCell: UITableViewHeaderFooterView {

    @IBOutlet weak var dropdownIcon: UIImageView!
    @IBOutlet weak var servicesView: UIView! {
          didSet {
              unselectHeader()
          }
     }
     
     func unselectHeader() {
        dropdownIcon.image = UIImage(named: "expand_more")
        servicesView.roundCorners(cornerRadius: 8.0, borderWidth: 1.3, borderColor: UIColor.SCBorderButtonColor().cgColor, cornerType: .all)
        servicesView.setNeedsDisplay()
     }
     
     func selectHeader() {
        dropdownIcon.image = UIImage(named: "expand_less")
        servicesView.roundCorners(cornerRadius: 8.0, borderWidth: 1.3, borderColor: UIColor.SCBorderButtonColor().cgColor, cornerType: .top)
        servicesView.setNeedsDisplay()
     }
}
