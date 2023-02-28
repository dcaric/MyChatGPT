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
    
    
    
    //**************************************************************************************
    // MARK: OPENAI HTTP REQUEST AND RESPONSE
    //**************************************************************************************
    func context(newQuestion: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        var wholeContext: String = ""
        var apiKey: String = ""


        if let openaikey: String = try? UserDefaults.standard.string(forKey: "openaikey") {
            apiKey = openaikey
        }
        
        
        if let conversation: String = try? UserDefaults.standard.string(forKey: "conversation") {
            wholeContext = conversation + " > " + newQuestion
        } else {
            wholeContext = newQuestion
        }
        
        //var wholeContextForGPT = wholeContext.replacingOccurrences(of: "$#$", with: ">")
        //wholeContextForGPT = wholeContext.replacingOccurrences(of: "SENTENCE_END", with: ">")

        wholeContext = wholeContext.replacingOccurrences(of: "\n", with: "")

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

                
                if var text = json["choices"][0]["text"].string {
                    if (text != "") {
                        // just in case remove tags
                        text = text.replacingOccurrences(of: "\n", with: " ")
                        //cleanTxt = cleanTxt.replacingOccurrences(of: "SENTENCE_END", with: "")
                        
                        wholeContext = wholeContext + " > " + text

                        UserDefaults.standard.set(wholeContext, forKey: "conversation")
                    }
                    
                    text = text.replacingOccurrences(of: " > ", with: " ")
                    text = text.replacingOccurrences(of: ">", with: " ")

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
    //**************************************************************************************

    
    //**************************************************************************************
    // MARK: OPENAI KEY
    //**************************************************************************************
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
    //**************************************************************************************

    
    
    //**************************************************************************************
    // MARK: HISTORY FOR CHATGPT
    //**************************************************************************************
    func readHistory() -> String {
        var wholeContext: String = ""

        if let conversation: String = try? UserDefaults.standard.string(forKey: "conversation") {
            wholeContext = conversation
        }
        
        print("wholeContext:\(wholeContext)")
        
        return wholeContext != "" ? wholeContext : "Welocome !"
    }
    
    
    func deleteHistory() {
        UserDefaults.standard.set("", forKey: "conversation")
    }
    //**************************************************************************************

    
    //**************************************************************************************
    //MARK: MESSAGES
    //**************************************************************************************

    struct Message : Codable {
        var messageBody: String
        var messageOriginMe: Bool
        var messageDate: Date
        
        init(messageBody: String, messageOriginMe: Bool, messageDate: Date) {
            self.messageBody = messageBody
            self.messageOriginMe = messageOriginMe
            self.messageDate = messageDate

        }
    }
    
    func readMessages() -> [Message] {
        var messages = [Message]()
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "messages") {
            messages = try! PropertyListDecoder().decode([Message].self, from: data)
        }
        return messages
    }

    func saveMessages(messages: [Message]) {
        let array : [Message] = messages
            if let data = try? PropertyListEncoder().encode(array) {
                UserDefaults.standard.set(data, forKey: "messages")
        }
    }
    //**************************************************************************************

    
}
