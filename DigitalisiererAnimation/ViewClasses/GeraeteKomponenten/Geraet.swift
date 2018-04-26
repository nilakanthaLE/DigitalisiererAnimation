//
//  Geraet.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 14.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift


class GeraetInAktionVC:UIViewController{
    
}

//Geraet
@IBDesignable class Geraet:NibLoadingView{
    //ViewModel
    var viewModel:GeraetViewModel!{
        didSet{
            viewModel.beweglichesFachTopPosition.producer.startWithValues{[weak self] pos in self?.animateFachAnfahrt(constant: pos)}
            ablageFaecher.viewModel      = viewModel.getViewModelFuerEinlagerungsFaecher()
            eingabeFach.viewModel        = viewModel.getViewModelForEingabeFach()
            beweglichesFach.viewModel    = viewModel.getViewModelForVerticalBeweglichesFach()
            gesuchtesDokumentView.viewModel = viewModel.getGesuchtesDokumentViewModel()
            scanDokumentView.viewModel    = viewModel.getScanDokumentViewModel()
        }
    }
    
    //IBOutlets
    @IBOutlet weak var beweglichesFachTop: NSLayoutConstraint!
    @IBOutlet weak var ablageFaecher: EinlagerungsFaecher!
    @IBOutlet weak var eingabeFach: FachMitKlappe!
    @IBOutlet weak var beweglichesFach: VertikalBeweglichesFach!
    @IBOutlet weak var gesuchtesDokumentView: DokumentView!
    @IBOutlet weak var scanDokumentView: DokumentView!
    @IBOutlet weak var gehaeuse: UIView!{
        didSet{
            gehaeuse.layer.borderColor  = UIColor.darkGray.cgColor
            gehaeuse.layer.borderWidth  = 2
            gehaeuse.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var gehaeuseBackground: UIView!{
        didSet{
            gehaeuseBackground.layer.borderColor  = UIColor.darkGray.cgColor
            gehaeuseBackground.layer.borderWidth  = 2
            gehaeuseBackground.layer.cornerRadius = 8
            gehaeuseBackground.clipsToBounds        = true
        }
    }
    // Animationen
    func animateFachAnfahrt(constant:CGFloat){
        beweglichesFachTop.constant = constant
        UIView.animate(withDuration: 1)     { self.view.layoutIfNeeded() }
        
        if mainModel.isEditModus{
//            geraetModel.geoffenetesAblageFach.value             = geraetModel.angefahrenesFach.value
//            geraetModel.klappWalzeIsOpen.value                  = true
//            geraetModel.geoeffnetesAblageFachKlappeIsOpen.value = true
        }
    }
    
    //Gestures
    @IBAction func ablageFaecherDoppelTapped(_ sender: UITapGestureRecognizer) {
        print("ablageFaecherDoppelTapped")
//        model.initPostionView( point: nil, float: nil, fachID: geraetModel.angefahrenesFachID )
    }
}


