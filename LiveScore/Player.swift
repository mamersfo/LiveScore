import Foundation
import CoreData

@objc(Player)
class Player: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var squad: Squad?
    
    class func create(moc: NSManagedObjectContext, name: String, squad: Squad?) -> Player {
        let instance = NSEntityDescription.insertNewObjectForEntityForName(
            "Player", inManagedObjectContext: moc) as! Player
        instance.name = name
        instance.squad = squad
        return instance
    }
    
    override var description: String {
        return name
    }
    
    class func findAll(moc: NSManagedObjectContext) -> [Player]? {
        let fr = NSFetchRequest(entityName: "Player")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return (try? moc.executeFetchRequest(fr)) as? [Player]
    }
    
    class func findByName(moc: NSManagedObjectContext, name: String) -> Player? {
        let fr = NSFetchRequest(entityName: "Player")
        fr.predicate = NSComparisonPredicate(
            leftExpression: NSExpression(forKeyPath: "name"),
            rightExpression: NSExpression(forConstantValue: name),
            modifier: .DirectPredicateModifier,
            type: .EqualToPredicateOperatorType,
            options: .NormalizedPredicateOption)
        return ((try? moc.executeFetchRequest(fr)) as? [Player])?.first
    }
}
