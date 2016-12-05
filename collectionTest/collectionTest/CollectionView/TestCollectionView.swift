//
//  TestCollectionView.swift
//  collectionTest
//
//  Created by yesway on 2016/12/1.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit

enum MethodType {
    case Delete, Move, Insert, CancelDelete, CancelMove, CancelInsert
}

class TestCollectionView: UIView {

    fileprivate struct Content {
        static let SH = UIScreen.main.bounds.size.height
        static let SW = UIScreen.main.bounds.size.width
        static let cellID = "cellid"
        static let headerViewID = "headerViewid"
    }

    //    - (CGFloat)itemSpace{
    //    if (!_itemSpace) {
    //    int rowNum = (int)(SW/self.flowLayout.itemSize.width);
    //    _itemSpace = (SW - rowNum * self.flowLayout.itemSize.width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right)/rowNum ;
    //    if (_itemSpace < self.flowLayout.minimumInteritemSpacing) {
    //    _itemSpace = self.flowLayout.minimumInteritemSpacing;
    //    }
    //    }
    //    return _itemSpace;
    //    }
    
    fileprivate var isSnake: Bool = false
    fileprivate var dataSources: [String] = []
    
    var type: MethodType = .CancelDelete {
        didSet {
            switch self.type {
            case .Delete:
                setDeleting()
                break
            case .CancelDelete:
                setCancelDeleting()
                break
            case .Move:
                setMoving()
                break
            case .CancelMove:
                setCancelMoving()
                break
            case .Insert:
                setInserting()
                break
            case .CancelInsert:
                setCancelInserting()
                break
            }
        }
    }
    
    fileprivate var moveGesture: UIPanGestureRecognizer?
    fileprivate var insertGesture: UILongPressGestureRecognizer?
    
    var collectionView: UICollectionView? {
        didSet {
            collectionView?.delegate = self
            collectionView?.dataSource = self
            collectionView?.backgroundColor = UIColor.white
            collectionView?.showsVerticalScrollIndicator = false
            collectionView?.showsHorizontalScrollIndicator = false
            collectionView?.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: Content.cellID)
        }
    }
    
    private var flowLayout: UICollectionViewFlowLayout? {
        didSet {
            flowLayout?.itemSize = CGSize(width: 130, height: 130)
            flowLayout?.minimumLineSpacing = 10
            flowLayout?.minimumInteritemSpacing = 0
        }
    }
    
    init(_ frame: CGRect, dataSource: Array<String>) {
        self.dataSources = dataSource
        super.init(frame: frame)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        flowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), collectionViewLayout: flowLayout!)
        addSubview(collectionView!)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDeleting() {
        shake()
    }
    
    private func setCancelDeleting() {
        cancelShake()
    }
    
    private func setMoving() {
        shake()
        moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMethod))
        collectionView?.addGestureRecognizer(moveGesture!)
    }
    
    private func setCancelMoving() {
        cancelShake()
        collectionView?.removeGestureRecognizer(moveGesture!)
    }
    
    private func setInserting() {
        shake()
        insertGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMethod))
        collectionView?.addGestureRecognizer(insertGesture!)
    }

    private func setCancelInserting() {
        cancelShake()
        collectionView?.removeGestureRecognizer(insertGesture!)
    }
    
    
    private func shake() {
        isSnake = true
        collectionView?.allowsSelection = true
        collectionView?.reloadData()
    }
    private func cancelShake() {
        isSnake = false
        collectionView?.allowsSelection = false
        collectionView?.reloadData()
    }
    
    @objc private func handleMethod(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: collectionView)
        let indexPath = collectionView?.indexPathForItem(at: location)
        
        if type == .Move {
            if indexPath != nil {
                switch sender.state {
                case .began:
                    collectionView?.beginInteractiveMovementForItem(at: indexPath!)
                    break
                case .changed:
                    collectionView?.updateInteractiveMovementTargetPosition(sender.location(in: collectionView))
                    break
                default:
                    break
                }
            }
            if sender.state == .ended {
                collectionView?.endInteractiveMovement()
            }
            
        } else if type == .Insert {
            if indexPath != nil {
            }
            
            guard let index = getIndexPathWithPoint(point: location), let destinationCell = collectionView?.cellForItem(at: index), let itemsize = flowLayout?.itemSize else {
                return
            }
            var destinationFame = destinationCell.frame
            if sender.state == .began {
                
                if index.row == dataSources.count {
                    let lastItemFrame = collectionView?.cellForItem(at: IndexPath(row: dataSources.count - 1, section: 0))?.frame
                    destinationFame = CGRect(x: (lastItemFrame?.origin.x)! + itemsize.width + getItemSpace(), y: (lastItemFrame?.origin.y)!, width: itemsize.width, height: itemsize.height)
                    if destinationFame.origin.x > Content.SW {
                        destinationFame.origin.x = (flowLayout?.sectionInset.left)!
                        destinationFame.origin.y += (flowLayout?.minimumLineSpacing)! + itemsize.height
                    }
                }
                let showImage = UIImageView(frame: CGRect(x: Content.SW/2 - 100, y: (collectionView?.contentOffset.y)! + (collectionView?.bounds.height)!/2 - 100, width: 200, height: 200))
                showImage.image = UIImage(named: "vivian.jpg")
                showImage.layer.cornerRadius = 5
                showImage.layer.masksToBounds = true
                collectionView?.addSubview(showImage)
                
                UIView.animate(withDuration: 1, animations: {
                    showImage.frame = destinationFame
                    }, completion: { [unowned self] (finished) in
                        showImage.removeFromSuperview()
                        
                        self.dataSources.insert("vivian.jpg", at: index.row)
                        self.collectionView?.performBatchUpdates({
                            self.collectionView?.insertItems(at: [index])
                            }, completion: nil)
                        
                    })
            }
            
        }
    }

    private func getItemSpace() -> CGFloat {
        
        guard let layout = flowLayout else {
            return 0
        }
        let rowNum = Content.SW/layout.itemSize.width
        var itemSpace = (Content.SW - rowNum * layout.itemSize.width - layout.sectionInset.left - layout.sectionInset.right)/rowNum
        if itemSpace < layout.minimumInteritemSpacing { itemSpace = layout.minimumInteritemSpacing }
        return itemSpace
    }
    
    private func getIndexPathWithPoint(point: CGPoint) -> IndexPath? {
        guard let itemsize = flowLayout?.itemSize else {
            return nil
        }

        if (!((collectionView?.indexPathForItem(at: CGPoint(x: point.x + itemsize.width, y: point.y))) != nil) && ((collectionView?.indexPathForItem(at: CGPoint(x: point.x, y: point.y + itemsize.height))) != nil)) {
            return collectionView?.indexPathForItem(at: CGPoint(x: point.x, y: point.y + itemsize.height))
        } else if (!((collectionView?.indexPathForItem(at: CGPoint(x: point.x, y: point.y + itemsize.height))) != nil) && ((collectionView?.indexPathForItem(at: CGPoint(x: point.x + itemsize.width, y: point.y))) != nil)) {
            return collectionView?.indexPathForItem(at: CGPoint(x: point.x + itemsize.width, y: point.y))
        } else {
            return nil
        }
    }
}

extension TestCollectionView: TestCollectionViewCellDelegate {
    func deleteCellAction(point: CGPoint) {
        guard let index = collectionView?.indexPathForItem(at: point) else {
            return
        }
        dataSources.remove(at: index.row)
        collectionView?.deleteItems(at: [index])
        collectionView?.reloadData()
    }
}
extension TestCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Content.cellID, for: indexPath) as? TestCollectionViewCell
        
        cell?.image.image = UIImage(named: dataSources[indexPath.row])
        cell?.deleteDelegate = self
        cell?.tag = indexPath.row
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TestCollectionViewCell else {
            return
        }
        if isSnake {
            cell.deleteBtn.isHidden = (self.type == .Delete) ? false : true
            let keyAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
            keyAnimation.values = [0.03, -0.03]
            keyAnimation.repeatCount = MAXFLOAT
            keyAnimation.duration = 0.2
            cell.image.layer.add(keyAnimation, forKey: "keyanimation")
        } else {
            cell.image.layer.removeAllAnimations()
            cell.deleteBtn.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let obj = dataSources[sourceIndexPath.row]
        dataSources.remove(at: sourceIndexPath.row)
        dataSources.insert(obj, at: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
