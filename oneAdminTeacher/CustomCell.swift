//
//  CustomCell.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class EmbaTeacherInfoCell : UITableViewCell{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
    }
}

class EmbaTeacherCell : UITableViewCell{
    
    @IBOutlet weak var Tag1: UILabel!
    @IBOutlet weak var Tag2: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Info: UILabel!
    @IBOutlet weak var Photo: UIImageView!
    
    override func awakeFromNib() {
        Photo.layer.masksToBounds = true
        Photo.layer.cornerRadius = Photo.frame.width / 2
        
        Tag1.layer.masksToBounds = true
        Tag1.layer.cornerRadius = 5
        
        Tag2.layer.masksToBounds = true
        Tag2.layer.cornerRadius = 5
    }
}


class EmbaClassCell : UITableViewCell{
    
    @IBOutlet weak var GradeYear: UILabel!
    @IBOutlet weak var ClassName: UILabel!
    @IBOutlet weak var OtherInfo: UILabel!
    
    override func awakeFromNib() {
        GradeYear.layer.cornerRadius = 5
        GradeYear.layer.masksToBounds = true
    }
}

class CourseInfoCell : UITableViewCell{
    
    @IBOutlet weak var StudentCount: UILabel!
    @IBOutlet weak var CourseName: UILabel!
    @IBOutlet weak var SubjectCode: UILabel!
    @IBOutlet weak var CourseType: UILabel!
    @IBOutlet weak var CourseTeacher: UILabel!
    @IBOutlet weak var Semester: UILabel!
    
    override func awakeFromNib() {
        StudentCount.layer.cornerRadius = 5
        StudentCount.layer.masksToBounds = true
        
        Semester.layer.cornerRadius = 5
        Semester.layer.masksToBounds = true
    }
}

class EmbaStudentCell : UITableViewCell{
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Company: UILabel!
    @IBOutlet weak var Class: UILabel!
    
    var student : Student!
    
    override func awakeFromNib() {
        Photo.layer.cornerRadius = Photo.frame.size.width / 2
        Photo.layer.masksToBounds = true
    }
}

class EmbaCourseScoreCell : UITableViewCell{
    
    @IBOutlet weak var CourseName: UILabel!
    @IBOutlet weak var CourseInfo: UILabel!
    @IBOutlet weak var CourseTeachers: UILabel!
    @IBOutlet weak var CourseScore: UILabel!
    @IBOutlet weak var CheckImage: UIImageView!
    
    override func awakeFromNib() {
        CourseScore.layer.cornerRadius = CourseScore.frame.size.width / 2
        CourseScore.layer.masksToBounds = true
    }
}

class StudentCell : UITableViewCell{
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    
    var student : Student!
    
    override func awakeFromNib() {
        Photo.layer.cornerRadius = Photo.frame.size.width / 2
        Photo.layer.masksToBounds = true
    }
}

class StudentBasicInfoCell : UITableViewCell{
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Value: UILabel!
    
    override func awakeFromNib() {
    }
}

class AttendanceItemCell : UITableViewCell{
    
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Type: UILabel!
    @IBOutlet weak var Periods: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class DisciplineItemCell : UITableViewCell{
    
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var Reason: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class SemesterScoreItemCell : UITableViewCell{
    
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var Score: UILabel!
    @IBOutlet weak var Info: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class ExamScoreItemCell : UITableViewCell{
    
    @IBOutlet weak var ExamName: UILabel!
    @IBOutlet weak var Score: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class ExamScoreMoreInfoItemCell : UITableViewCell{
    
    @IBOutlet weak var ExamName: UILabel!
    @IBOutlet weak var Score: UILabel!
    @IBOutlet weak var Info1: UILabel!
    @IBOutlet weak var Info2: UILabel!
    @IBOutlet weak var Info3: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class ClassCell : UITableViewCell{
    
    @IBOutlet weak var ClassIcon: UILabel!
    @IBOutlet weak var ClassName: UILabel!
    @IBOutlet weak var Major: UILabel!
    
    var classItem : ClassItem!
    
    override func awakeFromNib() {
//        ClassIcon.layer.cornerRadius = 5
//        ClassIcon.layer.masksToBounds = true
    }
}

class MessageCell : UITableViewCell{
    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Content: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Icon: UIImageView!
    @IBOutlet weak var IcomFrame: UIView!
    
    override func awakeFromNib() {
        IcomFrame.layer.cornerRadius = IcomFrame.frame.size.width / 2
        IcomFrame.layer.masksToBounds = true
    }
}

class OptionCell : UITableViewCell{
    
    @IBOutlet weak var OptionText: UILabel!
    @IBOutlet weak var OptionContent: UITextView!
    
    override func awakeFromNib() {
    }
}

class ChartOptionCell : UITableViewCell{
    
    @IBOutlet weak var ColorView: UIView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var ValueLabel: UILabel!
    
    override func awakeFromNib() {
    }
}

/*
class AbsentCell : UITableViewCell{
    
    @IBOutlet weak var Type: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Period: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class DisciplineCell : UITableViewCell{
    
    @IBOutlet weak var State: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Reason: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class SemesterCell : UITableViewCell{
    
    @IBOutlet weak var Title: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class SemesterScoreCell : UITableViewCell{
    
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var Info: UILabel!
    @IBOutlet weak var Type: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class ExamScoreCell : UITableViewCell{
    
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var Credit: UILabel!
    @IBOutlet weak var ScoreA: UILabel!
    @IBOutlet weak var ScoreB: UILabel!
    @IBOutlet weak var ScoreC: UILabel!
    @IBOutlet weak var SubTitleA: UILabel!
    @IBOutlet weak var SubTitleB: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class ExamScoreTitleCell : UITableViewCell{
    
    @IBOutlet weak var Domain: UILabel!
    @IBOutlet weak var Score: UILabel!
    
    override func awakeFromNib() {
    }
}
*/
