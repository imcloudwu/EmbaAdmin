//
//  AttendStudentViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 11/6/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class AttendStudentViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var CourseInfoItemData : CourseInfoItem!
    
    var Students : [EmbaStudent]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Students = GetAttendStudents()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let student = Students[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("AttendStudentCell") as? UITableViewCell
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AttendStudentCell")
        }
        
        cell?.textLabel?.text = student.StudentNumber + "   \(student.Gender)   " + student.ClassName + "       \(student.Name)"
        
        return  cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "修課學生數: \(Students.count)"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let student = Students[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentDetailViewCtrl") as! StudentDetailViewCtrl
        
        nextView.StudentData = self.GetStudentDetailData(student.Id)
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func GetAttendStudents() -> [EmbaStudent]{
        
        var retVal = [EmbaStudent]()
        
        var con = GetCommonConnect("test.emba.ntu.edu.tw")
        var err : DSFault!
        
        var rsp = con.SendRequest("main.QueryCourseStudent", bodyContent: "<Request><Condition><RefCourseID>\(CourseInfoItemData.CourseID)</RefCourseID></Condition></Request>", &err)
        
        //println(rsp)
        
        if err != nil{
            ShowErrorAlert(self,"查詢發生錯誤",err.message)
        }
        
        var nserr:NSError?
        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let students = xml?.root["Response"]["ScattendExt"].all{
            for student in students{
                
                let refStudentId = student["RefStudentId"].stringValue
                let studentName = student["StudentName"].stringValue
                let studentNumber = student["StudentNumber"].stringValue
                let gender = student["Gender"].stringValue
                let className = student["ClassName"].stringValue
                
                let es = EmbaStudent(Id: refStudentId, Name: studentName, EnglishName: "", ClassName: className, Birthdate: "", BirthPlace: "", StudentNumber: studentNumber, IdNumber: "", Gender: gender, EnrollYear: "", SchoolName: "", Department: "", Emails: "", Photo: nil, Companys: [Company](), Phone: nil, Address: nil)
                
                retVal.append(es)
            }
        }
        
        retVal.sort({$0.ClassName < $1.ClassName})
        
        return retVal
        
    }
    
    func GetStudentDetailData(value:String) -> EmbaStudent?{
        
        var retVal : EmbaStudent?
        
        var con = GetCommonConnect("test.emba.ntu.edu.tw")
        var err : DSFault!
        
        var rsp = con.sendRequestWithXmlType("main.QueryStudent", bodyContent: "<Request><Condition><StudentID>\(value)</StudentID></Condition></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self,"查詢發生錯誤",err.message)
        }
        var xml = AEXMLDocument(root: rsp)
        
        if let students = xml.root["Response"]["Student"].all {
            for student in students{
                let name = student["Name"].stringValue
                let className = student["ClassName"].stringValue
                let freshmanPhoto = GetImageFromBase64String(student["FreshmanPhoto"].stringValue, UIImage(named: "User-100.png"))
                
                let id = student["Id"].stringValue
                let englishName = student["EnglishName"].stringValue
                let birthdate = student["Birthdate"].stringValue
                let idNumber = student["IdNumber"].stringValue
                let birthPlace = student["BirthPlace"].stringValue
                let studentNumber = student["StudentNumber"].stringValue
                let gender = student["Gender"].stringValue
                let enrollYear = student["EnrollYear"].stringValue
                let schoolName = student["SchoolName"].stringValue
                let department = student["Department"].stringValue
                
                let emails = student["EmailList"].xmlString
                
                let phoneData = PhoneData(SmsPhone: student["SmsPhone"].stringValue, PermanentPhone: student["PermanentPhone"].stringValue, ContactPhone: student["ContactPhone"].stringValue)
                
                let addressData = AddressData(MailingAddress: student["MailingAddress"].xmlString, PermanentAddress: student["PermanentAddress"].xmlString, OtherAddress: student["OtherAddress"].xmlString)
                
                let company = Company(Name: student["CompanyName"].stringValue, Position: student["Position"].stringValue)
                
                if retVal == nil{
                    
                    var companys = [Company]()
                    companys.append(company)
                    
                    retVal = EmbaStudent(Id: id, Name: name, EnglishName: englishName, ClassName: className, Birthdate: birthdate, BirthPlace: birthPlace, StudentNumber: studentNumber, IdNumber: idNumber, Gender: gender, EnrollYear: enrollYear, SchoolName: schoolName, Department: department,  Emails: emails, Photo: freshmanPhoto, Companys: companys, Phone: phoneData, Address: addressData)
                }
                else{
                    retVal?.Companys.append(company)
                }
                
            }
        }
        
        return retVal
    }
    
    
}
