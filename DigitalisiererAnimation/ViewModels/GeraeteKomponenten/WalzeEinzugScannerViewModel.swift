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
    let klappWalzeDirection         = MutableProperty<Direction>(.stop)
    let klappWalzeIsOpen            = MutableProperty<Bool>(false)
    let blattStueckDicke            = mainModel.positionenUndFrames.blattWerte.blattDicke
    
    init(scanModulModel:ScanModulModel) {
        self.isScanning             <~ scanModulModel.isScanning.signal
        self.einzugDirection        <~ scanModulModel.einzugDirection.signal
        self.klappWalzeIsOpen       <~ scanModulModel.klappWalzeIsOpen.signal
        klappWalzeDirection         <~ einzugDirection.signal.map{scanModulModel.klappWalzeIsOpen.value ? $0 : .stop}
        mainModel.animationen.blattAnimationen.set(closure: animateBlattStueck, blattStueckTyp: .scanModul)
    }
    //ViewModel
    func getViewModelForKlappWalze() -> WalzeViewModel              { return WalzeViewModel(einzugDirection: klappWalzeDirection,isOben:true)}
    func getViewModelForEinzugWalze(isOben:Bool) -> WalzeViewModel  { return WalzeViewModel(einzugDirection: einzugDirection,isOben:isOben)}
    func getViewModelForScanTeil()->ScanTeilViewModel               { return ScanTeilViewModel(isScanning: isScanning)}
    
    //Animationen (Closure)
    var animateBlattStueck:((BlattAnimation)->Void)?                                                    //wird von View gesetzt
    private func animateBlattStueck(animation:BlattAnimation)       { animateBlattStueck?(animation) }  //wird von Animationen gecalled
}
class ScanTeilViewModel{
    let isScanning                  = MutableProperty<Bool>(false)
    init(isScanning:MutableProperty<Bool>){  self.isScanning <~ isScanning  }
}


//MARK: Einzüge
class EinzugViewModel{
    let blattStueckDicke            = mainModel.positionenUndFrames.blattWerte.blattDicke
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
