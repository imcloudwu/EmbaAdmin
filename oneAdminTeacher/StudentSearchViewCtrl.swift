//
//  StudentSearchViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 9/3/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentSearchViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var progressTimer : ProgressTimer!
    
    var _DisplayStudent = [EmbaStudent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressTimer = ProgressTimer(progressBar: progress)
        
        self.navigationItem.title = "學生查詢"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ReloadData(value:String){
        
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            var tmp = self.GetEmbaData(value)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self._DisplayStudent = tmp
                
                self.noDataLabel.hidden = self._DisplayStudent.count > 0
                
                self.tableView.reloadData()
                self.progressTimer.StopProgress()
            })
        })
    }
    
    func GetEmbaData(value:String) -> [EmbaStudent]{
        
        var mergeData = [String:EmbaStudent]()
        
        var con = GetCommonConnect("test.emba.ntu.edu.tw")
        var err : DSFault!
        
        var rsp = con.sendRequestWithXmlType("main.QueryStudent", bodyContent: "<Request><Condition><Or><QueryName>\(value)</QueryName><QueryCompany>\(value)</QueryCompany><QuerySchoolName>\(value)</QuerySchoolName></Or></Condition></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self,"查詢發生錯誤",err.message)
            return mergeData.values.array
        }
            
//        var nserr: NSError?
//        var xml = AEXMLDocument(xmlData: rsp, error: &nserr)
        
        var xml = AEXMLDocument(root: rsp)
        
//        if nserr != nil{
//            ShowErrorAlert(self, "Xml解析失敗", "\(nserr?.localizedDescription)")
//            return retVal
//        }
        
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
                
                if let stu = mergeData[id]{
                    
                    stu.Companys.append(company)
                }
                else{
                    
                    var companys = [Company]()
                    companys.append(company)
                    
                    mergeData[id] = EmbaStudent(Id: id, Name: name, EnglishName: englishName, ClassName: className, Birthdate: birthdate, BirthPlace: birthPlace, StudentNumber: studentNumber, IdNumber: idNumber, Gender: gender, EnrollYear: enrollYear, SchoolName: schoolName, Department: department,  Emails: emails, Photo: freshmanPhoto, Companys: companys, Phone: phoneData, Address: addressData)
                }
            }
        }
        
        return mergeData.values.array
    }
    
    func ToggleSideMenu(){
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _DisplayStudent.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _DisplayStudent[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("EmbaStudentCell") as! EmbaStudentCell
        
        cell.Photo.image = data.Photo
        cell.Name.text = data.Name
        cell.Company.text = data.Companys[0].Name + "\n" + data.Companys[0].Position
        cell.Class.text = data.ClassName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentDetailViewCtrl") as! StudentDetailViewCtrl
        nextView.StudentData = _DisplayStudent[indexPath.row]
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    //Mark : SearchBar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        
        ReloadData(searchBar.text)
    }
    
}

class EmbaStudent{
    
    var Id : String
    var Name : String
    var EnglishName : String
    var ClassName : String
    var Birthdate : String
    var BirthPlace : String
    var StudentNumber : String
    var IdNumber : String
    var Gender : String
    var EnrollYear : String
    var SchoolName : String
    var Department : String
    var Photo : UIImage!
    var Emails : String
    var Companys : [Company]
    
    var Phone : PhoneData
    var Address : AddressData
    
    init(Id: String, Name: String, EnglishName: String, ClassName: String, Birthdate: String, BirthPlace: String, StudentNumber: String, IdNumber: String, Gender: String, EnrollYear: String, SchoolName: String, Department: String, Emails: String, Photo: UIImage!, Companys: [Company], Phone: PhoneData, Address: AddressData){
        
        self.Id = Id
        self.Name = Name
        self.EnglishName = EnglishName
        self.ClassName = ClassName
        self.Companys = Companys
        self.Birthdate = Birthdate
        self.BirthPlace = BirthPlace
        self.StudentNumber = StudentNumber
        self.IdNumber = IdNumber
        self.Gender = Gender
        self.EnrollYear = EnrollYear
        self.SchoolName = SchoolName
        self.Department = Department
        self.Photo = Photo
        self.Emails = Emails
        
        self.Phone = Phone
        self.Address = Address
    }
}

struct Company{
    var Name : String
    var Position : String
}

struct PhoneData {
    var SmsPhone : String
    var PermanentPhone : String
    var ContactPhone : String
}

struct AddressData {
    var MailingAddress : String
    var PermanentAddress : String
    var OtherAddress : String
}
