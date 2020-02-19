//
//  PharmacyAPI.swift
//  PharmacyTodayWidget
//
//  Created by 沈維庭 on 2020/2/19.
//  Copyright © 2020 沈維庭. All rights reserved.
//

import UIKit

class PharmacyAPI {
    static let shared = PharmacyAPI()
    
    private(set) var path = "https://ns-eshop-lyc.herokuapp.com/api/v1/mask/pharmacy"
    
    func fetchPharmacy(completionHandle: @escaping (_ response: PharmacyResponse?, _ error: Error?) -> Void) {
        guard
            let url = URL(string: path),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return }
        var rlm_pharmacy = RLM_Manager.shared.fetch(type: RLM_Pharmacy.self).sorted(by: { $0.sortId < $1.sortId })
        if rlm_pharmacy.count > 8 {
            rlm_pharmacy = Array(rlm_pharmacy[..<8])
        }
        let favPharmacyIdStr = rlm_pharmacy.reduce("", { $0 + "\($1.id),"})
        components.queryItems = [URLQueryItem(name: "ids", value: favPharmacyIdStr)]
        
        guard let finalUrl = components.url else { return }
        
        URLSession.shared.dataTask(with: finalUrl) { (data, response, error) in
            guard let data = data else {
                print("Download failed: \(error?.localizedDescription)")
                return
            }
            do {
                let pharmacyResponse = try JSONDecoder().decode(PharmacyResponse.self, from: data)
                completionHandle(pharmacyResponse, nil)
            } catch {
                print("JsonDecoder failed: \(error.localizedDescription)")
            }
        }.resume()
    }
}
