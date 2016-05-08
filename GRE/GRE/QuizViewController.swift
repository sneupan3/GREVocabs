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
        answerLabel.hidden = true
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
        

        answerLabel.hidden = true
        allQuestionsAnswers = model.allQuestionsAndAnswers
        questionNumberLabel.text = String(format: "Question %1$d of %2$d",
                                          (correctGuesses + 1), model.numberOfQuestions)
        if(enabledQuestions.count > 1){
            let currentQuestion =  allQuestions.removeAtIndex(0)
            questionLabel.text = currentQuestion
            let correctAnswer = allQuestionsAnswers[questionLabel.text!]
            for buttons in buttonControls{
                buttons.enabled = true
            }
            for button in buttonControls{
                button.enabled = true
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
                button.setTitle(set.popFirst() ,forState: .Normal)
                    i += 1
            }
            
            if(!set.contains(correctAnswer!)){
                let randomVal = Int(arc4random_uniform(UInt32(4)))
                buttonControls[randomVal].setTitle(correctAnswer, forState: .Normal)
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
            sender.enabled = false
            answerLabel.hidden = false
            answerLabel.textColor = UIColor.redColor()
            answerLabel.text = "Incorrect"
        }else{
            answerLabel.hidden = false
            answerLabel.textColor = UIColor.greenColor()
            answerLabel.text = "Correct"
            
            correctGuesses += 1
            
            for buttons in buttonControls{
                buttons.enabled = false
            }
            
            if(correctGuesses == model.numberOfQuestions){
                results()
            }else{
                dispatch_after(
                    dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), // delay time
                    dispatch_get_main_queue(),
                    {
                        self.nextQuestion()
                    }
                )
            }
            
        }
    }
    
    func results(){
        
        
        let percentString = NSNumberFormatter.localizedStringFromNumber(
            Double(correctGuesses) / Double(totalGuesses),
            numberStyle: NSNumberFormatterStyle.PercentStyle)
        
        let alertController = UIAlertController(title: "Results",
                                                message: String(format: "%1$i attempts, %2$@ correct",
                                                    totalGuesses, percentString),
                                                preferredStyle: UIAlertControllerStyle.Alert)
        let newQuizAction = UIAlertAction(title: "New Quiz",
                                          style: UIAlertActionStyle.Default,
                                          handler: {(action) in self.resetQuiz()})
        alertController.addAction(newQuizAction)
        presentViewController(alertController, animated: true,
                              completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue,
                                  sender: AnyObject?) {
        
        if segue.identifier == "settingsOption" {
            let controller =
                segue.destinationViewController as! SettingsViewController
            controller.model = model
        }
    }
}


