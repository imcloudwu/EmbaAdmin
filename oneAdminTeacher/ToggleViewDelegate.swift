//
//  Extends.swift
//  EmbaAdmin
//
//  Created by Cloud on 2016/1/30.
//  Copyright © 2016年 ischool. All rights reserved.
//

class ToggleViewDelegate : NSObject{
    
    private var btn : UIBarButtonItem!
    
    init(searchBar : UISearchBar){
        
        //當切換選單時關閉鍵盤
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let sideMenu = app.centerContainer?.leftDrawerViewController as? SideMenuViewCtrl
        sideMenu?.searchBarOfCenter = searchBar
    }
    
    deinit{
        btn = nil
    }
    
    func ToggleSideMenu(){
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    var ToggleBtn : UIBarButtonItem{
        
        get{
            
            if btn == nil{
                btn = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
            }
            
            return btn
        }
        
    }
}
