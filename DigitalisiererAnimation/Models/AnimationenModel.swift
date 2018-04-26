//
//  AnimationenModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 12.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

class AnimationenModel{
    let blattAnimationDauer:TimeInterval = 2
    var dauerBlattStueckEinzuege:TimeInterval{ return Double( mainModel.positionenUndFrames.laufZeitWerte.blattStueckEinzugWidth / mainModel.positionenUndFrames.laufZeitWerte.blattWidth ) * blattAnimationDauer }
    var dauerBlattStueckScanner:TimeInterval{ return Double( mainModel.positionenUndFrames.laufZeitWerte.blattStueckScannerWidth / mainModel.positionenUndFrames.laufZeitWerte.blattWidth ) * blattAnimationDauer }
    
    
    //Heraussuchen von Dokumenten
    func heraussuchen(dokumente:[Dokument]){
        var gesuchteDokumenteInStapel = mainModel.geraetInAktion.dokumentenStapelModel.getStapelUndDokumente(gesucht: dokumente)
        func erledigt()     { geraetAnimationen.startAnimation(blattBewegungsTyp: .Initial) }
        func herausgabe()   { umstapeln(blattBewegungsTyp: .Ausgabe, completion: erledigt) }
        func heraussuchenEinFach(){
            print("-> heraussuchenEinFach gesuchteDokumenteInStapel.count: \(gesuchteDokumenteInStapel.count)")
            guard gesuchteDokumenteInStapel.count > 0 else {herausgabe(); return }
            //sucht alle gesuchten Dokumente eines Einlagerungsfachs heraus
            // lagert diese in unteres Fach zwischen
            let dokumenteInEinemStapel  = gesuchteDokumenteInStapel.removeFirst()
            var gesuchteDokumente       = dokumenteInEinemStapel.dokumente
            
            let dokInStapel = mainModel.geraetInAktion.dokumentenStapelModel.dokumenteInEinlagerungsFaechern[dokumenteInEinemStapel.fachID]
            
            func einDokumentInStapelFinden(){
                print("------> einDokumentInStapelFinden gesuchteDokumente.count: \(gesuchteDokumente.count)")
                guard gesuchteDokumente.count > 0 else {
                    //alle gesuchten Dokumente des Fachs liegen im unteren Fach
                    // stapelt alle Dokumente aus Fach oben zurück ins Einlagerungsfach
                    // -> danach eventuell mit nächstem Fach fortfahren
                    umstapeln(blattBewegungsTyp: .ObenZuEinlagerung(fachID: dokumenteInEinemStapel.fachID), completion: heraussuchenEinFach)
                    return}
                func gefundenesZwischenlagern(){ gesuchtesDokumentInUnteresFachZwischenLagern( einlagerungsFachID: dokumenteInEinemStapel.fachID, completion: einDokumentInStapelFinden) }
                //umstapeln, bis gefundenes oben im EinlagerungsFach liegt
                umstapeln(blattBewegungsTyp: .EinlagerungZuOben(fachID: dokumenteInEinemStapel.fachID),gesuchtesDokument:gesuchteDokumente.removeLast(), completion: gefundenesZwischenlagern,scannt:true)
            }
            einDokumentInStapelFinden()
        }
        //start
        guard let dokumenteInStapel = gesuchteDokumenteInStapel.first else {return}
        geraetAnimationen.startAnimation(blattBewegungsTyp: .EinlagerungZuOben(fachID: dokumenteInStapel.fachID), completion: heraussuchenEinFach)
    }
    
    
    //Einlagerung von Dokumenten
    func einlagerung(dokumente:[Dokument]){
        // von oberes Fach (Vert.bewegl) zu EinlagerungsFächer
        func umstapelnEinlagerungsFaecher(){
            guard mainModel.geraetInAktion.dokumentenStapelModel.dokumenteInOberesFachVertBeweglFach.count > 0 else {
                geraetAnimationen.startAnimation(blattBewegungsTyp: .Initial)
                return }
            guard let einlagerungsFachID = mainModel.geraetInAktion.dokumentenStapelModel.nextEinlagerungsFach else     { print("alle Fächer sind voll!");return }
            func einlagernEinFach() { umstapeln(blattBewegungsTyp: .ObenZuEinlagerung(fachID:einlagerungsFachID), completion: umstapelnEinlagerungsFaecher,scannt:true) }
            geraetAnimationen.startAnimation(blattBewegungsTyp: .ObenZuEinlagerung(fachID:einlagerungsFachID), completion: einlagernEinFach)
        }
        //von EingabeFach in oberes Fach (Vert.bewegl)
        func umstapelnInVertBewglFach() { umstapeln(blattBewegungsTyp: .EingabeZuOben, completion: umstapelnEinlagerungsFaecher) }
        //start
        eingabeInEingabeFach(dokumente: dokumente, completion: umstapelnInVertBewglFach)
    }
    
    //helper
    //Blätter in Einlagefach einlegen
    private func eingabeInEingabeFach(dokumente:[Dokument],completion:@escaping ()->Void){
        var dokumente = dokumente
        func animateEingabeBlatt(){
            geraetAnimationen.animationIsBeendet    = nil
            guard dokumente.count > 0 else { completion(); return}
            //Animationen
            blattAnimationen.einzelBlattTransport(blattBewegungsTyp: .Eingabe, completion: animateEingabeBlatt)
            //Stapel update
            _ = mainModel.geraetInAktion.dokumentenStapelModel.update(dokument: dokumente.removeFirst(), blattBewegungsTyp: .Eingabe)
        }
        //start
        //Gerätanimationen
        geraetAnimationen.startAnimation(blattBewegungsTyp: .Eingabe,completion:animateEingabeBlatt)
    }
    private func umstapeln(blattBewegungsTyp: BlattBewegungsTyp,gesuchtesDokument:Dokument,  completion:@escaping ()->Void, scannt:Bool = false){
        //BlattAnimationen
        var isLetzterTransport                      = false
        geraetAnimationen.isScanning.value          = false
        geraetAnimationen.dokumentGesucht.value = gesuchtesDokument
        func einzelBlattTransport(){
            geraetAnimationen.animationIsBeendet = nil
            guard !isLetzterTransport, let transportiertesDokument = mainModel.geraetInAktion.dokumentenStapelModel.update( blattBewegungsTyp: blattBewegungsTyp)
                else {
                    print("umstapeln: \(blattBewegungsTyp) --> dokumente im Stapel abgearbeitet)")
                    geraetAnimationen.isScanning.value          = false
                    completion()
                    return }
            
            if scannt {
                geraetAnimationen.dokumentFuerScan.value    = transportiertesDokument
                geraetAnimationen.isScanning.value          = true
            }
            print("umstapeln: \(blattBewegungsTyp) --> transportiertesDokument:\(transportiertesDokument.title!)")
            blattAnimationen.einzelBlattTransport(blattBewegungsTyp: blattBewegungsTyp,  completion: einzelBlattTransport)
            if (gesuchtesDokument == transportiertesDokument){isLetzterTransport = true}
        }
        //start
        //Gerätanimationen
        geraetAnimationen.startAnimation(blattBewegungsTyp: blattBewegungsTyp, completion:einzelBlattTransport )
        
    }
    private func umstapeln(blattBewegungsTyp: BlattBewegungsTyp,  completion:@escaping ()->Void, scannt:Bool = false){
        //BlattAnimationen
        func einzelBlattTransport(){
            geraetAnimationen.animationIsBeendet    = nil
            geraetAnimationen.isScanning.value      = false
            guard let transportiertesDokument = mainModel.geraetInAktion.dokumentenStapelModel.update( blattBewegungsTyp: blattBewegungsTyp)
                else {
                    print("umstapeln: \(blattBewegungsTyp) --> dokumente im Stapel abgearbeitet)")
                    geraetAnimationen.isScanning.value          = false
                    completion()
                    return}
            
            if scannt {
                geraetAnimationen.isScanning.value          = true
                geraetAnimationen.dokumentFuerScan.value    = transportiertesDokument}
            print("umstapeln: \(blattBewegungsTyp) --> transportiertesDokument:\(transportiertesDokument.title!)")
            blattAnimationen.einzelBlattTransport(blattBewegungsTyp: blattBewegungsTyp, completion: einzelBlattTransport)
        }
        //start
        //Gerätanimationen
        geraetAnimationen.startAnimation(blattBewegungsTyp: blattBewegungsTyp,completion:einzelBlattTransport )
    }
    private func umstapelnEinBlatt(blattBewegungsTyp: BlattBewegungsTyp, completion:@escaping ()->Void){
        //BlattAnimationen
        guard let transportiertesDokument = mainModel.geraetInAktion.dokumentenStapelModel.update( blattBewegungsTyp: blattBewegungsTyp,isUmstapelnEinBlatt:true )
            else { print("Fehler!!!!  \(blattBewegungsTyp)"); completion();return}
        print("umstapelnEinBlatt: \(blattBewegungsTyp) --> transportiertesDokument:\(transportiertesDokument.title!)")
        func blattTransport() {blattAnimationen.einzelBlattTransport(blattBewegungsTyp: blattBewegungsTyp, completion: completion)}
        geraetAnimationen.startAnimation(blattBewegungsTyp: blattBewegungsTyp,completion:blattTransport )
    }
    
    private func gesuchtesDokumentInUnteresFachZwischenLagern(einlagerungsFachID:Int, completion:@escaping ()->Void){
        print("gesuchtesDokumentInUnteresFachZwischenLagern fachID: \(einlagerungsFachID)")
        func einlagerungZuUnten(){
            geraetAnimationen.animationIsBeendet = nil
            // Dokument wird aus EinlagerungsFach ins untere Fach gelegt
            func aktion(){ umstapelnEinBlatt(blattBewegungsTyp: .EinlagerungZuUnten(fachID: einlagerungsFachID), completion: completion) }
            // Anfahrt Einlagerung -> unteresFach
            geraetAnimationen.startAnimation(blattBewegungsTyp: .EinlagerungZuUnten(fachID: einlagerungsFachID), completion: aktion)
        }
        //start
        // Dokument wird von Fachoben zurück ins EinlagerungsFach gelegt
        func obenZuEinlagerung() { umstapelnEinBlatt(blattBewegungsTyp: .ObenZuEinlagerung(fachID: einlagerungsFachID), completion: einlagerungZuUnten) }
        geraetAnimationen.startAnimation(blattBewegungsTyp: .ObenZuEinlagerung(fachID: einlagerungsFachID), completion: obenZuEinlagerung)
    }
    
    
    
    
    //Models
    let geraetAnimationen:GeraetAnimationen
    let blattAnimationen:BlattAnimationenModel
    init(anzahlEinlagerungsFaecher:Int,geraetInAktion:GeraetInAktionModel){
        blattAnimationen    = BlattAnimationenModel(anzahlEinlagerungsFaecher:anzahlEinlagerungsFaecher)
        geraetAnimationen   = GeraetAnimationen(geraetInAktion: geraetInAktion)
    }
    
}


class BlattAnimationenModel{
    func einzelBlattTransport(blattBewegungsTyp: BlattBewegungsTyp, completion:@escaping ()->Void){
        let closuresUndDirection    = AnimationenClosuresUndDirection(model: self, blattBewegungsTyp: blattBewegungsTyp)
        
        let zuAnimation             = BlattAnimation(direction: closuresUndDirection.direction, blattAnimationTyp: .erscheinen, completion: completion)
        let blattStueckVerschwinden = BlattAnimation(direction: closuresUndDirection.direction, blattAnimationTyp: .verschwinden, completion: nil,dauer:blattBewegungsTyp.dauerFuerBlattStueck)
        
        func vonAnimationBeendet(){ closuresUndDirection.blattStueck?(blattStueckVerschwinden)}
        let vonAnimation            = BlattAnimation(direction: closuresUndDirection.direction, blattAnimationTyp: .verschwinden, completion: vonAnimationBeendet)
        
        func blattStueckErscheinenBeendet(){ closuresUndDirection.zu(zuAnimation) }
        let blattStueckErscheinen   = BlattAnimation(direction: closuresUndDirection.direction, blattAnimationTyp: .erscheinen, completion: blattStueckErscheinenBeendet,dauer:blattBewegungsTyp.dauerFuerBlattStueck)

        //start
        closuresUndDirection.von?(vonAnimation)
        closuresUndDirection.blattStueck?(blattStueckErscheinen)
        
        //falls Eingabe in EingabeFach
        if blattBewegungsTyp == .Eingabe{ closuresUndDirection.zu(zuAnimation) }
    }
    
    //closures (werden von ViewModel gesetzt)
    func set(closure:@escaping ((BlattAnimation)->Void), blattStueckTyp:BlattStueckTyp? = nil ,fachTyp:FachTyp? = nil ){
        if let fachTyp = fachTyp {
            switch fachTyp{
                case .eingabeFach:                      blattAnimationEingabefach           = closure
                case .beweglichesFachOben:              blattAnimationBeweglichesFachOben   = closure
                case .beweglichesFachUnten:             blattAnimationBeweglichesFachUnten  = closure
                case .einlagerungsFach(let fachID):     blattAnimationAblagefaecher[fachID] = closure
            }
        }
        guard let blattStueckTyp = blattStueckTyp else { return }
        switch blattStueckTyp{
            case .scanModul: blattStueckAnimationScanModul                      = closure
            case .oberereinzug: blattStueckAnimationObererEinzug                = closure
            case .UntererEinzug: blattStueckAnimationUntererEinzug              = closure
        }
    }
    fileprivate var blattStueckAnimationObererEinzug:((BlattAnimation)->Void)       = {(animation:BlattAnimation) in Void()}
    fileprivate var blattStueckAnimationUntererEinzug:((BlattAnimation)->Void)      = {(animation:BlattAnimation) in Void()}
    fileprivate var blattStueckAnimationScanModul:((BlattAnimation)->Void)          = {(animation:BlattAnimation) in Void()}
    fileprivate var blattAnimationEingabefach:((BlattAnimation)->Void)              = {(animation:BlattAnimation) in Void()}
    fileprivate var blattAnimationBeweglichesFachOben:((BlattAnimation)->Void)      = {(animation:BlattAnimation) in Void()}
    fileprivate var blattAnimationBeweglichesFachUnten:((BlattAnimation)->Void)     = {(animation:BlattAnimation) in Void()}
    fileprivate var blattAnimationAblagefaecher:[((BlattAnimation)->Void)]
    
    init(anzahlEinlagerungsFaecher:Int){ blattAnimationAblagefaecher = Array.init(repeating: {(animation:BlattAnimation) in Void()} , count: anzahlEinlagerungsFaecher) }
}

class GeraetAnimationen{
    //wird von jeweiligem View gesetzt
    var animationIsBeendet:(()->())?
    
    let dokumentFuerScan    = MutableProperty<Dokument?>(nil)
    let dokumentGesucht     = MutableProperty<Dokument?>(nil)
    let isScanning          = MutableProperty<Bool>(false)
    
    private let angefahrensFachAnimation                    = MutableProperty<AngefahrenesFach>(AngefahrenesFach(typ: .Eingabe))
    
    init(geraetInAktion:GeraetInAktionModel) {
        geraetInAktion.angefahrenesFach                             <~ angefahrensFachAnimation.signal
        geraetInAktion.geraetModel.dokumentGesucht                  <~ dokumentGesucht.signal
        geraetInAktion.geraetModel.dokumentFuerScan                 <~ dokumentFuerScan.signal
        
        geraetInAktion.isScanning                                   <~ isScanning.signal
    }
    
    
   
    
    func startAnimation(blattBewegungsTyp:BlattBewegungsTyp,completion: (()->Void)? = nil) {
        animationIsBeendet      = completion
        
        switch blattBewegungsTyp{
        case .Eingabe:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:blattBewegungsTyp)
        case .EingabeZuOben:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:blattBewegungsTyp,einzugDirection:.right)
        case .ObenZuEinlagerung:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:blattBewegungsTyp,einzugDirection:.right)
        case .EinlagerungZuOben:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:blattBewegungsTyp,einzugDirection:.left)
        case .EinlagerungZuUnten:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:blattBewegungsTyp,einzugDirection:.left)
        case .Ausgabe:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:blattBewegungsTyp)
        case .Initial:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:blattBewegungsTyp)
            dokumentFuerScan.value                              = nil
            dokumentGesucht.value                               = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  self.animationIsBeendet?() }
    }
}



fileprivate struct AnimationenClosuresUndDirection{
    let von:((BlattAnimation)->Void)?
    let zu:((BlattAnimation)->Void)
    let blattStueck:((BlattAnimation)->Void)?
    let direction:Direction
    init(model:BlattAnimationenModel, blattBewegungsTyp: BlattBewegungsTyp){
        switch blattBewegungsTyp{
            
        case .Eingabe, .Initial:
            von         = nil
            zu          = model.blattAnimationEingabefach              //erscheinen
            blattStueck = nil
            direction   = .right
        case .EingabeZuOben:
            von         = model.blattAnimationEingabefach              //verschwinden
            zu          = model.blattAnimationBeweglichesFachOben      //erscheinen
            blattStueck = model.blattStueckAnimationObererEinzug
            direction   = .right
        case .ObenZuEinlagerung(let fachID):
            von         = model.blattAnimationBeweglichesFachOben
            zu          = model.blattAnimationAblagefaecher[fachID]
            blattStueck =  model.blattStueckAnimationScanModul
            direction   = .right
        case .EinlagerungZuOben(let fachID):
            von         = model.blattAnimationAblagefaecher[fachID]
            zu          = model.blattAnimationBeweglichesFachOben
            blattStueck =  model.blattStueckAnimationScanModul
            direction   = .left
        case .EinlagerungZuUnten(let fachID):
            von         = model.blattAnimationAblagefaecher[fachID]
            zu          = model.blattAnimationBeweglichesFachUnten
            blattStueck =  model.blattStueckAnimationScanModul
            direction   = .left
        case .Ausgabe:
            von         = model.blattAnimationBeweglichesFachUnten
            zu          = model.blattAnimationEingabefach
            blattStueck = model.blattStueckAnimationUntererEinzug
            direction   = .left
        }
    
    }
}
