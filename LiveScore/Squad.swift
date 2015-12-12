import Foundation
import CoreData

@objc(Squad)
class Squad: NSManagedObject {
    @NSManaged var club: Club!
    @NSManaged var team: String!
    
    class func create(moc: NSManagedObjectContext, club: Club, team: String) -> Squad {
        let instance = NSEntityDescription.insertNewObjectForEntityForName(
            "Squad", inManagedObjectContext: moc) as! Squad
        instance.club = club
        instance.team = team
        return instance
    }
    
    func isBlijdorp() -> Bool {
        return "Blijdorp" == self.club.name
    }
    
    override var description: String {
        return String(format: "%@ %@", club, team)
    }
}
