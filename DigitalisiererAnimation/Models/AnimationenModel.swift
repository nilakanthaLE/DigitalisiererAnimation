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
    let blattAnimationDauer:TimeInterval = 0.75
    
    
    //Heraussuchen von Dokumenten
    func heraussuchen(dokumente:[Dokument]){
        var gesuchteDokumenteInStapel = mainModel.geraetInAktion.dokumentenStapelModel.getStapelUndDokumente(gesucht: dokumente)
        func erledigt()     { geraetAnimationen.startAnimation(blattBewegungsTyp: .Eingabe) }
        func herausgabe()   { umstapeln(blattBewegungsTyp: .Ausgabe, completion: erledigt) }
        func heraussuchenEinFach(){
            guard gesuchteDokumenteInStapel.count > 0 else {herausgabe(); return }
            //sucht alle gesuchten Dokumente eines Einlagerungsfachs heraus
            // lagert diese in unteres Fach zwischen
            let dokumenteInEinemStapel  = gesuchteDokumenteInStapel.removeFirst()
            var gesuchteDokumente       = dokumenteInEinemStapel.dokumente
            
            let dokInStapel = mainModel.geraetInAktion.dokumentenStapelModel.dokumenteInEinlagerungsFaechern[dokumenteInEinemStapel.fachID]
            print("dok in fach:\(dokInStapel.map{$0.title!}))")
            
            func einDokumentInStapelFinden(){
                guard gesuchteDokumente.count > 0 else {
                    //alle gesuchten Dokumente des Fachs liegen im unteren Fach
                    // stapelt alle Dokumente aus Fach oben zurück ins Einlagerungsfach
                    // -> danach eventuell mit nächstem Fach fortfahren
                    umstapeln(blattBewegungsTyp: .ObenZuEinlagerung(fachID: dokumenteInEinemStapel.fachID), completion: heraussuchenEinFach)
                    return}
                func gefundenesZwischenlagern(){ gesuchtesDokumentInUnteresFachZwischenLagern( einlagerungsFachID: dokumenteInEinemStapel.fachID, completion: einDokumentInStapelFinden) }
                //umstapeln, bis gefundenes oben im EinlagerungsFach liegt
                print("gesucht:\(gesuchteDokumente.last)")
                umstapeln(blattBewegungsTyp: .EinlagerungZuOben(fachID: dokumenteInEinemStapel.fachID),gesuchtesDokument:gesuchteDokumente.removeLast(), completion: gefundenesZwischenlagern)
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
                geraetAnimationen.startAnimation(blattBewegungsTyp: .Eingabe)
                return }
            guard let einlagerungsFachID = mainModel.geraetInAktion.dokumentenStapelModel.nextEinlagerungsFach else     { print("alle Fächer sind voll!");return }
            func einlagernEinFach() { umstapeln(blattBewegungsTyp: .ObenZuEinlagerung(fachID:einlagerungsFachID), completion: umstapelnEinlagerungsFaecher) }
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
    private func umstapeln(blattBewegungsTyp: BlattBewegungsTyp,gesuchtesDokument:Dokument,  completion:@escaping ()->Void){
        //BlattAnimationen
        var isLetzterTransport = false
        func einzelBlattTransport(){
            geraetAnimationen.animationIsBeendet = nil
            guard !isLetzterTransport, let transportiertesDokument = mainModel.geraetInAktion.dokumentenStapelModel.update( blattBewegungsTyp: blattBewegungsTyp)
                else { print("umstapeln: \(blattBewegungsTyp) --> dokumente im Stapel abgearbeitet)"); completion();return}
            print("umstapeln: \(blattBewegungsTyp) --> transportiertesDokument:\(transportiertesDokument.title!)")
            blattAnimationen.einzelBlattTransport(blattBewegungsTyp: blattBewegungsTyp,  completion: einzelBlattTransport)
            if (gesuchtesDokument == transportiertesDokument){isLetzterTransport = true}
        }
        //start
        //Gerätanimationen
        geraetAnimationen.startAnimation(blattBewegungsTyp: blattBewegungsTyp, completion:einzelBlattTransport )
        
    }
    private func umstapeln(blattBewegungsTyp: BlattBewegungsTyp,  completion:@escaping ()->Void){
        //BlattAnimationen
        func einzelBlattTransport(){
            geraetAnimationen.animationIsBeendet = nil
            guard let transportiertesDokument = mainModel.geraetInAktion.dokumentenStapelModel.update( blattBewegungsTyp: blattBewegungsTyp)
                else { print("umstapeln: \(blattBewegungsTyp) --> dokumente im Stapel abgearbeitet)"); completion();return}
            print("umstapeln: \(blattBewegungsTyp) --> transportiertesDokument:\(transportiertesDokument.title!)")
            blattAnimationen.einzelBlattTransport(blattBewegungsTyp: blattBewegungsTyp, completion: einzelBlattTransport)
        }
        //start
        //Gerätanimationen
        geraetAnimationen.startAnimation(blattBewegungsTyp: blattBewegungsTyp,completion:einzelBlattTransport )
    }
    private func umstapelnEinBlatt(blattBewegungsTyp: BlattBewegungsTyp, completion:@escaping ()->Void){
        //BlattAnimationen
        guard let transportiertesDokument = mainModel.geraetInAktion.dokumentenStapelModel.update( blattBewegungsTyp: blattBewegungsTyp )
            else { print("Fehler!!!!)"); completion();return}
        print("umstapelnEinBlatt: \(blattBewegungsTyp) --> transportiertesDokument:\(transportiertesDokument.title!)")
        func blattTransport() {blattAnimationen.einzelBlattTransport(blattBewegungsTyp: blattBewegungsTyp, completion: completion)}
        geraetAnimationen.startAnimation(blattBewegungsTyp: blattBewegungsTyp,completion:blattTransport )
    }
    
    private func gesuchtesDokumentInUnteresFachZwischenLagern(einlagerungsFachID:Int, completion:@escaping ()->Void){
        print("gesuchtesDokumentInUnteresFachZwischenLagern")
        func einlagerungZuUnten(){
            print("einlagerungZuUnten")
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
        let blattStueckVerschwinden = BlattAnimation(direction: closuresUndDirection.direction, blattAnimationTyp: .verschwinden, completion: nil)
        
        func vonAnimationBeendet(){ closuresUndDirection.blattStueck?(blattStueckVerschwinden)}
        let vonAnimation            = BlattAnimation(direction: closuresUndDirection.direction, blattAnimationTyp: .verschwinden, completion: vonAnimationBeendet)
        
        func blattStueckErscheinenBeendet(){ closuresUndDirection.zu(zuAnimation) }
        let blattStueckErscheinen   = BlattAnimation(direction: closuresUndDirection.direction, blattAnimationTyp: .erscheinen, completion: blattStueckErscheinenBeendet)

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
    
    
    private let eingabeFachEinzugIsGestartet                = MutableProperty<Bool>(false)
    private let eingabeOberesFachVertBeweglFachIsGestartet  = MutableProperty<Bool>(false)
    private let eingabeUnteresFachVertBeweglFachIsGestartet = MutableProperty<Bool>(false)
    private let angefahrensFachAnimation                    = MutableProperty<AngefahrenesFach>(AngefahrenesFach(typ: .isEingabe))
    
    init(geraetInAktion:GeraetInAktionModel) {
        geraetInAktion.eingabeFachEinzugDirection                 <~ eingabeFachEinzugIsGestartet.signal.map{$0 ? .right : .stop}
        geraetInAktion.oberesFachInVertikalBeweglichDirection     <~ eingabeOberesFachVertBeweglFachIsGestartet.signal.map{$0 ? .right : .stop}
        geraetInAktion.unteresFachInVertikalBeweglichDirection    <~ eingabeUnteresFachVertBeweglFachIsGestartet.signal.map{$0 ? .left : .stop}
        geraetInAktion.angefahrenesFach                           <~ angefahrensFachAnimation.signal
    }
    
    
    
    
    func startAnimation(blattBewegungsTyp:BlattBewegungsTyp,completion: (()->Void)? = nil) {
        animationIsBeendet = completion
        switch blattBewegungsTyp{
        case .Eingabe:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:.isEingabe)
            
        case .EingabeZuOben:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:.isEingabe)
            eingabeFachEinzugIsGestartet.value                  = true
            eingabeOberesFachVertBeweglFachIsGestartet.value    = false
            eingabeUnteresFachVertBeweglFachIsGestartet.value   = false
        case .ObenZuEinlagerung(let fachID):
            angefahrensFachAnimation.value = AngefahrenesFach(typ:.isEinlagerung,openedEinlagerungsFach:OpenedEinlagerungsFach(fachID: fachID, einzugDirection: .stop))
            eingabeFachEinzugIsGestartet.value                  = false
            eingabeOberesFachVertBeweglFachIsGestartet.value    = true
            eingabeUnteresFachVertBeweglFachIsGestartet.value   = false
        case .EinlagerungZuOben(let fachID):
            angefahrensFachAnimation.value = AngefahrenesFach(typ:.isEinlagerung,openedEinlagerungsFach:OpenedEinlagerungsFach(fachID: fachID, einzugDirection: .left))
            eingabeFachEinzugIsGestartet.value                  = false
            eingabeOberesFachVertBeweglFachIsGestartet.value    = false
            eingabeUnteresFachVertBeweglFachIsGestartet.value   = false
        case .EinlagerungZuUnten(let fachID):
            angefahrensFachAnimation.value = AngefahrenesFach(typ:.isEinlagerung,openedEinlagerungsFach:OpenedEinlagerungsFach(fachID: fachID, einzugDirection: .left))
            eingabeFachEinzugIsGestartet.value                  = false
            eingabeOberesFachVertBeweglFachIsGestartet.value    = false
            eingabeUnteresFachVertBeweglFachIsGestartet.value   = false
        case .Ausgabe:
            angefahrensFachAnimation.value = AngefahrenesFach(typ:.isAusgabe)
            eingabeFachEinzugIsGestartet.value                  = false
            eingabeOberesFachVertBeweglFachIsGestartet.value    = false
            eingabeUnteresFachVertBeweglFachIsGestartet.value   = true
        }
        animationIsBeendet?()
    }
}



fileprivate struct AnimationenClosuresUndDirection{
    let von:((BlattAnimation)->Void)?
    let zu:((BlattAnimation)->Void)
    let blattStueck:((BlattAnimation)->Void)?
    let direction:Direction
    init(model:BlattAnimationenModel, blattBewegungsTyp: BlattBewegungsTyp){
        switch blattBewegungsTyp{
            
        case .Eingabe:
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
