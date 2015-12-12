import Foundation
import CoreData

@objc(Club)
class Club: NSManagedObject {
    @NSManaged var code: String!
    @NSManaged var name: String!
    
    class func create(moc: NSManagedObjectContext, code: String, name: String) -> Club {
        let instance = NSEntityDescription.insertNewObjectForEntityForName(
            "Club", inManagedObjectContext: moc) as! Club
        instance.code = code
        instance.name = name
        return instance
    }
    
    func isBlijdorp() -> Bool {
        return "Blijdorp" == self.name
    }
    
    override var description: String {
        return name
    }
}
