//
//  FachUndKlappe.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 15.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

//MARK: Fach mit Klappe und PapierStapel
class FachMitKlappeUndPapierStapelViewModel{
    let fachHoehen              = MutableProperty<CGFloat>(0) //wird von View gesetzt (layoutSubViews)
    let rechteWalzePosition     = MutableProperty<CGPoint>(CGPoint.zero)
    let linkeWalzePosition      = MutableProperty<CGPoint>(CGPoint.zero)
    let fachIsGeschlossen       = MutableProperty<Bool>(false)
    let widthWalze              = MutableProperty<CGFloat>(10)
    let linkeWalzeIsHidden:Bool
    let rechtewalzeIsHidden:Bool
    let isOberesFach:Bool
    
    //init
    let fachModel:FachModel
    init(fachModel:FachModel) {
        self.fachModel  = fachModel
        fachIsGeschlossen   <~ fachModel.fachIsGeschlossen.signal
        if fachModel.fachTyp.isVertikalBeweglichesFach { fachHoehen.producer.startWithValues{mainModel.positionenUndFrames.laufZeitWerte.hoeheFaecherInVertBeweglFach = $0 } }
        widthWalze          <~ mainModel.positionenUndFrames.laufZeitWerte.widthWalze.producer
        linkeWalzeIsHidden  = fachModel.fachTyp.linkeWalzeIsHidden
        rechtewalzeIsHidden = fachModel.fachTyp.rechteWalzeIsHidden
        isOberesFach        = fachModel.isOberesFach
        
        func updateWalzenPos(){
            linkeWalzePosition.value    = mainModel.positionenUndFrames.fineTuningWerte.getWalzenPos(fuer: fachModel.fachTyp)
            rechteWalzePosition.value   = mainModel.positionenUndFrames.fineTuningWerte.getWalzenPos(fuer: fachModel.fachTyp)
        }
        mainModel.positionenUndFrames.fineTuningWerte.fineTuningUpdate.producer.start(){ _ in updateWalzenPos() }
    }
    
    //ViewModels
    func getViewModelForWalze()-> WalzeViewModel                                { return WalzeViewModel(einzugDirection: fachModel.einzugDirection, isOben: true)}
    func getViewModelForKlappe(isPseudoKlappe:Bool = false) ->KlappeViewModel   { return KlappeViewModel(fachModel: fachModel,isPseudoKlappe:isPseudoKlappe) }
    func getViewModelForPapierStapel() -> PapierStapelViewModel                 { return PapierStapelViewModel(fachModel: fachModel)  }
    
    //helper
    func getEinlagerungsFachHoehe()->CGFloat{
        switch fachModel.fachIsGeschlossen.value{
        case true:  return fachModel.papierStapelModel.stapelHoehe + mainModel.positionenUndFrames.fachWerte.klappenHoehe + (fachModel.papierStapelModel.stapelHoehe > 0 ? 0 : mainModel.positionenUndFrames.fachWerte.freiraumLeeresAblagefach)
        case false: return mainModel.positionenUndFrames.fachWerte.geoffnetesAblageFachHoehe
        }
    }
    func fineTunerFuerWalzeStarten(){  mainModel.positionenUndFrames.fineTuningWerte.feinTuningFuerObjekt.value = ObjektFuerFeinTuning(fachModel: fachModel) }
}

//MARK: Klappe
class KlappeViewModel{
    var klappWinkel = MutableProperty<CGFloat>(0)
    
    //init
    let direction:Direction
    init(fachModel:FachModel, isPseudoKlappe:Bool = false){
        self.direction      = isPseudoKlappe ?  fachModel.klappeDirection.opposite : fachModel.klappeDirection
        if !isPseudoKlappe{ self.klappWinkel    <~ fachModel.klappWinkel.signal }
    }
}
