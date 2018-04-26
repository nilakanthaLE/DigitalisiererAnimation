//
//  EinlagerungsFaecherViewModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 15.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

//MARK: EinlagerungsFächer
class EinlagerungsFaecherViewModel{
    //für View relevant
    let fachHoehen:MutableProperty<[CGFloat]>
    let faecherViewModels:[FachMitKlappeUndPapierStapelViewModel]
    
    //init
    init(einlagerungsFaecherModel:EinlagerungsFaecherModel){
        fachHoehen                      = MutableProperty<[CGFloat]>(einlagerungsFaecherModel.faecher.map{_ in 0})
        faecherViewModels               = einlagerungsFaecherModel.faecher.map{FachMitKlappeUndPapierStapelViewModel(fachModel: $0)}
        
        
        einlagerungsFaecherModel.updateFachHoehen.producer.startWithValues{[weak self] fachID in self?.updateFachHoehen(fachID: fachID)}
    }
    
    private func updateFachHoehen(fachID:Int){
        // FachHoehen setzen
        fachHoehen.value = faecherViewModels.map{$0.getEinlagerungsFachHoehe() + ($0.fachModel.isOberesFach ? mainModel.positionenUndFrames.fachWerte.klappenHoehe : 0)}
        //setzt den aktuellen Abstand von View.top zur Walze des angefahrenen Einlagerungsfachs
        mainModel.positionenUndFrames.laufZeitWerte.abstandZurWalzeInAngefahrenemEinalgerungsFach = getWalzeYInGesamtView(von: fachID)
    }
    
    //helper
    private func getWalzeYInGesamtView(von fachID:Int)      -> CGFloat {
        guard fachID >= 0 else {return 0}
        let hoeheAblageFaecher  = fachHoehen.value.prefix(upTo: fachID).reduce(0, + )
        return hoeheAblageFaecher + mainModel.positionenUndFrames.fineTuningWerte.einlagerungsFachWalzePosition.y
    }
}
