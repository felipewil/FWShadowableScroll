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
private struct AssociationKeys {
    static var show = "show"
    static var observer = "observer"
    static var shadowLayer = "shadowLayer"
    static var topShadowView = "topShadowView"
}

/**
 Helper class to register the content offset observer.
 
 It uses an unmanaged object as mirror for the scroll view.
 When the original is deallocated (and thus triggering this class deallocation),
 the unmanaged object will still have a reference, possibiliting the observer removal.
 */
private class UIScrollViewObserverHelper : NSObject {
    
    /**
     ContentOffset property key path.
     */
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

@objc extension UIScrollView {
    
    // MARK: - Computed variables
    
    /**
     When set to `true`, will be create a view with a shadow layer at the top of the scroll view.
     That new shadow layer will only be visible when the scroll view contentOffset is bigger than zero.
     
     When set to `false`, the view layer will be removed.
     */
    var shouldShowScrollShadow: Bool {
        get { return objc_getAssociatedObject(self, &AssociationKeys.show) as? Bool ?? false }
        set {
            guard shouldShowScrollShadow != newValue else { return }
            
            objc_setAssociatedObject(self, &AssociationKeys.show, newValue, .OBJC_ASSOCIATION_ASSIGN)
            
            if newValue {
                addTopShadowView()
            }
            else {
                removeTopShadowView()
            }
        }
    }
    
    /**
     The shadow layer created when `shouldShowScrollShadow` property is set to `true`.
     */
    var shadowLayer: CALayer? {
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
    
    /**
     A view created to hold the shadow layer. It is added above the scroll view.
     */
    var topShadowView: UIView? {
        get {
            if let shadowView = objc_getAssociatedObject(self, &AssociationKeys.topShadowView) as? UIView {
                return shadowView
            }
            
            guard shouldShowScrollShadow else { return nil }
            
            let shadowView = createShadowView()
            self.topShadowView = shadowView
            
            return shadowView
        }
        set { objc_setAssociatedObject(self, &AssociationKeys.topShadowView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var scrollViewObserverHelper: UIScrollViewObserverHelper? {
        get { return objc_getAssociatedObject(self, &AssociationKeys.observer) as? UIScrollViewObserverHelper }
        set { objc_setAssociatedObject(self, &AssociationKeys.observer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var shadowHeight: CGFloat { get { return 4.0 } }
    
    // MARK: - Private helpers
    
    private func createShadowView() -> UIView {
        let height: CGFloat = 10.0
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
        
        shadowLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: shadowHeight)
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: -4.0)
        shadowLayer.shadowRadius = 4.0
        
        return shadowLayer
    }
    
    private func removeTopShadowView() {
        topShadowView?.removeFromSuperview()
        topShadowView = nil
        scrollViewObserverHelper = nil
    }
    
    private func addTopShadowView() {
        guard let superview = self.superview else { return }
        guard let topShadowView = topShadowView else { return }
        
        superview.insertSubview(topShadowView, aboveSubview: self)
        
        makeConstraint(for: topShadowView, to: self, using: .left)
        makeConstraint(for: topShadowView, to: self, using: .right)
        makeConstraint(for: topShadowView, to: self, using: .top)
        makeConstraint(for: topShadowView, to: nil, using: .height, withConstant: topShadowView.frame.size.height)
        
        scrollViewObserverHelper = UIScrollViewObserverHelper(scrollView: self) { [ weak self ] in
            self?.updateTopShadow()
        }
    }
    
    private func makeConstraint(for item: UIView,
                                to toItem: UIView?,
                                using attribute: NSLayoutAttribute,
                                withConstant constant: CGFloat = 0.0) {
        let toItemAttribute = attribute == .height ? .notAnAttribute : attribute
        
        NSLayoutConstraint(item: item,
                           attribute: attribute,
                           relatedBy: .equal,
                           toItem: toItem,
                           attribute: toItemAttribute,
                           multiplier: 1.0,
                           constant: constant).isActive = true
    }
    
    private func updateTopShadow() {
        let shadowHeight = min(contentOffset.y / 3, self.shadowHeight)
        let shadowPath = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: shadowHeight)
        
        shadowLayer?.shadowOpacity = contentOffset.y > 0.0 ? 1.0 : 0.0
        shadowLayer?.shadowPath = UIBezierPath(rect: shadowPath).cgPath
    }
    
}
