//
//  AblageFaecher.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 14.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift




@IBDesignable class EinlagerungsFaecher:NibLoadingView{
    var viewModel:EinlagerungsFaecherViewModel!{
        didSet{
            for fach in faecher{ fach.viewModel = viewModel.faecherViewModels[fach.tag] }
            
            func animateUpdateFachHoehen(new:[CGFloat]){
                for hoehe in fachHoehen         { hoehe.constant = new[Int(hoehe.identifier ?? "0")!] }
                UIView.animate(withDuration: 1) { self.view.layoutIfNeeded() }
            }
            viewModel.fachHoehen.producer.startWithValues{animateUpdateFachHoehen(new: $0)}
        }
    }
    @IBOutlet var faecher: [FachMitKlappe]!
    @IBOutlet var fachHoehen: [NSLayoutConstraint]!
    
}




