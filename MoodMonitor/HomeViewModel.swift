//
//  HomeViewModel.swift
//  SilverCloud
//
//  Created by Maria Ortega on 02/06/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewModel: NSObject {
     
     // MARK: - Properties

     private weak var view: HomeViewController?
     private let apiService = APIService()
     private let appDelegate = UIApplication.shared.delegate as! AppDelegate
     private var audioPlayer: AVAudioPlayer?

     // MARK: - Init

     init(view: HomeViewController) {
         self.view = view
     }
     
     // MARK: - API call

     func login(username: String, password: String, completion: @escaping (Result<Any>) -> ()) {
          apiService.login(username: username, password: password) { (response) in
               switch response {
               case .success(_):
                    completion(Result.success(()))
               case .failure(_):
                    self.deleteUserData()
                    completion(Result.failure(.noData))
               }
          }
     }
     
     func registerDevice(completion: @escaping (Result<Any>) -> ()) {
          guard let view = view, let deviceToken = appDelegate.devToken else { return }
          apiService.registerDevice(from: view, deviceToken: deviceToken, completion: completion)
     }
     
     func retrieveSessionData(completion: @escaping (Result<[[String: Any]]>) -> ()) {
          if let cookie = APIConstants.loginCookieValue {
               let deviceToken: String = appDelegate.devToken ?? KeychainManager.getOAuthToken() ?? ""
               apiService.retrieveSessions(token: deviceToken, cookie: cookie, completion: completion)
          }
     }

     func retrieveMappingData(cookie: String, completion: @escaping (Result<AppMapping>) -> ()) {
          if let cookie = APIConstants.loginCookieValue {
               apiService.retrieveMapping(cookie: cookie, completion: completion)
          }
     }
     
     func retrieveLocalMapping(completion: @escaping (Result<AppMapping>) -> ()) {
          MappingDataManager.getLocalMapping(completion: completion)
     }
     
     // MARK: - Media Logic

     func downloadAndDisplayMedia(url: URL, completion: @escaping (Bool, String) -> ()) {
          createAppFolder()
          let audio = self.getAudioTitle(url: url.absoluteString)
          downloadMediaAndSaveFile(url: url, audio: audio, completion: { response in
               completion(response, audio)
          })
     }
     
     private func getAudioTitle(url: String) -> String {
         let components = url.split(separator: "/")
         let fullName = components.last?.split(separator: ".")
         return String(fullName?.first ?? "")
     }
     
     func createAppFolder() {
          let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
          let documentsDirectory = paths[0]
          let docURL = URL(string: documentsDirectory)!
          if !FileManager.default.fileExists(atPath: docURL.absoluteString) {
              do {
                  try FileManager.default.createDirectory(atPath: docURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
              } catch {
                  print(error.localizedDescription);
              }
          }
     }
     
     func downloadMediaAndSaveFile(url: URL, audio: String, completion: @escaping (Bool) -> ()) {
          let docFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
          let destinationPath = docFolder.appendingPathComponent("/"+audio+".mp3")
          apiService.downloadMedia(url: url, to: destinationPath, completion: completion)
      }
     
     // MARK: KeyChain Manager
     
     func saveUserData(data: Any) {
          setUserLoginStatus(true)
          KeychainManager.saveUserData(data: data)
     }
     
     func deleteUserData() {
          setUserLoginStatus(false)
          KeychainManager.deleteUserData()
     }
     
     // MARK: User status Manager
     
     func setUserLoginStatus(_ status: Bool) {
          defaults.set(status, forKey: isUserLoggedIn)
     }
     
     func isUserLoggedOut() -> Bool {
          return !defaults.bool(forKey: isUserLoggedIn)
     }
     
     // MARK: Watch Connectivity Session Management
     
     func postMoods(from view: HomeViewController, moods: [String : Any]) {
          let currentMood = moods["currentMood"]!
          
          // POST current mood to website
          // Retrieve mood's date and time
          let date = Date()
          let calendar = Calendar.current
          let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date) // TODO add .timezone
          let year = String(describing: components.year!)
          let month = String(describing: components.month!)
          let day = String(describing: components.day!)
          let hours = String(describing: components.hour!)
          let minutes = String(describing: components.minute!)
          let stringDate =  "\(year)-\(month)-\(day) \(hours):\(minutes)" // format "yyyy-MM-dd HH:mm"
          
          DispatchQueue.main.async {
              let deviceIdentifier: String! = UIDevice.current.identifierForVendor?.uuidString
              var dict = Dictionary<String,Any>()
              if deviceIdentifier != nil {
                  dict["deviceId"] = deviceIdentifier
                  dict["datetime"] = stringDate
                  dict["mood"] = currentMood
                  // Get associated factors sent by the watch
                  dict["factors"] = moods["factors"]
                  // Create and send JSON containing the data
                  let jsonData: NSData
                  do {
                      jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) as NSData
                      let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
                      self.sendData(from: view, jsonData: jsonString, endpoint: APIConstants.domainURL + "/mobile/ios/mood/")
                  }
                  catch _ {
                  }
              }
          }
     }
     
     func sendData(from view: HomeViewController, jsonData: String, endpoint: String) {
         var apiRequest = URLRequest(url: URL(string: endpoint)!)
         var body = jsonData
         apiRequest.httpMethod = "POST"
         body = body.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
         apiRequest.httpBody = (jsonData as NSString).data(using: String.Encoding.utf8.rawValue)
         apiRequest.setValue(endpoint, forHTTPHeaderField:"Referer")
         apiRequest.setValue("application/json", forHTTPHeaderField:"Content-Type")
         let config = URLSessionConfiguration.default
         let session = Foundation.URLSession(configuration: config, delegate: view, delegateQueue: nil)
         let task = session.dataTask(with: apiRequest, completionHandler: {
             (responseData, response, error) in
             // Handle the list of moods received in response
             if let responseData = responseData {
                 do {
                     var moods = ""
                     let jsonAnswer = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as! [String:Any]
                     if (jsonAnswer["all_moods"] != nil){
                         moods = jsonAnswer["all_moods"]! as! String
                         // Format the string to be able to retrieve each mood
                         moods.remove(at: moods.startIndex) // remove [ at beginning
                         moods = String(moods.dropLast()) // remove ] at end
                         moods = moods.replacingOccurrences(of: "{", with: "\"record\":{")
                         moods = "{" + moods + "}"
                     }
                     do {
                         // Send the moods to the watch
                         try view.wcSession.updateApplicationContext(["moods":moods])
                     } catch _ {
                     }
                 } catch _ {
                 }
             }
         })
         task.resume()
     }
     
     // MARK: Reachability Manager
     
     func isConnectedToNetwork() -> Bool {
          return Reachability.isConnectedToNetwork()
     }
}
