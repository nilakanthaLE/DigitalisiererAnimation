//
//  PapierStapel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 18.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift


class PapierStapelAnimiert:PapierStapel{
    //Animationen
    fileprivate override func animate(_ blattAnimation:BlattAnimation){
        switch blattAnimation.blattAnimationTyp{
        case .erscheinen:       animateErscheinendesFallendesBlatt(animation: blattAnimation)
        case .verschwinden:     animateVerschwindendesBlatt(animation: blattAnimation)
        }
    }
    //erscheinen
    private func animateErscheinendesFallendesBlatt(animation:BlattAnimation){
        fallBlatt.frame     = fallBlattFrameTop
        fallBlatt.isHidden  = false
        
        func fallendesBlatt()       { self.animateFallendesBlatt(completion: animation.completion) }
        setPositionFallBlattUndVerdeckViews()
        animate(animation: animation, completion: fallendesBlatt)
    }
    //verschwinden
    private func animateVerschwindendesBlatt(animation:BlattAnimation){
        func completion(){
            removeBlatt()
            animation.completion?()
        }
        setPositionBlattUndVerdeckViews()
        animate(animation: animation, completion: completion)
    }
    //fallendes Blatt
    private func animateFallendesBlatt(duration:TimeInterval = 1,completion:(()->Void)?){
        mainModel.animationen.geraetAnimationen.isScanning.value    = false
        UIView.animate(withDuration: duration, animations: { self.fallBlatt.frame = self.fallBlattFrameBottom })
        { _ in
            self.fallBlatt.isHidden = true
            self.addBlatt()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  completion?() }
        }
    }
    
    //helper
    private func animate(animation:BlattAnimation,completion:(()->Void)?){
        verdeckRechts.frame     = view.bounds
        verdeckLinks.frame      = view.bounds
        verdeckRechts.isHidden  = false
        verdeckLinks.isHidden   = false
        
        //Start und End Positionen der Verdecke
        var verdeckLinksStartX:CGFloat{
            if animation.blattAnimationTyp == .erscheinen {return animation.direction == .left ? 0 : -view.frame.width}
            return animation.direction == .left ? viewModel.verdeckLinksX(blattBreite: view.frame.width) : -view.frame.width
        }
        var verdeckRechtsStartX:CGFloat{
            if animation.blattAnimationTyp == .erscheinen { return animation.direction == .left ? view.frame.width : 0 }
            return animation.direction == .left ? view.frame.width : viewModel.verdeckRechtsX(blattBreite: view.frame.width)
        }
        var verdeckLinksEndX:CGFloat{
            if animation.blattAnimationTyp == .erscheinen { return -view.frame.width }
            return animation.direction == .left ?  viewModel.verdeckLinksX(blattBreite: view.frame.width) - view.frame.width  : 0
        }
        var verdeckRechtsEndX:CGFloat{
            if animation.blattAnimationTyp == .erscheinen { return view.frame.width }
            return animation.direction == .left ? 0 :  viewModel.verdeckRechtsX(blattBreite: view.frame.width) + view.frame.width
        }
        
        //Startposition setzen
        verdeckRechts.frame.origin.x    = verdeckRechtsStartX
        verdeckLinks.frame.origin.x     = verdeckLinksStartX
        
        //enimation zur Endposition
        UIView.animate(withDuration: animation.dauer, animations: {
            self.verdeckRechts.frame.origin.x    = verdeckRechtsEndX
            self.verdeckLinks.frame.origin.x     = verdeckLinksEndX
        }) { _ in
            self.verdeckRechts.isHidden  = true
            self.verdeckLinks.isHidden   = true
            completion?()
        }
    }
}


class PapierStapel:NibLoadingView{
    override var nibName: String{return "PapierStapel"}
    var viewModel:PapierStapelViewModel!{
        didSet{
            initFallBlatt()
            clipsToBounds = true
            //Stapel initial füllen
            for _ in 0 ..< viewModel.anzahlBlaetterInit{ addBlatt() }
            viewModel.animateBlatt = animate
        }
    }
    
    fileprivate func animate(_ blattAnimation:BlattAnimation){}
    
    //Stapel der Blätter
    private var blattStack  = [Blatt]() {didSet{viewModel.setBlattAnzahl(anzahlBlaetter: blattStack.count)}}
    private var lastBlatt:Blatt?    { return blattStack.last }
    private var newBlatt:Blatt{
        let blatt          = Blatt(superView: view, blattDicke: viewModel.blattDicke)
        blatt.viewModel    = viewModel.getViewModelForBlatt()
        setPositionBlattUndVerdeckViews()
        return blatt
    }
    fileprivate func addBlatt(){
        let blatt   = newBlatt
        
        //Constraints
        let blattAbstand:NSLayoutConstraint = {
            if let lastBlatt = lastBlatt {return lastBlatt.topAnchor.constraint(equalTo: blatt.bottomAnchor)}
            return view.bottomAnchor.constraint(equalTo: blatt.bottomAnchor)
        }()
        blattAbstand.isActive   = true
        blattAbstand.reactive.constant <~ viewModel.blattAbstand.producer
        
        //addToStack
        blattStack.append(blatt)
    }
    fileprivate func removeBlatt(){
        lastBlatt?.removeFromSuperview()
        blattStack.removeLast()
    }
    
    //Fallendes Blatt
    fileprivate var fallBlatt:UIView!
    fileprivate var fallBlattFrameTop:CGRect    { return CGRect(x: 0, y: 0, width: view.frame.width, height: viewModel.blattDicke) }
    fileprivate var fallBlattFrameBottom:CGRect {
        let y = lastBlatt == nil ? view.frame.height - viewModel.blattAbstand.value : lastBlatt!.frame.origin.y - viewModel.blattAbstand.value
        return CGRect(x: 0, y: y, width: view.frame.width, height: viewModel.blattDicke)
    }
    private func initFallBlatt(){
        fallBlatt                       = UIView()
        fallBlatt.backgroundColor       = .darkGray
        fallBlatt.frame                 = fallBlattFrameTop
        fallBlatt.isHidden              = true
        view.addSubview(fallBlatt)
    }
    
    //IBOutlets
    // VerdeckViews
    @IBOutlet weak var verdeckLinks: UIView!
    @IBOutlet weak var verdeckRechts: UIView!
    
    //MARK: helper
    fileprivate func setPositionBlattUndVerdeckViews(){
        guard let lastBlatt = lastBlatt else {return}
        view.sendSubview(toBack: verdeckLinks)
        view.sendSubview(toBack: verdeckRechts)
        view.sendSubview(toBack: lastBlatt)
    }
    fileprivate func setPositionFallBlattUndVerdeckViews(){
        view.sendSubview(toBack: verdeckLinks)
        view.sendSubview(toBack: verdeckRechts)
        view.sendSubview(toBack: fallBlatt)
    }
    
    //layoutSubViews
    override func layoutSubviews() { viewModel?.frame = view.frame }
}


//MARK: Blatt
class Blatt:NibLoadingView{
    var viewModel:BlattViewModel!{
        didSet{
            blattHaelfteLinks.viewModel     = viewModel.getViewModelForBlattHaelfte(blattHaelfte: .left)
            blattHaelfteRechts.viewModel    = viewModel.getViewModelForBlattHaelfte(blattHaelfte: .right)
        }
    }
    @IBOutlet fileprivate weak var blattHaelfteRechts: BlattHaelfte!
    @IBOutlet fileprivate weak var blattHaelfteLinks: BlattHaelfte!
    
    convenience init(superView:UIView,blattDicke:CGFloat) {
        self.init(frame: CGRect.zero)
        superView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive             = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive           = true
        heightAnchor.constraint(equalToConstant: blattDicke).isActive                   = true
    }
}


//MARK: BlattHaelfte
class BlattHaelfte:NibLoadingView{
    //ViewModel
    var viewModel:BlattHaelfteViewModel!    {
        didSet{
            clipsToBounds                   = true
            linkeSeiteView.backgroundColor  = viewModel.blattHaelfte == .left ? .black : .clear
            rechteSeiteView.backgroundColor = viewModel.blattHaelfte == .right ? .black : .clear
            viewModel.klappWinkel.producer.startWithValues{[weak self] winkel in self?.animateKlappen(winkel: winkel) }
        }
    }
    
    //Animation
    private func animateKlappen(winkel:CGFloat){
        let multiplicator:CGFloat   = viewModel.blattHaelfte == .left ? 1 : -1
        let angel                   = winkel * multiplicator
        UIView.animate(withDuration: 1) { self.transform = CGAffineTransform(rotationAngle: angel) }
    }
    
    //IBOutlets
    //eine Seite ist immer unsichtbar
    // damit sie beim klappen nicht gesehen wird
    @IBOutlet weak var linkeSeiteView: UIView!
    @IBOutlet weak var rechteSeiteView: UIView!
}




