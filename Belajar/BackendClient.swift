//
//  BackendService.swift
//  Belajar
//
//  Created by Jim Cramer on 27/08/2016.
//  Copyright © 2016 Belajar NL. All rights reserved.
//

import Foundation

private let tokenInfoEndPoint = "https://www.googleapis.com/oauth2/v3/tokeninfo"
//private let signinEndPoint = "http://192.168.178.39:9000/auth/google/idtoken/"
//private let apiEndPoint = "http://192.168.178.39:9000/api"
private let signinEndPoint = "https://www.belajar.nl/auth/google/idtoken/"
private let apiEndPoint = "https://www.belajar.nl/api"
private let jwtKey = "jwt"
private let expiryMargin = 300.0  // 300 sec = 5 min

class BackendClient {
    
    struct User {
        let email: String
        let name: String
    }

    static let shared = BackendClient()
    
    private lazy var jwt: String? = UserDefaults.standard.string(forKey: jwtKey)
    
    private var authenticatedSession: URLSession?
    
    init() {
        jwt = UserDefaults.standard.string(forKey: jwtKey)
    }
    
    func signInWithGoogle(googleUser: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void) {
        let idToken = googleUser.authentication.idToken
        requestJWTFromServer(googleIdToken: idToken!) {[weak self] jwt in
            guard let weakSelf = self else {
                completionHandler(false)
                return
            }
            weakSelf.jwt = jwt
            UserDefaults.standard.set(jwt, forKey: jwtKey)
            weakSelf.signInToServer() { user in
                if user != nil {
                    if let userID = googleUser.userID,
                        let name = googleUser.profile.name,
                        let email = googleUser.profile.email,
                        let imageUrl = googleUser.profile.imageURL(withDimension: 100) {
                        let formData = "name=\(name)&email=\(email)&googleId=\(userID)&googleImageUrl=\(imageUrl)"
                        let request = NSMutableURLRequest(url: URL(string: apiEndPoint + "/users/google/update")!)
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.httpMethod = "POST"
                        request.httpBody = formData.data(using: .utf8)
                        let task = weakSelf.authenticatedSession!.dataTask(with: request as URLRequest) {(data, response, error) in
                            let success = weakSelf.verifyResponse(data: data, response: response, error: error)
                            completionHandler(success)
                        }
                        task.resume()
                    }
                } else {
                    completionHandler(false)
                }
            }
        }
    }
    
    func signInToServer(completionHandler: @escaping (User?) -> Void) {
        
        guard jwt != nil && !isTokenExpired() else {
            completionHandler(nil)
            return
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = ["Authorization" : "Bearer " + jwt! ]
        authenticatedSession = URLSession(configuration: config)
        
        let task = authenticatedSession!.dataTask(with: URL(string: apiEndPoint + "/users/me")!) { [weak self] (data, response, error) in
            guard let weakSelf = self,
                weakSelf.verifyResponse(data: data, response: response, error: error),
                let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                let email = jsonObj?["email"] as? String,
                let name = jsonObj?["name"] as? String
                else {
                    completionHandler(nil)
                    return
            }
            
            completionHandler(User(email: email, name: name))
        }
        
        task.resume()
    }
    
    func signOut() {
        jwt = nil
    }
    
    func requestJWTFromServer(googleIdToken idToken: String, completionHandler: @escaping (String?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: signinEndPoint)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = "id_token=\(idToken)".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self] (data, response, error) in
            guard let weakSelf = self,
                weakSelf.verifyResponse(data: data, response: response, error: error),
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                let jwt = json?["token"] as? String else {
                    completionHandler(nil)
                    return
            }
            
            completionHandler(jwt)
        }
        task.resume()
    }
    
    func isTokenExpired() -> Bool {
        guard jwt != nil else { return true }
        let components = jwt!.components(separatedBy: ".")
        guard let payloadData = NSData(base64Encoded: components[1], options: []) as? Data,
            let payloadObj = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
            let exp = payloadObj?["exp"] as? Double
            else { return false }
        let now = NSDate().timeIntervalSince1970 / 1000.0
        if exp - expiryMargin < now {
            jwt = nil
            return true
        }
        return false
    }
    
    func getHostTopics(completionHandler: @escaping ([Topic]?) -> Void) {
        guard authenticatedSession != nil else {
            fatalError()
        }
        
        let task = authenticatedSession!.dataTask(with: URL(string: apiEndPoint + "/topics/app")!) { [weak self] (data, response, error) in
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
    
    func getHostArticle(withFileName fileName: String, completionHandler:  @escaping (Article?) -> Void) {
        guard authenticatedSession != nil else {
            fatalError()
        }
        
        let url = URL(string: apiEndPoint + "/article/authed/get/" + fileName)!
        let task = authenticatedSession!.dataTask(with: url) { [weak self] (data, response, error) in
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
    
    func getHostArticles(withFileNames fileNames: [String], completionHandler: @escaping ([String : Article?]) -> Void) {
        var todoCount = fileNames.count
        var articles = [String: Article?]()
        var lock = NSObject()
        
        if todoCount == 0 {
            completionHandler(articles)
        }
        
        // TODO: handle server timeouts, errors etc
        
        for fileName in fileNames {
            BackendClient.shared.getHostArticle(withFileName: fileName) { [weak self] article in
                objc_sync_enter(lock)
                defer { objc_sync_exit(lock) }
                articles[fileName] = article
                todoCount -= 1
                if todoCount == 0 {
                    completionHandler(articles)
                }
            }
        }
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
