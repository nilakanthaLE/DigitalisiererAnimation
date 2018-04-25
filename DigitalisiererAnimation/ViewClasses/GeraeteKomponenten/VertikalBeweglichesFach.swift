//
//  VertikalBeweglichesFach.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 13.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa


@IBDesignable class VertikalBeweglichesFach:NibLoadingView{
    var viewModel:VertikalBeweglichesFachViewModel! {
        didSet{
            for width in einzuegeWidth{ width.reactive.constant <~ viewModel.widthWalze.producer }
            einzugOberesFachTopConstraint.reactive.constant     <~ viewModel.beweglichesFachObererEinzug.producer
            einzugUnteresFachTopConstraint.reactive.constant    <~ viewModel.beweglichesFachUnterEinzug.producer
            
            oberesFach.viewModel                = viewModel.getViewModelForFach(fachTyp: .beweglichesFachOben)
            unteresFach.viewModel               = viewModel.getViewModelForFach(fachTyp: .beweglichesFachUnten)
            obererEinzug.viewModel              = viewModel.getViewModelForEinzug(fachTyp: .beweglichesFachOben)
            untererEinzug.viewModel             = viewModel.getViewModelForEinzug(fachTyp: .beweglichesFachUnten)
            beweglicherDoppelEinzug.viewModel   = viewModel.getViewModelsForScanModul()
        }
    }

    //MARK: IBOutlets
    @IBOutlet private var einzuegeWidth: [NSLayoutConstraint]!
    @IBOutlet weak var obererEinzug: Einzug!
    @IBOutlet weak var untererEinzug: Einzug!
    @IBOutlet weak var oberesFach: FachMitKlappe!
    @IBOutlet weak var unteresFach: FachMitKlappe!
    @IBOutlet weak var beweglicherDoppelEinzug: BeweglicherDoppelEinzugScanModul!  
    @IBOutlet private weak var einzugOberesFachTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var einzugUnteresFachTopConstraint: NSLayoutConstraint!
    
    //Tap Gestures
    @IBAction func tapObererEinzug(_ sender: UITapGestureRecognizer)            { viewModel.fineTunerStarten(einzugIsOben: true) }
    @IBAction func tapUntererEinzug(_ sender: UITapGestureRecognizer)           { viewModel.fineTunerStarten(einzugIsOben: false) }
    
    override func layoutSubviews() {
        
    }
}

