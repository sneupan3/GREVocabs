//
//  FlashCardViewController.swift
//  GRE
//
//  Created by Samip Neupane on 4/30/16.
//  Copyright © 2016 UNO. All rights reserved.
//

import UIKit

class FlashCardViewController: UIViewController {

    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var buttonLabel: UIButton!
    @IBOutlet var nextButton: UIButton!
    private var allQuestionsAnswers: [String:String] = [:]
    private var questions: [String] = []
    private var currentQuestion: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.hidden = true
        initialize()
    }
    
    func initialize(){
        
    
        let filepaths =  NSBundle.mainBundle().pathsForResourcesOfType(
            "txt", inDirectory: nil)
        
        for filepath in filepaths{
            
            do {
                let contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
                
                let myStrings = contents.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                
                for string in myStrings{
                    let newString = string.componentsSeparatedByString(":")
                    allQuestionsAnswers[newString[0]] = newString[1];
                    questions.append(newString[0])
                }
            } catch {
                print("Error")
            }
        }
        
        buttonLabel.hidden = false
        let randomVal = Int(arc4random_uniform(UInt32(questions.count)))
        currentQuestion = questions[randomVal]
        questionLabel.text = currentQuestion
    
    }
    
    func nextQuestion(){
        buttonLabel.hidden = false
        let randomVal = Int(arc4random_uniform(UInt32(questions.count)))
        currentQuestion = questions[randomVal]
        questionLabel.text = currentQuestion
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {

        buttonLabel.hidden = true
    
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.questionLabel.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
                
                //Once the label is completely invisible, set the text and fade it back in
                self.questionLabel.text = self.allQuestionsAnswers[self.currentQuestion]
                
                // Fade in
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.questionLabel.alpha = 1.0
                    }, completion: nil)
        })
        nextButton.hidden = false
    }

    @IBAction func nextButtonAction(sender: AnyObject) {
        nextButton.hidden = true
        self.nextQuestion()

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
