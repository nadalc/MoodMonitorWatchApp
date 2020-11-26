//
//  APIService.swift
//  SilverCloud
//
//  Created by Maria Ortega on 03/06/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class APIService: NSObject {

     // MARK: - API calls

     func login(username: String, password: String, completion: @escaping (Result<Any>) -> ()) {
          var loginRequest = URLRequest(url: URL(string: APIConstants.accountLoginURL)!)
          let deviceIdentifier: String! = UIDevice.current.identifierForVendor?.uuidString
          var body = "username=\(username)&password=\(password)&csrfmiddlewaretoken=CKFU5EyazzZ2yF4oWXytMM4mCFFGbujy&device_id=" + deviceIdentifier + ";";
          loginRequest.httpMethod = "POST";
          body = body.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
          loginRequest.httpBody = (body as NSString).data(using: String.Encoding.utf8.rawValue);
          loginRequest.setValue("csrftoken=CKFU5EyazzZ2yF4oWXytMM4mCFFGbujy", forHTTPHeaderField:"Cookie")
          loginRequest.setValue(APIConstants.accountLoginURL, forHTTPHeaderField:"Referer");
          loginRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
             
          let session = Foundation.URLSession.shared
          let task = session.dataTask(with: loginRequest, completionHandler: {
               data, response, error in
               if (response == nil) {
                    completion(Result.failure(.noData))
               }
               if (error == nil) {
                    completion(Result.success(()))
               }
          })
          UIApplication.shared.isNetworkActivityIndicatorVisible = true
          task.resume()
     }
     
     func registerDevice(from view: HomeViewController, deviceToken: String, completion: @escaping (Result<Any>) -> ()) {
          var csrfToken: String?
          var registerRequest = URLRequest(url: URL(string: APIConstants.deviceRegistrationUrl)!)
          if let url = registerRequest.url, let cookies = (HTTPCookieStorage.shared.cookies(for: url)), cookies.count > 0 {
               for cookie in cookies {
                    if cookie.name == "csrftoken" {
                         csrfToken = cookie.value
                    }
               }
          }
          var body = "deviceToken=\(deviceToken)&csrfmiddlewaretoken=\(csrfToken ?? "")";
          registerRequest.httpMethod = "POST";
          body = body.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
          registerRequest.httpBody = (body as NSString).data(using: String.Encoding.utf8.rawValue);
          registerRequest.setValue(APIConstants.deviceRegistrationUrl, forHTTPHeaderField:"Referer");
          registerRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
          let config = URLSessionConfiguration.default
          let session = Foundation.URLSession(configuration: config, delegate: view, delegateQueue: nil)
          let task = session.dataTask(with: registerRequest, completionHandler: {
               (responseData, response, error) in
               if let responseData = responseData {
                    do {
                         _ = try JSONSerialization.jsonObject(with: responseData, options: [])
                         completion(Result.success(()))
                    } catch {
                         completion(Result.failure(.error("\(error)")))
                    }
               }
          })
          UIApplication.shared.isNetworkActivityIndicatorVisible = true
          task.resume()
     }
     
     public func retrieveSessions(token: String, cookie: String, completion: @escaping (Result<[[String: Any]]>) -> ()) {
          let session = URLSession.shared
          var request = URLRequest(url: URL(string: APIConstants.sessionsUrl)!)
          request.httpMethod = "GET"
                           
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")                        
          request.addValue(cookie, forHTTPHeaderField: "Cookie")
          request.addValue(token, forHTTPHeaderField: "AUTHORIZATION")

          let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                               
               guard error == nil else {
                    DispatchQueue.main.async {
                         completion(Result.failure(.noData))
                    }
                    return
               }
                               
               guard let data = data else {
                    DispatchQueue.main.async {
                         completion(Result.failure(.noData))
                    }
                    return
               }
                               
               do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                         DispatchQueue.main.async {
                              completion(Result.success(json))
                         }
                    } else {
                         DispatchQueue.main.async {
                              completion(Result.failure(.noData))
                         }
                    }
               } catch {
                    DispatchQueue.main.async {
                         completion(Result.failure(.noData))
                    }
               }
          })
          task.resume()
     }
     
     /*
      Download the file from the given url and store it locally in the app.
     */
     func downloadMedia(url: URL, to localUrl: URL, completion: @escaping (Bool) -> ()) {
          let session = URLSession(configuration: URLSessionConfiguration.default)
          var request = URLRequest(url: url)
          request.httpMethod = "GET"
              
          let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
               if let tempLocalUrl = tempLocalUrl, error == nil {
                    do {
                         try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                         DispatchQueue.main.async {
                              completion(true)
                         }
                    } catch (let writeError) {
                         DispatchQueue.main.async {
                              let errorCode = (writeError as NSError).code
                              switch errorCode {
                                   case 516: // Already Exist
                                        completion(true)
                                   default:
                                        completion(false)
                              }
                         }
                    }
               } else {
                    DispatchQueue.main.async {
                         completion(false)
                    }
               }
          }
          task.resume()
     }
     
     public func retrieveRegions(completion: @escaping (Result<RegionList>) -> ()) {
          let session = URLSession.shared
          var request = URLRequest(url: URL(string: APIConstants.regionsUrl)!)
          request.httpMethod = "GET"
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")

          let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                               
               guard error == nil else {
                    DispatchQueue.main.async {
                         completion(Result.failure(.noData))
                    }
                    return
               }
                               
               guard let data = data else {
                    DispatchQueue.main.async {
                         completion(Result.failure(.noData))
                    }
                    return
               }
               
               do {
                    let regionList = try JSONDecoder().decode(RegionList.self, from: data)
                    DispatchQueue.main.async {
                         completion(Result.success(regionList))
                    }
               } catch {
                    DispatchQueue.main.async {
                         completion(Result.failure(.noData))
                    }
               }
          })
          task.resume()
     }

     public func retrieveMapping(cookie: String, completion: @escaping (Result<AppMapping>) -> ()) {
          let session = URLSession.shared
          var request = URLRequest(url: URL(string: APIConstants.mappingURL)!)
          request.httpMethod = "GET"
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.addValue(cookie, forHTTPHeaderField:"Cookie")

          let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                                 
               guard error == nil else {
                    DispatchQueue.main.async {
                         completion(Result.failure(.noData))
                    }
                    return
               }
                                 
               guard let data = data else {
                    DispatchQueue.main.async {
                         completion(Result.failure(.noData))
                    }
                    return
               }
               
               MappingDataManager.saveMapping(data: data)
               DispatchQueue.main.async {
                    MappingDataManager.mappingDataModel(data: data, completion: completion)
               }
          })
          task.resume()
     }
}
