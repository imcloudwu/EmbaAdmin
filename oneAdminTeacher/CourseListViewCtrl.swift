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
    
    let Literature = UIImage(named: "Literature-50.png")
    let Geometry = UIImage(named: "Geometry-50.png")
    
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
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            var data = self.GetCourseData()
            
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
        
        var retVal = [CourseInfoItem]()
        
        var con = GetCommonConnect("test.emba.ntu.edu.tw")
        var err : DSFault!
        
        var rsp = con.SendRequest("main.QueryCourseInfo", bodyContent: "", &err)
        
        if err != nil{
            ShowErrorAlert(self,"查詢發生錯誤",err.message)
        }
        
        var nserr:NSError?
        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
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
                
                var Credit = 0
                
                if let credit = course["Credit"].stringValue.toInt(){
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
                
                var sysm = SemesterItem(SchoolYear: SchoolYear,Semester: Semester)
                
                var course = CourseInfoItem(CourseID: CourseID, CourseName: CourseName, Credit: Credit, CourseType: CourseType, DeptName: DeptName, SubjectCode: SubjectCode, SubjectName: SubjectName, Teachers: Teachers, Assistants : Assistants, Semester: sysm,StudentCount : CourseCount.intValue)
                
                retVal.append(course)
            }
        }
        
        retVal.sort({$0.Semester > $1.Semester})
        
        return retVal
    }
    
    func ToggleSideMenu(){
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self._DisplayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = self._DisplayData[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CourseInfoCell") as! CourseInfoCell
        
        cell.CourseName.text = data.CourseName
        cell.SubjectCode.text = "課號: \(data.SubjectCode)"
        cell.CourseType.text = "類別: \(data.CourseType)"
        cell.CourseTeacher.text = "教師: " + ",".join(data.Teachers)
        
        cell.Icon.image = data.CourseType == "核心必修" ? Geometry : Literature
        
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
        
        Search(searchBar.text)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        Search(searchText)
    }
    
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
            
            if let a = course.CourseName.lowercaseString.rangeOfString(text.lowercaseString){
                return true
            }
            
            if let b = course.SubjectCode.lowercaseString.rangeOfString(text.lowercaseString){
                return true
            }
            
            if course.Teachers.count > 0{
                
                if let c = course.Teachers[0].lowercaseString.rangeOfString(text.lowercaseString){
                    return true
                }
            }
            
            if let d = course.Semester.SchoolYear.lowercaseString.rangeOfString(text.lowercaseString){
                return true
            }
            
            return course.Semester.Semester == CovertSemesterText(text)
            
//            switch text{
//                
//                case "上":
//                    return course.Semester.Semester == self.CovertSemesterText(text)
//                case "下":
//                    return course.Semester.Semester == self.CovertSemesterText(text)
//                case "夏":
//                    return course.Semester.Semester == self.CovertSemesterText(text)
//                default:
//                    return false
//            }
            
        })
        
        return founds
    }
    
}

struct CourseInfoItem{
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
}