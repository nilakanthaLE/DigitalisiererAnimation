//
//  VertBeweglFachViewModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 15.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

//MARK: vertikal bewegliches (Doppel)Fach mit Scanmodul und Einzügen
class VertikalBeweglichesFachViewModel{
    let beweglichesFachObererEinzug = MutableProperty<CGFloat>(0)
    let beweglichesFachUnterEinzug  = MutableProperty<CGFloat>(0)
    let widthWalze                  = MutableProperty<CGFloat>(0)
    //models
    let scanModulModel:ScanModulModel
    let oberesFachModel:FachModel
    let unteresFachModel:FachModel
    
    //init
    let vertikalBeweglichesFachModel:VertikalBeweglichesFachModel
    init( vertikalBeweglichesFachModel:VertikalBeweglichesFachModel){
        self.vertikalBeweglichesFachModel   = vertikalBeweglichesFachModel
        oberesFachModel                     = vertikalBeweglichesFachModel.oberesFach
        unteresFachModel                    = vertikalBeweglichesFachModel.unteresFach
        scanModulModel                      = vertikalBeweglichesFachModel.scanModulModel
        
        scanModulModel.position.producer.startWithValues{mainModel.positionenUndFrames.setKlappWalzeYInGesamtView(fuer: $0)}
        widthWalze  <~ mainModel.positionenUndFrames.laufZeitWerte.widthWalze.producer
        mainModel.positionenUndFrames.fineTuningWerte.fineTuningUpdate.producer.startWithValues {[weak self]_ in
            self?.beweglichesFachObererEinzug.value   = mainModel.positionenUndFrames.fineTuningWerte.beweglichesFachObererEinzug
            self?.beweglichesFachUnterEinzug.value    = mainModel.positionenUndFrames.fineTuningWerte.beweglichesFachUnterEinzug
        }
    }
    
    //ViewModels
    func getFachModel(fachTyp:FachTyp)->FachModel   { return fachTyp == .beweglichesFachOben ? oberesFachModel : unteresFachModel}
    func getViewModelForFach(fachTyp:FachTyp) -> FachMitKlappeUndPapierStapelViewModel  { return FachMitKlappeUndPapierStapelViewModel(fachModel: getFachModel(fachTyp:fachTyp)) }
    func getViewModelsForScanModul() -> BeweglichesScanModulViewModel                   { return BeweglichesScanModulViewModel(scanModulModel: scanModulModel) }
    func getViewModelForEinzug(fachTyp:FachTyp) -> EinzugViewModel                      { return EinzugViewModel(einzugDirection: fachTyp == .beweglichesFachOben ? vertikalBeweglichesFachModel.obererEinzugDirection : vertikalBeweglichesFachModel.untererEinzugDirection, fachTyp: fachTyp) }
    
    
    //FineTuning
    func fineTunerStarten(einzugIsOben:Bool){ mainModel.positionenUndFrames.fineTuningWerte.feinTuningFuerObjekt.value = einzugIsOben ? .EinzugOben : .EinzugUnten }
}
