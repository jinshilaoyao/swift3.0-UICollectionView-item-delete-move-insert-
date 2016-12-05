//
//  TestCollectionViewCell.swift
//  collectionTest
//
//  Created by yesway on 2016/12/2.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit

protocol TestCollectionViewCellDelegate: NSObjectProtocol {
    func deleteCellAction(point: CGPoint)
}

class TestCollectionViewCell: UICollectionViewCell {
    
    var deleteBtn: UIButton
    
    var image: UIImageView
    
    weak var deleteDelegate: TestCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        deleteBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        deleteBtn.isHidden = true
        image = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height - 10))
        super.init(frame: frame)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        image.layer.cornerRadius = 5
        image.layer.masksToBounds = true
        addSubview(image)
        
        deleteBtn.layer.cornerRadius = 7.5
        deleteBtn.layer.masksToBounds = true
        deleteBtn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        deleteBtn.setImage(UIImage(named: "delete"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deletingAction), for: .touchUpInside)
        addSubview(deleteBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func deletingAction() {
        deleteDelegate?.deleteCellAction(point: self.center)
    }
    
}
