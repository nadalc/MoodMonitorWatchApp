//
//  ServicesViewCell.swift
//  SilverCloud
//
//  Created by Maria Ortega on 08/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class ServicesViewCell: UITableViewCell {

     // MARK: - IBOutlet

     @IBOutlet weak var servicesView: UIView! {
          didSet {
               unselectCell()
          }
     }
     @IBOutlet weak var serviceTitle: UILabel!
     @IBOutlet weak var separatorLine: UIView!
     @IBOutlet weak var checkIcon: UIImageView!
     
     // MARK: - Properties

     static let identifier = "ServicesViewCell"
     
     // MARK: - Setups

     func setupCell(service: Region, selected: Region?) {
          serviceTitle.text = service.name
          guard let selected = selected else {
               unselectCell()
               return
          }
          self.updateCellStatus(service: service, selected: selected)

     }
             
     func updateCellStatus(service: Region, selected: Region) {
          if service.domain == selected.domain {
               selectCell()
          } else {
               unselectCell()
          }
     }
     
     func addBottomStyle() {
          servicesView.roundCorners(cornerRadius: 8.0, borderWidth: 1.3, borderColor: UIColor.SCBorderButtonColor().cgColor, cornerType: .bottom)
          separatorLine.isHidden = true
     }
     
     func selectCell() {
          checkIcon.isHidden = false
          addStyle()
     }
     
     func unselectCell() {
          checkIcon.isHidden = true
          addStyle()
     }
     
     private func addStyle() {
          servicesView.roundCorners(cornerRadius: 0.0, borderWidth: 1.3, borderColor: UIColor.SCBorderButtonColor().cgColor, cornerType: .all)
     }
     
     override func awakeFromNib() {
        super.awakeFromNib()
     }

     override func setSelected(_ selected: Bool, animated: Bool) {
          super.setSelected(selected, animated: animated)
     }
}
