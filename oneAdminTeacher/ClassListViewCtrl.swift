//
//  ClassListViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 2016/1/21.
//  Copyright © 2016年 ischool. All rights reserved.
//

//import UIKit
//
//class ClassListViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
//    
//    var toggleViewDelegate : ToggleViewDelegate!
//    
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var progressBar: UIProgressView!
//    
//    var progressTimer : ProgressTimer!
//    
//    var _ClassDatas = [EmbaClass]()
//    var _DisplayData = [EmbaClass]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        searchBar.delegate = self
//        
//        progressTimer = ProgressTimer(progressBar: progressBar)
//        
//        self.navigationItem.title = "全校班級"
//        
//        tableView.estimatedRowHeight = 56.0
//        tableView.rowHeight = UITableViewAutomaticDimension
//        
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        
//        toggleViewDelegate = ToggleViewDelegate(searchBar: searchBar)
//        
//        self.navigationItem.leftBarButtonItem = toggleViewDelegate.ToggleBtn
//        
//        if self._ClassDatas.count > 0{
//            return
//        }
//        
//        progressTimer.StartProgress()
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
//            
//            let classData = self.GetClassData()
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                
//                self._ClassDatas = classData
//                self._DisplayData = self._ClassDatas
//                
//                self.tableView.reloadData()
//                
//                self.progressTimer.StopProgress()
//            })
//        })
//        
//    }
//    
//    func GetClassData() -> [EmbaClass]{
//        
//        var retVal = [EmbaClass]()
//        
//        let con = GetCommonConnect(Global.DSAName)
//        var err : DSFault!
//        
//        let rsp = con.SendRequest("main.GetAllClass", bodyContent: "", &err)
//        
//        if err != nil{
//            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
//            return retVal
//        }
//        
//        if let xml = try? AEXMLDocument(xmlData: rsp.dataValue){
//            
//            if let classes = xml.root["Response"]["Class"].all{
//                
//                for c in classes{
//                    
//                    let classId = c["ClassID"].stringValue
//                    let className = c["ClassName"].stringValue
//                    let gradeYear = c["GradeYear"].stringValue
//                    let refTeacherId = c["RefTeacherId"].stringValue
//                    let teacherName = c["TeacherName"].stringValue
//                    let teacherAccount = c["TeacherAccount"].stringValue
//                    
//                    let ec = EmbaClass(Id: classId, ClassName: className, GradeYear: gradeYear, RefTeacherId: refTeacherId, TeacherName: teacherName, TeacherAccount: teacherAccount)
//                    
//                    retVal.append(ec)
//                }
//            }
//        }
//        
//        return retVal.sort({ $0.GradeYear.intValue > $1.GradeYear.intValue})
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        return _DisplayData.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
//        
//        let data = _DisplayData[indexPath.row]
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("EmbaClassCell") as! EmbaClassCell
//        
//        cell.GradeYear.text = data.GradeYear
//        
//        cell.ClassName.text = data.ClassName
//        
//        var info = data.TeacherName
//        
//        if info.isEmpty{
//            info += data.TeacherAccount
//        }
//        else{
//            info += data.TeacherAccount.isEmpty ? data.TeacherAccount : "\n" + data.TeacherAccount
//        }
//        
//        cell.OtherInfo.text = info
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
//        
//        let data = _DisplayData[indexPath.row]
//        
//        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentSearchViewCtrl") as! StudentSearchViewCtrl
//        
//        nextView.ClassData = data
//        
//        self.navigationController?.pushViewController(nextView, animated: true)
//    }
//    
//    //Mark : SearchBar
//    func searchBarSearchButtonClicked(searchBar: UISearchBar){
//        searchBar.resignFirstResponder()
//        self.view.endEditing(true)
//        
//        Search(searchBar.text!)
//    }
//    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        Search(searchText)
//    }
//    
//    func Search(searchText:String){
//        
//        if searchText == "" {
//            self._DisplayData = self._ClassDatas
//        }
//        else{
//            
//            var searchTexts = searchText.componentsSeparatedByString(" ")
//            
//            //First search : searchTexts[0] should has value
//            var results = GetSearchResult(self._ClassDatas, text: searchTexts[0])
//            
//            //Second search
//            for text in searchTexts{
//                
//                if text == searchTexts.first || text.isEmpty{
//                    continue
//                }
//                
//                results = GetSearchResult(results, text: text)
//                
//            }
//            
//            self._DisplayData = results
//        }
//        
//        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
//        
//        self.tableView.reloadData()
//        
//    }
//    
//    func GetSearchResult(sources:[EmbaClass],text:String) -> [EmbaClass]{
//        
//        let founds = sources.filter({ cls in
//            
//            if let _ = cls.ClassName.lowercaseString.rangeOfString(text.lowercaseString){
//                return true
//            }
//            
//            if let _ = cls.GradeYear.lowercaseString.rangeOfString(text.lowercaseString){
//                return true
//            }
//            
//            if let _ = cls.TeacherName.lowercaseString.rangeOfString(text.lowercaseString){
//                return true
//            }
//            
//            if let _ = cls.TeacherAccount.lowercaseString.rangeOfString(text.lowercaseString){
//                return true
//            }
//            
//            return false
//        })
//        
//        return founds
//    }
//}


