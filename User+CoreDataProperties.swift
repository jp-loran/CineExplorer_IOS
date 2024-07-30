//
//  User+CoreDataProperties.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 13/05/24.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var lastName: String?
    @NSManaged public var birthday: Date?
    @NSManaged public var email: String?
    @NSManaged public var password: String?

}

extension User : Identifiable {

}
