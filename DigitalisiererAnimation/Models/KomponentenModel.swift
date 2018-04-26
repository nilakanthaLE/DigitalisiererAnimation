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
    let openedFach          = MutableProperty<AngefahrenesFach?>(nil)
    let updateFachHoehen    = MutableProperty<Int>(-1)
    
    let faecher:[FachModel]
    init(anzahlBlaetter:[Int]){
        faecher     = anzahlBlaetter.enumerated().map{FachModel(fachTyp: .einlagerungsFach($0.offset), anzahlBlaetter: $0.element)}
        openedFach.producer.startWithValues { [weak self] openedFach in self?.setOpenedFach(fuer: openedFach) }
    }
    
    private func setOpenedFach(fuer openedFach:AngefahrenesFach?){
        // schließt und öffnet
        // setzt EinzugsDirection
        for fach in faecher.enumerated(){
            fach.element.fachIsGeschlossen.value        = openedFach == nil || fach.offset != openedFach!.typ.fachID
            fach.element.einzugDirection.value          = (openedFach == nil || fach.offset != openedFach?.typ.fachID) ? .stop : openedFach!.einzugDirection
        }
        updateFachHoehen.value = openedFach == nil ? -1 : openedFach!.typ.fachID
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
    let isOberesFach:Bool
    init(fachTyp:FachTyp, anzahlBlaetter:Int){
        self.fachTyp            = fachTyp
        klappeDirection         = fachTyp.klappeDirection
        papierStapelModel       = PapierStapelModel(anzahlBlaetter:anzahlBlaetter, klappDirection: klappeDirection,klappWinkel:klappWinkel, fachIsGeschlossen: fachIsGeschlossen)
        isOberesFach            = fachTyp == .einlagerungsFach(0) || fachTyp == .beweglichesFachOben || fachTyp == .eingabeFach
    }
    
}

class ScanModulModel{
    //set
    let einzugDirection                 = MutableProperty<Direction>(.stop)
    let position                        = MutableProperty<Position>(.oben)
    let isScanning                      = MutableProperty<Bool>(false)
    let klappWalzeIsOpen                = MutableProperty<Bool>(false)
    init(position:MutableProperty<Position>,klappWalzeIsOpen:MutableProperty<Bool>,einzugDirection:MutableProperty<Direction>,
         isScanning:MutableProperty<Bool>){
        self.position           <~ position.signal
        self.klappWalzeIsOpen   <~ klappWalzeIsOpen.signal
        self.einzugDirection    <~ einzugDirection.signal
        self.isScanning         <~ isScanning.signal
    }
}

class VertikalBeweglichesFachModel{
    let oberesFach                  = FachModel(fachTyp: .beweglichesFachOben, anzahlBlaetter: 0)
    let unteresFach                 = FachModel(fachTyp: .beweglichesFachUnten, anzahlBlaetter: 0 )
    let obererEinzugDirection       = MutableProperty<Direction>(.stop)
    let untererEinzugDirection      = MutableProperty<Direction>(.stop)
    
    
    
    let scanModulModel:ScanModulModel
    let positionScanModul           = MutableProperty<Position>(.oben)
    let klappWalzeIsOpen            = MutableProperty<Bool>(false)
    let scanModulEinzugDirection    = MutableProperty<Direction>(.stop)
    
    init(angefahrenesFach:MutableProperty<AngefahrenesFach>,isScanning:MutableProperty<Bool>){
        scanModulModel = ScanModulModel(position: positionScanModul, klappWalzeIsOpen: klappWalzeIsOpen, einzugDirection: scanModulEinzugDirection, isScanning: isScanning)
        positionScanModul               <~ angefahrenesFach.signal.map{$0.typ.positionScanModul}
        obererEinzugDirection           <~ angefahrenesFach.producer.map{$0.typ.einzugDirectionObererEinzug}
        untererEinzugDirection          <~ angefahrenesFach.producer.map{$0.typ.einzugDirectionUntererEinzug}
        klappWalzeIsOpen                <~ angefahrenesFach.producer.map{$0.typ.klappWalzeIsOpen}
        scanModulEinzugDirection        <~ angefahrenesFach.producer.map{$0.typ.scanModulEinzugDirection}
        oberesFach.einzugDirection      <~ angefahrenesFach.producer.map{$0.typ.einzugDirectionOberesFach}
        unteresFach.einzugDirection     <~ angefahrenesFach.producer.map{$0.typ.einzugDirectionUnteresFach}
    }
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




