//
//  StudentInfoViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/29/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentInfoViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,ContainerViewProtocol {
    
    var StudentData:EmbaStudent!
    var ParentNavigationItem : UINavigationItem?
    var AddBtn : UIBarButtonItem!
    
    var _displayData = [DisplayItem]()
    
    var IsBasicPage = true
    var MustClear = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //self.automaticallyAdjustsScrollViewInsets = true
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "加入清單", style: UIBarButtonItemStyle.Plain, target: self, action: "AddToList")
        AddBtn = UIBarButtonItem(image: UIImage(named: "Add User-25.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "AddToList")
        //ParentNavigationItem?.rightBarButtonItems?.append(AddBtn)
        
        if IsBasicPage{
            SetBasicInfo()
        }
        else{
            SetOtherInfo()
        }
        
        if MustClear{
            ClearAll()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
//    override func viewWillAppear(animated: Bool) {
//        LockBtnEnableCheck()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetBasicInfo(){
        _displayData.append(DisplayItem(Title: "所屬班級", Value: StudentData.ClassName, OtherInfo: "", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "行動電話", Value: StudentData.Phone.SmsPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "戶籍電話", Value: StudentData.Phone.PermanentPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "聯絡電話", Value: StudentData.Phone.ContactPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "郵遞地址", Value: GetAddress(StudentData.Address.MailingAddress), OtherInfo: "address", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "戶籍地址", Value: GetAddress(StudentData.Address.PermanentAddress), OtherInfo: "address", ColorAlarm: false))
        _displayData.append(DisplayItem(Title: "其他地址", Value: GetAddress(StudentData.Address.OtherAddress), OtherInfo: "address", ColorAlarm: false))
        
        var index = 1
        for email in GetEmails(StudentData.Emails){
            _displayData.append(DisplayItem(Title: "電子郵件\(index)", Value: email, OtherInfo: "", ColorAlarm: false))
            index++
        }
    }
    
    func SetOtherInfo(){
        
        let school = StudentData.Department.isEmpty ? StudentData.SchoolName : StudentData.SchoolName + " " + StudentData.Department
        _displayData.append(DisplayItem(Title: "學歷", Value: school, OtherInfo: "", ColorAlarm: false))
        
        var index = 1
        for company in StudentData.Companys{
            _displayData.append(DisplayItem(Title: "工作經歷\(index) / 公司", Value: company.Name, OtherInfo: "", ColorAlarm: false))
            _displayData.append(DisplayItem(Title: "工作經歷\(index) / 職稱", Value: company.Position, OtherInfo: "", ColorAlarm: false))
        }
        
    }
    
    func ClearAll(){
        _displayData = [DisplayItem]()
        _displayData.append(DisplayItem(Title: "", Value: "沒有課程資料", OtherInfo: "", ColorAlarm: false))
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let data = _displayData[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentBasicInfoCell") as! StudentBasicInfoCell
        
        cell.Title.text = data.Title
        cell.Value.text = data.Value
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let data = _displayData[indexPath.row]
        
        if data.OtherInfo == "phoneNumber"{
            DialNumber(data.Value)
        }
        
        if data.OtherInfo == "address"{
            GoogleMap(data.Value)
        }
    }
    
//    func AddToList(){
//        Global.Students.append(StudentData)
//        LockBtnEnableCheck()
//        
//        //存入catch
//        StudentCoreData.SaveCatchData(StudentData)
//    }
    
    func GetAddress(xmlString:String) -> String{
        var nserr : NSError?
        let xml = AEXMLDocument(xmlData: xmlString.dataValue, error: &nserr)
        
        var retVal = ""
        
        if let addresses = xml?.root["AddressList"]["Address"].all{
            for address in addresses{
                
                let zipCode = address["ZipCode"].stringValue == "" ? "" : "[" + address["ZipCode"].stringValue + "]"
                let county = address["County"].stringValue
                let town = address["Town"].stringValue
                let detailAddress = address["DetailAddress"].stringValue
                
                retVal = zipCode + county + town + detailAddress
                
                if retVal != ""{
                    return retVal
                }
            }
        }
        
        return "查無地址資料"
    }
    
    func GetEmails(xmlString:String) -> [String]{
        
        var retVal = [String]()
        
        var nserr : NSError?
        let xml = AEXMLDocument(xmlData: xmlString.dataValue, error: &nserr)
        
        if let email1 = xml?.root["email1"].stringValue{
            retVal.append(email1)
        }
        
        if let email2 = xml?.root["email2"].stringValue{
            retVal.append(email2)
        }
        
        if let email3 = xml?.root["email3"].stringValue{
            retVal.append(email3)
        }
        
        if let email4 = xml?.root["email4"].stringValue{
            retVal.append(email4)
        }
        
        if let email5 = xml?.root["email5"].stringValue{
            retVal.append(email5)
        }
        
        return retVal
    }
    
    func DialNumber(phoneNumber:String){
        if let urlEncoding = phoneNumber.UrlEncoding{
            let phone = "telprompt://" + urlEncoding
            let url:NSURL = NSURL(string:phone)!
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func GoogleMap(address:String){
        
        if let urlEncoding = address.UrlEncoding{
            
            let appleMap = "http://maps.apple.com/?q=\(urlEncoding)"
            let appleUrl:NSURL = NSURL(string:appleMap)!
            
            let alert = UIAlertController(title: "繼續？", message: "即將開啟Apple map", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (okaction) -> Void in
                UIApplication.sharedApplication().openURL(appleUrl)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
//            let mapLink = "comgooglemapsurl://www.google.com.tw/maps/place/" + urlEncoding
//            let url:NSURL = NSURL(string:mapLink)!
            
//            if UIApplication.sharedApplication().canOpenURL(url) {
//                UIApplication.sharedApplication().openURL(url)
//            }
//            else{
//                var alert = UIAlertController(title: "繼續?", message: "需要安裝Google Map才能進行", preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (okaction) -> Void in
//                    let itunes = "https://itunes.apple.com/app/id585027354"
//                    let itunesUrl:NSURL = NSURL(string:itunes)!
//                    UIApplication.sharedApplication().openURL(itunesUrl)
//                }))
//                
//                self.presentViewController(alert, animated: true, completion: nil)
//            }
        }
    }
    
//    func LockBtnEnableCheck(){
//        if contains(Global.Students, StudentData){
//            AddBtn.enabled = false
//        }
//        else{
//            AddBtn.enabled = true
//        }
//    }
}
