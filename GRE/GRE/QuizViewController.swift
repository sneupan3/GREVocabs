//
//  ViewController.swift
//  GRE
//
//  Created by Samip Neupane on 4/28/16.
//  Copyright © 2016 UNO. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController, ModelDelegate{
    
    @IBOutlet var questionNumberLabel: UILabel!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var buttonControls: [UIButton]!
    
    private var model: Model!
    
    private var allQuestionsAnswers:[String:String] = [:]
    private var enabledQuestions : [String] = []
    private var allQuestions:[String] = []
    private var totalGuesses = 0
    private var totalQuestions = 0
    private var correctGuesses = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerLabel.isHidden = true
        model = Model(delegate: self)
        settingsChanged()
    }
    
    func settingsChanged() {
        enabledQuestions = model.questionsInEnabledLevel
        resetQuiz()
    }
    
    func resetQuiz(){
        allQuestions = model.newQuestionSet()
        totalGuesses = 0
        correctGuesses = 0
        nextQuestion()
        
    }
    
    func nextQuestion(){
        

        answerLabel.isHidden = true
        allQuestionsAnswers = model.allQuestionsAndAnswers
        questionNumberLabel.text = String(format: "Question %1$d of %2$d",
                                          (correctGuesses + 1), model.numberOfQuestions)
        if(enabledQuestions.count > 1){
            let currentQuestion =  allQuestions.remove(at: 0)
            questionLabel.text = currentQuestion
            let correctAnswer = allQuestionsAnswers[questionLabel.text!]
            for buttons in buttonControls{
                buttons.isEnabled = true
            }
            for button in buttonControls{
                button.isEnabled = true
            }
            
            
            let currentItems: [String] = []
            var set = Set(currentItems)
            while (set.count != 4) {
                let newRandom = Int(arc4random_uniform(UInt32(enabledQuestions.count)))
                if(allQuestionsAnswers[enabledQuestions[newRandom]]! != correctAnswer){
                    set.insert(allQuestionsAnswers[enabledQuestions[newRandom]]!)
                }
            }
        
            var i = 0;
            
            for button in buttonControls{
                button.setTitle(set.popFirst() ,for: .normal)
                    i += 1
            }
            
            if(!set.contains(correctAnswer!)){
                let randomVal = Int(arc4random_uniform(UInt32(4)))
                buttonControls[randomVal].setTitle(correctAnswer, for: .normal)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func guess(sender: UIButton) {
        
        let guess = sender.titleLabel?.text
        let correct = allQuestionsAnswers[(questionLabel?.text)!]
        totalGuesses += 1
        
        if(guess != correct){
            sender.isEnabled = false
            answerLabel.isHidden = false
            answerLabel.textColor = UIColor.red
            answerLabel.text = "Incorrect"
        }else{
            answerLabel.isHidden = false
            answerLabel.textColor = UIColor.green
            answerLabel.text = "Correct"
            
            correctGuesses += 1
            
            for buttons in buttonControls{
                buttons.isEnabled = false
            }
            
            if(correctGuesses == model.numberOfQuestions){
                results()
            }else{
                let deadlineTime = DispatchTime.now() + .seconds(1);                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.nextQuestion()
                }
                
//                dispatch_after(
//                    DispatchTime.now(dispatch_time_t(DISPATCH_TIME_NOW), Int64(1 * NSEC_PER_SEC)), // delay time
//                    DispatchQueue.main,
//                    {
//                        self.nextQuestion()
//                    }
                //)
            }
            
        }
    }
    
    func results(){
        
        let result = NSNumber(value: correctGuesses / totalGuesses)
        let percentString = NumberFormatter.localizedString(
            from: result,
            number: NumberFormatter.Style.percent
        )
        let alertController = UIAlertController(title: "Results",
                                                message: String(format: "%1$i attempts, %2$@ correct",
                                                    totalGuesses, percentString),
                                                preferredStyle: UIAlertControllerStyle.alert)
        let newQuizAction = UIAlertAction(title: "New Quiz",
                                          style: UIAlertActionStyle.default,
                                          handler: {(action) in self.resetQuiz()})
        alertController.addAction(newQuizAction)
        present(alertController, animated: true,
                              completion: nil)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue,
                                  sender: AnyObject?) {
        
        if segue.identifier == "settingsOption" {
            let controller =
                segue.destination as! SettingsViewController
            controller.model = model
        }
    }
}


