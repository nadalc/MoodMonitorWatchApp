//
//  PageListTableViewCell.swift
//  SilverCloud
//
//  Created by Maria Ortega on 09/09/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class PageListTableViewCell: UITableViewCell {

     // MARK: - IBOutlets

     @IBOutlet weak var pageTitle: UILabel!
     @IBOutlet weak var pageReadButton: UIButton!
     
     // MARK: - Properties
      
     static let identifier = "PageListTableViewCell"

     // MARK: - Setups
     
     func setupView(title: String, isRead: Bool) {
          pageTitle.text = title
          pageReadButton.setImage(UIImage(named: isRead ? "check_circle" : "unchecked_circle"), for: .normal)
          // DD: 16/10/2020: According to bug https://bugs.tapadoo.com/issue/SCHIOS-71
          // The page check marks are rarely correct.  A discussion with Silvercloud on doing this for android suggests making the app really chatty and keeping tabs server side on what pages had been read. Which is not ideal
          // On the iOS bug, Maryann suggested we can just not show this, so I've hidden the image for now
          pageReadButton.isHidden = true
     }
     
     override func awakeFromNib() {
        super.awakeFromNib()
     }

     override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
     }

}
