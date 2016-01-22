//
//  CourseListViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 9/18/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class CourseListViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var _Datas = [CourseInfoItem]()
    var _DisplayData = [CourseInfoItem]()
    
    var progressTimer: ProgressTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        
        self.navigationItem.title = "課程查詢"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if self._Datas.count > 0{
            return
        }
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let data = self.GetCourseData()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.progressTimer.StopProgress()
                
                self._Datas = data
                self._DisplayData = self._Datas
                
                self.tableView.reloadData()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func GetCourseData() -> [CourseInfoItem]{
        
        var mergeData = [String:CourseInfoItem]()
        
        var retVal = [CourseInfoItem]()
        
        let con = GetCommonConnect("test.emba.ntu.edu.tw")
        var err : DSFault!
        
        let rsp = con.SendRequest("main.QueryCourseInfo", bodyContent: "", &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
            return retVal
        }
        
        var xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        } catch _ {
            xml = nil
        }
        
        if let courses = xml?.root["Response"]["Course"].all{
            
            for course in courses{
                
                let SchoolYear = course["SchoolYear"].stringValue
                let Semester = course["Semester"].stringValue
                let CourseID = course["CourseID"].stringValue
                let CourseName = course["CourseName"].stringValue
                let CourseType = course["CourseType"].stringValue
                let DeptName = course["DeptName"].stringValue
                let SubjectCode = course["SubjectCode"].stringValue
                let SubjectName = course["SubjectName"].stringValue
                let CourseCount = course["CourseCount"].stringValue
                let Syllabus = course["Syllabus"].stringValue
                
                var Credit = 0
                
                if let credit = Int(course["Credit"].stringValue){
                    Credit = credit
                }
                
                var Teachers = [String]()
                var Assistants = [String]()
                
                if let teachers = course["CourseTeacher"]["Teacher"].all{
                    
                    for teacher in teachers{
                        
                        let prefix = teacher["Perfix"].stringValue
                        let teacheName = teacher["TeacherName"].stringValue
                        
                        if prefix == "教師"{
                            Teachers.append(teacheName)
                        }else{
                            Assistants.append(teacheName)
                        }
                    }
                }
                
                let sysm = SemesterItem(SchoolYear: SchoolYear,Semester: Semester)
                
                let course = CourseInfoItem(CourseID: CourseID, CourseName: CourseName, Credit: Credit, CourseType: CourseType, DeptName: DeptName, SubjectCode: SubjectCode, SubjectName: SubjectName, Teachers: Teachers, Assistants : Assistants, Semester: sysm,StudentCount : CourseCount.intValue, Syllabus : Syllabus)
                
                if let _ = mergeData[course.CourseID]{
                    mergeData[course.CourseID]!.Teachers += course.Teachers
                    mergeData[course.CourseID]!.Assistants += course.Assistants
                }
                else{
                    mergeData[course.CourseID] = course
                }
                
            }
        }
        
        retVal += mergeData.values
        
        return retVal.sort({$0.Semester > $1.Semester})
    }
    
    func ToggleSideMenu(){
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self._DisplayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = self._DisplayData[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseInfoCell") as! CourseInfoCell
        
        cell.CourseName.text = data.CourseName
        
        let subjectCode = data.SubjectCode
        
        let subjectType = data.CourseType.isEmpty ? data.CourseType : " / " + data.CourseType
        let subjectCredit = " / \(data.Credit) 學分"
        
        cell.SubjectCode.text = subjectCode + subjectType + subjectCredit
        
        cell.CourseType.text = data.DeptName
        cell.CourseTeacher.text = data.Teachers.joinWithSeparator(",")
        
        cell.StudentCount.text = "人數\n\(data.StudentCount)"
        
        cell.Semester.text = data.Semester.SchoolYear + " " + CovertSemesterText(data.Semester.Semester)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = self._DisplayData[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("CourseDetailViewCtrl") as! CourseDetailViewCtrl
        
        nextView.CourseInfoItemData = data
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    //Mark : SearchBar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        
        Search(searchBar.text!)
    }
    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        Search(searchText)
//    }
    
    func Search(searchText:String){
        
        if searchText == "" {
            self._DisplayData = self._Datas
        }
        else{
            
            var searchTexts = searchText.componentsSeparatedByString(" ")
            
            //First search : searchTexts[0] should has value
            var results = GetSearchResult(self._Datas, text: searchTexts[0])
            
            //Second search
            for text in searchTexts{
                
                if text == searchTexts.first || text.isEmpty{
                    continue
                }
                
                results = GetSearchResult(results, text: text)

            }
            
            self._DisplayData = results
        }
        
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        
        self.tableView.reloadData()
        
    }
    
    func GetSearchResult(sources:[CourseInfoItem],text:String) -> [CourseInfoItem]{
        
        let founds = sources.filter({ course in
            
            if let _ = course.CourseName.lowercaseString.rangeOfString(text.lowercaseString){
                return true
            }
            
            if let _ = course.CourseType.lowercaseString.rangeOfString(text.lowercaseString){
                return true
            }
            
            if let _ = course.DeptName.lowercaseString.rangeOfString(text.lowercaseString){
                return true
            }
            
            if let _ = course.SubjectCode.lowercaseString.rangeOfString(text.lowercaseString){
                return true
            }
            
            if course.Teachers.count > 0{
                
                if let _ = course.Teachers[0].lowercaseString.rangeOfString(text.lowercaseString){
                    return true
                }
            }
            
            if let _ = course.Semester.SchoolYear.lowercaseString.rangeOfString(text.lowercaseString){
                return true
            }
            
            return course.Semester.Semester == CovertSemesterText(text)
            
        })
        
        return founds
    }
    
}

struct CourseInfoItem {
    var CourseID:String
    var CourseName:String
    var Credit:Int
    var CourseType:String
    var DeptName:String
    var SubjectCode:String
    var SubjectName:String
    var Teachers:[String]
    var Assistants:[String]
    var Semester:SemesterItem
    var StudentCount : Int
    var Syllabus : String
}