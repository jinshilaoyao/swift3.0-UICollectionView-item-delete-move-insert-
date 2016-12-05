//
//  ViewController.swift
//  collectionTest
//
//  Created by yesway on 2016/12/1.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    struct Content {
        static let SH: CGFloat = UIScreen.main.bounds.size.height
        static let SW: CGFloat = UIScreen.main.bounds.size.width
        static let ButtonWidth: CGFloat = (SW - 80)/3
        static let ButtonHeight: CGFloat = 60
    }
    
    lazy var imageDataSource: [String] = {
        var array = Array<String>()
        for i in 1...20 {
            let imageName = "\(i).jpg"
            array.append(imageName)
        }
        return array
    }()
    
    var collectionView: TestCollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView = TestCollectionView(CGRect(x: 0, y: 100, width: Content.SW, height: Content.SH - 100), dataSource: imageDataSource)
        view.addSubview(collectionView!)
        
        perpareButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func perpareButton() {
        
        let deleteButton = UIButton(frame: CGRect(x: 20, y: 20, width: Content.ButtonWidth, height: Content.ButtonHeight))
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitle("Cancel", for: .selected)
        deleteButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        view.addSubview(deleteButton)
        
        let moveButton = UIButton(frame: CGRect(x: Content.ButtonWidth + 40, y: 20, width: Content.ButtonWidth, height: Content.ButtonHeight))
        moveButton.setTitle("Move", for: .normal)
                moveButton.setTitle("Cancel", for: .selected)
        moveButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        moveButton.addTarget(self, action: #selector(moveAction), for: .touchUpInside)
        view.addSubview(moveButton)
        
        let insertButton = UIButton(frame: CGRect(x: (Content.ButtonWidth + 40)*2, y: 20, width: Content.ButtonWidth, height: Content.ButtonHeight))
        insertButton.setTitle("Insert", for: .normal)
                insertButton.setTitle("Cancel", for: .selected)
        insertButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        insertButton.addTarget(self, action: #selector(insertAction), for: .touchUpInside)
        view.addSubview(insertButton)
    }

    func deleteAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        collectionView?.type = sender.isSelected ? MethodType.Delete : MethodType.CancelDelete
    }
    
    func moveAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        collectionView?.type = sender.isSelected ? MethodType.Move : MethodType.CancelMove
    }
    
    func insertAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        collectionView?.type = sender.isSelected ? MethodType.Insert : MethodType.CancelInsert
    }
}

