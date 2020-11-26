//
//  KeychainManager.swift
//  SilverCloud
//
//  Created by Maria Ortega on 12/06/2020.
//  Copyright © 2020 James. All rights reserved.
//

import WebKit
import SimpleKeychain

class KeychainManager {
     
     private static let keychain = A0SimpleKeychain()

     struct KeychainParams {
          static let authUserJWT = "auth0-user-jwt"
          static let callbackHandler = "callbackHandler"
     }
     
     static func saveUserData(data: Any) {
          keychain.useAccessControl = true
          keychain.defaultAccessiblity = .whenUnlockedThisDeviceOnly
          keychain.setTouchIDAuthenticationAllowableReuseDuration(5.0)
          keychain.setData(NSKeyedArchiver.archivedData(withRootObject: data), forKey: KeychainParams.authUserJWT)
     }
     
     static func deleteUserData() {
          keychain.deleteEntry(forKey: KeychainParams.authUserJWT)
     }
     
     static func getUserData() -> [String: String] {
          let message = NSLocalizedString("Please enter your passcode/fingerprint to login", comment: "Prompt TouchID message")
          let jwt = keychain.data(forKey: KeychainParams.authUserJWT, promptMessage: message)
            
          if let jwt = jwt {
               return NSKeyedUnarchiver.unarchiveObject(with: jwt) as! Dictionary<String, String>
          } else {
               return Dictionary<String, String>()
          }
     }
     
     static func getOAuthToken() -> String? {
          return keychain.string(forKey: KeychainParams.authUserJWT)
     }
}
