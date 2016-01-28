//
//  TeacherSearchViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 2016/1/22.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class TeacherSearchViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    var _TeacherDatas = [EmbaTeacher]()
    var _DisplayTeachers = [EmbaTeacher]()
    
    var _CurrentTag : Tag!
    
    var _TagDic = [String:[Tag]]()
    
    @IBOutlet weak var TagBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var progressTimer : ProgressTimer!
    
    @IBAction func TagBtnClick(sender: AnyObject) {
        
        //Action 1
        let menu1 = UIAlertController(title: "請選擇群組", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu1.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for key in _TagDic.keys{
            
            menu1.addAction(UIAlertAction(title: key, style: UIAlertActionStyle.Default, handler: { (act1) -> Void in
                
                //Action 2
                
                let menu2 = UIAlertController(title: "請選擇類別", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
                
                menu2.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
                
                if let tags = self._TagDic[key]{
                    
                    for tag in tags{
                        
                        menu2.addAction(UIAlertAction(title: tag.Name, style: UIAlertActionStyle.Default, handler: { (act1) -> Void in
                            
                            self._CurrentTag = tag
                            
                            self.TagBtn.setTitle(tag.Prefix + "-" + tag.Name, forState: UIControlState.Normal)
                            
                            self.GetDataByTag()
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 104
        tableView.rowHeight = UITableViewAutomaticDimension
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "教師資料"
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if self._TagDic.count > 0{
            return
        }
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let tags = self.GetTags()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self._TagDic = tags
                self.progressTimer.StopProgress()
            })
        })
    }
    
    func GetDataByTag(){
        
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let datas = self.GetTeacherDataByTag()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self._TeacherDatas = datas
                self._DisplayTeachers = datas
                self.progressTimer.StopProgress()
                
                self.tableView.reloadData()
            })
        })
    }
    
    func GetDataByValue(value:String){
        
        self.TagBtn.setTitle("按類別查詢", forState: UIControlState.Normal)
        
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let datas = self.GetTeacherDataByValues(value)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self._TeacherDatas = datas
                self._DisplayTeachers = datas
                self.progressTimer.StopProgress()
                
                self.tableView.reloadData()
            })
        })
    }
    
    func ToggleSideMenu(){
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func GetTags() -> [String:[Tag]]{
        
        var mergeData = [String:[Tag]]()
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
        let rsp = con.SendRequest("main.QueryTeacherTAG", bodyContent: "", &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
            return mergeData
        }
        
        if let xml = try? AEXMLDocument(xmlData: rsp.dataValue){
            
            if let tags = xml.root["Response"]["Tag"].all{
                
                for tag in tags{
                    
                    let id = tag["TagID"].stringValue
                    let tagPrefix = tag["TagPrefix"].stringValue
                    let tagName = tag["TagName"].stringValue
                    
                    let t = Tag(Id: id, Prefix: tagPrefix, Name: tagName)
                    
                    if mergeData[t.Prefix] == nil{
                        mergeData[t.Prefix] = [Tag]()
                    }
                    
                    if !mergeData[t.Prefix]!.contains(t){
                        mergeData[t.Prefix]?.append(t)
                    }
                    
                }
            }
        }
        
        return mergeData
    }
    
    func GetTeacherDataByTag() -> [EmbaTeacher]{
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
        let rsp = con.SendRequest("main.QueryTeacher", bodyContent: "<Request><Condition><Ref_Tag_id>\(_CurrentTag.Id)</Ref_Tag_id></Condition></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
            return [EmbaTeacher]()
        }
        
        return ParseData(rsp)
    }
    
    func GetTeacherDataByValues(value:String) -> [EmbaTeacher]{
        
        let con = GetCommonConnect(Global.DSAName)
        var err : DSFault!
        
        let rsp = con.SendRequest("main.QueryTeacher", bodyContent: "<Request><Condition><Or><TeacherName>\(value)</TeacherName><StLoginName>\(value)</StLoginName><Email>\(value)</Email><Mobil>\(value)</Mobil><OtherPhone>\(value)</OtherPhone><Phone>\(value)</Phone><MajorWorkPlace>\(value)</MajorWorkPlace></Or></Condition></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self,title: "查詢發生錯誤",msg: err.message)
            return [EmbaTeacher]()
        }
        
        return ParseData(rsp)
    }
    
    func ParseData(rsp:String) -> [EmbaTeacher]{
        
        var retVal = [EmbaTeacher]()
        
        if let xml = try? AEXMLDocument(xmlData: rsp.dataValue){
            
            if let teachers = xml.root["Response"]["TeacherRecord"].all{
                
                for teacher in teachers{
                    
                    let Id = teacher["Ref_Teacher_Id"].stringValue
                    let TeacherName = teacher["TeacherName"].stringValue
                    let Nickname = teacher["Nickname"].stringValue
                    let Gender = teacher["Gender"].stringValue
                    let IdNumber = teacher["IdNumber"].stringValue
                    let ContactPhone = teacher["ContactPhone"].stringValue
                    let Email = teacher["Email"].stringValue
                    let StLoginName = teacher["StLoginName"].stringValue
                    let Birthday = teacher["Birthday"].stringValue
                    let Address = teacher["Address"].stringValue
                    let Mobil = teacher["Mobil"].stringValue
                    let OtherPhone = teacher["OtherPhone"].stringValue
                    let Phone = teacher["Phone"].stringValue
                    let MajorWorkPlace = teacher["MajorWorkPlace"].stringValue
                    let Research = teacher["Research"].stringValue
                    let Memo = teacher["Memo"].stringValue
                    let EnglishName = teacher["EnglishName"].stringValue
                    let EmployeeNo = teacher["EmployeeNo"].stringValue
                    let NtuSystemNo = teacher["NtuSystemNo"].stringValue
                    let WebSiteUrl = teacher["WebSiteUrl"].stringValue
                    
                    let Photo = GetImageFromBase64String(teacher["Photo"].stringValue, defaultImg: UIImage(named: "User-100.png"))
                    
                    var Tags = [Tag]()
                    
                    if let tags = teacher["TAG"]["TagRecord"].all{
                        
                        for tag in tags{
                            
                            let TagName = tag["TagName"].stringValue
                            let TagPerfix = tag["TagPerfix"].stringValue
                            
                            let t = Tag(Id: "", Prefix: TagName, Name: TagPerfix)
                            
                            if !Tags.contains(t){
                                Tags.append(t)
                            }
                            
                        }
                    }
                    
                    let et = EmbaTeacher(Id: Id, TeacherName: TeacherName, Nickname: Nickname, Gender: Gender, IdNumber: IdNumber, ContactPhone: ContactPhone, Email: Email, StLoginName: StLoginName, Birthday: Birthday, Address: Address, Mobil: Mobil, OtherPhone: OtherPhone, Phone: Phone, MajorWorkPlace: MajorWorkPlace, Research: Research, Memo: Memo, EnglishName: EnglishName, EmployeeNo: EmployeeNo, NtuSystemNo: NtuSystemNo, WebSiteUrl: WebSiteUrl, Photo: Photo!, Tags: Tags)
                    
                    retVal.append(et)
                }
            }
        }
        
        return retVal
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _DisplayTeachers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _DisplayTeachers[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EmbaTeacherCell") as! EmbaTeacherCell
        
        cell.Photo.image = data.Photo
        
        var name = data.TeacherName
        
        if name.isEmpty{
            name += data.EnglishName
        }
        else{
            name += data.EnglishName.isEmpty ? data.EnglishName : " / " + data.EnglishName
        }
        
        cell.Name.text = name
        
        var info1 = data.Birthday
        
        if info1.isEmpty{
            info1 += data.Gender
        }
        else{
            info1 += data.Gender.isEmpty ? data.Gender : " / " + data.Gender
        }
        
        var info2 = data.MajorWorkPlace
        
        if info2.isEmpty{
            info2 += data.ContactPhone
        }
        else{
            
            var phone = data.ContactPhone
            
            if phone.isEmpty{
                phone = data.Mobil
            }
            
            if phone.isEmpty{
                phone = data.Phone
            }
            
            info2 += phone.isEmpty ? phone : " / " + phone
        }
        
        cell.Info.text = info1 + "\n" + info2
        
        cell.Tag1.hidden = true
        if data.Tags.count > 0{
            cell.Tag1.text = data.Tags[0].Prefix + "-" + data.Tags[0].Name
            cell.Tag1.hidden = false
        }
        
        cell.Tag2.hidden = true
        if data.Tags.count > 1{
            cell.Tag2.text = data.Tags[1].Prefix + "-" + data.Tags[1].Name
            cell.Tag2.hidden = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = _DisplayTeachers[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("TeacherDetailViewCtrl") as! TeacherDetailViewCtrl
        
        nextView.TeacherData = data
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    //Mark : SearchBar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        
        self.GetDataByValue(searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        Search(searchText)
    }
    
    func Search(searchText:String){
        
        if searchText.isEmpty {
            self._DisplayTeachers = self._TeacherDatas
        }
        else{
            
            let founds = self._TeacherDatas.filter({ t in
                
                let lowerText = searchText.lowercaseString
                
                if let _ = t.TeacherName.lowercaseString.rangeOfString(lowerText){
                    return true
                }
                
                if let _ = t.EnglishName.lowercaseString.rangeOfString(lowerText){
                    return true
                }
                
                if let _ = t.StLoginName.lowercaseString.rangeOfString(lowerText){
                    return true
                }
                
                if let _ = t.Email.lowercaseString.rangeOfString(lowerText){
                    return true
                }
                
                if let _ = t.EmployeeNo.lowercaseString.rangeOfString(lowerText){
                    return true
                }
                
                if let _ = t.NtuSystemNo.lowercaseString.rangeOfString(lowerText){
                    return true
                }
                
                if let _ = t.ContactPhone.lowercaseString.rangeOfString(lowerText){
                    return true
                }
                
                if let _ = t.MajorWorkPlace.lowercaseString.rangeOfString(lowerText){
                    return true
                }
                
                return false
            })
            
            self._DisplayTeachers = founds
        }
        
        self.tableView.reloadData()
    }
}

struct EmbaTeacher{
    var Id : String
    var TeacherName : String
    var Nickname : String
    var Gender : String
    var IdNumber : String
    var ContactPhone : String
    var Email : String
    var StLoginName : String
    var Birthday : String
    var Address : String
    var Mobil : String
    var OtherPhone : String
    var Phone : String
    var MajorWorkPlace : String
    var Research : String
    var Memo : String
    var EnglishName : String
    var EmployeeNo : String
    var NtuSystemNo : String
    var WebSiteUrl : String
    var Photo : UIImage
    var Tags : [Tag]
}

struct Tag : Equatable{
    var Id : String
    var Prefix : String
    var Name : String
}

func ==(lhs: Tag, rhs: Tag) -> Bool {
    
    if lhs.Id.isEmpty && rhs.Id.isEmpty{
        return lhs.Prefix == rhs.Prefix && lhs.Name == rhs.Name
    }
    else{
        return lhs.Id == rhs.Id
    }
}
