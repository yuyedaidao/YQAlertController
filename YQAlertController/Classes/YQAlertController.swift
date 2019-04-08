//
//  YQViewController.swift
//  YQAlertController_Example
//
//  Created by 王叶庆 on 2019/4/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SwiftPopup
import SnapKit

public typealias YQAlertItemHandler = (YQAlertItem) -> ()

public enum YQAlertItem {
    case message(String)
    case image(UIImage, CGSize?)
    case radio(Bool,String,YQAlertItemHandler?)
    case button(String, YQAlertItemHandler?)
    case custom(UIView)
}

class YQAlertItemWrapper {
    let item: YQAlertItem
    init(_ item: YQAlertItem) {
        self.item = item
    }
}

class YQAlertContainer: UIView {
    let stack = UIStackView()
    init(contentInset: UIEdgeInsets) {
        super.init(frame: CGRect.zero)
        stack.alignment = .leading
        stack.axis = .vertical
        stack.spacing = 12
        
        addSubview(stack)
        stack.snp.makeConstraints { (maker) in
            maker.edges.equalTo(contentInset)
        }
    }
    
    func add(_ view: UIView) {
        stack.addArrangedSubview(view)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class YQAlertController: SwiftPopup {

    var containerView: YQAlertContainer!
    public var horizontalMargin: CGFloat = UIScreen.main.bounds.width / 5
    public var verticalMargin: CGFloat = UIScreen.main.bounds.height / 6
    public var contentInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    
    var alertTitle: String? = nil
    var items: [YQAlertItemWrapper] = []
    var flagIndex: Int = 0
    private init(title: String?) {
        super.init()
        containerView = YQAlertContainer(contentInset: self.contentInsets)

        if let title = title {
            let label = UILabel()
            label.textColor = UIColor.darkText
            label.text = title
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            label.textAlignment = .center
//            label.translatesAutoresizingMaskIntoConstraints = false
            containerView.add(label)
            label.snp.makeConstraints { (maker) in
                maker.leading.trailing.equalTo(0)
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = items.last?.item {
            switch item {
            case .button(_ , _):
                break
            default:
                add(.button("取消", nil))
            }
        }
        
        containerView.backgroundColor = UIColor.white
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 8
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (maker) in
            maker.leading.greaterThanOrEqualTo(self.horizontalMargin)
            maker.trailing.greaterThanOrEqualTo(-self.horizontalMargin)
            maker.top.greaterThanOrEqualTo(self.verticalMargin).priority(.low)
            maker.bottom.greaterThanOrEqualTo(-self.verticalMargin).priority(.low)
            maker.center.equalTo(self.view)
        }
        
    }
    
    public class func create(with title: String? = nil, items: YQAlertItem...) -> YQAlertController {
        let vc = YQAlertController(title: title)
        for item in items {
            vc.add(item)
        }
        return vc
    }
    
    public func add(_ item: YQAlertItem) {
        items.append(YQAlertItemWrapper(item))
        switch item {
        case .message(let message):
            let label = UILabel()
            label.text = message
            label.textColor = UIColor.darkText
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 15)
            containerView.add(label)
            label.tag = flagIndex
            label.snp.makeConstraints { (maker) in
                maker.leading.trailing.equalTo(0)
            }

            
        case .image(let image, let size):
            let imgView = UIImageView(image: image)
            imgView.contentMode = .scaleAspectFit
            containerView.add(imgView)
            let size = size ?? CGSize(width: CGFloat.infinity, height: 60)
            imgView.snp.makeConstraints { (maker) in
                maker.size.equalTo(size)
            }
            imgView.tag = flagIndex
        case .radio(let selected, let title, _):
            let button = UIButton(type: .custom)
            button.isSelected = selected
            let title = "  \(title)"
            button.setTitle(title, for: .normal)
            button.setTitle(title, for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.setTitleColor(UIColor.darkGray, for: .normal)
            let bundle = Bundle(for: YQAlertContainer.classForCoder())
            button.setImage(UIImage(named: "radio-normal", in: bundle, compatibleWith: nil), for: .normal)
            button.setImage(UIImage(named: "radio-select", in: bundle, compatibleWith: nil), for: .selected)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            containerView.add(button)
            button.tag = flagIndex
            
        case .button(let title, _):
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.darkText, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            containerView.add(button)
            button.tag = flagIndex
            button.snp.makeConstraints { (maker) in
                maker.leading.trailing.equalTo(0)
            }

        default:
            break
        }
        flagIndex += 1
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - Action
extension YQAlertController {
    @objc func buttonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let item = items[sender.tag].item
        switch item {
        case .radio(_, _, let handler):
            handler?(item)
        case .button(_, let handler):
            handler?(item)
            self.dismiss()
        default:
            break
        }
    }
}
