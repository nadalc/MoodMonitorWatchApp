//
//  APIConstants.swift
//  SilverCloud
//
//  Created by Maria Ortega on 03/06/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

let playsinline = "?playsinline=1"

class APIConstants {

     static let externalUrl = "https://www.silvercloudhealth.com"
     static let regionsUrl = "https://ie.silvercloudhealth.com/static/services.json"
     static let cookiesKey = "cookiesKey-"
     static let sessionid = "sessionid"
     static let loginURL = "/login/"
     static let logoutURL = "/account/logout"
     static let autoLogoutURL = "?loggedOut=True"
     static let forgotUserDetails = "/account/password_reset"
     static let helpCenterFAQs = "/help/faqs"
     static let helpHeaderMenu = "/help/?link=header_menu"
     static let silverCloudURL = ".silvercloudhealth.com"
     static let latestWebViewLoaded = "latestWebViewLoaded"
     static let homeTitle = "Home"
     static let toolsTitle = "Tools"
     static let programmeTitle = "Programme"
     static let appVersionHeaderKey = "SCHAPPVERSION"
     static let appVersionHeaderValue = "2"
     static let tabBarKey = "bottomNav"
     static let toolsKey = "tools"
     static let programmesKey = "programmes"
     
     struct URLParams {
          static let middlewareToken = "CKFU5EyazzZ2yF4oWXytMM4mCFFGbujy"
     }
     
     static var isRegionSelected: Bool {
          return defaults.string(forKey: serviceKey) != nil ? true : false
     }
     
     static var domainURL: String {
          let region = defaults.string(forKey: serviceKey) ?? "prototype"
          return "https://" + region + silverCloudURL
     }
     
     static var fullDomainURL: String {
          return domainURL + "/"
     }
     
     static var cookieDomainURL: String {
          let region = defaults.string(forKey: serviceKey) ?? "prototype"
          return cookiesKey + region + silverCloudURL
     }
     
     static var accountLoginURL: String {
          return APIConstants.domainURL + "/mobile/ios/login/"
     }

     static var homeURL: String {
          return APIConstants.domainURL + "/mobile/ios-app/"
     }
     
     static var mindfullessURL: String {
          return APIConstants.domainURL + "/tools/225" + playsinline
     }

     static var deviceRegistrationUrl: String {
          return APIConstants.domainURL + "/mobile/ios/device/"
     }
     
     static var sessionsUrl: String {
          return APIConstants.domainURL + "/mobile/session_history/"
     }
     
     static var mappingURL: String {
          return APIConstants.domainURL + "/content/user_program_details/"
     }
     
     static var helpURL: String {
          return APIConstants.domainURL + "/help"
     }

     static var loginCookieValue: String? {
          if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: APIConstants.accountLoginURL)!), cookies.count > 0 {
               let cookie = cookies.map { $0.name + "=" + $0.value }
               return cookie.joined(separator: ";")
          }
          return nil
     }
     
     static var isNativeNavEnabled: Bool {
          return defaults.bool(forKey: serviceNavEnabledKey)
     }
}
