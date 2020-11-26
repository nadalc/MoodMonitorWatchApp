//
//  AppMapping.swift
//  SilverCloud
//
//  Created by Maria Ortega on 25/08/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

struct AppMapping: Codable  {
    let tools: [Section]
    let bottomNav: [Section]
    let programmes: [String: Programme]
}

struct Section: Codable {
    let url: String
    let icon: String?
    let name: String
}

struct Programme: Codable {
    let modules: [Module]
    let name: String
}

struct Module: Codable {
    let moduleId: Int
    let title: String
    let description: String
    let pages: [Page]
}

struct Page: Codable {
    let pageId: Int
    let url: String
    let title: String
    let description: String
}
