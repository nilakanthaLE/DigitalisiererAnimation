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
    let geraetModel:GeraetModel
    let dokumentenStapelModel           = DokumentenStapelModel()
    
    
    //Animationen starten und beenden
    let angefahrenesFach                        = MutableProperty<AngefahrenesFach>(AngefahrenesFach(typ: .Eingabe))
    let eingabeFachEinzugDirection              = MutableProperty<Direction>(.stop)
    let oberesFachInVertikalBeweglichDirection  = MutableProperty<Direction>(.stop)
    let unteresFachInVertikalBeweglichDirection = MutableProperty<Direction>(.stop)
    
    //init
    init(){
        geraetModel = GeraetModel(dokumenteInEinlagerungsFaechern: dokumentenStapelModel.dokumenteInEinlagerungsFaechern)
        geraetModel.eingabeFach.einzugDirection                             <~ eingabeFachEinzugDirection.signal
        geraetModel.vertikalBeweglichesFach.oberesFach.einzugDirection      <~ oberesFachInVertikalBeweglichDirection.signal
        geraetModel.vertikalBeweglichesFach.unteresFach.einzugDirection     <~ unteresFachInVertikalBeweglichDirection.signal
        geraetModel.vertikalBeweglichesFach.obererEinzugDirection           <~ angefahrenesFach.producer.map{$0.typ.einzugDirectionObererEinzug}
        geraetModel.vertikalBeweglichesFach.untererEinzugDirection          <~ angefahrenesFach.producer.map{$0.typ.einzugDirectionUntererEinzug}
        geraetModel.angefahrenesFach                                        <~ angefahrenesFach.producer
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
    func update(dokument:Dokument? = nil, blattBewegungsTyp:BlattBewegungsTyp) -> Dokument?{
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
            guard nextEinlagerungsFach == fachID else {
                print ("update ObenZuEinlagerung -> nextEinlagerungsFach == fachID")
                return nil }
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
        return gesuchtInEinlagerung.enumerated().filter{$0.element.count > 0 }.map{GesuchteDokumenteInStapel(dokumente: $0.element, fachID: $0.offset)}
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
        case .eingabeFach:          dokumenteInEingabeFach.append(dokument)
        case .beweglichesFachOben:  dokumenteInOberesFachVertBeweglFach.append(dokument)
        case .beweglichesFachUnten: dokumenteInUnteresFachVertBeweglFach.append(dokument)
        case .einlagerungsFach(let fachID):
            dokument.einlagernInFach(fach: fachID, position: dokumenteInEinlagerungsFaechern[fachID].count)
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
    let angefahrenesFach    = MutableProperty<AngefahrenesFach>(AngefahrenesFach(typ: .Eingabe))
    let dokumentFuerScan    = MutableProperty<Dokument?>(nil)
    let dokumentGesucht     = MutableProperty<Dokument?>(nil)
    
    //Models
    let vertikalBeweglichesFach = VertikalBeweglichesFachModel()
    let eingabeFach             = FachModel(fachTyp: .eingabeFach, anzahlBlaetter: 0)
    let einlagerungsFaecher:EinlagerungsFaecherModel
    let scanAnzeigeModel:ScanAnzeigeDokumentModel
    let gesuchtesDokumentAnzeigeModel:ScanAnzeigeDokumentModel
    
    //init
    init(dokumenteInEinlagerungsFaechern:[[Dokument]]){
        einlagerungsFaecher             =  EinlagerungsFaecherModel( anzahlBlaetter: dokumenteInEinlagerungsFaechern.map{$0.count})
        scanAnzeigeModel                = ScanAnzeigeDokumentModel(scanAnzeigeTyp: .ScanAnzeige,dokumentProperty:dokumentFuerScan,gesucht:dokumentGesucht)
        gesuchtesDokumentAnzeigeModel   = ScanAnzeigeDokumentModel(scanAnzeigeTyp: .GesuchtesDokument,dokumentProperty:dokumentGesucht)
        
        vertikalBeweglichesFach.positionScanModul   <~ angefahrenesFach.signal.map{$0.typ.positionScanModul}
        einlagerungsFaecher.openedFach              <~ angefahrenesFach.signal
    }
    
}

//MARK: Dokument Scan Anzeige 
class ScanAnzeigeDokumentModel{
    
    
    let isHidden                = MutableProperty<Bool>(true)
    let buchstabeUndZahl        = MutableProperty<BuchstabeUndZahl?>(nil)
    
    let scanGestartet           = MutableProperty<Void>(Void())
    let matching                = MutableProperty<Matching>(.none)
    
    let ergebnisMatch           = MutableProperty<Matching>(.none)
    init(scanAnzeigeTyp:ScanAnzeigeTyp,dokument:Dokument? = nil,dokumentProperty:MutableProperty<Dokument?> = MutableProperty<Dokument?>(nil),gesucht:MutableProperty<Dokument?> = MutableProperty<Dokument?>(nil)){
        switch scanAnzeigeTyp{
        case .ScanAnzeige:
            isHidden            <~ dokumentProperty.producer.map{_ in true}
            matching            <~ dokumentProperty.producer.map{_ in .none}
            buchstabeUndZahl    <~ dokumentProperty.producer.map{ BuchstabeUndZahl(title: $0?.title)}
            scanGestartet       <~ dokumentProperty.producer.filter{ $0 != nil }.map{ _ in () }
            ergebnisMatch       <~ dokumentProperty.producer.map{ gesucht.value == nil ? .none : $0 == gesucht.value ? .matched : .matchedNicht}
        case .GesuchtesDokument:
            isHidden            <~ dokumentProperty.producer.map { $0 == nil }
            buchstabeUndZahl    <~ dokumentProperty.producer.map{ BuchstabeUndZahl(title: $0?.title)}
        case .NurAnsicht:
            isHidden.value              = false
            buchstabeUndZahl.value      = BuchstabeUndZahl(title:(dokument?.title))
        }
    }
    func setMatching(){ matching.value  = ergebnisMatch.value}
}



