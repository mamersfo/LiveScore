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

    class func create(moc: NSManagedObjectContext, match: Match, half: Int, seconds: Int, squad: Squad, scorer: Player?, assist: Player?, comment: String?) -> Goal {
        let instance = NSEntityDescription.insertNewObjectForEntityForName(
            "Goal", inManagedObjectContext: moc) as! Goal
        instance.match = match
        instance.half = half
        instance.seconds = seconds
        instance.squad = squad
        instance.scorer = scorer
        instance.assist = assist
        instance.comment = comment
        return instance
    }
    
    override var description: String {
        return String(format: "match: %s, half: %d, seconds: %d",
            match.description,
            half,
            seconds
        )
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
