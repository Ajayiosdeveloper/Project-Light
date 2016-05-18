//
//  PLSidebarViewModel.swift
//  Makeit
//
//  Created by Tharani P on 18/05/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLSidebarViewModel: NSObject {

    var qbClient = PLQuickbloxHttpClient()
    
    func getTodaysTasks()
    {
        print("Today")
     let type = "startDate"
        qbClient.tasksWithType(type) { (tasks) in
            print(tasks?.count)
        }
    }
    
    func getUpcomingTasks()
    {
        print("Upcoming")
        let type = "startDate[gt]"
        qbClient.tasksWithType(type) { (tasks) in
            print(tasks?.count)
        }
    }
    func getPendingTasks()
    {
        print("Pending")
        
        let type = "targetDate[lt]"
        qbClient.tasksWithType(type) { (tasks) in
            print(tasks?.count)
        }
    }
    
}
