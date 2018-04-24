//
//  WalzeEinzugScannerViewModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 15.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

class BeweglichesScanModulViewModel{
    let abstandVonOben              = MutableProperty<CGFloat>(0)
    let position                    = MutableProperty<Position>(.oben)
    private let scanModulModel:ScanModulModel
    init(scanModulModel:ScanModulModel) {
        self.scanModulModel         = scanModulModel
        abstandVonOben              <~ scanModulModel.position.producer.map {mainModel.positionenUndFrames.fineTuningWerte.getAbstandScanModul(fuer: $0)}
        scanModulModel.position     <~ position.signal
        scanModulModel.position     <~ mainModel.positionenUndFrames.fineTuningWerte.fineTuningUpdate.signal.map{[weak self] _ in self?.position.value ?? .oben}
    }
    func setPosition(swipeDirection:UISwipeGestureRecognizerDirection)  { position.value    = swipeDirection == .up ? .oben : .unten }
    func getViewModelForScanModul() -> ScanModulViewModel               { return ScanModulViewModel(scanModulModel: scanModulModel) }
    
    func fineTunerStarten(){ mainModel.positionenUndFrames.fineTuningWerte.feinTuningFuerObjekt.value = position.value == .oben ? .ScanModulOben : .ScanModulUnten }
}

//MARK: ScanModul (mit KlappWalze)
class ScanModulViewModel{
    let isScanning                  = MutableProperty<Bool>(false)
    let einzugDirection             = MutableProperty<Direction>(.stop)
    let klappWalzeIsOpen            = MutableProperty<Bool>(false)
    
    init(scanModulModel:ScanModulModel) {
        self.isScanning             <~ scanModulModel.isScanning.signal
        self.einzugDirection        <~ scanModulModel.einzugDirection.signal
        self.klappWalzeIsOpen       <~ scanModulModel.klappWalzeIsOpen.signal
        mainModel.animationen.blattAnimationen.set(closure: animateBlattStueck, blattStueckTyp: .scanModul)
    }
    //ViewModel
    func getViewModelForKlappWalze() -> WalzeViewModel              { return WalzeViewModel(einzugDirection: einzugDirection,isOben:true)}
    func getViewModelForEinzugWalze(isOben:Bool) -> WalzeViewModel  { return WalzeViewModel(einzugDirection: einzugDirection,isOben:isOben)}
    
    //Animationen (Closure)
    var animateBlattStueck:((BlattAnimation)->Void)?                                                    //wird von View gesetzt
    private func animateBlattStueck(animation:BlattAnimation)       { animateBlattStueck?(animation) }  //wird von Animationen gecalled
}

//MARK: Einzüge
class EinzugViewModel{
    let einzugDirection = MutableProperty<Direction>(Direction.stop)
    init(einzugDirection:MutableProperty<Direction>,fachTyp:FachTyp) {
        self.einzugDirection <~ einzugDirection.producer
        mainModel.animationen.blattAnimationen.set(closure: animateBlattStueck, blattStueckTyp: fachTyp  ==  .beweglichesFachOben  ? .oberereinzug : .UntererEinzug )
    }
    //ViewModel
    func getViewModelForWalze(isOben:Bool) -> WalzeViewModel       { return WalzeViewModel(einzugDirection: einzugDirection,isOben:isOben) }
    
    //Animationen (Closure)
    var animateBlattStueck:((BlattAnimation)->Void)?                                                    //wird von View gesetzt
    private func animateBlattStueck(animation:BlattAnimation)       { animateBlattStueck?(animation) }  //wird von Animationen gecalled
}

//MARK: Walzen
class WalzeViewModel{
    let spinDirection     = MutableProperty(Direction.stop)
    init (einzugDirection:MutableProperty<Direction>,isOben:Bool)   { spinDirection   <~ einzugDirection.signal.map{isOben ? $0.opposite : $0} }
}
