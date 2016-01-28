//
//  EmbaCourseViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 9/17/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class EmbaCourseViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,ContainerViewProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var progressTimer : ProgressTimer!
    
    var _Datas = [CourseScoreItem]()
    
    var StudentData : EmbaStudent!
    
    var ParentNavigationItem : UINavigationItem?
    
    let CheckImage = UIImage(named: "Checked-32.png")
    let NoneImage = UIImage()
    
    var HerderTag = "embaHeader"
    
    var TotalCourse = 0
    var TotalCredits = 0
    var AchieveCredits = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let data = self.AddHeaderData(self.GetData())
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.progressTimer.StopProgress()
                
                self._Datas = data
                self.CountCredits()
                
                if self._Datas.count == 0{
                    self.noDataLabel.hidden = false
                }
                else{
                    self.noDataLabel.hidden = true
                }
                
                self.tableView.reloadData()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.textAlignment = NSTextAlignment.Right
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        if self._Datas.count > 0{
            return "課程 : \(TotalCourse) 已修學分 : \(AchieveCredits) / \(TotalCredits)"
        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _Datas.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        let data = _Datas[indexPath.row]
        
        if data.CourseName == HerderTag{
            return 30
        }
        
        return 74
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _Datas[indexPath.row]
        
        switch data.CourseName{
            
        case HerderTag:
            
            var cell = tableView.dequeueReusableCellWithIdentifier(HerderTag)
            
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: HerderTag)
                cell?.backgroundColor = UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
            }
            
            cell?.textLabel?.text = data.Semester.Description
            
            return cell!
            
        default:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("EmbaCourseScoreCell") as! EmbaCourseScoreCell
            
            cell.CourseName.text = data.CourseName
            cell.CourseInfo.text = data.CourseType.isEmpty ? "\(data.Credit) 學分" : data.CourseType + " / \(data.Credit) 學分"
            cell.CourseTeachers.text = data.Teachers.joinWithSeparator(",")
            cell.CourseScore.text = data.Score
            cell.CheckImage.image = data.IsPass ? CheckImage : NoneImage
            
            return cell
            
        }
    }
    
    func GetData() -> [CourseScoreItem]{
        
        var retVal = [CourseScoreItem]()
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
        let rsp = con.SendRequest("main.QueryStudentScore", bodyContent: "<Request><Condition><Or><StudentID>\(StudentData.Id)</StudentID></Or></Condition></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self, title: "成績查詢發生錯誤", msg: "")
        }
        
        var xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        } catch _ {
            xml = nil
        }
        
        var mergeList = [String]()
        
        if let scores = xml?.root["Response"]["Score"].all{
            
            for score in scores{
                
                let SchoolYear = score["SchoolYear"].stringValue
                let Semester = score["Semester"].stringValue
                let IsPass = score["IsPass"].stringValue == "t" ? true : false
                let IsRequired = score["IsRequired"].stringValue == "t" ? true : false
                let SubjectName = score["SubjectName"].stringValue
                let CourseType = score["CourseType"].stringValue
                let Score = score["Score"].stringValue
                
                var Credit : Int = 0
                if let credit = Int(score["Credit"].stringValue){
                    Credit = credit
                }
                
                var Teachers = [String]()
                
                if let teachers = score["Teachers"]["Teacher"].all{
                    
                    for teacher in teachers{
                        
                        let teacherName = teacher["TeacherName"].stringValue
                        
                        if !teacherName.isEmpty{
                            Teachers.append(teacherName)
                        }
                    }
                }
                
                let sysm = SemesterItem(SchoolYear: SchoolYear,Semester: Semester)
                
                let course = CourseScoreItem(Semester: sysm, CourseName: SubjectName, CourseType: CourseType, Score: Score, Teachers: Teachers, Credit: Credit, IsPass: IsPass, IsRequired: IsRequired)
                
                if !course.CourseName.isEmpty{
                    
                    let key = course.Semester.Description + "#" + course.CourseName
                    
                    if !mergeList.contains(key){
                        mergeList.append(key)
                        retVal.append(course)
                    }
                    
                }
                
            }
        }
        
        //retVal.sortInPlace({$0.Semester > $1.Semester})
        
        return retVal.sort({$0.Semester > $1.Semester})
    }
    
    func AddHeaderData(sourceData:[CourseScoreItem]) -> [CourseScoreItem]{
        
        var retVal = [CourseScoreItem]()
        
        var lastSemester:SemesterItem?
        
        for course in sourceData{
            
            if lastSemester != course.Semester{
                
                lastSemester = course.Semester
                
                retVal.append(CourseScoreItem(Semester: lastSemester, CourseName: HerderTag, CourseType: "", Score: "", Teachers: [String](), Credit: 0, IsPass: false, IsRequired: false))
            }
            
            retVal.append(course)
        }
        
        return retVal
    }
    
    func CountCredits(){
        
        TotalCourse = 0
        TotalCredits = 0
        AchieveCredits = 0
        
        for course in self._Datas{
            TotalCredits += course.Credit
            AchieveCredits += course.IsPass ? course.Credit : 0
            TotalCourse += course.CourseName == HerderTag ? 0 : 1
        }
    }
    
}

struct CourseScoreItem{
    var Semester:SemesterItem!
    var CourseName:String
    var CourseType:String
    var Score:String
    var Teachers:[String]
    var Credit:Int
    var IsPass:Bool
    var IsRequired:Bool
}
