//
//  BeweglicherDoppelEinzugMitKlappe..swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 12.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift


//MARK: BeweglicherDoppelEinzugScanModul
@IBDesignable class BeweglicherDoppelEinzugScanModul:NibLoadingView{
    //ViewModel
    var viewModel:BeweglichesScanModulViewModel! {
        didSet{
            doppelEinzugScanModul.viewModel = viewModel.getViewModelForScanModul()
            
            viewModel.abstandVonOben.producer.startWithValues{[weak self] abstand in self?.move(to:abstand)}
            
            //Gestures
            doppelEinzugScanModul.addGestureRecognizer(UISwipeGestureRecognizer(direction: .up,target: self, action: #selector(swiped)))
            doppelEinzugScanModul.addGestureRecognizer(UISwipeGestureRecognizer(direction: .down,target: self, action: #selector(swiped)))
        }
    }

    //Outlets
    @IBOutlet private weak var constraintTop: NSLayoutConstraint!
    @IBOutlet private weak var doppelEinzugScanModul: DoppelEinzugScanModul!
    
    //Animationen
    private func move(to abstand:CGFloat){
        constraintTop.constant = abstand
        UIView.animate(withDuration: 2) { self.view.layoutIfNeeded() }
    }
    
    // Gestures
    @objc private func swiped(sender:UISwipeGestureRecognizer)              { viewModel.setPosition(swipeDirection: sender.direction) }
    @IBAction private func modulTapped(_ sender: UITapGestureRecognizer)    { viewModel.fineTunerStarten() }
}

//MARK: ScanModul (mit KlappWalze)
@IBDesignable class DoppelEinzugScanModul:NibLoadingView{
    //ViewModel
    var viewModel:ScanModulViewModel! {
        didSet{
            viewModel.klappWalzeIsOpen.producer.startWithValues{[weak self] isOpen in self?.animateKlappenDerWalze(isOpen: isOpen)}
            for walze in einzugWalzen { walze.viewModel = viewModel.getViewModelForEinzugWalze(isOben: walze.tag == 0)}
            klappWalze.viewModel = viewModel.getViewModelForKlappWalze()
            viewModel.animateBlattStueck    = blattStueck.animateBlattStueck
        }
    }
    

    //Outlets
    @IBOutlet var scannModule: [ScanModul]!
    @IBOutlet weak var klappWalzenView: UIView!
    @IBOutlet var einzugWalzen: [Walze]!            { didSet{}}
    @IBOutlet weak var klappWalze: Walze!           { didSet{}}
    @IBOutlet weak var blattStueck: BlattStueck!    {  didSet{ blattStueck.viewModel           = BlattStueckViewModel(blattStueckTyp:.scanModul) } }
    
    //Animationen
    private func animateKlappenDerWalze(isOpen:Bool){
        switch isOpen{
        case true:  UIView.animate(withDuration: 1) { self.klappWalzenView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)  }
        case false: UIView.animate(withDuration: 1) { self.klappWalzenView.transform = CGAffineTransform(rotationAngle:  0) }
        }
    }
    
    //Anpassung der Walzengröße (im beweglichen Fach)
    override func layoutSubviews() { mainModel.positionenUndFrames.laufZeitWerte.setWidthWalze(width: klappWalze.frame.width) }
}


//MARK: Einzug
@IBDesignable class Einzug:NibLoadingView{
    //ViewModel
    var viewModel:EinzugViewModel!{
        didSet{
            viewModel.animateBlattStueck    = blattStueck.animateBlattStueck
            walzeOben.viewModel   = viewModel.getViewModelForWalze(isOben: true)
            walzeUnten.viewModel  = viewModel.getViewModelForWalze(isOben: false)
        }
    }
    
    //IBOutlets
    @IBOutlet private weak var walzeOben: Walze!            { didSet { } }
    @IBOutlet private weak var walzeUnten: Walze!           { didSet { } }
    @IBOutlet private weak var blattStueck: BlattStueck!{
        didSet {
            blattStueck.viewModel           = BlattStueckViewModel(blattStueckTyp: .oberereinzug)
            
        }
    }
}

//MARK: BlattStueck
@IBDesignable class BlattStueck:NibLoadingView{
    //ViewModel
    var viewModel:BlattStueckViewModel!
    
    //Animation
    func animateBlattStueck(animation:BlattAnimation){
        verdeckView.isHidden        = false
        var verdeckStartX:CGFloat{
            switch animation.blattAnimationTyp{
            case .erscheinen:   return 0
            case .verschwinden: return animation.direction == .left ? self.frame.size.width : -self.frame.size.width
            }
        }
        var verdeckEndX:CGFloat{
            switch animation.blattAnimationTyp{
            case .erscheinen:   return  animation.direction == .left ? -self.frame.size.width : self.frame.size.width
            case .verschwinden: return 0
            }
        }
        verdeckView.frame.origin.x  = verdeckStartX
        UIView.animate(withDuration: animation.dauer, animations: {
            self.verdeckView.frame.origin.x = verdeckEndX
        }) {[weak self] _ in
            self?.verdeckView.isHidden = animation.blattAnimationTyp == .erscheinen ? true : false
            animation.einzelBlattEinzugAnimationBeendet?()
            animation.completion?()
        }
    }
    
    //IBOutlets
    @IBOutlet private weak var verdeckView: UIView!
    
    //layoutSubViews
    override func layoutSubviews() { viewModel.setBlattStueckWidth(width:frame.width) }
}



//MARK: Walze
@IBDesignable class Walze : UIView {
    //ViewModel
    var viewModel:WalzeViewModel!{
        didSet{
            backgroundColor = UIColor.clear
            viewModel.spinDirection.signal.observeValues{ [weak self] direction in self?.startSpin(direction: direction ) }
        }
    }
    
    //Animation
    private func startSpin(direction:Direction){
        self.rotateView(direction: .stop)
        self.rotateView(direction: direction)
    }
    
    //drawRect
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: rect.width / 2, startAngle: 0, endAngle: CGFloat.pi * 2 , clockwise: true)
        path.close()
        
        // fill the path
        UIColor.red.set()
        path.fill()
        let markierung = UIBezierPath()
        markierung.move(to: CGPoint(x: 0, y: rect.height / 2))
        markierung.addLine(to: CGPoint(x: rect.width, y: rect.height / 2))
        markierung.move(to: CGPoint(x: rect.width / 2 , y: 0))
        markierung.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        markierung.lineWidth = 0.5
        UIColor.black.set()
        markierung.stroke()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        self.layer.mask = shapeLayer
    }
}

//MARK: Scanner
@IBDesignable class ScanModul:UIView{
    @IBInspectable var isUnten:Bool = false
    
    //init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    //drawRect
    override func draw(_ rect: CGRect) {
        UIColor.red.set()
        let path = UIBezierPath()
        
        switch isUnten {
        case true:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        case false:
            path.move(to: CGPoint(x: rect.width / 2, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        path.close()
        path.fill()
        
        let shapeLayer  = CAShapeLayer()
        shapeLayer.path = path.cgPath
        self.layer.mask = shapeLayer
    }
}







extension UISwipeGestureRecognizer{
    convenience init(direction:UISwipeGestureRecognizerDirection,target: Any, action:Selector?){
        self.init(target: target, action: action)
        self.direction = direction
    }
}





