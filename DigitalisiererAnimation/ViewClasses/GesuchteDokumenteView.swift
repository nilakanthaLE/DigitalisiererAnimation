//
//  GesuchteDokumenteView.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 27.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift



class DokumenteFindenUndScannenView:NibLoadingView{
    var viewModel:DokumenteFindenUndScannenViewModel!{
        didSet{
            gesuchteDokumenteView.viewModel = viewModel.gesuchteDokumenteViewModel
            scanDokumentView.viewModel      = viewModel.scanAnzeigeViewModel
        }
    }
    @IBOutlet weak var gesuchteDokumenteView: GesuchteDokumenteView!
    @IBOutlet weak var scanDokumentView: DokumentView!
}

class GesuchteDokumenteView:UIStackView{
    var viewModel:GesuchteDokumenteViewModel!{
        didSet{
            axis            = .vertical
            distribution    = .fillEqually
            viewModel.dokumentenAnzeigeMatrix.signal.observeValues{[weak self] viewModels in self?.setDokViewMatrix(viewModels: viewModels)}
            
        }
    }
    func setDokViewMatrix(viewModels:[[ScanAnzeigeDokumentViewModel]]){
        
        let viewMatrix = viewModels.map{$0.map{VM -> FlexiblesDokumentView in
            let view = FlexiblesDokumentView(frame: CGRect.zero)
            view.viewModel = VM
            return view
            }
        }
        let proZeile = viewMatrix.first?.count ?? 0
        for subview in arrangedSubviews {subview.removeFromSuperview()}
        let zeilen = viewMatrix.map{zeile -> UIStackView in
            var zeile = zeile as [UIView]
            let leerViews: [UIView] =  Array.init(repeating: UIView(), count: proZeile - zeile.count)
            zeile.append(contentsOf: leerViews)
            let newStackZeile           = UIStackView(arrangedSubviews: zeile)
            newStackZeile.axis          = .horizontal
            newStackZeile.distribution  = .fillEqually
            newStackZeile.spacing       = 4
            return newStackZeile
        }
        for zeile in zeilen{ addArrangedSubview(zeile) }
    }
}

//MARK: DokumentView
class FlexiblesDokumentView:NibLoadingView{
    var viewModel:ScanAnzeigeDokumentViewModel!{  didSet{ dokumentView.viewModel = viewModel  } }
    @IBOutlet weak var dokumentView: DokumentView!
}

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
        UIView.animate(withDuration: duration, animations: { self.verdeckView.frame = newFrame })
        {_ in self.viewModel.scanBeendet() }
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
        else{ layer.borderWidth = viewModel.isGesuchteDokumenteView ? 2 : 5 }
    }
}

enum Matching{ case  matched,matchedNicht,none }
