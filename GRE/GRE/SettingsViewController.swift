//
//  SettingsViewController.swift
//  GRE
//
//  Created by Samip Neupane on 4/29/16.
//  Copyright © 2016 UNO. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var switches: [UISwitch]!
    @IBOutlet var numberOfQuestions: UITextField!
    
    var model: Model!
    fileprivate var quizLevels = ["Easy" , "Medium", "Hard"]
    fileprivate var settingsChanged = false
    fileprivate var defaultLevel = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberOfQuestions.keyboardType = UIKeyboardType.numberPad
        
        for i in 0 ..< switches.count {
            switches[i].isOn = model.levels[quizLevels[i]]!
        }
        
        numberOfQuestions.placeholder = String(model.numberOfQuestions)

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func questionsChanged(_ sender: AnyObject) {
        if(Int(sender.text) == nil){
             model.changeNumberOfQuestions(10)
        
        }else{
            model.changeNumberOfQuestions(Int(sender.text)!)
            model.notifyDelegate()
        }
        settingsChanged = true
        
    }
    
    @IBAction func switchesChanged(_ sender: AnyObject) {
        for i in 0 ..< switches.count {
            if sender === switches[i] {
                model.toggleLevels(quizLevels[i])
                settingsChanged = true
            }
        }
        
        if Array(model.levels.values).filter({$0 == true}).count == 0 {
            
            model.toggleLevels(quizLevels[defaultLevel])
            switches[defaultLevel].isOn = true
            displayErrorDialog()
        }
        
    }
    
    func displayErrorDialog() {
        // create UIAlertController for user input
        let alertController = UIAlertController(
            title: "At Least One Region Required",
            message: String(format: "Selecting %@ as the default region.",
                quizLevels[defaultLevel]),
            preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true,
                              completion: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if settingsChanged {
            model.notifyDelegate() //  if settings changed
        }
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
