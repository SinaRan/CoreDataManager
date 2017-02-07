//
//  CoreDataManager.swift
//  CoreDataManager
//
//  Created by DT-iOS on 2/5/17.
//  Copyright © 2017 DT-iOS. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class CoreDataManager {
    private var _entities : [Entity]! = nil
    private var _username: String? = nil
    private var _password: String? = nil
    
    private var _hasAuth : Bool! = false
    private var _didLogin : Bool! = false
    private var _server : HttpServer!
    static var _managedContext : NSManagedObjectContext!
    
    internal var username: String? { get{ return _username}}
    internal var password: String? { get{ return _password}}
    internal var hasAuth : Bool { get { return _hasAuth}}
    internal var entities : [Entity]! {get {return _entities}}
    
    internal var didLogin : Bool { get {return _didLogin}set{_didLogin=newValue}}
    public init(entities:[Entity],managedContext:NSManagedObjectContext){
        CoreDataManager._managedContext = managedContext
        _entities = entities
    }
    
    public init(entities:[Entity],username:String,password:String,managedContext:NSManagedObjectContext){
        CoreDataManager._managedContext = managedContext
        _entities = entities
        _username = username
        _password = password
        _hasAuth = true
    }
    public func startServer(){
        _server = Server.Initial(self)
        
        do {
            try _server.start()
        }
        catch{}
    }
    public func stopServer(){
        do {
            try _server.stop()
        }
        catch{}
    }
    
    
    class func Get(name:String)->[NSManagedObject]?{
        var entitName = name
        

        entitName.replaceRange(entitName.startIndex...entitName.startIndex, with: String(entitName[entitName.startIndex]).capitalizedString)
        
        
        let fetchRequest = NSFetchRequest(entityName: entitName)
        do {
            let results = try _managedContext.executeFetchRequest(fetchRequest)
            return results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    class func GetWithCondition(name:String,predicat:NSPredicate)->[NSManagedObject]?{
        var entitName = name
        
        entitName.replaceRange(entitName.startIndex...entitName.startIndex, with: String(entitName[entitName.startIndex]).capitalizedString)
        
        let fetchRequest = NSFetchRequest(entityName: entitName)

        fetchRequest.predicate = predicat
        do {
            let results = try _managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            return results
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
}