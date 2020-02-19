//
//  FaceMasksAPI.swift
//  FaceMasksMap
//
//  Created by 沈維庭 on 2020/2/10.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

typealias CompletionHandle = (_ response: FaceMasksResponse?, _ error: Error?) -> Void

protocol API {
    func getInfo(completionHandle: @escaping CompletionHandle)
}

class FaceMasksAPI: API {
    static let shared = FaceMasksAPI()
    
    private(set) var sourcePath = "https://kiang.github.io/pharmacies/json/points.json"
    
    private init() { }
    
    func getInfo(completionHandle: @escaping CompletionHandle) {
        guard let url = URL(string: sourcePath) else { return }

        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data else {
                print("donwload failrd: \(error?.localizedDescription)")
                return
            }
            do {
                let response = try JSONDecoder().decode(FaceMasksResponse.self, from: data)
                completionHandle(response, nil)
            } catch let error {
                print("JsonDecoder failed: \(error.localizedDescription)")
            }
        }).resume()
    }
}
