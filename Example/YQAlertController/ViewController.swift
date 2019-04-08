//
//  ViewController.swift
//  YQAlertController
//
//  Created by wyqpadding@gmail.com on 04/08/2019.
//  Copyright (c) 2019 wyqpadding@gmail.com. All rights reserved.
//

import UIKit
import YQAlertController


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.orange
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let alert = YQAlertController.create(with: "我是标题", items: .message("行不行的吧，你看着办，我靠，你竟然真看着办了，听我的，不办，明白了吗，什么，不明白，我靠，去玩泥巴"), .radio(false, "下次不再提醒", { (item) in
            print("我是单选按钮")
        }))
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

