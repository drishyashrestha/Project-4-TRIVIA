//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit


class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  private let triviaService = TriviaQuestionService()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addGradient()
    questionContainerView.layer.cornerRadius = 8.0
    // TODO: FETCH TRIVIA QUESTIONS HERE
      triviaService.fetchTrivia { [weak self] question in
              if let question = question {
                  // Questions fetched successfully
                  self?.questions = question
                  DispatchQueue.main.async {
                      self?.updateQuestion(withQuestionIndex: 0)
                  }
              } else {
                  // Handle the case when questions couldn't be fetched
                  print("Failed to fetch trivia questions")
              }
          }
  }

        private func updateQuestion(withQuestionIndex questionIndex: Int) {
            currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
              let question = questions[questionIndex]
              questionLabel.text = question.question
              categoryLabel.text = question.category
              
              // Reset answer buttons
              answerButton0.isHidden = false
              answerButton1.isHidden = false
              answerButton2.isHidden = false
              answerButton3.isHidden = false
              
              if question.incorrectAnswers.count == 1 {
                  // True/false question
                  answerButton2.isHidden = true
                  answerButton3.isHidden = true
                  answerButton0.setTitle("True", for: .normal)
                  answerButton1.setTitle("False", for: .normal)
              } else {
                  // Multiple-choice question
                  let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
                  answerButton0.setTitle(answers[0], for: .normal)
                  answerButton1.setTitle(answers[1], for: .normal)
                  answerButton2.setTitle(answers[2], for: .normal)
                  answerButton3.setTitle(answers[3], for: .normal)
              }
          
        }
    
    private func checkAnswer(selectedAnswer: String) -> Bool {
       let correctAnswer = questions[currQuestionIndex].correctAnswer
       return selectedAnswer == correctAnswer
     }
    
    private func displayFeedback(isCorrect: Bool) {
      let message = isCorrect ? "Correct!" : "Incorrect!"
      let alertController = UIAlertController(title: "Feedback", message: message, preferredStyle: .alert)
      let action = UIAlertAction(title: "Next", style: .default) { [weak self] _ in
        self?.showNextQuestion()
      }
      alertController.addAction(action)
      present(alertController, animated: true, completion: nil)
    }
    
    
    private func showNextQuestion() {
        
        currQuestionIndex += 1
        
        if currQuestionIndex < questions.count {
          updateQuestion(withQuestionIndex: currQuestionIndex)
        } else {
          showFinalScore()
        }
      }
 
  private func updateToNextQuestion(answer: String) {

      let isCorrect = isCorrectAnswer(answer)
       
       // Provide feedback to the user based on correctness
       displayFeedback(isCorrect: isCorrect)
       
       if isCorrect {
           numCorrectQuestions += 1
       }
       
       // Move to the next question only if the user taps "Next" in the feedback dialog
       // Otherwise, wait for the user's action
   }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Your game is over!!!!",
                                            message: " Your Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
      currQuestionIndex = 0
      numCorrectQuestions = 0
      updateQuestion(withQuestionIndex: currQuestionIndex)
    }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
      // Call fetchNewQuestions() to fetch and set new trivia questions
              self.fetchNewQuestions()
  }
  
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
    private func fetchNewQuestions() {
            triviaService.fetchTrivia { [weak self] questions in
                if let questions = questions {
                    self?.questions = questions
                    self?.currQuestionIndex = 0
                    self?.numCorrectQuestions = 0
                    DispatchQueue.main.async {
                        self?.updateQuestion(withQuestionIndex: 0)
                    }
                } else {
                    print("Failed to fetch new trivia questions")
                }
            }
        }

  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        let selectedAnswer = sender.titleLabel?.text ?? ""
        let isCorrect = checkAnswer(selectedAnswer: selectedAnswer)
        displayFeedback(isCorrect: isCorrect)
        if isCorrect {
            numCorrectQuestions += 1
        }
    }
    
}

