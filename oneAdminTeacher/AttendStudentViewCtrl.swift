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
    
    let _LightGrayColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 0.2)
    
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AttendStudentCell") as! AttendStudentCell
        
        
        if student.Id.isEmpty{
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.studentNumber.text = student.ClassName
            cell.studentNumber.textColor = UIColor.blackColor()
            cell.studentNumber.font = UIFont.boldSystemFontOfSize(17)
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.studentNumber.text = student.StudentNumber
            cell.studentNumber.textColor = UIColor.darkGrayColor()
            cell.studentNumber.font = UIFont.systemFontOfSize(16)
        }
        
        cell.name.text = student.Name
        cell.gender.text = student.Gender
        
        return  cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        var count = 0
        
        for s in Students{
            if !s.Id.isEmpty{
                count++
            }
        }
        
        return "修課學生數: \(count)"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let student = Students[indexPath.row]
        
        if !student.Id.isEmpty{
            
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentDetailViewCtrl") as! StudentDetailViewCtrl
            
            nextView.StudentData = self.GetStudentDetailData(student.Id)
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func GetAttendStudents() -> [EmbaStudent]{
        
        var retVal = [EmbaStudent]()
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
        let rsp = con.SendRequest("main.QueryCourseStudent", bodyContent: "<Request><Condition><RefCourseID>\(CourseInfoItemData.CourseID)</RefCourseID></Condition></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
        }
        
        var xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        } catch _ {
            xml = nil
        }
        
        var tmpCollection = [EmbaStudent]()
        
        if let students = xml?.root["Response"]["ScattendExt"].all{
            for student in students{
                
                let refStudentId = student["RefStudentId"].stringValue
                let studentName = student["StudentName"].stringValue
                let studentNumber = student["StudentNumber"].stringValue
                let gender = student["Gender"].stringValue
                let className = student["ClassName"].stringValue
                
                let es = EmbaStudent(Id: refStudentId, Name: studentName, EnglishName: "", ClassName: className, Birthdate: "", BirthPlace: "", StudentNumber: studentNumber, IdNumber: "", Gender: gender, EnrollYear: "", Schools: [SchoolItem](), Department: "", GroupDepartment: "", Emails: "", Photo: nil, Companys: [Company](), Phone: nil, Address: nil)
                
                tmpCollection.append(es)
            }
        }
        
        var filter = [String:[EmbaStudent]]()
        
        var keys = [String]()
        
        for t in tmpCollection.sort({ $0.ClassName < $1.ClassName}){
            
            if filter[t.ClassName] == nil{
                keys.append(t.ClassName)
                filter[t.ClassName] = [EmbaStudent]()
            }
            
            filter[t.ClassName]?.append(t)
        }
        
        for k in keys{
            
            if let students = filter[k]{
                
                let header = EmbaStudent(Id: "", Name: "", EnglishName: "", ClassName: k, Birthdate: "", BirthPlace: "", StudentNumber: "", IdNumber: "", Gender: "", EnrollYear: "", Schools: [SchoolItem](), Department: "", GroupDepartment: "", Emails: "", Photo: nil, Companys: [Company](), Phone: nil, Address: nil)
                
                retVal.append(header)
                
                for student in students{
                    retVal.append(student)
                }
            }
        }
        
        return retVal
    }
    
    func GetStudentDetailData(value:String) -> EmbaStudent?{
        
        var retVal : EmbaStudent?
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
//        var rsp = con.sendRequestWithXmlType("main.QueryStudent", bodyContent: "<Request><Condition><StudentID>\(value)</StudentID></Condition></Request>", &err)
        
        let rsp = con.SendRequest("main.QueryStudent", bodyContent: "<Request><Condition><StudentID>\(value)</StudentID></Condition></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
        }
        
        //var xml = AEXMLDocument(root: rsp)
        
        let xml = try? AEXMLDocument(xmlData: rsp.dataValue)
        
        if let students = xml?.root["Response"]["Student"].all {
            for student in students{
                let name = student["Name"].stringValue
                let className = student["ClassName"].stringValue
                let freshmanPhoto = GetImageFromBase64String(student["FreshmanPhoto"].stringValue, defaultImg: UIImage(named: "User-100.png"))
                
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
                let groupDepartment = student["GroupDepartment"].stringValue
                
                let emails = student["EmailList"].xmlString
                
                let phoneData = PhoneData(SmsPhone: student["SmsPhone"].stringValue, PermanentPhone: student["PermanentPhone"].stringValue, ContactPhone: student["ContactPhone"].stringValue)
                
                let addressData = AddressData(MailingAddress: student["MailingAddress"].xmlString, PermanentAddress: student["PermanentAddress"].xmlString, OtherAddress: student["OtherAddress"].xmlString)
                
                let company = Company(Name: student["CompanyName"].stringValue, Position: student["Position"].stringValue, Status : student["work_status"].stringValue)
                
                let school = SchoolItem(Name: schoolName, Department: department)
                
                if retVal == nil{
                    
                    var companys = [Company]()
                    companys.append(company)
                    
                    var schools = [SchoolItem]()
                    schools.append(school)
                    
                    retVal = EmbaStudent(Id: id, Name: name, EnglishName: englishName, ClassName: className, Birthdate: birthdate, BirthPlace: birthPlace, StudentNumber: studentNumber, IdNumber: idNumber, Gender: gender, EnrollYear: enrollYear, Schools: schools, Department: department, GroupDepartment: groupDepartment, Emails: emails, Photo: freshmanPhoto, Companys: companys, Phone: phoneData, Address: addressData)
                }
                else{
                    
                    if !retVal!.Companys.contains(company){
                        retVal?.Companys.append(company)
                    }
                    
                    if !retVal!.Schools.contains(school){
                        retVal?.Schools.append(school)
                    }
                    
                }
                
            }
        }
        
        return retVal
    }
    
    
}
