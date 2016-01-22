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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 51.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
        
        if !StudentData.Phone.SmsPhone.isEmpty{
            _displayData.append(DisplayItem(Title: "行動電話", Value: StudentData.Phone.SmsPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        }
        
        if !StudentData.Phone.PermanentPhone.isEmpty{
            _displayData.append(DisplayItem(Title: "家用電話", Value: StudentData.Phone.PermanentPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        }
        
        if !StudentData.Phone.ContactPhone.isEmpty{
            _displayData.append(DisplayItem(Title: "聯絡電話", Value: StudentData.Phone.ContactPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        }
        
        if let address = GetAddress(StudentData.Address.MailingAddress) where !address.isEmpty{
           _displayData.append(DisplayItem(Title: "聯絡地址", Value: address, OtherInfo: "address", ColorAlarm: false))
        }
        
        if let address = GetAddress(StudentData.Address.PermanentAddress) where !address.isEmpty{
           _displayData.append(DisplayItem(Title: "住家地址", Value: address, OtherInfo: "address", ColorAlarm: false))
        }
        
        if let address = GetAddress(StudentData.Address.OtherAddress) where !address.isEmpty{
            _displayData.append(DisplayItem(Title: "其他地址", Value: address, OtherInfo: "address", ColorAlarm: false))
        }
        
        var index = 1
        for email in GetEmails(StudentData.Emails){
            
            if !email.isEmpty{
                
                _displayData.append(DisplayItem(Title: "電子郵件\(index)", Value: email, OtherInfo: "email", ColorAlarm: false))
                
                index++
            }
        }
    }
    
    func SetOtherInfo(){
        
        var 學歷 = [String]()
        
        for school in StudentData.Schools{
            
            var text = school.Name
            
            text += school.Department.isEmpty ? "" : "/" + school.Department
            
            if !text.isEmpty{
                學歷.append(text)
            }
        }
        
        if 學歷.count > 0{
            _displayData.append(DisplayItem(Title: "學歷", Value: 學歷.joinWithSeparator("\n"), OtherInfo: "", ColorAlarm: false))
        }
        
        var 經歷 = [String]()
        
        for company in StudentData.Companys{
            
            var text = company.Name
            
            text += company.Position.isEmpty ? "" : "/" + company.Position
            
            text += company.Status.isEmpty ? "" : "(" + company.Status + ")"
            
            if !text.isEmpty{
                經歷.append(text)
            }
        }
        
        if 經歷.count > 0{
            _displayData.append(DisplayItem(Title: "經歷", Value: 經歷.joinWithSeparator("\n"), OtherInfo: "", ColorAlarm: false))
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let data = _displayData[indexPath.row]
        
//        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
//        
//        if cell == nil{
//            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
//            cell?.textLabel?.numberOfLines = 0
//            cell?.detailTextLabel?.numberOfLines = 0
//        }
//        
//        cell?.textLabel?.text = data.Title
//        cell?.detailTextLabel?.text = data.Value
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentBasicInfoCell") as! StudentBasicInfoCell
        
        cell.Title.text = data.Title
        cell.Value.text = data.Value
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let data = _displayData[indexPath.row]
        
        switch data.OtherInfo{
            
        case "address" :
            
            let alert = UIAlertController(title: "繼續？", message: "即將開啟Apple map", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (okaction) -> Void in
                GoogleMap(data.Value)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            break
            
        case "phoneNumber" :
            DialNumber(data.Value)
            break
            
        case "email" :
            
            let alert = UIAlertController(title: "繼續？", message: "即將進行電子郵件編輯", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (okaction) -> Void in
                SendEmail(data.Value)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            break
            
        default:
            break
        }
    }
    
//    func AddToList(){
//        Global.Students.append(StudentData)
//        LockBtnEnableCheck()
//        
//        //存入catch
//        StudentCoreData.SaveCatchData(StudentData)
//    }
    
    func GetAddress(xmlString:String) -> String?{
        
        let xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: xmlString.dataValue)
        } catch _ {
            xml = nil
        }
        
        var retVal = ""
        
        if let addresses = xml?.root["Address"].all{
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
        
        return nil
    }
    
    func GetEmails(xmlString:String) -> [String]{
        
        var retVal = [String]()
        
        let xml: AEXMLDocument?
        do {
            xml = try AEXMLDocument(xmlData: xmlString.dataValue)
        } catch _ {
            xml = nil
        }
        
        if let email1 = xml?.root["email1"].stringValue where email1 != "element <email1> not found"{
            retVal.append(email1)
        }
        
        if let email2 = xml?.root["email2"].stringValue where email2 != "element <email2> not found"{
            retVal.append(email2)
        }
        
        if let email3 = xml?.root["email3"].stringValue where email3 != "element <email3> not found"{
            retVal.append(email3)
        }
        
        if let email4 = xml?.root["email4"].stringValue where email4 != "element <email4> not found"{
            retVal.append(email4)
        }
        
        if let email5 = xml?.root["email5"].stringValue where email5 != "element <email5> not found"{
            retVal.append(email5)
        }
        
        return retVal
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


