//
//  MappingDataManager.swift
//  SilverCloud
//
//  Created by Maria Ortega on 04/09/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

class MappingDataManager: NSObject {
     
     static let mappingFileName = "MappingData"
     static let json = "json"
     static let mappingPath = mappingFileName + "." + json
     
     private static func getDocumentsDirectory() -> URL {
         let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         return paths[0]
     }
     
     static func saveMapping(data: Data) {
          let url = self.getDocumentsDirectory().appendingPathComponent(mappingPath)
          do {
               try data.write(to: url)
          } catch {
               print(error.localizedDescription)
          }
     }
     
     static func mappingDataModel(data: Data, completion: @escaping (Result<AppMapping>) -> ()) {
          do {
               let mappingData = try decoder().decode(AppMapping.self, from: data)
               completion(Result.success(mappingData))
          } catch {
               self.getLocalMapping(completion: completion)
          }
     }
     
     static func getLocalMapping(completion: @escaping (Result<AppMapping>) -> ()) {
          let url = self.getDocumentsDirectory().appendingPathComponent(mappingPath)
          do {
               if let data = FileManager.default.contents(atPath: url.path) {
                    let mappingData = try decoder().decode(AppMapping.self, from: data)
                    completion(Result.success(mappingData))
               } else {
                    self.mappingSavedModel(completion: completion)
               }
          } catch {
               self.mappingSavedModel(completion: completion)
          }
     }

     static func mappingSavedModel(completion: @escaping (Result<AppMapping>) -> ()) {
          do {
               if  let bundleURL = Bundle.main.url(forResource: mappingFileName, withExtension: json), let data = FileManager.default.contents(atPath: bundleURL.path) {
                    let mappingData = try decoder().decode(AppMapping.self, from: data)
                    completion(Result.success(mappingData))
               } else {
                    completion(Result.failure(.noData))
               }
          } catch {
               completion(Result.failure(.noData))
          }
     }
     
     private static func decoder() -> JSONDecoder {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          return decoder
     }
     
}
