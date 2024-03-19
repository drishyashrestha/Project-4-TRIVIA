//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Drishya Shrestha on 3/18/24.
//

import Foundation
import UIKit



class TriviaQuestionService {
   
     func fetchTrivia(completion: (([TriviaQuestion]?) -> Void)? = nil) {
        let url = URL(string: "https://opentdb.com/api.php?amount=5")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                            assertionFailure("Error: \(error!.localizedDescription)")
                            return
                        }
                        guard let httpResponse = response as? HTTPURLResponse else {
                            assertionFailure("Invalid response")
                            return
                        }
                        guard let data = data else {
                            assertionFailure("No data received")
                            return
                        }
                        
                        // Check for rate limiting (HTTP status code 429)
                        if httpResponse.statusCode == 429 {
                            print("Rate limit exceeded. Please try again later.")
                            completion?(nil)
                            return
                        }
                        
                        // Handle other HTTP status codes
                        guard httpResponse.statusCode == 200 else {
                            assertionFailure("Invalid response status code: \(httpResponse.statusCode)")
                            return
                        }
                        
            let questions = TriviaQuestionService.parse(data: data)
            DispatchQueue.main.async {
                completion?(questions)
            }
        }
        task.resume()
    }
    
    private static func parse(data: Data) -> [TriviaQuestion]? {
        do {
            guard let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return nil
            }
            
            if let results = jsonDictionary["results"] as? [[String: Any]], results.count > 0 {
                var triviaQuestions = [TriviaQuestion]()
                for result in results {
                    if let category = result["category"] as? String,
                       let question = result["question"] as? String,
                       let correctAnswer = result["correct_answer"] as? String,
                       let incorrectAnswers = result["incorrect_answers"] as? [String] {
                        triviaQuestions.append(TriviaQuestion(category: category, question: question, correctAnswer: correctAnswer, incorrectAnswers: incorrectAnswers))
                    }
                }
                return triviaQuestions
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
        
        return nil
    }
}
