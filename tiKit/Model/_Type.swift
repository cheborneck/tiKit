// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Type.swift instead.

import CoreData

enum TypeAttributes: String {
    case summary = "summary"
    case title = "title"
}

enum TypeRelationships: String {
    case violations = "violations"
}

@objc
class _Type: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Type"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Type.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var summary: String?

    // func validateSummary(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var title: String?

    // func validateTitle(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var violations: NSSet

}

extension _Type {

    func addViolations(objects: NSSet) {
        let mutable = self.violations.mutableCopy() as NSMutableSet
        mutable.unionSet(objects)
        self.violations = mutable.copy() as NSSet
    }

    func removeViolations(objects: NSSet) {
        let mutable = self.violations.mutableCopy() as NSMutableSet
        mutable.minusSet(objects)
        self.violations = mutable.copy() as NSSet
    }

    func addViolationsObject(value: Violation!) {
        let mutable = self.violations.mutableCopy() as NSMutableSet
        mutable.addObject(value)
        self.violations = mutable.copy() as NSSet
    }

    func removeViolationsObject(value: Violation!) {
        let mutable = self.violations.mutableCopy() as NSMutableSet
        mutable.removeObject(value)
        self.violations = mutable.copy() as NSSet
    }

}
