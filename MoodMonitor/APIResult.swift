//
//  APIResult.swift
//  SilverCloud
//
//  Created by Maria Ortega on 03/06/2020.
//  Copyright © 2020 James. All rights reserved.
//

import UIKit

enum Result<Value> {
     case success(Value)
     case failure(APIServiceError)
}

enum APIServiceError: Error {
     case noToken
     case noData
     case close
     case networkError(Error)
     case genericError(Error)
     case unknown(Error)
     case error(String)
}
