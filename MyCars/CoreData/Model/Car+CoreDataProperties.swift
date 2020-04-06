//
//  Car+CoreDataProperties.swift
//  MyCars
//
//  Created by Валентина Калайда on 11.02.2020.
//  Copyright © 2020 Валентина Калайда. All rights reserved.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var fanChoice: Bool
    @NSManaged public var imageData: Data
    @NSManaged public var lastStarted: Date?
    @NSManaged public var mark: String?
    @NSManaged public var model: String?
    @NSManaged public var rating: Double
    @NSManaged public var timesDriven: Int16
    @NSManaged public var tintColor: NSObject?

}
