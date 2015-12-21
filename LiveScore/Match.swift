import Foundation
import CoreData

@objc(Match)
class Match: NSManagedObject {
}

extension Match {
    @NSManaged var date: String!
    @NSManaged var home: Squad!
    @NSManaged var away: Squad!
    @NSManaged var goals: NSMutableOrderedSet

    class func create(moc: NSManagedObjectContext, date: String, home: Squad, away: Squad) -> Match {
            
        let instance = NSEntityDescription.insertNewObjectForEntityForName(
            "Match", inManagedObjectContext: moc) as! Match
        
        instance.date = date
        instance.home = home
        instance.away = away
            
        return instance
    }
    
    override var description: String {
        return String(format: "%@ %@ - %@ %@",
            self.home.club.name,
            self.home.team,
            self.away.club.name,
            self.away.team)
    }
    
    var blijdorp: Squad? {
        if home.isBlijdorp() {
            return home
        }
        if away.isBlijdorp() {
            return away
        }
        return nil
    }
    
    var opponent: Squad? {
        if !home.isBlijdorp() {
            return home
        }
        if !away.isBlijdorp() {
            return away
        }
        return nil
    }
    
    func add(goal: Goal) {
        goal.match = self
        self.goals.addObject(goal)
    }
}