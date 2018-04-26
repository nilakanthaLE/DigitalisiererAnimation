//
//  PapierStapelViewModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 15.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

//MARK: PapierStapel
class PapierStapelViewModel{
    let blattDicke                      = mainModel.positionenUndFrames.blattWerte.blattDicke
    let blattAbstand                    = MutableProperty<CGFloat>(0)
    let klappWinkelLinkeBlattHaelfte    = MutableProperty<CGFloat>(0)
    let klappWinkelRechteBlattHaelfte   = MutableProperty<CGFloat>(0)
    
    //init
    let anzahlBlaetterInit:Int
    let fachModel:FachModel
    init(fachModel:FachModel){
        self.fachModel                  = fachModel
        self.anzahlBlaetterInit         = fachModel.papierStapelModel.anzahlBlaetter.value
        blattAbstand                    <~ fachModel.fachIsGeschlossen.producer.map{ $0 ? mainModel.positionenUndFrames.blattWerte.blattAbstandGeschlossen : mainModel.positionenUndFrames.blattWerte.blattAbstandOffen }
        klappWinkelLinkeBlattHaelfte    <~ fachModel.papierStapelModel.klappWinkel.signal.filter{_ in fachModel.papierStapelModel.klappDirection == .left}
        klappWinkelRechteBlattHaelfte   <~ fachModel.papierStapelModel.klappWinkel.signal.filter{_ in fachModel.papierStapelModel.klappDirection == .right}
        
        //setzt den Klappwinkel in Fach
        let observer = Signal<Void, NoError>.Observer{[weak self] _ in  self?.setKlappWinkel() }
        fachModel.papierStapelModel.anzahlBlaetter.signal.map{_ in ()}.observe(observer)
        fachModel.einzugDirection.signal.map{_ in ()}.observe(observer)         
        
        
        
        //Animation Closures
        mainModel.animationen.blattAnimationen.set(closure: animateBlatt, fachTyp: fachModel.fachTyp)
    }
    
    //Klappwinkel berechnen und in Fach setzen
    // der Klappwinkel hängt vom Frame des Stapels ab
    var frame  = CGRect.zero {
        didSet{
            setKlappWinkel()
            mainModel.positionenUndFrames.laufZeitWerte.blattWidth = frame.width
        }
    } // wird von view gesetzt (layoutSubviews)
    func setKlappWinkel(){
        var winkel:CGFloat{
            guard fachModel.einzugDirection.value == fachModel.klappeDirection else {return 0}
            let stapelViewHoehe = frame.height
            let blattWidth      = frame.width
            let stapelHoehe     = mainModel.positionenUndFrames.getPapierStapelHoehe(anzahlBlaetter: fachModel.papierStapelModel.anzahlBlaetter.value, fachGeoeffnet: true)
            return atan( (stapelViewHoehe - stapelHoehe - 1) / (blattWidth / 2))
        }
        fachModel.klappWinkel.value = winkel
    }
    
    //Animationen (Closure)
    var animateBlatt:((BlattAnimation)->Void)?                                                          //wird von View gesetzt
    private func animateBlatt(animation:BlattAnimation)     { animateBlatt?(animation) }                //wird von Animationen gecalled
    
    
    //helper
    private func ueberLapp(blattBreite:CGFloat) -> CGFloat  { return (blattBreite / 2) - (cos(klappWinkelLinkeBlattHaelfte.value) * (blattBreite / 2)) }
    func verdeckLinksX(blattBreite:CGFloat) -> CGFloat      { return -blattBreite + ueberLapp(blattBreite:blattBreite) }
    func verdeckRechtsX(blattBreite:CGFloat) -> CGFloat     { return blattBreite - ueberLapp(blattBreite:blattBreite) }
    func setBlattAnzahl(anzahlBlaetter:Int)                 { fachModel.papierStapelModel.anzahlBlaetter.value = anzahlBlaetter }
    
    
    //ViewModels
    func getViewModelForBlatt() -> BlattViewModel{  return BlattViewModel(fachModel: fachModel) }
}


//MARK: Blatt
class BlattViewModel{
    //init
    var klappWinkel = MutableProperty<CGFloat>(0)
    let klappRichtung:Direction //ein Fach klappt immer nur in eine Richtung
    init( fachModel:FachModel ){
        klappRichtung   = fachModel.klappeDirection
        klappWinkel     <~ fachModel.klappWinkel.producer
    }
    
    //ViewModels
    func getViewModelForBlattHaelfte(blattHaelfte:Direction) -> BlattHaelfteViewModel{
        return BlattHaelfteViewModel(klappRichtung: klappRichtung, klappWinkel: klappWinkel, blattHaelfte:blattHaelfte)
    }
}

//MARK: BlattHaelfte
class BlattHaelfteViewModel{
    //für View relevant
    var klappWinkel             = MutableProperty<CGFloat>(0)
    
    //init
    let blattHaelfte:Direction
    init(klappRichtung:Direction, klappWinkel:MutableProperty<CGFloat>, blattHaelfte:Direction) {
        self.blattHaelfte   = blattHaelfte
        if klappRichtung == blattHaelfte { self.klappWinkel            <~ klappWinkel.producer }
    }
}



class BlattStueckViewModel{
    let blattStueckTyp:BlattStueckTyp
    init(blattStueckTyp:BlattStueckTyp) { self.blattStueckTyp = blattStueckTyp }
    func setBlattStueckWidth(width:CGFloat){
        switch blattStueckTyp{
        case .scanModul:        mainModel.positionenUndFrames.laufZeitWerte.blattStueckScannerWidth = width
        case .oberereinzug:     mainModel.positionenUndFrames.laufZeitWerte.blattStueckEinzugWidth  = width
        case .UntererEinzug:    mainModel.positionenUndFrames.laufZeitWerte.blattStueckEinzugWidth  = width
        }
        
    }
}
