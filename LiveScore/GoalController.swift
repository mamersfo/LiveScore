import UIKit
import Social

class GoalController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    var players: [Player]?
    
    var squads: [Squad]?
    var squadPicker: UIPickerView!
    var scorerPicker: UIPickerView!
    var assistPicker: UIPickerView!
    
    @IBOutlet weak var squadField: UITextField!
    @IBOutlet weak var scorerField: UITextField!
    @IBOutlet weak var assistField: UITextField!
    @IBOutlet weak var commentField: UITextField!

    var goal: Goal? {
        didSet {
            self.squads = [goal!.match.home, goal!.match.away]

            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                self.players = Player.findAll(appDelegate.managedObjectContext)
            }
        }
    }
    
    override func viewDidLoad() {
        self.squadPicker = UIPickerView()
        self.squadPicker.dataSource = self
        self.squadPicker.delegate = self
        self.squadPicker.showsSelectionIndicator = true
        self.squadField.inputView = self.squadPicker
        
        self.scorerPicker = UIPickerView()
        self.scorerPicker.dataSource = self
        self.scorerPicker.delegate = self
        self.scorerPicker.showsSelectionIndicator = true
        self.scorerField.inputView = self.scorerPicker
        
        self.assistPicker = UIPickerView()
        self.assistPicker.dataSource = self
        self.assistPicker.delegate = self
        self.assistPicker.showsSelectionIndicator = true
        self.assistField.inputView = self.assistPicker
        
        if let g = self.goal {
            if let squad = g.squad {
                self.squadField.text = squad.club.name
            }
            
            if let scorer = g.scorer {
                self.scorerField.text = scorer.name
            }
            
            if let assist = g.assist {
                self.assistField.text = assist.name
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch( pickerView ) {
        case squadPicker:
            return self.squads!.count
        case scorerPicker:
            return self.players!.count
        case assistPicker:
            return self.players!.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch( pickerView ) {
        case squadPicker:
            return squads![row].club.name
        case scorerPicker:
            return players![row].name
        case assistPicker:
            return players![row].name
        default:
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch( pickerView ) {
        case squadPicker:
            goal!.squad = squads![row]
            self.squadField.text = goal!.squad!.club.name
            self.squadField.resignFirstResponder()
        case scorerPicker:
            goal!.scorer = players![row]
            self.scorerField.text = goal!.scorer!.name
            self.scorerField.resignFirstResponder()
        case assistPicker:
            goal!.assist = players![row]
            self.assistField.text = goal!.assist!.name
            self.assistField.resignFirstResponder()
        default:
            break
        }
    }
    
    func tweetText() -> String? {
        if let g = self.goal {
            var tweet = String(format: "%d'", g.minutes)
        
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                if let goals = Goal.findByMatch(appDelegate.managedObjectContext, match: g.match) {
                    let homeGoals = goals.filter{ $0.squad == g.match.home }
                    let awayGoals = goals.filter{ $0.squad == g.match.away }
                    tweet += String(format: " %d-%d", homeGoals.count, awayGoals.count)
                }
            }
            
            if let squad = g.squad {
                if squad.isBlijdorp() {
                    if let scorer = g.scorer {
                        tweet += String(format: ", doelpunt %@", scorer.name)
                    }
                    
                    if let comment = g.comment {
                        tweet += String(format: " (%@)", comment)
                    }

                    if let assist = g.assist {
                        tweet += String(format: ", assist %@", assist.name)
                    }
                } else {
                    tweet += String(format: " doelpunt %@", squad.club.name)
                    
                    if let comment = g.comment {
                        tweet += String(format: " (%@)", comment)
                    }
                }
            }

            return tweet
        }
        
        return nil
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.saveContext()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let text = textField.text {
            switch(textField) {
            case commentField:
                goal!.comment = text
            default:
                break
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.commentField {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    @IBAction func placeTweet(sender: UIButton) {
        if let text = self.tweetText() {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                if let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                    tweetSheet.setInitialText(text)
                    self.presentViewController(tweetSheet, animated: true, completion: nil)
                }
            } else {
                print("Unable to tweet: \(text)")
            }
        }
    }
}