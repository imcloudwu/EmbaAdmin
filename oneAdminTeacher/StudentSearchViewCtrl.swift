//
//  StudentSearchViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 9/3/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentSearchViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    var toggleViewDelegate : ToggleViewDelegate!
    
    @IBOutlet weak var classBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var progressTimer : ProgressTimer!
    
    var _DisplayStudent = [EmbaStudent]()
    var _ClassStudent = [EmbaStudent]()
    
    var _ClassData = [String:[EmbaClass]]()
    var _CurrentClass : EmbaClass!
    
    var canSearchLessTwoWords = false
    
    @IBAction func classBtnClick(sender: AnyObject) {
        
        //Sort grade...
        var grades = [Int]()
        
        for key in _ClassData.keys{
            if let grade = Int(key){
                grades.append(grade)
            }
        }
        
        grades = grades.sort({$0 > $1})
        
        //Action 1
        let menu1 = UIAlertController(title: "請選擇年級", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu1.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for grade in grades{
            
            let key = "\(grade)"
            
            menu1.addAction(UIAlertAction(title: key, style: UIAlertActionStyle.Default, handler: { (act1) -> Void in
                
                //Action 2
                
                let menu2 = UIAlertController(title: "請選擇班級", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
                
                menu2.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
                
                if let classes = self._ClassData[key]{
                    
                    for c in classes{
                        
                        menu2.addAction(UIAlertAction(title: c.ClassName, style: UIAlertActionStyle.Default, handler: { (act1) -> Void in
                            
                            self._CurrentClass = c
                            
                            self.classBtn.setTitle("  " + c.ClassName, forState: UIControlState.Normal)
                            
                            if let cls = self._CurrentClass{
                                //self.ReloadStudentData(cls)
                                self.ReloadData(cls)
                            }
                            
                        }))
                    }
                }
                
                self.presentViewController(menu2, animated: true, completion: nil)
                
            }))
            
        }
        
        self.presentViewController(menu1, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toggleViewDelegate = ToggleViewDelegate(searchBar: searchBar)
        
        self.navigationItem.leftBarButtonItem = toggleViewDelegate.ToggleBtn
        
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
        self.navigationItem.title = "學生查詢"
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Get Class Datas
        if _ClassData.count == 0{
            
            noDataLabel.text = "資料產生中,請稍候..."
            
            progressTimer.StartProgress()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                var classData = [String:[EmbaClass]]()
                
                //merge class data
                for c in self.GetClassData(){
                    
                    if classData[c.GradeYear] == nil{
                        classData[c.GradeYear] = [EmbaClass]()
                    }
                    
                    classData[c.GradeYear]?.append(c)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.noDataLabel.text = "您可以開始進行查詢"
                    
                    self._ClassData = classData
                    
                    self.progressTimer.StopProgress()
                })
            })
        }
        
        if _ClassStudent.count > 0{
            return
        }
        else if let c = self._CurrentClass{
            ReloadData(c)
        }
    }
    
    func ReloadData(value:Any){
        
        //self.searchBar.userInteractionEnabled = false
        self.noDataLabel.hidden = true
        //self.classBtn.enabled = false
        
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let tmp = self.GetStudentData(value)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                //self.classBtn.enabled = true
                
                if tmp.count == 0{
                    self.noDataLabel.text = "查無資料"
                    self.noDataLabel.hidden = false
                }
                
                self._ClassStudent = tmp
                self._DisplayStudent = tmp
                
                self.tableView.reloadData()
                self.progressTimer.StopProgress()
            })
        })
    }
    
    func GetClassData() -> [EmbaClass]{
        
        var retVal = [EmbaClass]()
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
        let rsp = con.SendRequest("main.GetAllClass", bodyContent: "", &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
            return retVal
        }
        
        if let xml = try? AEXMLDocument(xmlData: rsp.dataValue){
            
            if let classes = xml.root["Response"]["Class"].all{
                
                for c in classes{
                    
                    let classId = c["ClassID"].stringValue
                    let className = c["ClassName"].stringValue
                    let gradeYear = c["GradeYear"].stringValue
                    let refTeacherId = c["RefTeacherId"].stringValue
                    let teacherName = c["TeacherName"].stringValue
                    let teacherAccount = c["TeacherAccount"].stringValue
                    
                    let ec = EmbaClass(Id: classId, ClassName: className, GradeYear: gradeYear, RefTeacherId: refTeacherId, TeacherName: teacherName, TeacherAccount: teacherAccount)
                    
                    retVal.append(ec)
                }
            }
        }
        
        return retVal.sort({ $0.GradeYear.intValue > $1.GradeYear.intValue})
    }
    
    func GetStudentData(value:Any) -> [EmbaStudent]{
        
        var body = ""
        
        if let c = value as? EmbaClass{
            body = "<Request><Condition><Or><ClassName>\(c.ClassName)</ClassName></Or></Condition></Request>"
        }
        else if let v = value as? String{
            body = "<Request><Condition><Or><StudentName>\(v)</StudentName><Company>\(v)</Company><EduSchoolName>\(v)</EduSchoolName><ClassName>\(v)</ClassName></Or></Condition></Request>"
        }
        
        return GetStudentDataWithBody(body)
    }
    
    func GetStudentDataWithBody(body:String) -> [EmbaStudent]{
        
        var mergeData = [String:EmbaStudent]()
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
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
        
        let closure = { (value:String) -> Void in
        
            self._CurrentClass = nil
            self.classBtn.setTitle("  按年級班級查詢", forState: UIControlState.Normal)
            
            self.ReloadData(value)
        }
        
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        
        if let text = searchBar.text {
            
            if text.characters.count > 1{
                closure(text)
            }
            else{
                
                if canSearchLessTwoWords{
                    closure(text)
                }
                else{
                    
                    let alert = UIAlertController(title: "條件太少可能會造成查訊資量量過大", message: "確認繼續?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
                    
                    alert.addAction(UIAlertAction(title: "繼續", style: UIAlertActionStyle.Destructive, handler: { (act) -> Void in
                        self.canSearchLessTwoWords = true
                        closure(text)
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
            
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        SearchFromLocal(searchText)
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
                
                if let _ = stu.ClassName.lowercaseString.rangeOfString(text.lowercaseString){
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
        
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        
        self.tableView.reloadData()
    }
    
}

struct EmbaClass{
    var Id : String
    var ClassName : String
    var GradeYear : String
    var RefTeacherId : String
    var TeacherName : String
    var TeacherAccount : String
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
