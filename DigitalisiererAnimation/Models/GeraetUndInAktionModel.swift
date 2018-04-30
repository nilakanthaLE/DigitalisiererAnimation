//
//  GeraetUndInAktionModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 15.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

//MARK: Gerät in Aktion
class GeraetInAktionModel{
    //Models
    let dokumentenStapelModel           = DokumentenStapelModel()
    
    
    //Animationen starten und beenden
    let angefahrenesFach                = MutableProperty<AngefahrenesFach>(AngefahrenesFach(typ: .Eingabe))
    let isScanning                      = MutableProperty<Bool>(false)
    
    //init
    let geraetModel:GeraetModel
    init(){
        geraetModel = GeraetModel(dokumenteInEinlagerungsFaechern: dokumentenStapelModel.dokumenteInEinlagerungsFaechern, angefahrenesFach: angefahrenesFach, isScanning: isScanning)
    }
}

//MARK: Dokumentenstapel
class DokumentenStapelModel{
    //Dokumentenstapel
    var dokumenteInEingabeFach:[Dokument]               = [Dokument]()
    var dokumenteInOberesFachVertBeweglFach:[Dokument]  = [Dokument]()
    var dokumenteInUnteresFachVertBeweglFach:[Dokument] = [Dokument]()
    var dokumenteInEinlagerungsFaechern:[[Dokument]]    = Dokument.getDokumenteInAblagefaecher()
    

    //DokumentenStapel Methoden und calc Properties
    var nextEinlagerungsFach:Int?{ // das erste Fach (von oben), das die Kapazität noch nicht erreicht hat (nil falls alle voll)
        return dokumenteInEinlagerungsFaechern.index { $0.count < mainModel.kapazitaetEinlagerungsFaecher }
    }
    

    //Stapel updaten
    func update(dokument:Dokument? = nil, blattBewegungsTyp:BlattBewegungsTyp, isUmstapelnEinBlatt:Bool = false) -> Dokument?{
        switch blattBewegungsTyp{
            
        case .Eingabe:
            guard let dokument = dokument else { return nil}
            add(dokument: dokument, zu: .eingabeFach)
            return dokument
        case .EingabeZuOben:
            guard let dokument = removeOberestesDokument(aus: .eingabeFach) else { return nil}
            add(dokument: dokument, zu: .beweglichesFachOben)
            return dokument
        case .ObenZuEinlagerung(let fachID):
            guard nextEinlagerungsFach == fachID || isUmstapelnEinBlatt else { return nil }
            guard let dokument = removeOberestesDokument(aus: .beweglichesFachOben) else { return nil}
            add(dokument: dokument, zu: .einlagerungsFach(fachID))
            return dokument
        case .EinlagerungZuOben(let fachID):
            guard let dokument = removeOberestesDokument(aus: .einlagerungsFach(fachID) ) else { return nil}
            add(dokument: dokument, zu: .beweglichesFachOben)
            return dokument
        case .EinlagerungZuUnten(let fachID):
            guard let dokument = removeOberestesDokument(aus: .einlagerungsFach(fachID) )else { return nil}
            add(dokument: dokument, zu: .beweglichesFachUnten)
            return dokument
        case .Ausgabe:
            guard let dokument = removeOberestesDokument(aus: .beweglichesFachUnten) else { return nil}
            add(dokument: dokument, zu: .eingabeFach)
            return dokument
        case .Initial: return nil
        }
    }
    
    //Dokumente herausfinden
    func getStapelUndDokumente(gesucht dokumente:[Dokument]) -> [GesuchteDokumenteInStapel] {
        let gesuchtInEinlagerung = dokumenteInEinlagerungsFaechern.map{ Array(Set($0).intersection(Set(dokumente))) }
        return gesuchtInEinlagerung.enumerated().filter{ $0.element.count > 0 }.map{GesuchteDokumenteInStapel(dokumente: $0.element, fachID: $0.offset)}
    }
    
    func getDokumente(fuer fachTyp:FachTyp) -> [Dokument]{
        switch fachTyp{
        case .eingabeFach:                      return dokumenteInEingabeFach
        case .beweglichesFachOben:              return dokumenteInOberesFachVertBeweglFach
        case .beweglichesFachUnten:             return dokumenteInUnteresFachVertBeweglFach
        case .einlagerungsFach(let fachID):     return dokumenteInEinlagerungsFaechern[fachID]
        }
    }
    private func add(dokument:Dokument, zu fachTyp:FachTyp) {
        switch fachTyp{
        case .eingabeFach:
            dokumenteInEingabeFach.append(dokument)
            dokument.wurdeHerausgegeben()
        case .beweglichesFachOben:  dokumenteInOberesFachVertBeweglFach.append(dokument)
        case .beweglichesFachUnten: dokumenteInUnteresFachVertBeweglFach.append(dokument)
        case .einlagerungsFach(let fachID):
            //nur wenn das Dokument von Außen kommt -> einlagern (sonst wird es nur umgestapelt)
            if dokument.fachNr == -1 { dokument.einlagernInFach(fach: fachID, position: dokumenteInEinlagerungsFaechern[fachID].count) }
            dokumenteInEinlagerungsFaechern[fachID].append(dokument)
        }
    }
    private func removeOberestesDokument(aus fachTyp:FachTyp) -> Dokument? {
        switch fachTyp{
        case .eingabeFach:
            guard dokumenteInEingabeFach.count > 0 else {return nil}
            return dokumenteInEingabeFach.removeLast()
        case .beweglichesFachOben:
            guard dokumenteInOberesFachVertBeweglFach.count  > 0 else {return nil}
            return dokumenteInOberesFachVertBeweglFach.removeLast()
        case .beweglichesFachUnten:
            guard dokumenteInUnteresFachVertBeweglFach.count  > 0 else {return nil}
            return dokumenteInUnteresFachVertBeweglFach.removeLast()
        case .einlagerungsFach(let fachID):
            guard dokumenteInEinlagerungsFaechern[fachID].count  > 0 else {return nil}
            return dokumenteInEinlagerungsFaechern[fachID].removeLast()
        }
    }
}



//MARK: Gerät
class GeraetModel{
    let dokumentFuerScan    = MutableProperty<Dokument?>(nil)
    let dokumenteGesucht    = MutableProperty<[Dokument]>([Dokument]())
    let angefahrenesFach    = MutableProperty<AngefahrenesFach>(AngefahrenesFach(typ: .Eingabe))
    //Models
    
    let eingabeFach         = FachModel(fachTyp: .eingabeFach, anzahlBlaetter: 0)
    let einlagerungsFaecher:EinlagerungsFaecherModel
    
    
    
    //init
    let dokumenteFindenUndScannenModel:DokumenteFindenUndScannenModel
    let vertikalBeweglichesFach:VertikalBeweglichesFachModel
    init(dokumenteInEinlagerungsFaechern:[[Dokument]],angefahrenesFach:MutableProperty<AngefahrenesFach>,isScanning:MutableProperty<Bool>){
        einlagerungsFaecher             = EinlagerungsFaecherModel( anzahlBlaetter: dokumenteInEinlagerungsFaechern.map{$0.count})
        dokumenteFindenUndScannenModel  = DokumenteFindenUndScannenModel(zuScannen: dokumentFuerScan, gesuchte: dokumenteGesucht)
        vertikalBeweglichesFach         = VertikalBeweglichesFachModel(angefahrenesFach: angefahrenesFach, isScanning: isScanning)
        self.angefahrenesFach           <~ angefahrenesFach.signal
        einlagerungsFaecher.openedFach  <~ angefahrenesFach.signal
        eingabeFach.einzugDirection     <~ angefahrenesFach.signal.map{$0.typ.einzugDirectionEingabeFach}
    }
    
}

//MARK: Dokument Scan Anzeige 
class ScanAnzeigeDokumentModel{
    
    let buchstabeUndZahl        = MutableProperty<BuchstabeUndZahl?>(nil)
    let isHidden                = MutableProperty<Bool>(true)
    
    
    let scanGestartet           = MutableProperty<Void>(Void())
    let scanBeendet             = MutableProperty<Void>(Void())
    let matching                = MutableProperty<Matching>(.none)
    
    
    //init
    init(dokument:Dokument? = nil){
        isHidden.value              = false
        buchstabeUndZahl.value      = BuchstabeUndZahl(title:(dokument?.title))
    }
    init (zuScannen:MutableProperty<Dokument?>,matching:MutableProperty<Matching>){
        isHidden            <~ zuScannen.signal.map{_ in true}  //zurücksetzen, bei neu
        buchstabeUndZahl    <~ zuScannen.signal.map{ BuchstabeUndZahl(title: $0?.title)}
        scanGestartet       <~ zuScannen.signal.filter{ $0 != nil }.map{ _ in () }
        self.matching       <~ matching.signal
    }
}

class GesuchteDokumenteModel{
    //Models
    let gesuchteDokumenteModels = MutableProperty<[ScanAnzeigeDokumentModel]> ([ScanAnzeigeDokumentModel]())
    //init
    init(gesuchte:MutableProperty<[Dokument]>,gefundene:MutableProperty<[Dokument]>){
        gesuchteDokumenteModels <~ gesuchte.signal.map{$0.map{ ScanAnzeigeDokumentModel(dokument: $0) } }
        gefundene.signal.observeValues { [weak self] dokumente in self?.setMatching(fuer: dokumente) }
    }
    //helper
    func setMatching(fuer gefundene:[Dokument]){
        let models = gesuchteDokumenteModels.value.filter{gefundene.map{BuchstabeUndZahl(title: $0.title)}.contains($0.buchstabeUndZahl.value) }
        for model in models{ model.matching.value = .matched }
    }
}

class DokumenteFindenUndScannenModel{
    fileprivate let matching    = MutableProperty<Matching>(.none)
    fileprivate let gefundene   = MutableProperty<[Dokument]>([Dokument]())
    
    let scanAnzeigeModel:ScanAnzeigeDokumentModel
    let gesuchteDokumenteModel:GesuchteDokumenteModel
    init(zuScannen:MutableProperty<Dokument?>,gesuchte: MutableProperty<[Dokument]> ){
        
        
        scanAnzeigeModel        = ScanAnzeigeDokumentModel(zuScannen: zuScannen,matching:matching)
        gesuchteDokumenteModel  = GesuchteDokumenteModel(gesuchte: gesuchte, gefundene: gefundene)
        scanAnzeigeModel.scanBeendet.signal.observe {[weak self] _ in self?.scanBeendet(zuScannen: zuScannen.value, gesuchte: gesuchte.value) }
    }
    
    func scanBeendet(zuScannen:Dokument?,gesuchte:[Dokument]){
        matching.value  = DokumenteFindenUndScannenModel.matchErgebnis(fuer: zuScannen, in: gesuchte)
        gefundene.value = DokumenteFindenUndScannenModel.gefunden(fuer: zuScannen, in: gesuchte, bisherGefunden: gefundene.value)
    }
    static func gefunden(fuer dokument:Dokument?, in gesucht:[Dokument],bisherGefunden:[Dokument]) -> [Dokument]{
        var bisherGefunden = bisherGefunden
        if matchErgebnis(fuer: dokument, in: gesucht) == .matched { bisherGefunden.append(dokument!) }
        return bisherGefunden
    }
    static func matchErgebnis(fuer dokument:Dokument?, in gesucht:[Dokument]) -> Matching{
        guard let dokument = dokument else { return .none}
        return Array(Set(gesucht).intersection(Set([dokument]))).count == 0 ? .matchedNicht : .matched
    }
}
