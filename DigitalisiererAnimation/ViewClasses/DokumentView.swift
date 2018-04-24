//
//  DokumentView.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 26.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift


//MARK: DokumentView
class DokumentView:NibLoadingView{
    //ViewModel
    var viewModel:ScanAnzeigeDokumentViewModel!{
        didSet{
            clipsToBounds = true
            
            buchStabeLabel.reactive.text     <~ viewModel.buchstabeUndZahl.producer.map{($0 ?? BuchstabeUndZahl(title: nil)).buchstabe}
            zahlLabel.reactive.text          <~ viewModel.buchstabeUndZahl.producer.map{($0 ?? BuchstabeUndZahl(title: nil)).zahl}
            verdeckView.reactive.isHidden    <~ viewModel.isHidden.producer.map{!$0}
            viewModel.scanGestartet.signal.observeValues    { [weak self] _ in self?.scanAnimation() }
            viewModel.matching.signal.observeValues         { [weak self] _ in self?.setNeedsDisplay() }
            
            backGroundView.viewModel = viewModel.getViewModelForBackGround()
            
            viewModel.isHidden.producer.filter{$0}.startWithValues{[weak self] _ in self?.verdeckView.frame.origin = CGPoint.zero }
        }
    }
    
    //Animation
    func scanAnimation(duration:TimeInterval = mainModel.animationen.blattAnimationDauer){
        verdeckView.frame.origin = CGPoint.zero
        viewModel.matching.value = Matching.none
        var newFrame:CGRect{
            var _frame      = verdeckView.frame
            _frame.origin.y = verdeckView.frame.height
            return _frame
        }
        UIView.animate(withDuration: duration, animations: { self.verdeckView.frame = newFrame }) {_ in self.viewModel.setMatching() }
    }
    
    //IBOutlets
    @IBOutlet weak var buchStabeLabel: UILabel!
    @IBOutlet weak var zahlLabel: UILabel!
    @IBOutlet weak var verdeckView: UIView!
    @IBOutlet weak fileprivate var backGroundView: BackgroundView!
}

//MARK: BackGroundView
class BackgroundView:UIView{
    var viewModel:BackgroundViewModel!{ didSet{ viewModel.matching.signal.observeValues { [weak self] _ in self?.setNeedsDisplay() } } }
    override func draw(_ rect: CGRect) {
        guard viewModel != nil else {return}
        layer.borderColor   = UIColor.green.cgColor
        layer.borderWidth   = 0
        
        guard viewModel.matching.value != .none else {return}
        
        if viewModel.matching.value == .matchedNicht{
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: frame.width, y: frame.height))
            path.move(to: CGPoint(x: 0, y: frame.height))
            path.addLine(to: CGPoint(x: frame.width, y: 0))
            path.lineWidth = 5
            UIColor.red.set()
            path.stroke()
        }
        else{ layer.borderWidth = 5 }
    }
}

enum Matching{ case  matched,matchedNicht,none }
