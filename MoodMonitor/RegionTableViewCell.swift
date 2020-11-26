//
//  RegionTableViewCell.swift
//  SilverCloud
//
//  Created by Maria Ortega on 06/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class RegionTableViewCell: UITableViewCell {

     // MARK: - Properties

     static let identifier = "RegionTableViewCell"
     
     // MARK: - IBOutlet

     @IBOutlet weak var regionFlag: UIImageView!
     @IBOutlet weak var regionTitle: UILabel!
     @IBOutlet weak var checkIcon: UIImageView!
     
     @IBOutlet weak var regionOpt: UIView! {
          didSet {
               unselectCell()
          }
     }
     
     // MARK: - Setup
     
     func setupCell(region: Region, selected: Region?) {
          self.regionTitle.text = region.name
          self.regionFlag.image = UIImage(named: getRegionFlag(name: region.name))
          guard let selected = selected else {
               unselectCell()
               return
          }
          self.updateCellStatus(region: region, selected: selected)
     }
                    
     func updateCellStatus(region: Region, selected: Region) {
          if region.domain == selected.domain {
               selectCell()
          } else {
               unselectCell()
          }
     }

     func selectCell() {
          regionOpt.layer.borderWidth = 2.0
          regionOpt.layer.borderColor = UIColor.SCLightBlueColor().cgColor
          checkIcon.isHidden = false
     }
     
     func unselectCell() {
          regionOpt.roundCorners(cornerRadius: 8.0, borderWidth: 1.3, borderColor: UIColor.SCBorderButtonColor().cgColor, cornerType: .all)
          checkIcon.isHidden = true
     }

     override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
          super.setSelected(selected, animated: animated)
    }
     
     private func getRegionFlag(name: String) -> String {
          if name == "UK" {
               return "united-kingdom-flag"
          } else if name == "US" {
               return "united-states-of-america-flag"
          } else if name == "EU" {
               return "european-union"
          } else if name == "Canada" {
               return "canada-flag"
          } else {
               return "placeholder-flag"
          }
     }

}
