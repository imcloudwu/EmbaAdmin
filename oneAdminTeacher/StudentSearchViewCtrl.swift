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
    var _ClassStudent = [EmbaStudent]()
    
    var ClassData : EmbaClass!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ClassData == nil{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        }
        else{
            noDataLabel.text = "資料產生中,請稍候..."
        }
        
        progressTimer = ProgressTimer(progressBar: progress)
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.title = ClassData == nil ? "學生查詢" : ClassData.ClassName
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if ClassData != nil && _ClassStudent.count == 0{
            ReloadData("")
        }
    }
    
    func ReloadData(value:String){
        
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let tmp = self.GetEmbaData(value)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self._DisplayStudent = tmp
                
                if self.ClassData != nil{
                    
                    self._ClassStudent = tmp
                    
                    self.noDataLabel.text = self._ClassStudent.count == 0 ? "查無學生資料" : ""
                }
                
                self.noDataLabel.hidden = self._DisplayStudent.count > 0
                
                self.tableView.reloadData()
                self.progressTimer.StopProgress()
            })
        })
    }
    
    func GetEmbaData(value:String) -> [EmbaStudent]{
        
        var mergeData = [String:EmbaStudent]()
        
        let con = GetCommonConnect("test.emba.ntu.edu.tw")
        var err : DSFault!
        
        let body = ClassData == nil ? "<Request><Condition><Or><StudentName>\(value)</StudentName><Company>\(value)</Company><EduSchoolName>\(value)</EduSchoolName><ClassName>\(value)</ClassName></Or></Condition></Request>" : "<Request><Condition><Or><ClassName>\(ClassData.ClassName)</ClassName></Or></Condition></Request>"
        
        let rsp = con.SendRequest("main.QueryStudent", bodyContent: body, &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
            return Array(mergeData.values)
        }
        
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
                
                let addressData = AddressData(MailingAddress: student["MailingAddress"].stringValue, PermanentAddress: student["PermanentAddress"].stringValue, OtherAddress: student["OtherAddress"].stringValue)
                
                let company = Company(Name: student["CompanyName"].stringValue, Position: student["Position"].stringValue, Status : student["work_status"].stringValue)
                
                let school = SchoolItem(Name: schoolName, Department: department)
                
                if let stu = mergeData[id]{
                    
                    if !stu.Companys.contains(company){
                        stu.Companys.append(company)
                    }
                    
                    if !stu.Schools.contains(school){
                        stu.Schools.append(school)
                    }
                }
                else{
                    
                    var schools = [SchoolItem]()
                    schools.append(school)
                    
                    var companys = [Company]()
                    companys.append(company)
                    
                    mergeData[id] = EmbaStudent(Id: id, Name: name, EnglishName: englishName, ClassName: className, Birthdate: birthdate, BirthPlace: birthPlace, StudentNumber: studentNumber, IdNumber: idNumber, Gender: gender, EnrollYear: enrollYear, Schools: schools, Department: department,  GroupDepartment: groupDepartment, Emails: emails, Photo: freshmanPhoto, Companys: companys, Phone: phoneData, Address: addressData)
                }
            }
        }
        
        return Array(mergeData.values)
    }
    
    func ToggleSideMenu(){
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
        cell.Class.text = data.ClassName
        
        cell.Company.text = ""
        
        if data.Companys.count > 0{
            cell.Company.text = data.Companys[0].Name + "\n" + data.Companys[0].Position
        }
        
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
        
        if ClassData == nil{
            ReloadData(searchBar.text!)
        }
        else{
            SearchFromLocal(searchBar.text!)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if ClassData != nil{
            SearchFromLocal(searchText)
        }
    }
    
    func SearchFromLocal(text:String){
        
        if text == ""{
            self._DisplayStudent = self._ClassStudent
        }
        else{
            
            let founds = self._ClassStudent.filter({ stu in
                
                if let _ = stu.Name.lowercaseString.rangeOfString(text.lowercaseString){
                    return true
                }
                
                for company in stu.Companys{
                    if let _ = company.Name.lowercaseString.rangeOfString(text.lowercaseString){
                        return true
                    }
                }
                
                for school in stu.Schools{
                    if let _ = school.Name.lowercaseString.rangeOfString(text.lowercaseString){
                        return true
                    }
                }
                
                return false
            })
            
            self._DisplayStudent = founds
        }
        
        self.tableView.reloadData()
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
    var Schools : [SchoolItem]
    var GroupDepartment : String
    var Photo : UIImage!
    var Emails : String
    var Companys : [Company]
    
    var Phone : PhoneData!
    var Address : AddressData!
    
    init(Id: String, Name: String, EnglishName: String, ClassName: String, Birthdate: String, BirthPlace: String, StudentNumber: String, IdNumber: String, Gender: String, EnrollYear: String, Schools: [SchoolItem], Department: String, GroupDepartment: String, Emails: String, Photo: UIImage!, Companys: [Company], Phone: PhoneData!, Address: AddressData!){
        
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
        self.Schools = Schools
        self.GroupDepartment = GroupDepartment
        self.Photo = Photo
        self.Emails = Emails
        
        self.Phone = Phone
        self.Address = Address
    }
}

struct Company : Equatable{
    var Name : String
    var Position : String
    var Status : String
}

func ==(lhs: Company, rhs: Company) -> Bool {
    return lhs.Name == rhs.Name && lhs.Position == rhs.Position
}

struct SchoolItem : Equatable{
    var Name : String
    var Department : String
}

func ==(lhs: SchoolItem, rhs: SchoolItem) -> Bool {
    return lhs.Name == rhs.Name && lhs.Department == rhs.Department
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
