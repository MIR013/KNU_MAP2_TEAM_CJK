//
//  CoreDataStack.swift
//  REMAINDER_MJ
//
//  Created by 구민정 on 04/06/2019.
//  Copyright © 2019 구민정. All rights reserved.
//

import CoreData
//static class
/*
    //CoreData 구조 설명
 
*/

class CoreDataStack {
    // continer를 만들어서 반환
    static let persistentContainer: NSPersistentContainer={
        let container = NSPersistentContainer(name:"REMAINDER_MJ")
        container.loadPersistentStores{ (_,error) in
            if let error = error as NSError?{
                fatalError("unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    static var context: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    //갑분 클래스 -> 값 저장 용
    class func saveContext(){
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else{
            return //변화 없음
        }
        //변화 있음
        do{
            try context.save()
            print("success save!")
        }
        catch{
            let nserror = error as NSError
            fatalError("unresolved error!! \(nserror), \(nserror.userInfo)")
        }
    }
    
}
