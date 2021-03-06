//
//  CourseWebViewCtrl.swift
//  EmbaAdmin
//
//  Created by Cloud on 2016/1/21.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class CourseWebViewCtrl: UIViewController,UIWebViewDelegate {
    
    var progressTimer : ProgressTimer!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tint: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var Url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        
        tint.text = "查無資料"
        
        webView.delegate = self
        
        //載入登入頁面
        if let url = Url where !url.isEmpty{
            
            let urlobj = NSURL(string: url)
            let request = NSURLRequest(URL: urlobj!)
            webView.loadRequest(request)
        }
        else{
            tint.hidden = false
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(webView: UIWebView){
        progressTimer.StartProgress()
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        progressTimer.StopProgress()
    }
    
    
}


