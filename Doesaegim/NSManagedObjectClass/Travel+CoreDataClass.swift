//
//  Travel+CoreDataClass.swift
//  Doesaegim
//
//  Created by sun on 2022/11/14.
//
//

import CoreData
import Foundation


public class Travel: NSManagedObject {
    
    // MARK: - Functions
    
    @discardableResult
    static func addAndSave(with object: TravelDTO) throws -> Travel {
        let context = PersistentManager.shared.context
        let travel = Travel(context: context)
        travel.id = object.id
        travel.name = object.name
        travel.startDate = object.startDate
        travel.endDate = object.endDate
        
        try PersistentManager.shared.saveContext()
        
        return travel
    }
}