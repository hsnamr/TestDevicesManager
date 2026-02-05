//
//  WebService.swift
//  TDM
//
//  Created by Hussian Ali Al-Amri on 11/1/16.
//  Copyright © 2016 IM. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SystemConfiguration
import CoreTelephony

final class WebService {

    private let baseURL = "http://private-1cc0f-devicecheckout.apiary-mock.com"

    static let shared = WebService()
    private init() {}

    // MARK: - Devices API

    func getDevices(completion: @escaping () -> Void) {
        AF.request("\(baseURL)/devices", method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    PersistenceService.shared.addDevices(from: json, completion: completion)
                case .failure(let error):
                    print("WebService getDevices error: \(error)")
                }
            }
    }

    func addDevice(
        name: String,
        os: String,
        manufacturer: String,
        completion: ((String) -> Void)? = nil
    ) {
        let parameters: [String: Any] = [
            "device": name,
            "os": os,
            "manufacturer": manufacturer
        ]
        AF.request(
            "\(baseURL)/devices",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                completion?("Success")
            case .failure(let error):
                print("WebService addDevice error: \(error)")
                completion?("Failure")
            }
        }
    }

    func updateDevice(
        id: Int16,
        isCheckedOut: Bool,
        lastCheckedOutBy: String?,
        lastCheckedOutDate: Date?
    ) {
        var parameters: [String: Any]
        if isCheckedOut {
            let dateString = lastCheckedOutDate.map { ISO8601DateFormatter().string(from: $0) }
                ?? "2016-11-04T10:33:00-05:00"
            parameters = [
                "lastCheckedOutDate": dateString,
                "lastCheckedOutBy": lastCheckedOutBy ?? "",
                "isCheckedOut": true
            ]
        } else {
            parameters = ["isCheckedOut": false]
        }

        AF.request(
            "\(baseURL)/devices/\(id)",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            if case .success(let value) = response.result {
                print("JSON: \(value)")
            }
        }
    }

    func deleteDevice(id: Int16, completion: ((String) -> Void)? = nil) {
        AF.request("\(baseURL)/devices/\(id)", method: .delete, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    completion?("Success")
                case .failure:
                    completion?("Failure")
                }
            }
    }

    // MARK: - Reachability

    func getCurrentNetworkType() -> String? {
        CTTelephonyNetworkInfo().currentRadioAccessTechnology
    }

    /// Uses SCNetworkReachability to determine if the device has network connectivity.
    func isConnectedToNetwork() -> Bool {
        if getCurrentNetworkType() != nil {
            return true
        }

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        guard let reachability = defaultRouteReachability else { return false }

        var flags: SCNetworkReachabilityFlags = []
        guard SCNetworkReachabilityGetFlags(reachability, &flags) else { return false }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return isReachable && !needsConnection
    }
}
