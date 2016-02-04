//
//  CourseDetailViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 11/6/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class CourseDetailViewCtrl: UIViewController {
    
    var CourseInfoItemData : CourseInfoItem!
    
    @IBOutlet weak var SubTitleView: UIView!
    @IBOutlet weak var EmbedView: UIView!
    @IBOutlet weak var Segment: UISegmentedControl!
    
    var ExpandBtn : UIBarButtonItem!
    
    @IBOutlet weak var CourseName: UILabel!
    @IBOutlet weak var SchoolYear: UILabel!
    @IBOutlet weak var Semester: UILabel!
    @IBOutlet weak var Type: UILabel!
    @IBOutlet weak var Credit: UILabel!
    @IBOutlet weak var Teacher: UILabel!
    @IBOutlet weak var Assistant: UILabel!
    
    let upArrow = UIImage(named: "Up 4-25.png")
    let downArrow = UIImage(named: "Down 4-25.png")
    
    var _lastSelectIndex = -1
    
    @IBOutlet weak var Height: NSLayoutConstraint!
    
    @IBAction func SegmentSelected(sender: AnyObject) {
        
        _lastSelectIndex = Segment.selectedSegmentIndex
        
        if Segment.selectedSegmentIndex == 0{
            
            let newController = self.storyboard?.instantiateViewControllerWithIdentifier("AttendStudentViewCtrl") as! AttendStudentViewCtrl
            
            newController.CourseInfoItemData = CourseInfoItemData
            
            ChangeContainerViewContent(newController)
        }
        else if Segment.selectedSegmentIndex == 1{
            
            let newController = self.storyboard?.instantiateViewControllerWithIdentifier("CourseTimeViewCtrl") as! CourseTimeViewCtrl
            
            newController.CourseInfoItemData = CourseInfoItemData
            
            ChangeContainerViewContent(newController)
        }
        else if Segment.selectedSegmentIndex == 2{
            
            let newController = self.storyboard?.instantiateViewControllerWithIdentifier("CourseCaseViewCtrl") as! CourseCaseViewCtrl
            
            newController.CourseInfoItemData = CourseInfoItemData
            
            ChangeContainerViewContent(newController)
        }
        else{
            
            let newController = self.storyboard?.instantiateViewControllerWithIdentifier("CourseWebViewCtrl") as! CourseWebViewCtrl
            
            newController.Url = CourseInfoItemData.Syllabus
            
            ChangeContainerViewContent(newController)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var pics = ["background.png","background5.png"]
//        let randomIndex = Int(arc4random_uniform(2))
        
        let background = UIImageView(image: UIImage(named: "背景圖片.jpg"))
        background.frame = SubTitleView.bounds
        //nback.contentMode = UIViewContentMode.ScaleAspectFill
        SubTitleView.insertSubview(background, atIndex: 0)
        
        ExpandBtn = UIBarButtonItem(image: upArrow, style: UIBarButtonItemStyle.Plain, target: self, action: "ChangeHeight")
        self.navigationItem.rightBarButtonItem = ExpandBtn
        
        CourseName.text = CourseInfoItemData.CourseName
        SchoolYear.text = CourseInfoItemData.Semester.SchoolYear
        Semester.text = CourseInfoItemData.Semester.Semester == "0" ? CovertSemesterText(CourseInfoItemData.Semester.Semester) : CourseInfoItemData.Semester.Semester
        Type.text = CourseInfoItemData.CourseType
        Credit.text = "\(CourseInfoItemData.Credit)"
        Teacher.text = CourseInfoItemData.Teachers.joinWithSeparator(",")
        Assistant.text = CourseInfoItemData.Assistants.joinWithSeparator(",")
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.navigationItem.title = ""
        
        if Segment.selectedSegmentIndex != _lastSelectIndex{
            SegmentSelected(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ChangeHeight(){
        SubTitleView.hidden = !SubTitleView.hidden
        Height.constant = SubTitleView.hidden ? 0 : 133
        ExpandBtn.image = SubTitleView.hidden ? downArrow : upArrow
    }
    
    func ChangeContainerViewContent(vc : UIViewController){
        
        childViewControllers.first?.removeFromParentViewController()
        
        addChildViewController(vc)
        
        for sub in EmbedView.subviews {
            sub.removeFromSuperview()
        }
        
        vc.view.frame = EmbedView.bounds
        
        EmbedView.addSubview(vc.view)
    }

    
    
}
