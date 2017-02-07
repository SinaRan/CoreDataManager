//
//  Server.swift
//  CoreDataManager
//
//  Created by DT-iOS on 2/5/17.
//  Copyright © 2017 DT-iOS. All rights reserved.
//

import Foundation
import CoreData
class Server {
    class func Initial(coreDataManager:CoreDataManager)->HttpServer {
        let server = HttpServer()
        server["/"] = { r in
            scopes {
                html {
                    body {
                        ul(coreDataManager.entities) { entity in
                            li {
                                a { href = "/coreData/\(entity.name)"; inner = entity.name }
                            }
                            
                        }
                        ul{
                            li{ a{ href = "/customQuery/query"; inner = "Custom Query" }}
                        }
                    }
                    
                }
                }(r)
        }
        server.POST["/login"] = { r in
                    let formFields = r.parseUrlencodedForm()
                    let u = formFields[0].1
                    let p = formFields[1].1
                    if u == coreDataManager.username! && p == coreDataManager.password! {
                        coreDataManager.didLogin = true
                        return .MovedPermanently("/")
                    }
                    else {
                        return HttpResponse.OK(.Html("Username or Password is wrong"))
                    }
//            return HttpResponse.OK(.Html("Username or Password is wrong"))
        }
        server["login"] = { r in
            scopes{
                if coreDataManager.hasAuth{
                    html {
                        head {
                            script { src = "http://cdn.staticfile.org/jquery/2.1.4/jquery.min.js" }
                            stylesheet { href = "http://cdn.staticfile.org/twitter-bootstrap/3.3.0/css/bootstrap.min.css" }
                        }
                        body {
                            h3 { inner = "Sign In" }
                            
                            form {
                                method = "POST"
                                action = "/login"
                                
                                fieldset {
                                    input { placeholder = "Username"; name = "username"; type = "text"; autofocus = "" }
                                    input { placeholder = "Password"; name = "password"; type = "password"; autofocus = "" }
                                    a {
                                        href = "/login"
                                        button {
                                            type = "submit"
                                            inner = "Login"
                                        }
                                    }
                                }
                                
                            }
                            javascript {
                                src = "http://cdn.staticfile.org/twitter-bootstrap/3.3.0/js/bootstrap.min.js"
                            }
                        }
                    }
                    
                }
            }(r)
        }
        server["coreData/:param"] = { r in
            scopes {
                var entities : Entity?
                let path = r.queryParams.first?.0
                if path != nil {
                    var param = path!.stringByReplacingOccurrencesOfString("/coreData/", withString: "")
                    param.replaceRange(param.startIndex...param.startIndex, with: String(param[param.startIndex]).capitalizedString)
                    for i in coreDataManager.entities {
                        if i.name == param {
                            entities = i
                        }
                    }
                    if entities != nil {
                        let attributes = CoreDataManager.Get(entities!.name)
                        html {
                            body {
                                center {
                                    h2 { inner = "\(param)" }
                                }
                                    table(r.queryParams) { users in
                                        style = "width:100%"
                                        tr {
                                            for at in entities!.attributes!.enumerate() {
                                                td { inner = "\(at.element)"}
                                            }
                                        }
                                        for i in attributes!.enumerate() {
                                            tr {
                                                if i.index % 2 == 0 {
                                                    bgcolor = "#dddddd"
                                                }
                                                else {
                                                    bgcolor = "#FFFFFF"
                                                }
                                                for at in entities!.attributes!.enumerate() {
                                                    if at.index != entities!.attributes!.count {
                                                        let e = i.element.valueForKey(at.element)
                                                        if e != nil {
                                                            td { inner = "\(i.element.valueForKey(at.element)!)"}
                                                        }
                                                        else {
                                                            td { inner = "nil"}

                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
                
                }(r)
        }
        server["customQuery/query"] = { r in
            scopes{
                html {
                    head {
                        script { src = "http://cdn.staticfile.org/jquery/2.1.4/jquery.min.js" }
                        stylesheet { href = "http://cdn.staticfile.org/twitter-bootstrap/3.3.0/css/bootstrap.min.css" }
                    }
                    body {
                        h3 { inner = "Custom Query" }
                        
                        form {
                            method = "POST"
                            action = "/customQuery/query"
                            fieldset {
                                textarea {
                                    //                                style = "width:50%"
                                    cols = "100"
                                    rows = "5"
                                    name = "query"
                                    type = "text"
                                }
                                p {
                                    a {
                                        href = "/customQuery/query"
                                        button {
                                            type = "submit"
                                            inner = "submit"
                                        }
                                    }
                                }
                            }
                        }
//                        method = "POST"
//                        action = "/customQuery/query"
//                        a {
//                            href = "/customQuery/query"
//                            button {
//                                type = "submit"
//                                inner = "submit"
//                            }
//                        }
                        javascript {
                            src = "http://cdn.staticfile.org/twitter-bootstrap/3.3.0/js/bootstrap.min.js"
                        }
                    }
                }
            }(r)
        }
        server.POST["/customQuery/query"] = { r in
            scopes {
                var attributes = [String]()
                var isAttribute = false
                var isEntity = false
                var isPreOperator = false
                var isPostOperator = false
                var hasCondition = false
                var qPostOperator = [String]()
                var qPreOperator = [String]()
                var qOperator = [String]()
                var entity = ""
                let formFields = r.parseUrlencodedForm()
                var query = formFields[0].1
                query = query.stringByReplacingOccurrencesOfString("\r", withString: " ")
                query = query.stringByReplacingOccurrencesOfString("\n", withString: " ")
                let word = query.characters.split{$0 == " "}.map(String.init)
                for i in word.enumerate() {
                    if i.element != "," && i.element != ";" {
                        if isPostOperator {
                            if i.element != "and" && i.element != "AND" && i.element != "And" {
                                qPostOperator.append(i.element)
                            }
                        }
                        if i.element == "=" || i.element == "<=" || i.element == ">=" || i.element == "like" || i.element == "Like" || i.element == "LIKE"  {
                            if i.element == "Like" || i.element == "like" || i.element == "LIKE" {
                                qOperator.append("contains[c]")
                            }
                            else {
                                qOperator.append(i.element)
                            }
                            isPreOperator = false
                            isPostOperator = true
                            hasCondition = true
                        }
                        if isPreOperator {
                            qPreOperator.append(i.element)
                        }
                        
                        if i.element == "where" || i.element == "WHERE" || i.element == "Where" || i.element == "And" || i.element == "and" || i.element == "AND"{
                            isPreOperator = true
                            isEntity = false
                            isPostOperator = false
                        }
                        if isEntity {
                            entity = i.element
                        }
                        if i.element == "from" || i.element == "FROM" || i.element == "From" {
                            isAttribute = false
                            isEntity = true
                        }
                        if isAttribute {
                            if i.element.containsString(",") {
                                let word = i.element.characters.split{$0 == ","}.map(String.init)
                                for j in word {
                                    if !attributes.contains(j) {
                                        attributes.append(j)
                                    }
                                }
                            }
                            if !attributes.contains(i.element) {
                                attributes.append(i.element)
                            }
                        }
                        if i.element == "select" {
                            isAttribute = true
                        }
                        
                    }
                }
                var ats : [NSManagedObject]? = nil
                if hasCondition {
                    var format = ""
                    for i in qPostOperator.enumerate() {
                        if i.index != qPostOperator.count-1 {
                            format = "\(format) \(qPreOperator[i.index]) \(qOperator[i.index]) \"\(i.element)\" AND"
                        }
                        else {
                            format = "\(format) \(qPreOperator[i.index]) \(qOperator[i.index]) \"\(i.element)\""
                        }
                    }
                   
                    let predicate =  NSPredicate(format: format)
                    ats = CoreDataManager.GetWithCondition(entity, predicat: predicate)
                }
                else {
                    if entity != "" {
                        ats = CoreDataManager.Get(entity)
                    }
                    else {
//                        h2 { inner = "Oops! Something went wrong. Please double check your query" }
                    }
                }
                
                
                if ats != nil && ats?.count != 0{
                    var atss : [(index:Int , element:NSManagedObject)] = Array()
                    for i in ats!.enumerate() {
                        atss.append(i)
                    }
                    if attributes.contains("*") {
                        attributes.removeAll()
                        
                        for j in atss[0].element.entity.attributesByName {
                            attributes.append(j.0)
                        }
                    }
                    html {
                        body {
                            center {
                                h2 { inner = "\(entity)" }
                            }
                            table(r.queryParams) { users in
                                style = "width:100%"
                                tr {
                                    for at in attributes.enumerate() {
                                        var contains = false
                                        
                                        for element in ats![0].entity.attributesByName {
                                            if element.0 == at.element {
                                                contains = true
                                            }

                                        }
                                        if contains {
                                            td { inner = "\(at.element)"}
                                        }
                                    }
                                }
                                for i in ats!.enumerate() {
                                    tr {
                                        if i.index % 2 == 0 {
                                            bgcolor = "#dddddd"
                                        }
                                        else {
                                            bgcolor = "#FFFFFF"
                                        }
                                        for at in attributes.enumerate() {
                                            if at.index != attributes.count {
                                                for elements in i.element.entity.attributesByName {
                                                    if elements.0 == at.element {
                                                        let e = i.element.valueForKey(at.element)
                                                        if e != nil {
                                                            td { inner = "\(i.element.valueForKey(at.element)!)"}
                                                        }
                                                        else {
                                                            td { inner = "nil"}
                                                            
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    html {
                        body {
                            center {
                                h2 { inner = "Oops! Something went wrong. Please double check your query" }
                            }
                        }
                    }
                }
                
            }(r)
            
            //            return HttpResponse.OK(.Html("Username or Password is wrong"))
        }

        server.middleware.append { r in
//            print("Middleware:\(r.method) \(r.path)")
            if r.path != "/login" {
                if coreDataManager.hasAuth && !coreDataManager.didLogin{
                    return .MovedPermanently("/login")
                }
            }
            else {
                if !coreDataManager.hasAuth{
                    return .MovedPermanently("/")
                }
                else if coreDataManager.didLogin {
                    return .MovedPermanently("/")
                }

            }
            return nil
        }
        return server

    }
}