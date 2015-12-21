import UIKit
import CoreData
import Social
import AudioToolbox

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var halfControl: UISegmentedControl!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var homeScores: UITextView!
    @IBOutlet weak var awayScores: UITextView!
    
    @IBOutlet weak var blijdorpButton: UIButton!
    @IBOutlet weak var opponentButton: UIButton!
    
    var timer: NSTimer?

    var detailItem: AnyObject? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startStopButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.configureView()
    }
    
    override func viewDidAppear(animated: Bool) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            
            if appDelegate.timerStart != nil {
                self.startTimer()
            }
            
            self.halfControl.selectedSegmentIndex = appDelegate.half - 1
            
            if let match = self.detailItem as? Match {
                if let goals = Goal.findByMatch(appDelegate.managedObjectContext, match: match) {
                    let home = goals.filter{ $0.squad == match.home }
                    let away = goals.filter{ $0.squad == match.away }
                    
                    self.scoreLabel.text = String(format: "%d - %d", home.count, away.count)
                    
                    homeScores.text = home.map{
                        String(format: "%@ %d'", $0.scorer ?? "N.N", $0.minutes) }.joinWithSeparator("\n")
                    
                    awayScores.text = away.map{
                        String(format: "%d' %@", $0.minutes, $0.scorer ?? "N.N") }.joinWithSeparator("\n")
                }
            }
        }
    }

    override func viewDidDisappear(animated: Bool) {
        self.stopTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tick() {
        if let started = (UIApplication.sharedApplication().delegate as? AppDelegate)!.timerStart {
            if let button = self.startStopButton {
                let total = abs(started.timeIntervalSinceNow)
                let minutes = Int(floor(total / 60.0))
                let seconds = Int(total % 60.0)
                let title = String(format: "%d:%02d", minutes, seconds)
                button.setTitle(title, forState: .Normal)
                
                if ( ( minutes == 8 && seconds == 20 ) || ( minutes == 16 && seconds == 40 ) ) {
                    // time to substitute
                    AudioServicesPlaySystemSound(1304)
                }
            }
        }
    }
    
    func tweet(text: String, image: UIImage?) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            if let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                tweetSheet.setInitialText(text)
                
                if let img = image {
                    tweetSheet.addImage(img)
                }
                
                self.presentViewController(tweetSheet, animated: true, completion: nil)
            }
        } else {
            print("Unable to tweet: ", text)
        }
    }
    
    func startTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil, repeats: true)
        
        self.startStopButton.setTitle("0:00", forState:  .Normal)
        self.startStopButton.backgroundColor = self.view.tintColor
        self.startStopButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.halfControl.enabled = false
        self.blijdorpButton.enabled = true
        self.opponentButton.enabled = true
    }
    
    func stopTimer() {
        if let someTimer = self.timer {
            someTimer.invalidate()
        }
        self.startStopButton.setTitle("Start", forState: .Normal)
        self.startStopButton.backgroundColor = UIColor.whiteColor()
        self.startStopButton.setTitleColor(self.view.tintColor, forState: .Normal)
        self.halfControl.enabled = true
        self.blijdorpButton.enabled = false
        self.opponentButton.enabled = false
    }
        
    @IBAction func startStop( sender: UIButton ) {
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            
            if ( sender.titleLabel!.text! == "Start" ) {
                if let match = self.detailItem as? Match {
                    appDelegate.match = match
                    appDelegate.half = self.halfControl.selectedSegmentIndex + 1
                    appDelegate.timerStart = NSDate()

                    self.startTimer()

                    if ( appDelegate.half == 1 ) {
                        self.tweet(String(format: "De wedstrijd %@ is begonnen!", match.description), image: nil)
                    } else if ( appDelegate.half == 2 ) {
                        self.tweet(String(format: "De tweede helft is begonnen", match.description), image: nil)
                    }
                }
            } else {
                appDelegate.match = nil
                appDelegate.timerStart = nil
                self.stopTimer()
                
                if let match = self.detailItem as? Match {
                    if (appDelegate.half == 2 ) {
                        self.tweet(String(format: "De wedstrijd %@ is afgelopen", match.description), image: appDelegate.screenShot())
                    }
                }
            }
        }
    }
    
    @IBAction func end( sender: UISegmentedControl ) {
        if let match = self.detailItem as? Match {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                if ( sender.selectedSegmentIndex == 2 ) {
                    self.tweet(String(format: "De wedstrijd %@ is afgelopen", match.description), image: appDelegate.screenShot())
                }
            }
        }
    }
    
    @IBAction func modify( sender: UIButton ) {
        if let match = self.detailItem as? Match {
            let scoreController = ScoreController.forMatch(match)
            self.navigationController?.pushViewController(scoreController, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let match = self.detailItem as? Match {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                if let started = appDelegate.timerStart {
                    let controller = (segue.destinationViewController as! UINavigationController).topViewController as! GoalController
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                    
                    var squad: Squad? {
                        if segue.identifier == "Blijdorp Goal" {
                            return match.blijdorp
                        } else {
                            return match.opponent
                        }
                    }
                    
                    controller.goal = Goal.create(appDelegate.managedObjectContext, match: match, half: appDelegate.half, seconds: Int(abs(started.timeIntervalSinceNow)), squad: squad, scorer: Player.findByName(appDelegate.managedObjectContext, name: "N.N."))
                }
            }
        }
    }
}
