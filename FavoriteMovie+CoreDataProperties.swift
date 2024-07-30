//
//  FavoriteMovie+CoreDataProperties.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 06/06/24.
//
//

import Foundation
import CoreData


extension FavoriteMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMovie> {
        return NSFetchRequest<FavoriteMovie>(entityName: "FavoriteMovie")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var adult: Bool
    @NSManaged public var releaseDate: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var originalLanguage: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var overview: String?

}

extension FavoriteMovie : Identifiable {

}
