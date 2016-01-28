//
//  CourseCaseViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 11/9/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class CourseCaseViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var CourseInfoItemData : CourseInfoItem!
    
    var TeacherData : EmbaTeacher!
    
    var Datas = [CaseItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        Datas = GetData()
        
        if Datas.count == 0{
            Datas.append(CaseItem(TeacherName: "查無使用個案", EnglishCaseName: "", ChineseCaseName: ""))
        }
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Datas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = Datas[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CourseCaseCell")
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CourseCaseCell")
            cell?.textLabel?.font = UIFont.systemFontOfSize(16.0)
            cell?.textLabel?.textColor = UIColor.darkGrayColor()
            cell?.textLabel?.numberOfLines = 0
        }
        
        var text = data.ChineseCaseName.isEmpty ? data.EnglishCaseName : data.ChineseCaseName
        
        text += data.TeacherName == "查無使用個案" ? data.TeacherName : " / " + data.TeacherName
        
        cell?.textLabel?.text = text
        
        return cell!
    }
    
    func GetData() -> [CaseItem]{
        
        var retVal = [CaseItem]()
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
        var body = ""
        
        if TeacherData != nil{
            body = "<Request><Condition><RefTeacherID>\(TeacherData.Id)</RefTeacherID></Condition></Request>"
        }
        else{
            body = "<Request><Condition><RefCourseID>\(CourseInfoItemData.CourseID)</RefCourseID></Condition></Request>"
        }
        
        let rsp = con.SendRequest("main.QueryCaseUsage", bodyContent: body, &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
            return retVal
        }
        
        var xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: rsp.dataValue)
        } catch _ {
            xml = nil
            return retVal
        }
        
        if let cases = xml?.root["Response"]["CaseUsage"].all{
            for c in cases{
                
                let teacher_Name = c["Teacher_Name"].stringValue
                let chinese_CaseName = c["Chinese_CaseName"].stringValue
                let english_CaseName = c["English_CaseName"].stringValue
                
                let ci = CaseItem(TeacherName: teacher_Name, EnglishCaseName: english_CaseName, ChineseCaseName: chinese_CaseName)
                
                retVal.append(ci)
            }
        }
        
        return retVal
        
    }
}

struct CaseItem {
    var TeacherName : String
    var EnglishCaseName : String
    var ChineseCaseName : String
}
