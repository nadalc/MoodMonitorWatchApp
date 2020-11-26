//
//  RegionListViewController.swift
//  SilverCloud
//
//  Created by Maria Ortega on 06/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class RegionListViewController: UIViewController {

    // MARK: - IBOutlet

    @IBOutlet weak var regionTableView: UITableView!
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            setupButton(isEnabled: false)
        }
    }
    
    // MARK: - Properties
     
     var regionData: RegionList!
     private var isServicesSelected: Bool = false
     private let servicesSection = 1
     private let regionsSection = 0
     private var regionSelected: Region!

    // MARK: - Setup

    override func viewDidLoad() {
          super.viewDidLoad()
          setupTableView()
    }
    
    private func setupButton(isEnabled: Bool) {
        nextButton.alpha = isEnabled ? 1.0 : 0.5
        nextButton.isEnabled = isEnabled
    }
    
    // MARK: - IBAction

    @IBAction func goToLogin(_ sender: Any) {
          if let regionSelected = regionSelected {
               defaults.set(regionSelected.domain, forKey: serviceKey)
               defaults.set(regionSelected.enableMobileNavigation, forKey: serviceNavEnabledKey)
               defaults.set(false, forKey: isFirstLoaded)
               NavigationManager.loadHomeVC(in: self)
          }
    }
}

extension RegionListViewController: UITableViewDelegate, UITableViewDataSource {
    
     private func setupTableView() {
          self.regionTableView.delegate = self
          self.regionTableView.dataSource = self
          
          let nib = UINib(nibName: ServicesViewCell.identifier, bundle: nil)
          self.regionTableView.register(nib, forCellReuseIdentifier: ServicesViewCell.identifier)
          self.regionTableView.separatorStyle = .none
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if let regionData = regionData {
               switch section {
               case regionsSection:
                    return regionData.regions.count + 1
               default:
                    return isServicesSelected ? regionData.services.count : 0
               }
          } else {
               return 0
          }
     }
     
     func numberOfSections(in tableView: UITableView) -> Int {
          return 2
     }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          switch indexPath.section {
          case regionsSection:
               let cell = tableView.dequeueReusableCell(withIdentifier: RegionTableViewCell.identifier, for: indexPath) as! RegionTableViewCell
               if indexPath.row == regionData.regions.count {
                    cell.setupCell(region: Region(domain: "prototype", name: "prototype", oauth: true, enableMobileNavigation: true), selected: regionSelected)
               } else {
                    cell.setupCell(region: regionData.regions[indexPath.row], selected: regionSelected)
               }
               return cell
          default:
               let cell = tableView.dequeueReusableCell(withIdentifier: ServicesViewCell.identifier, for: indexPath) as! ServicesViewCell
               cell.selectionStyle = .none
               cell.setupCell(service: regionData.services[indexPath.row], selected: regionSelected)
               if indexPath.row == regionData.services.count - 1 {
                    cell.addBottomStyle()
               }
               return cell
          }
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          if indexPath.section == regionsSection {
               let cell = tableView.cellForRow(at: indexPath) as! RegionTableViewCell
               cell.selectCell()
               if indexPath.row == regionData.regions.count {
                    regionSelected = Region(domain: "prototype", name: "prototype", oauth: true, enableMobileNavigation: true)
               } else {
                    regionSelected = regionData.regions[indexPath.row]
               }
               setupButton(isEnabled: true)
          } else {
               let cell = tableView.cellForRow(at: indexPath) as! ServicesViewCell
               cell.selectCell()
               regionSelected = regionData.services[indexPath.row]
               setupButton(isEnabled: true)
          }
     }
     
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
          if indexPath.section == regionsSection {
               if let cell = tableView.cellForRow(at: indexPath) as? RegionTableViewCell {
                    cell.unselectCell()
               }
          } else {
               if let cell = tableView.cellForRow(at: indexPath) as? ServicesViewCell {
                    cell.unselectCell()
               }
          }
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let headerView = Bundle.main.loadNibNamed("ServicesHeaderViewCell", owner: self, options: nil)?.first as! ServicesHeaderViewCell
          let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTap(sender:)))
          headerView.addGestureRecognizer(tapRecognizer)
          return section == regionsSection ? nil : headerView
     }
     
     @objc func headerTap(sender: UITapGestureRecognizer) {
          guard let headerView = sender.view as? ServicesHeaderViewCell else {
               return
          }

          isServicesSelected = !isServicesSelected
     
          var indexPaths = [IndexPath]()
          for (index, _) in regionData.services.enumerated() {
               let indexPath = IndexPath(row: index, section: servicesSection)
               indexPaths.append(indexPath)
          }
               
          if isServicesSelected {
               headerView.selectHeader()
               regionTableView.insertRows(at: indexPaths, with: .fade)
               regionTableView.reloadInputViews()
          } else {
               headerView.unselectHeader()
               regionTableView.deleteRows(at: indexPaths, with: .fade)
          }
     }
     
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return section == regionsSection ? 0 : 102
     }
     
}
