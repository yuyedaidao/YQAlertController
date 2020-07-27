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
        let alert = YQAlertController.create()
        let titleLabel = UILabel()
        titleLabel.text = "新建文件夹"
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 63.0 / 255, green: 108.0 / 255, blue: 1, alpha: 1)
        alert.add(.custom(titleLabel))
        titleLabel.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
        }
        let inputTF = UITextField()
        inputTF.borderStyle = .none
        inputTF.leftViewMode = .always
        inputTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 4))
        inputTF.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        inputTF.clipsToBounds = true
        inputTF.layer.cornerRadius = 5
        alert.add(.custom(inputTF))
        inputTF.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(36)
        }
        alert.add(.radio(false, "设置为共享文件夹", { (item) in
            
        }))
        
        alert.show()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

