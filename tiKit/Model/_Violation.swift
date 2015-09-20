// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Violation.swift instead.

import CoreData

enum ViolationAttributes: String {
    case actualTime = "actualTime"
    case location = "location"
    case timeStamp = "timeStamp"
}

enum ViolationRelationships: String {
    case type = "type"
}

@objc
class _Violation: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Violation"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Violation.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var actualTime: NSDate?

    // func validateActualTime(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var location: AnyObject?

    // func validateLocation(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var timeStamp: NSDate?

    // func validateTimeStamp(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var type: Type?

    // func validateType(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

