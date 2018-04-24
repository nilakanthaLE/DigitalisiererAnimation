//
//  KomponentenModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 12.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift







class EinlagerungsFaecherModel{
    let openedFach          = MutableProperty<OpenedEinlagerungsFach?>(nil)
    let updateFachHoehen    = MutableProperty<Int>(-1)
    
    let faecher:[FachModel]
    init(anzahlBlaetter:[Int]){
        faecher     = anzahlBlaetter.enumerated().map{FachModel(fachTyp: .einlagerungsFach($0.offset), anzahlBlaetter: $0.element)}
        openedFach.producer.startWithValues { [weak self] openedFach in self?.setOpenedFach(fuer: openedFach) }
    }
    
    private func setOpenedFach(fuer openedFach:OpenedEinlagerungsFach?){
        // schließt und öffnet
        // setzt EinzugsDirection
        for fach in faecher.enumerated(){
            fach.element.fachIsGeschlossen.value        = openedFach == nil || fach.offset != openedFach!.fachID
            fach.element.einzugDirection.value          = openedFach == nil || fach.offset == openedFach?.fachID ? .stop : openedFach!.einzugDirection
        }
        updateFachHoehen.value = openedFach == nil ? -1 : openedFach!.fachID
    }
}

class FachModel{
    //set
    let klappWinkel                     = MutableProperty<CGFloat>(0)           //wird  von papierStapelViewModel gesetzt
    let einzugDirection                 = MutableProperty<Direction>(.stop)
    let fachIsGeschlossen               = MutableProperty<Bool>(false)          //fuer Blatt Abstand in Stapel

    //init
    let klappeDirection:Direction
    let papierStapelModel:PapierStapelModel
    let fachTyp:FachTyp
    init(fachTyp:FachTyp, anzahlBlaetter:Int){
        self.fachTyp            = fachTyp
        klappeDirection         = fachTyp.klappeDirection
        papierStapelModel       = PapierStapelModel(anzahlBlaetter:anzahlBlaetter, klappDirection: klappeDirection,klappWinkel:klappWinkel, fachIsGeschlossen: fachIsGeschlossen)
    }
    
}

class ScanModulModel{
    //set
    let einzugDirection                 = MutableProperty<Direction>(.stop)
    let position                        = MutableProperty<Position>(.oben)
    let isScanning                      = MutableProperty<Bool>(false)
    let klappWalzeIsOpen                = MutableProperty<Bool>(false)
}

class VertikalBeweglichesFachModel{
    let oberesFach          = FachModel(fachTyp: .beweglichesFachOben, anzahlBlaetter: 0)
    let unteresFach         = FachModel(fachTyp: .beweglichesFachUnten, anzahlBlaetter: 0 )
    let scanModulModel      = ScanModulModel()
    let position            = MutableProperty<Position>(.oben)
}

class PapierStapelModel{
    //<get set>
    var anzahlBlaetter:MutableProperty<Int>

    //init
    let klappDirection:Direction
    let klappWinkel         = MutableProperty<CGFloat>(0)
    let fachIsGeschlossen   = MutableProperty<Bool>(false)
    init(anzahlBlaetter:Int = 0,klappDirection:Direction, klappWinkel:MutableProperty<CGFloat>,fachIsGeschlossen : MutableProperty<Bool>){
        self.anzahlBlaetter = MutableProperty<Int>(anzahlBlaetter)
        self.klappDirection = klappDirection
        self.klappWinkel        <~ klappWinkel.producer
        self.fachIsGeschlossen  <~ fachIsGeschlossen.producer
    }
    var stapelHoehe:CGFloat{ return mainModel.positionenUndFrames.getPapierStapelHoehe(anzahlBlaetter: anzahlBlaetter.value, fachGeoeffnet: !fachIsGeschlossen.value) }
}




