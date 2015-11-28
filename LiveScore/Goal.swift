import Foundation
import CoreData

@objc(Goal)
class Goal: NSManagedObject {
}

extension Goal {
    @NSManaged var match: Match!
    @NSManaged var half: Int
    @NSManaged var seconds: Int
    @NSManaged var squad: Squad?
    @NSManaged var scorer: Player?
    @NSManaged var assist: Player?
    @NSManaged var comment: String?

    class func create(moc: NSManagedObjectContext, match: Match, half: Int, seconds: Int, squad: Squad?, scorer: Player?) -> Goal {
        let instance = NSEntityDescription.insertNewObjectForEntityForName(
            "Goal", inManagedObjectContext: moc) as! Goal
        instance.match = match
        instance.half = half
        instance.seconds = seconds
        instance.squad = squad
        instance.scorer = scorer
        return instance
    }
    
    override var description: String {
        var desc = String(format: "%d\"", self.minutes)
        
        if let squad = self.squad {
            if squad.isBlijdorp() {
                if let scorer = self.scorer {
                    desc += String(format: " %@", scorer.name)
                }
                if let assist = self.assist {
                    desc += String(format: ", assist %@", assist.name)
                }
            } else {
                desc += String(format: " %@", squad.club)
            }
        }
        
        return desc
    }
    
    class func findByMatch(moc: NSManagedObjectContext, match: Match) -> [Goal]? {
        let fr = NSFetchRequest(entityName: "Goal")
        fr.predicate = NSComparisonPredicate(
            leftExpression: NSExpression(forKeyPath: "match"),
            rightExpression: NSExpression(forConstantValue: match),
            modifier: .DirectPredicateModifier,
            type: .EqualToPredicateOperatorType,
            options: .NormalizedPredicateOption)
        fr.sortDescriptors = [NSSortDescriptor(key: "half", ascending: true),
                              NSSortDescriptor(key: "seconds", ascending: true)]
        return (try? moc.executeFetchRequest(fr)) as? [Goal]
    }
    
    var minutes: Int {
        return ((self.half - 1) * 25) + Int(self.seconds / 60 )
    }    
}
