//
//  PLProjectAssignmentViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

enum AssignmentValidation:ErrorType {
    case NameEmpty,InvalidDate,DescriptionEmpty,NoAssignee
}


class PLProjectAssignmentViewModel: NSObject {
    
    var qbClient:PLQuickbloxHttpClient!
    var assigneeList:[PLTeamMember]!
    var selectedAssigneeList:[PLTeamMember]!
    
    init(assignees:[PLTeamMember]) {
        
        assigneeList = assignees
        selectedAssigneeList = [PLTeamMember]()
    }
    
    func assignmentValidations(name:String,targetDate:NSDate,description:String,projectId:String,assignees:[PLTeamMember]) throws->Bool {
        
        if name.characters.count == 0 { throw AssignmentValidation.NameEmpty}
        let today = NSDate()
        if (targetDate.earlierDate(today).isEqualToDate(targetDate)){
            
            throw AssignmentValidation.InvalidDate
        }
        if description.characters.count == 0
        {
            throw AssignmentValidation.DescriptionEmpty
        }
        if  assignees.count == 0
        {
            throw AssignmentValidation.NoAssignee
        }
        return true
    }
    
    func createAssignmentForProject(id:String,name:String,targetDate:NSDate,description:String,assignees:[PLTeamMember],completion:(Bool)->Void)
    {
        
        var asigneeIds:[String] = [String]()
        
        for each in assignees
        {
            asigneeIds.append(each.memberId)
        }
        
        qbClient = PLQuickbloxHttpClient()
        let targetDateString = NSDateFormatter.localizedStringFromDate(targetDate, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        qbClient.createAssignmentForProject(id, date:targetDateString , name:name, description: description, assignees:asigneeIds) { (res) in
            
            completion(res)
        }
        
        
        
    }
    
    func numbersOfRows()->Int
    {
        return assigneeList.count
    }
    
    func titleOfRowAtIndexPath(row:Int)->String
    {
        let member = assigneeList[row]
        
        return member.fullName
    }
    
    func addAssignee(row:Int) {
        
        self.selectedAssigneeList.append(self.assigneeList[row])
    }
    
    func removeAssignee(row:Int)  {
        
       let object = self.assigneeList[row]
       let index = self.selectedAssigneeList.indexOf(object)
       self.selectedAssigneeList.removeAtIndex(index!)
    }
    
    func getSelectedAssigneeList() -> [PLTeamMember] {
        
        return self.selectedAssigneeList
    }

}
