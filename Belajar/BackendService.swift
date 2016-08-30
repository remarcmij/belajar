//
//  BackendService.swift
//  Belajar
//
//  Created by Jim Cramer on 27/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

//private let signinEndPoint = "https://www.belajar.nl/auth/idtoken/"
private let tokenInfoEndPoint = "https://www.googleapis.com/oauth2/v3/tokeninfo"
private let signinEndPoint = "http://192.168.178.39:9000/auth/google/idtoken/"
private let apiEndPoint = "http://192.168.178.39:9000/api"

class BackendService {
    
    static let shared = BackendService()
    
    private lazy var googleServiceInfo: [String: Any]? = {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else { return nil }
        return dict
    }()
    
    private var session: URLSession?
    
    func signin(user: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void) {
        let idToken = user.authentication.idToken // Safe to send to the server
        getAuthenticatedSession(withIdToken: idToken!) { [weak self] aSession in
            self?.session = aSession
            completionHandler(aSession != nil)
        }
    }
    
    private func getAuthenticatedSession(withIdToken idToken: String, completionHandler: @escaping (URLSession?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: signinEndPoint)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = "id_token=\(idToken)".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self] (data, response, error) in
            guard let me = self,
                me.verifyResponse(data: data, response: response, error: error),
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                let jsonWebToken = json?["token"] as? String else {
                    completionHandler(nil)
                    return
            }
            
            let config = URLSessionConfiguration.ephemeral
            config.httpAdditionalHeaders = ["Authorization" : "Bearer " + jsonWebToken ]
            completionHandler(URLSession(configuration: config))
        }
        task.resume()
    }
    
    func getHostTopics(completionHandler: @escaping ([Topic]?) -> Void) {
        guard session != nil else {
            fatalError()
        }
        
        let task = session!.dataTask(with: URL(string: apiEndPoint + "/topics/app/authed")!) { [weak self] (data, response, error) in
            guard let me = self,
                me.verifyResponse(data: data, response: response, error: error),
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []),
                let jsonObjects = jsonData as? [[String: Any]]
                else {
                    completionHandler(nil)
                    return
            }
            
            let topics = jsonObjects
                .map({ Topic.create(fromJSONObject: $0) })
                .filter({ $0 != nil} )
                .map({ $0! })
            
            completionHandler(topics)
        }
        
        task.resume()
    }
    
    func getHostArticle(fileName: String, completionHandler:  @escaping (Article?) -> Void) {
        guard session != nil else {
            fatalError()
        }
        
        let url = URL(string: apiEndPoint + "/article/public/get/" + fileName)!
        let task = session!.dataTask(with: url) { [weak self] (data, response, error) in
            guard let me = self,
                me.verifyResponse(data: data, response: response, error: error),
                let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []),
                let jsonObject = jsonData as? [String: Any]
                else {
                    completionHandler(nil)
                    return
            }
            completionHandler(Article.create(fromJSONObject: jsonObject))
        }
        
        task.resume()
    }
    
    private func verifyResponse(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        guard error == nil else {
            print(error!.localizedDescription)
            return false
        }
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        guard statusCode == 200 else {
            print("HTTP response status code: \(statusCode)")
            return false
        }
        
        guard data != nil else {
            print("HTTP response has nil data")
            return false
        }
        
        return true
    }
}
