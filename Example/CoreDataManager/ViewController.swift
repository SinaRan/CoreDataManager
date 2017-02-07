//
//  ViewController.swift
//  CoreDataManager
//
//  Created by Sina Ranjbar on 02/07/2017.
//  Copyright (c) 2017 Sina Ranjbar. All rights reserved.
//

import UIKit
import CoreDataManager

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataGenerator.Generate()
        var entities = [Entity]()
        entities.append(Entity(attributes: ["first_name","age","last_name"], name: "Users"))
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        let coreData = CoreDataManager(entities: entities, username: "Admin", password: "Admin", managedContext: appDelegate.managedObjectContext)
        coreData.startServer()
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

