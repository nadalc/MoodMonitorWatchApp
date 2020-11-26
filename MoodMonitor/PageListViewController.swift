//
//  PageListViewController.swift
//  SilverCloud
//
//  Created by Maria Ortega on 08/09/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

typealias PageListData = (module: Module, pageSelected: Int)

protocol PageListDelegate: class {
     func reloadPageContent(url: String)
}

class PageListViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var moduleTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listView: UIView! {
        didSet {
            listView.roundTopCorners(radius: 18)
        }
    }
     
    // MARK: - Properties
     
     static let identifier = "PageListViewController"
     weak var delegate: PageListDelegate?
     var data: PageListData!
     
    // MARK: - Setups
     
     func setupView(data: PageListData) {
          self.data = data
     }
     
    override func viewDidLoad() {
          super.viewDidLoad()
          moduleTitle.text = data.module.title.uppercased()
    }
     
     override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          view.fadeInOverlay()
     }
     
     override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          view.clearOverlay()
     }
    
    // MARK: - IBActions

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableView Methods

extension PageListViewController: UITableViewDelegate, UITableViewDataSource {
    
     private func setupTableView() {
          tableView.delegate = self
          tableView.dataSource = self
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return data.module.pages.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: PageListTableViewCell.identifier, for: indexPath) as! PageListTableViewCell
          cell.setupView(title: data.module.pages[indexPath.row].title, isRead: indexPath.row <= data.pageSelected)
          return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          self.dismiss(animated: true) {
               self.delegate?.reloadPageContent(url: self.data.module.pages[indexPath.row].url)
          }
     }
     
}
