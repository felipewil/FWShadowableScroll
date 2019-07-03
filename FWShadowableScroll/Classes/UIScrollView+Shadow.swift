//
//  UIScrollView+Shadow.swift
//  FWShadowableScroll
//
//  Created by Felipe Leite on 13/09/18.
//

import UIKit

// MARK: - Keys

/**
 Keys for value association.
 */
fileprivate struct AssociationKeys {
    static var show = "show"
    static var observer = "observer"
    static var shadowLayer = "shadowLayer"
    static var shadowView = "shadowView"
    static var shadowHeight = "shadowHeight"
    static var shadowRadius = "shadowRadius"
    static var topConstraint = "topConstraint"
}

/**
 Helper class to register the content offset observer.
 
 It uses an unmanaged object as mirror for the scroll view.
 When the original is deallocated (and thus triggering this class deallocation),
 the unmanaged object will still have a reference, possibiliting the observer removal.
 */
private class UIScrollViewObserverHelper : NSObject {
    
    /// ContentOffset property key path.
    private let ContentOffsetKeyPath = "contentOffset"
    
    // MARK: - Variables
    
    @objc dynamic weak private var scrollView : UIScrollView?
    private let changeHandler: () -> Void
    
    private let unmanagedObservedObject: Unmanaged<NSObject>
    private var unsafeUnretainedObject: NSObject {
        return unmanagedObservedObject.takeUnretainedValue()
    }
    
    /**
     Creates a helper class that will register a key-value observer for changes in the contentOffset property.
     
     - parameters:
     - scrollView: the scroll view to observe.
     - changeHandler: closure to be called when the property changes.
     */
    init(scrollView: UIScrollView, changeHandler: @escaping () -> Void) {
        self.scrollView = scrollView
        self.changeHandler = changeHandler
        self.unmanagedObservedObject = Unmanaged.passUnretained(scrollView)
        
        super.init()
        
        unsafeUnretainedObject.addObserver(self, forKeyPath: ContentOffsetKeyPath, options: [ .initial, .new ], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == ContentOffsetKeyPath {
            changeHandler()
        }
    }
    
    deinit {
        // Removing the observer on deinit is mandaroy for OS prior to iOS 11
        unsafeUnretainedObject.removeObserver(self, forKeyPath: ContentOffsetKeyPath)
    }
}

@objc public extension UIScrollView {
    
    // MARK: - Computed variables
    
    /**
     When set to `true`, will be created a new view positioned at the scroll view origin. This view will be used to hold the layer with the shadow.
     
     That new shadow layer will only be visible when the scroll view contentOffset is bigger than zero.
     
     When set to `false`, the view layer will be removed.
     */
    @IBInspectable
    var shouldShowScrollShadow: Bool {
        get { return objc_getAssociatedObject(self, &AssociationKeys.show) as? Bool ?? false }
        set {
            guard shouldShowScrollShadow != newValue else { return }
            
            objc_setAssociatedObject(self, &AssociationKeys.show, newValue, .OBJC_ASSOCIATION_ASSIGN)
            
            if newValue {
                addShadowView()
            }
            else {
                removeShadowView()
            }
        }
    }
    
    /**
     The shadow view and layer height. By default it is 4.0.
     
     The shadow view height, actually, will be 2.5 times this value.
    */
    var shadowHeight: CGFloat {
        get { return objc_getAssociatedObject(self, &AssociationKeys.shadowHeight) as? CGFloat ?? 4.0 }
        set {
            objc_setAssociatedObject(self, &AssociationKeys.shadowHeight, newValue as NSNumber, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            guard shouldShowScrollShadow else { return }
            
            removeShadowView()
            addShadowView()
        }
    }

    /// The shadow radius. By default it is 4.0.
    var shadowRadius: CGFloat {
        get { return objc_getAssociatedObject(self, &AssociationKeys.shadowRadius) as? CGFloat ?? 4.0 }
        set {
            objc_setAssociatedObject(self, &AssociationKeys.shadowRadius, newValue as NSNumber, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            guard shouldShowScrollShadow else { return }
            
            removeShadowView()
            addShadowView()
        }
    }
    
    /// The shadow layer created when `shouldShowScrollShadow` property is set to `true`.
    private var shadowLayer: CALayer? {
        get {
            if let shadowLayer = objc_getAssociatedObject(self, &AssociationKeys.shadowLayer) as? CALayer {
                return shadowLayer
            }
            
            guard shouldShowScrollShadow else { return nil }
            
            let shadowLayer = createShadowLayer()
            self.shadowLayer = shadowLayer
            
            return shadowLayer
        }
        set { objc_setAssociatedObject(self, &AssociationKeys.shadowLayer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// A view created to hold the shadow layer. It is added above the scroll view.
    private var shadowView: UIView? {
        get {
            if let shadowView = objc_getAssociatedObject(self, &AssociationKeys.shadowView) as? UIView {
                return shadowView
            }
            
            guard shouldShowScrollShadow else { return nil }
            
            let shadowView = createShadowView()
            self.shadowView = shadowView
            
            return shadowView
        }
        set { objc_setAssociatedObject(self, &AssociationKeys.shadowView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Helper Object to observe contentOffset changes.
    private var scrollViewObserverHelper: UIScrollViewObserverHelper? {
        get { return objc_getAssociatedObject(self, &AssociationKeys.observer) as? UIScrollViewObserverHelper }
        set { objc_setAssociatedObject(self, &AssociationKeys.observer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var topConstraint: NSLayoutConstraint? {
        get { return objc_getAssociatedObject(self, &AssociationKeys.topConstraint) as? NSLayoutConstraint }
        set { objc_setAssociatedObject(self, &AssociationKeys.topConstraint, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Private helpers
    
    private func createShadowView() -> UIView {
        let height = shadowHeight * 2.5
        let viewFrame = CGRect(x: self.frame.origin.x,
                               y: self.frame.origin.y,
                               width: self.frame.size.width,
                               height: height)
        
        let shadowView = UIView(frame: viewFrame)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.layer.masksToBounds = true
        
        if let shadowLayer = shadowLayer {
            shadowView.layer.addSublayer(shadowLayer)
        }
        
        return shadowView
    }
    
    private func createShadowLayer() -> CALayer {
        let shadowLayer = CALayer()
        
        shadowLayer.frame = CGRect(x: 0.0,
                                   y: 0.0,
                                   width: self.frame.size.width,
                                   height: shadowHeight)
        shadowLayer.shadowOffset = CGSize(width: 0.0,
                                          height: -shadowHeight)
        shadowLayer.shadowRadius = shadowRadius
        
        return shadowLayer
    }
    
    private func removeShadowView() {
        shadowView?.removeFromSuperview()
        shadowView = nil
        shadowLayer = nil
        scrollViewObserverHelper = nil
    }
    
    private func addShadowView() {
        guard let superview = self.superview else { return }
        guard let shadowView = shadowView else { return }
        
        superview.insertSubview(shadowView, aboveSubview: self)
        
        NSLayoutConstraint.activate([
            shadowView.leftAnchor.constraint(equalTo: leftAnchor),
            shadowView.rightAnchor.constraint(equalTo: rightAnchor),
            shadowView.heightAnchor.constraint(equalToConstant: shadowView.frame.size.height)
        ])

        topConstraint = shadowView.topAnchor.constraint(equalTo: topAnchor)
        topConstraint?.isActive = true
        
        scrollViewObserverHelper = UIScrollViewObserverHelper(scrollView: self) { [ weak self ] in
            self?.updateShadow()
        }
    }
    
    private func updateShadow() {
        if let tableView = self as? UITableView, tableView.style == .plain {
            updateTableViewShadow(tableView)
        }
        else {
            tryUpdateShadow(withHeight: contentOffset.y)
        }
    }
    
    private func updateTableViewShadow(_ tableView: UITableView) {
        guard let section = tableView.indexPathsForVisibleRows?.first?.section else { return }
        
        let sectionRect = tableView.rect(forSection: section)       
        let headerRect = headerFrame(atSection: section, from: tableView)
        let nextHeaderRect = headerFrame(atSection: section + 1, from: tableView)
        let sectionOffset = contentOffset.y - sectionRect.origin.y
        let remaining = nextHeaderRect.height > 0.0 ? max(sectionRect.size.height - headerRect.size.height - sectionOffset, 0) : CGFloat.greatestFiniteMagnitude

        topConstraint?.constant = min(sectionRect.maxY - contentOffset.y, headerRect.height)
        
        let offset = headerRect.height > 0.0 ? sectionOffset : contentOffset.y
        let shadowHeight = max(min(offset, remaining), 0)
        tryUpdateShadow(withHeight: shadowHeight)
    }
    
    private func headerFrame(atSection section: Int, from tableView: UITableView) -> CGRect {
        guard section < tableView.numberOfSections else { return .zero }
        return tableView.rectForHeader(inSection: section)
    }
    
    private func tryUpdateShadow(withHeight height: CGFloat) {
        let shadowHeight = min(height / 3, self.shadowHeight)
        let shadowPath = CGRect(x: 0.0,
                                y: 0.0,
                                width: frame.size.width,
                                height: shadowHeight)
        
        shadowLayer?.shadowOpacity = contentOffset.y > 0.0 ? 1.0 : 0.0
        shadowLayer?.shadowPath = UIBezierPath(rect: shadowPath).cgPath
    }
    
}
