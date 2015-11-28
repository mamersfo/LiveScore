import UIKit

class ScoreController: UITableViewController {
    
    var goals: [Goal]?
    
    var match: Match? {
        didSet {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                self.goals = Goal.findByMatch(appDelegate.managedObjectContext, match: self.match!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    class func forMatch(match: Match) -> ScoreController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ScoreController") as! ScoreController
        controller.match = match
        return controller
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let goals = self.goals {
            return goals.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = self.goals![indexPath.item].description
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                let goal = self.goals![indexPath.item]
                self.goals?.removeAtIndex(indexPath.item)
                appDelegate.managedObjectContext.deleteObject(goal)
                appDelegate.saveContext()
                tableView.deleteRowsAtIndexPaths([indexPath],
                    withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }    
}
