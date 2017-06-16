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

    fileprivate var difficultyKey = "difficulty"
    fileprivate var numOfQuestions = "questions"
    
    fileprivate var delegate: ModelDelegate! = nil
    
    fileprivate var difficultyLevels = ["Easy" : true, "Medium": false , "Hard": false]
    var numberOfQuestions = 4
    
    fileprivate var allQuestionsAnswers: [String:String] = [:]
    fileprivate var currentLevelQuestions: [String] = []
    fileprivate var allQuestions: [String] = []
    fileprivate var allFiles: [String] = []
    
    
    init(delegate: ModelDelegate){
        self.delegate = delegate
      
        
        let userDefaults = UserDefaults.standard
        
        if let tempDifficulty = userDefaults.dictionary(forKey: difficultyKey){
            self.difficultyLevels = tempDifficulty as! [String : Bool]
        }
        
        let tempNumberOfQuestions = userDefaults.integer(forKey: numOfQuestions)
        if(tempNumberOfQuestions != 0) {
            self.numberOfQuestions = tempNumberOfQuestions
            
        }
        
        let filepaths =  Bundle.main.paths(
            forResourcesOfType: "txt", inDirectory: nil)
        for filepath in filepaths{
            
            do {
                let contents = try NSString(contentsOfFile: filepath, usedEncoding: nil) as String
                
                let myStrings = contents.components(separatedBy: CharacterSet.newlines)
                
                for string in myStrings{
                    allQuestions.append(string)
                    let newString = string.components(separatedBy: ":")
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
            let difficulty = question.components(separatedBy: ":")[2]
            let temDif = difficulty.trimmingCharacters(in: CharacterSet.newlines)
            if let tempVar: Bool = difficultyLevels[temDif]{
                if(tempVar){
                    currentLevelQuestions.append(question.components(separatedBy: ":")[0])
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
    
    func toggleLevels(_ name:String){
        difficultyLevels[name] = !(difficultyLevels[name]!)
        UserDefaults.standard.set(
            difficultyLevels as NSDictionary, forKey: difficultyKey)
        UserDefaults.standard.synchronize()
        questionsInEachLevels()
        
    }
    
    func changeNumberOfQuestions(_ value: Int){
         self.numberOfQuestions = value
        UserDefaults.standard.set(
        numberOfQuestions as Int, forKey: numOfQuestions)
        UserDefaults.standard.synchronize()
    }
    
    func notifyDelegate(){
        delegate.settingsChanged()
    }
    
}
