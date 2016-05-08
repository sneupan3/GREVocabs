//
//  Model.swift
//  GRE
//
//  Created by Samip Neupane on 4/29/16.
//  Copyright © 2016 UNO. All rights reserved.
//


import Foundation

protocol ModelDelegate {
    func settingsChanged()
}


class Model{

    private var difficultyKey = "difficulty"
    private var numOfQuestions = "questions"
    
    private var delegate: ModelDelegate! = nil
    
    private var difficultyLevels = ["Easy" : true, "Medium": false , "Hard": false]
    var numberOfQuestions = 4
    
    private var allQuestionsAnswers: [String:String] = [:]
    private var currentLevelQuestions: [String] = []
    private var allQuestions: [String] = []
    private var allFiles: [String] = []
    
    
    init(delegate: ModelDelegate){
        self.delegate = delegate
      
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let tempDifficulty = userDefaults.dictionaryForKey(difficultyKey){
            self.difficultyLevels = tempDifficulty as! [String : Bool]
        }
        
        let tempNumberOfQuestions = userDefaults.integerForKey(numOfQuestions)
        if(tempNumberOfQuestions != 0) {
            self.numberOfQuestions = tempNumberOfQuestions
            
        }
        
        let filepaths =  NSBundle.mainBundle().pathsForResourcesOfType(
            "txt", inDirectory: nil)
        for filepath in filepaths{
            
            do {
                let contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
                
                let myStrings = contents.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                
                for string in myStrings{
                    allQuestions.append(string)
                    let newString = string.componentsSeparatedByString(":")
                    allQuestionsAnswers[newString[0]] = newString[1];
                }
                
            } catch {
                print("Error Occured")
            }
        }
        questionsInEachLevels();
    }
    
    
    func questionsInEachLevels(){
        currentLevelQuestions.removeAll()
        
        for question in allQuestions{
            let difficulty = question.componentsSeparatedByString(":")[2]
            let temDif = difficulty.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            if let tempVar: Bool = difficultyLevels[temDif]{
                if(tempVar){
                    currentLevelQuestions.append(question.componentsSeparatedByString(":")[0])
                }
            }
        }
    }
    
    var levels : [String:Bool]{
        return difficultyLevels
    }
    
    var questionsInEnabledLevel:[String]{
        return currentLevelQuestions
    }
    
    var allQuestionsAndAnswers:[String : String]{
        return allQuestionsAnswers
    }
    
    func newQuestionSet()->[String]{
        var questionSet:[String] = []
        var count = 0;
        
        while (count < numberOfQuestions){
            let randomIndex = Int(arc4random_uniform(
                UInt32(currentLevelQuestions.count)))
            let curQuestion = currentLevelQuestions[randomIndex]
        
            if (!questionSet.contains(curQuestion)){
            questionSet.append(curQuestion)
            count += 1
            }
        }
        return questionSet
    }
    
    func toggleLevels(name:String){
        difficultyLevels[name] = !(difficultyLevels[name]!)
        NSUserDefaults.standardUserDefaults().setObject(
            difficultyLevels as NSDictionary, forKey: difficultyKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        questionsInEachLevels()
        
    }
    
    func changeNumberOfQuestions(value: Int){
         self.numberOfQuestions = value
        NSUserDefaults.standardUserDefaults().setObject(
        numberOfQuestions as Int, forKey: numOfQuestions)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func notifyDelegate(){
        delegate.settingsChanged()
    }
    
}
