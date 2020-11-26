//
//  CookieManager.swift
//  SilverCloud
//
//  Created by Maria Ortega on 09/07/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit
import WebKit

class CookieManager: NSObject {
     
     static func setCookies(webview: WKWebView, navigationResponse: WKNavigationResponse) {
          if let response = navigationResponse.response as? HTTPURLResponse,
             let allHttpHeaders = response.allHeaderFields as? [String: String],
             let responseUrl = response.url {
              HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
              let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHttpHeaders, for: responseUrl)
              if cookies.isEmpty {
                  webview.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                      if cookies.count > 0, let url = webview.url, url.absoluteString.contains(APIConstants.silverCloudURL) {
                         _ = cookies.map({HTTPCookieStorage.shared.setCookie($0)})
                         storeCookies(cookies: cookies)
                      }
                  }
               } else {
                    _ = cookies.map({HTTPCookieStorage.shared.setCookie($0)})
              }
          }
     }
     
     static func storeCookies(url: URL) {
          if let cookies = HTTPCookieStorage.shared.cookies(for: url), cookies.count > 0, url.absoluteString.contains(APIConstants.silverCloudURL) {
               storeCookies(cookies: cookies)
          }
     }
     
     static func storeCookies(cookies: [HTTPCookie]) {
          var cookieDomain = ""
          var cookieDict = [String : AnyObject]()
          for cookie in cookies {
               cookieDomain = cookie.domain
               HTTPCookieStorage.shared.setCookie(cookie)
               cookieDict[cookie.name] = cookie.properties as AnyObject?
               HTTPCookieStorage.shared.setCookie(cookie)
          }
          defaults.set(cookieDict, forKey: APIConstants.cookiesKey + cookieDomain)
     }
     
     static func clearCookies() {
          KeychainManager.deleteUserData()
          HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)

          for cookie in defaults.dictionaryRepresentation() {
               if cookie.key.contains(APIConstants.cookiesKey) {
                    defaults.removeObject(forKey: cookie.key)
               }
          }
     }
     
     static func retrieveCookies() -> HTTPCookie? {
          if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: APIConstants.domainURL)!), cookies.count > 0, let sessionCookie = cookies.first(where: { $0.name as String == APIConstants.sessionid }) {
               return sessionCookie
          } else if let cookieDictionary: [String: Any] = defaults.dictionary(forKey: APIConstants.cookieDomainURL), let sessionid = cookieDictionary[APIConstants.sessionid], let sessionCookie = HTTPCookie(properties: sessionid as! [HTTPCookiePropertyKey : Any]) {
               return sessionCookie
          } else {
              return nil
          }
     }
}
