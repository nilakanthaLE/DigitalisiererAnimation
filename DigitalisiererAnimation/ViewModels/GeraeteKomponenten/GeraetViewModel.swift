//
//  KomponentenViewModels.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 13.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift



//MARK: Gerät
class GeraetViewModel{
    //für View relevant
    let beweglichesFachTopPosition  = MutableProperty<CGFloat>(0)
    
    //init
    let geraetModel:GeraetModel
    init(geraetModel:GeraetModel){
        self.geraetModel = geraetModel
        beweglichesFachTopPosition <~ geraetModel.angefahrenesFach.producer.map{mainModel.positionenUndFrames.getBeweglichesFachTopPosition(angefahrensFach: $0)}
        
        //delay, damit erst abstandZurWalzeInAngefahrenemEinalgerungsFach gestzt wird, bevor es hier Verwendung findet
        geraetModel.angefahrenesFach.producer.startWithValues {[weak self] angefahrenesFach in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self?.beweglichesFachTopPosition.value = mainModel.positionenUndFrames.getBeweglichesFachTopPosition(angefahrensFach: angefahrenesFach) }  }
        
    }
    
    //ViewModels
    func getViewModelForEingabeFach() -> FachMitKlappeUndPapierStapelViewModel              { return FachMitKlappeUndPapierStapelViewModel(fachModel: geraetModel.eingabeFach) }
    func getViewModelFuerEinlagerungsFaecher() -> EinlagerungsFaecherViewModel              { return EinlagerungsFaecherViewModel(einlagerungsFaecherModel: geraetModel.einlagerungsFaecher)}
    func getViewModelForVerticalBeweglichesFach() -> VertikalBeweglichesFachViewModel       { return VertikalBeweglichesFachViewModel(vertikalBeweglichesFachModel: geraetModel.vertikalBeweglichesFach)}
    func getViewModelForDokumenteFindenUndScannen() -> DokumenteFindenUndScannenViewModel   { return DokumenteFindenUndScannenViewModel(model: geraetModel.dokumenteFindenUndScannenModel)}
}








