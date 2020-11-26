//
//  SunCloudPickedInterfaceController.swift
//  WatchApp Extension
//
//  Created by Silvercloud Health  on 17/09/2018.
//  Copyright © 2019 Silvercloud Health . All rights reserved.
//

import WatchKit
import Foundation


class SunCloudPickedInterfaceController: WKInterfaceController {

    var isOkClicked = false
    @IBOutlet var tableOfFactors: WKInterfaceTable!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        populateTableWithFactors()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // If click on back button, we empty the list of factors
        if (!isOkClicked){
            listOfFactors = [String]()
        }
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func populateTableWithFactors() {
        tableOfFactors.setNumberOfRows(factors.count, withRowType: "SunCloudTableRow")
         for (index, factor) in factors.enumerated() {
            let row = tableOfFactors.rowController(at: index) as! SunCloudTableRow
            row.label.setText(factor)
            row.title = factor
            row.isSelected = false
         }
    }
    
    // Highlight selected factors and add them to the list to send
    override func table(_:WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let row = tableOfFactors.rowController(at: rowIndex) as! SunCloudTableRow
        if row.isSelected == false {
            row.select()
            row.isSelected = true
        }
        else {
            row.unselect()
            row.isSelected = false
        }
    }
    
    @IBAction func okClicked() {
        isOkClicked = true
    }
}
