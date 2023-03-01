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
    
    let trasholdForZipingHistory: Int = 200
    
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
        
        // some cleaning
        wholeContext = wholeContext.replacingOccurrences(of: " >  >  > ", with: ">")
        wholeContext = wholeContext.replacingOccurrences(of: " >  > ", with: ">")
        wholeContext = wholeContext.replacingOccurrences(of: "\n", with: "")
        
        
        // load old compressed conversation part
        var coversationOld: String = ""
        if let conversationHistory: String = try? UserDefaults.standard.string(forKey: "conversationHistory") {
            coversationOld = conversationHistory
        }
        print("1) coversationOld: \(coversationOld)")

        

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
                        //cleanTxt = cleanTxt.replacingOccurrences(of: "SENTENCE_END", with: "")
                        
                        wholeContext = wholeContext + " > " + text
                        wholeContext = wholeContext.replacingOccurrences(of: "\n", with: " ")

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

    
    func openAiRequest(wholeContext: String, completion: @escaping (Result<String, Error>) -> Void) {
        var apiKey: String = ""

        if let openaikey: String = try? UserDefaults.standard.string(forKey: "openaikey") {
            apiKey = openaikey
        }
        
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
                        //text = text.replacingOccurrences(of: "\n", with: " ")

                    }
                    
                    text = text.replacingOccurrences(of: " > ", with: " ")
                    text = text.replacingOccurrences(of: ">", with: " ")

                    print("Answer: \(text)")

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
    func zipHistory() -> String {
        var wholeContext: String = ""

        if let conversation: String = try? UserDefaults.standard.string(forKey: "conversation") {
            wholeContext = conversation
        }
        
        print("conversation:\(wholeContext)")
        print("conversation.count:\(wholeContext.count)")
        var prepareForHistory: [String] = wholeContext.components(separatedBy: ">")
        print("prepareForHistory.count:\(prepareForHistory.count)")
        var prepareForHistoryPart1: String = ""
        var prepareForHistoryPart2: String = ""
        
        if (prepareForHistory.count >= trasholdForZipingHistory) {
            
            var n: Int = 0
            while n < prepareForHistory.count {
                if (n < prepareForHistory.count / 2) {
                    prepareForHistoryPart1 = prepareForHistoryPart1 + prepareForHistory[n]
                } else {
                    prepareForHistoryPart2 = prepareForHistoryPart2 + prepareForHistory[n]
                }
                
                n += 1
            }
            print("prepareForHistoryPart1:\(prepareForHistoryPart1)")
            print("prepareForHistoryPart2:\(prepareForHistoryPart2)")
            
            
            // overwrite conversation with a 2nd part of conversation
            UserDefaults.standard.set(prepareForHistoryPart2, forKey: "conversation")

            //UserDefaults.standard.set("", forKey: "conversationHistory") // delete all for testing
            
            // first part of conversation compress and save under conversationHistory
            var coversationOld: String = ""
            optimizeHistory(conversation: prepareForHistoryPart1) { result in
                print("prepareForHistoryPart1 result:\(result)")
                UserDefaults.standard.set(coversationOld, forKey: "conversationHistory")
            }
        }


        return wholeContext != "" ? wholeContext : "Welocome !"
    }
    
    
    func deleteHistory() {
        UserDefaults.standard.set("", forKey: "conversation")
    }
    
    func optimizeHistory(conversation: String, completion: @escaping (String) -> Void) {
        
        print("OPTIMIZE THIS CONVERSATION: \(conversation)")

        
        if (conversation != "") {
            openAiRequest(wholeContext: conversation) { (result: Result) in
                switch result {
                case .success(var text):
                    print("SUMMARIZED: \(text)")
                    completion(text)
                case .failure(let error):
                    print("Error generating text: \(error)")
                    completion("ERROR")
                }
            }
        } else {
            print("NO HISTORY TO OPTIMIZE")
        }

        
        
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
