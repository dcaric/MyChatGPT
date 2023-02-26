//
//  Store.swift
//  MyChatGPT
//
//  Created by Dario Caric on 26.02.2023..
//

import Foundation
import Alamofire
import SwiftyJSON

public class Store: ObservableObject {
    
    
    func context(newQuestion: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        var wholeContext: String = ""
        var apiKey: String = ""


        if let openaikey: String = try? UserDefaults.standard.string(forKey: "openaikey") {
            apiKey = openaikey
        }
        
        
        if let conversation: String = try? UserDefaults.standard.string(forKey: "conversation") {
            wholeContext = conversation + newQuestion
        }
        
        print("1) wholeContext: \(wholeContext)")
        
        let url = "https://api.openai.com/v1/completions"
        let parameters: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": wholeContext,
            "temperature": 0.7,
            "max_tokens": 1000,
            "stop" : "None",
            "n" : 1
            
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("json: \(json)")

                
                if let text = json["choices"][0]["text"].string {
                    if (text != "") {
                        wholeContext = wholeContext + text
                        wholeContext = wholeContext.replacingOccurrences(of: "\n", with: " ")
                        UserDefaults.standard.set(wholeContext, forKey: "conversation")
                    }
                    print("Answer: \(text)")
                    print("2) wholeContext: \(wholeContext)")

                    completion(.success(text))

                } else {
                    completion(.success("Server currently down"))

                }
            case .failure(let error):
                print("ERROR:\(error)")
                completion(.success("Server currently down"))


            }
        }
        
    }
    
    
    func saveKey(openAiKey: String) {
        UserDefaults.standard.set(openAiKey, forKey: "openaikey")

    }
    
    func readKey() -> Bool {
        var apiKey: String = ""
        if let openaikey: String = try? UserDefaults.standard.string(forKey: "openaikey") {
            apiKey = openaikey
        }
        return apiKey != "" ? true : false
    }
    

    
}
