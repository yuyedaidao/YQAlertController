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
import KeyboardMan

public typealias YQAlertItemHandler = (Any) -> ()

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
    var contentInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            stack.snp.updateConstraints { (maker) in
                maker.edges.equalTo(contentInset)
            }
        }
    }
    let stack = UIStackView()
    init(contentInset: UIEdgeInsets) {
        self.contentInset = contentInset
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
    public var contentInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15) {
        didSet {
            containerView.contentInset = contentInsets
        }
    }
    public var adjustOffsetWhenKeyboardShown = true
    public var spaceToKeyboard: CGFloat = 20
    public var dismissWhenTappedEmptySpace = false
    public var alignment: UIStackView.Alignment = .leading {
        didSet {
            containerView.stack.alignment = alignment
        }
    }
    /// 视图展示前(viewDidLoad中)是否增加取消按钮
    public var appendCancelButton = true
    private let keyboardMan = KeyboardMan()
    
    var alertTitle: String? = nil
    var items: [YQAlertItemWrapper] = []
    var flagIndex: Int = 0
    
    private init(title: String?) {
        super.init()
        containerView = YQAlertContainer(contentInset: self.contentInsets)
        containerView.stack.alignment = alignment
        if let title = title {
            let label = UILabel()
            label.textColor = UIColor.darkText
            label.text = title
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            label.textAlignment = .center
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
        
        if appendCancelButton, let item = items.last?.item {
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
            maker.center.equalToSuperview()
        }
        
        keyboardMan.animateWhenKeyboardAppear = { [weak self] (_, height, increment) in
            guard let self = self else {return}
            guard self.adjustOffsetWhenKeyboardShown else {return}
     
            self.containerView.snp.remakeConstraints { (maker) in
                maker.leading.greaterThanOrEqualTo(self.horizontalMargin)
                maker.trailing.greaterThanOrEqualTo(-self.horizontalMargin)
                maker.top.greaterThanOrEqualTo(self.verticalMargin).priority(.low)
                maker.centerX.equalToSuperview()
                maker.bottom.greaterThanOrEqualTo(-self.spaceToKeyboard - increment).priority(.low)
            }
            self.view.layoutIfNeeded()
          
        }

        keyboardMan.animateWhenKeyboardDisappear = {[weak self] (_) in
            guard let self = self else {return}
            guard self.adjustOffsetWhenKeyboardShown else {return}
            self.containerView.snp.remakeConstraints { (maker) in
                maker.leading.greaterThanOrEqualTo(self.horizontalMargin)
                maker.trailing.greaterThanOrEqualTo(-self.horizontalMargin)
                maker.top.greaterThanOrEqualTo(self.verticalMargin).priority(.low)
                maker.bottom.greaterThanOrEqualTo(-self.verticalMargin).priority(.low)
                maker.center.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAction))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissAction() {
        if dismissWhenTappedEmptySpace {
            dismiss(completion: nil)
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
            button.setImage(UIImage.named("radio-normal"), for: .normal)
            button.setImage(UIImage.named("radio-select"), for: .selected)
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

        case .custom(let view):
            containerView.add(view)
        }
        flagIndex += 1
        
    }
    

}


// MARK: - Action
extension YQAlertController {
    @objc func buttonAction(_ sender: UIButton) {
        
        let item = items[sender.tag].item
        switch item {
        case .radio(_, _, let handler):
            sender.isSelected = !sender.isSelected
            handler?(sender)
        case .button(_, let handler):
            handler?(sender)
            self.dismiss()
        default:
            break
        }
    }
}
