//
//  MockData.swift
//  CoreDataManager
//
//  Created by DT-iOS on 2/7/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataGenerator {
    static let names = ["Aaron","Irma","Bob","Mack","Brett","Hazel","Edith","Catherine","Shawn","Perry"]
    static let surname = ["Austin","Palmer","Sutton","Shelton","Murray","Robertson","West","Klein","Gill","Gill"]
    static let age  = [20,39,14,18,30,9,49,23,50,15]
    class func Generate(){
        for i in names.enumerate() {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let entity =  NSEntityDescription.entityForName("Users",inManagedObjectContext:managedContext)
            let users = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext)
            users.setValue(i.element, forKey: "first_name")
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            users.setValue(surname[i.index], forKey: "last_name")
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            users.setValue(age[i.index], forKey: "age")
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
}