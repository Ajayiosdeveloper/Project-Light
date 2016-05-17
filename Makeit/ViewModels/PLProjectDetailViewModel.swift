//
//  PLProjectDetailViewModel.swift
//  Makeit
//
//  Created by ajaybabu singineedi on 21/04/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import UIKit

class PLProjectDetailViewModel: NSObject {
    
    var contributors:[PLTeamMember]!
    var commitments:[PLCommitment]!
    var assignments:[PLAssignment]!
    var communicationWays:[String]!
    var qbClient:PLQuickbloxHttpClient!
    
    
    init(members:[PLTeamMember]) {
        
        contributors = members
        commitments = [PLCommitment]()
        assignments = [PLAssignment]()
        communicationWays = ["Voice Chat","Video Chat","Text Chat"]
    }
    
    func numbersOfContributorsRows()->Int
    {
        return contributors.count
    }
    
    func numberOfCommitmentRows() -> Int {
        
        return commitments.count
    }
    
    func numberOfAssignmentRows() -> Int {
        
        return assignments.count
    }
    
    func contributorTitleForRowAtIndexPath(row:Int)->String
    {
        let member = contributors[row]
        
        return member.fullName
    }
    
   func contributorEmailForRowAtIndexPath(row:Int)->String
    {
        let member = contributors[row]
        
        return member.memberEmail
    }

    
    func contributorImageRowAtIndexPath(row:Int,completion:(UIImage?)->Void) {
        
        let member = contributors[row]
        let avatar = member.avatar
        if avatar == "Avatar"
        {
            completion(nil)
        }
        else{
            
            qbClient.downloadTeamMemberAvatar(avatar){result in
                
                if result != nil{
                    
                    completion(result)
                }
                else{
                    
                    completion(nil)
                }
            }
        }
    }
    
    
    func commitmentTitleForRowAtIndexPath(row:Int) -> String {
        
        let commitment = commitments[row]
        return commitment.name
    }
    
    func commitmentSubTitleForRowAtIndexPath(row:Int)->String
    {
        let commitment = commitments[row]
        return commitment.details
    }
    
    func assignmentTitleForRowAtIndexPath(row:Int)->String{
        
        let assignment = assignments[row]
        return assignment.name
    }
    
    func assignmentSubTitleForRowAtIndexPath(row:Int) -> String {
        
        let assignment = assignments[row]
        return assignment.details
    }
    

    func communicationType(index:Int) -> String {
        
        return communicationWays[index]
    }
    
    func getProjectContributorsList() -> [PLTeamMember] {
        
        return contributors
    }
    
    func getCommitmentsFromRemote(id:String,completion:(Bool)->Void)
    {
        qbClient = PLQuickbloxHttpClient()
        
        qbClient.fetchCommitmentsForProject(id){res,commitments in
            
            if let _ = commitments{
                
                for each in commitments!{
                    
                 let commitment = PLCommitment()
                 commitment.commitmentId = each.ID!
                 commitment.name = each.fields?.objectForKey("name") as! String
                 commitment.details = (each.fields?.objectForKey("description"))! as! String
                // commitment.targetDate = (each.fields?.objectForKey("targetDate"))! as! String
                 self.commitments.append(commitment)
                }
                completion(true)
            }else{completion(false)}
            
            
        }
        
    }
    
    func getAssignmentsFromRemote(id:String,completion:(Bool)->Void)
    {
        qbClient.fetchAssignmentsForProject(id){res,assignments in
            
            if let _ = assignments{
                
                for each in assignments!{
                
                let assignment = PLAssignment()
                assignment.commitmentId = each.ID!
                assignment.name = each.fields?.objectForKey("name") as! String
                assignment.details = (each.fields?.objectForKey("description"))! as! String
               // assignment.targetDate = (each.fields?.objectForKey("targetDate"))! as! String
               
                assignment.assineesUserIds = (each.fields?.objectForKey("assigneeUserId"))! as! [UInt]
                self.assignments.append(assignment)
              }
                completion(true)

            }else {completion(false)}
            
    }

    }
    
    func selectedCommitmentFor(row:Int)->PLCommitment?
    {
        if row <= self.commitments.count
        {
            return commitments[row]
        }
        return nil
    }
    
    func selectedAssignment(row:Int) -> PLAssignment? {
        
        if  row <= self.assignments.count
        {
            return assignments[row]
        }
        return nil
    }
    
    func selectedContributor(row:Int)->PLTeamMember{
        
        return contributors[row]
    }
    
}
