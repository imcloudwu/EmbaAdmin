//
//  TeacherInfoViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 2016/1/25.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class TeacherInfoViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var TeacherData : EmbaTeacher!
    var _DisplayDatas = [DisplayItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 51.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if !TeacherData.Gender.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "性別", Value: TeacherData.Gender, OtherInfo: "", ColorAlarm: false))
        }
        
        if !TeacherData.Nickname.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "暱稱", Value: TeacherData.Nickname, OtherInfo: "", ColorAlarm: false))
        }
        
        if !TeacherData.EmployeeNo.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "人事編號", Value: TeacherData.EmployeeNo, OtherInfo: "", ColorAlarm: false))
        }
        
        if !TeacherData.NtuSystemNo.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "教師編號", Value: TeacherData.NtuSystemNo, OtherInfo: "", ColorAlarm: false))
        }
        
        if !TeacherData.Research.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "研究室位置", Value: TeacherData.Research, OtherInfo: "", ColorAlarm: false))
        }
        
        if !TeacherData.Phone.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "研究室電話", Value: TeacherData.Phone, OtherInfo: "phoneNumber", ColorAlarm: false))
        }
        
        if !TeacherData.ContactPhone.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "聯絡電話", Value: TeacherData.ContactPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        }
        
        if !TeacherData.Mobil.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "行動電話", Value: TeacherData.Mobil, OtherInfo: "phoneNumber", ColorAlarm: false))
        }
        
        if !TeacherData.OtherPhone.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "其他電話", Value: TeacherData.OtherPhone, OtherInfo: "phoneNumber", ColorAlarm: false))
        }
        
        if !TeacherData.StLoginName.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "登入帳號", Value: TeacherData.StLoginName, OtherInfo: "email", ColorAlarm: false))
        }
        
        if !TeacherData.Email.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "電子郵件", Value: TeacherData.Email, OtherInfo: "email", ColorAlarm: false))
        }
        
        if !TeacherData.Address.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "戶籍地址", Value: TeacherData.Address, OtherInfo: "address", ColorAlarm: false))
        }
        
        if !TeacherData.Memo.isEmpty{
            _DisplayDatas.append(DisplayItem(Title: "備註", Value: TeacherData.Memo, OtherInfo: "", ColorAlarm: false))
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _DisplayDatas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _DisplayDatas[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EmbaTeacherInfoCell") as! EmbaTeacherInfoCell
        
        cell.titleLabel.text = data.Title
        
        cell.detailLabel.text = data.Value
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = _DisplayDatas[indexPath.row]
        
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
    
    
}
