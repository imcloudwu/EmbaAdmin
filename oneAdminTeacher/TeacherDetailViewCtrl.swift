//
//  TeacherDetailViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 2016/1/25.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class TeacherDetailViewCtrl: UIViewController {
    
    var TeacherData : EmbaTeacher!
    
    let upArrow = UIImage(named: "Up 4-25.png")
    let downArrow = UIImage(named: "Down 4-25.png")
    
    var _expandBtn : UIBarButtonItem!
    
    var _mustFlipPhoto = true
    var _lastSegmentIndex = -1
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var photoImv: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var frameViewHeight: NSLayoutConstraint!
    
    @IBAction func segmentClick(sender: AnyObject) {
        
        if segment.selectedSegmentIndex == 0{
            
            let contentView = self.storyboard?.instantiateViewControllerWithIdentifier("TeacherInfoViewCtrl") as! TeacherInfoViewCtrl
            
            contentView.TeacherData = TeacherData
            
            ChangeContainerViewContent(contentView)
        }
        else if segment.selectedSegmentIndex == 1{
            
            let contentView = self.storyboard?.instantiateViewControllerWithIdentifier("CourseCaseViewCtrl") as! CourseCaseViewCtrl
            
            contentView.TeacherData = TeacherData
            
            ChangeContainerViewContent(contentView)
        }
        else if segment.selectedSegmentIndex == 2{
            
            let contentView = self.storyboard?.instantiateViewControllerWithIdentifier("CourseWebViewCtrl") as! CourseWebViewCtrl
            
            contentView.Url = TeacherData.WebSiteUrl
            
            ChangeContainerViewContent(contentView)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = UIImageView(image: UIImage(named: "背景圖片.jpg"))
        background.frame = frameView.bounds
        frameView.insertSubview(background, atIndex: 0)
        self.navigationController?.navigationBar.topItem?.title = TeacherData.TeacherName
        
        _expandBtn = UIBarButtonItem(image: upArrow, style: UIBarButtonItemStyle.Plain, target: self, action: "ChangeHeight")
        self.navigationItem.rightBarButtonItem = _expandBtn
        
        photoImv.image = nil
        photoImv.layer.cornerRadius = photoImv.frame.size.width / 2
        photoImv.layer.masksToBounds = true
        
        photoImv.layer.borderWidth = 3.0
        photoImv.layer.borderColor = UIColor.whiteColor().CGColor
        
        let tap = UITapGestureRecognizer(target: self, action: "DisplayPhoto")
        photoImv.addGestureRecognizer(tap)
        
        var name = TeacherData.TeacherName
        name += TeacherData.EnglishName.isEmpty ? "" : " / " + TeacherData.EnglishName
        name += TeacherData.MajorWorkPlace.isEmpty ? "" : "\n" + TeacherData.MajorWorkPlace
        
        nameLabel.text = name

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if _mustFlipPhoto{
            UIView.transitionWithView(photoImv, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromTop, animations: { () -> Void in
                self.photoImv.image = self.TeacherData.Photo
                }) { (Bool) -> Void in
                    self._mustFlipPhoto = false
            }
        }
        
        if segment.selectedSegmentIndex == _lastSegmentIndex{
            return
        }
        
        self.segmentClick(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ChangeHeight(){
        frameView.hidden = !frameView.hidden
        frameViewHeight.constant = frameView.hidden ? 0 : 133
        _expandBtn.image = frameView.hidden ? downArrow : upArrow
    }
    
    func DisplayPhoto(){
        
        _lastSegmentIndex = segment.selectedSegmentIndex
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("DisplayViewCtrl") as! DisplayViewCtrl
        
        nextView.Image = TeacherData.Photo
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func ChangeContainerViewContent(vc : UIViewController){
        
        childViewControllers.first?.removeFromParentViewController()
        
        addChildViewController(vc)
        
        for sub in containView.subviews {
            sub.removeFromSuperview()
        }
        
        vc.view.frame = containView.bounds
        
        containView.addSubview(vc.view)
    }

    
    
}
