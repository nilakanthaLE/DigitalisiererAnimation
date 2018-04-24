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
    }
    
    //ViewModels
    func getViewModelForEingabeFach() -> FachMitKlappeUndPapierStapelViewModel          { return FachMitKlappeUndPapierStapelViewModel(fachModel: geraetModel.eingabeFach) }
    func getViewModelFuerEinlagerungsFaecher() -> EinlagerungsFaecherViewModel          { return EinlagerungsFaecherViewModel(einlagerungsFaecherModel: geraetModel.einlagerungsFaecher)}
    func getViewModelForVerticalBeweglichesFach() -> VertikalBeweglichesFachViewModel   { return VertikalBeweglichesFachViewModel(vertikalBeweglichesFachModel: geraetModel.vertikalBeweglichesFach)}
    func getScanDokumentViewModel()->ScanAnzeigeDokumentViewModel                       { return ScanAnzeigeDokumentViewModel(scanAnzeigeDokumentModel: geraetModel.scanAnzeigeModel)}
    func getGesuchtesDokumentViewModel()->ScanAnzeigeDokumentViewModel                  { return ScanAnzeigeDokumentViewModel(scanAnzeigeDokumentModel: geraetModel.gesuchtesDokumentAnzeigeModel) }
}

//MARK: DokumentView
class ScanAnzeigeDokumentViewModel{
    //für View relevant
    let buchstabeUndZahl                                = MutableProperty<BuchstabeUndZahl?>(nil)
    let scanGestartet                                   = MutableProperty(Void())
    let isHidden                                        = MutableProperty(false)
    let matching                                        = MutableProperty(Matching.none)
    
    let scanAnzeigeDokumentModel:ScanAnzeigeDokumentModel
    init(scanAnzeigeDokumentModel:ScanAnzeigeDokumentModel){
        self.scanAnzeigeDokumentModel = scanAnzeigeDokumentModel
        buchstabeUndZahl    <~ scanAnzeigeDokumentModel.buchstabeUndZahl.producer
        scanGestartet       <~ scanAnzeigeDokumentModel.scanGestartet.producer
        isHidden            <~ scanAnzeigeDokumentModel.isHidden.producer
        matching            <~ scanAnzeigeDokumentModel.matching.producer
    }
    
    func getViewModelForBackGround() -> BackgroundViewModel { return BackgroundViewModel(matching: matching) }
    func setMatching()                                      {  scanAnzeigeDokumentModel.setMatching()  }
}


//BackGroundView (für DokumentView)
class BackgroundViewModel{
    var matching = MutableProperty<Matching>(.none)
    init(matching: MutableProperty<Matching>){ self.matching <~ matching.producer }
}






