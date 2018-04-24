//
//  EnumsUndStructs.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 20.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreGraphics


enum TagVerwendung{
    case Filter,TagDokumente
    var opposite:TagVerwendung{ return self == .Filter ? .TagDokumente : .Filter}
}
enum DokumentenAuswahlViewTyp{ case Eingabe, Herausfinden }
struct EinlagerungsFaecherWerte{
    let abstandY:CGFloat                    = 50
}

struct BlattWerte{
    let blattDicke:CGFloat                  = 0.5
    let blattAbstandOffen:CGFloat           = 2.0
    let blattAbstandGeschlossen:CGFloat     = 1.0
    
}

struct FachWerte{
    //(Ablage)Faecher
    let klappenHoehe:CGFloat                = 3.0
    let freiraumLeeresAblagefach:CGFloat    = 3.0
    let geoffnetesAblageFachHoehe:CGFloat   = 100.0
}

struct EinlagerungsFachAnimation{
    let geoffentesFachID:Int
    let geoffnetesFachEingabeGestartet:Bool
}
struct OpenedEinlagerungsFach{
    let fachID:Int
    let einzugDirection:Direction
}
struct AngefahrenesFach{
    enum AngefahrenesFachTyp{ case isEingabe,isAusgabe,isEinlagerung }
    let typ:AngefahrenesFachTyp
    // für EinlagerungsFächer:
    let openedEinlagerungsFach:OpenedEinlagerungsFach
    
    init(typ:AngefahrenesFachTyp,openedEinlagerungsFach:OpenedEinlagerungsFach = OpenedEinlagerungsFach(fachID: -1, einzugDirection: .stop)){
        self.typ                    = typ
        self.openedEinlagerungsFach = openedEinlagerungsFach
    }
}


enum BlattBewegungsTyp:Equatable{ case Eingabe,EingabeZuOben,ObenZuEinlagerung(fachID:Int),EinlagerungZuOben(fachID:Int),EinlagerungZuUnten(fachID:Int),Ausgabe }
enum ObjektFuerFeinTuning   {
    case WalzeEingabeFach, WalzeLinksFachUnten, WalzeRechtsFachOben, WalzenEinlagerungsFaecher, ScanModulOben, ScanModulUnten, EinzugOben, EinzugUnten
    
    init(fachModel:FachModel){
        switch fachModel.fachTyp {
        case .eingabeFach:          self = .WalzeEingabeFach
        case .beweglichesFachOben:  self = .WalzeRechtsFachOben
        case .beweglichesFachUnten: self = .WalzeLinksFachUnten
        case .einlagerungsFach:     self = .WalzenEinlagerungsFaecher
        }
    }
}
enum ScanAnzeigeTyp         { case ScanAnzeige,GesuchtesDokument,NurAnsicht  }
enum FachTyp:Equatable{
    case eingabeFach,beweglichesFachOben,beweglichesFachUnten,einlagerungsFach(Int)
    var klappeDirection:Direction{
        switch self{
        case .eingabeFach:              return .right
        case .beweglichesFachOben:      return .right
        case .beweglichesFachUnten:     return .left
        case .einlagerungsFach:         return .left
        }
    }
    var rechteWalzeIsHidden:Bool{
        switch self{
        case .eingabeFach:              return false
        case .beweglichesFachOben:      return false
        case .beweglichesFachUnten:     return true
        case .einlagerungsFach:         return true
        }
    }
    var linkeWalzeIsHidden:Bool{
        switch self{
        case .eingabeFach:              return true
        case .beweglichesFachOben:      return true
        case .beweglichesFachUnten:     return false
        case .einlagerungsFach:         return true
        }
    }
    var isVertikalBeweglichesFach:Bool { return self == .beweglichesFachOben || self == .beweglichesFachUnten}
}




struct BuchstabeUndZahl{
    let buchstabe:String
    let zahl:String
    init(title:String?){
        buchstabe   = String((title ?? "A").first!)
        zahl        = String((title ?? "1").last!)
    }
}
struct GesuchteDokumenteInStapel{
    let dokumente:[Dokument]
    let fachID:Int
}
struct BlattAnimation{
    var dauer:TimeInterval = mainModel.animationen.blattAnimationDauer
    var direction:Direction
    var blattAnimationTyp: BlattAnimationTyp
    var einzelBlattEinzugAnimationBeendet:(()->Void)?
    var completion:(()->Void)? = nil
    var isGesuchtesDokument = false
    init(){
        direction                           = .stop
        blattAnimationTyp                   = .erscheinen
        einzelBlattEinzugAnimationBeendet   = nil
    }
    
    init(direction: Direction, blattAnimationTyp: BlattAnimationTyp, einzelBlattEinzugAnimationBeendet: (()->Void)?,isGesuchtesDokument:Bool = false){
        self.direction                          = direction
        self.blattAnimationTyp                  = blattAnimationTyp
        self.einzelBlattEinzugAnimationBeendet  = einzelBlattEinzugAnimationBeendet
        self.isGesuchtesDokument                = isGesuchtesDokument
    }
    init(direction: Direction, blattAnimationTyp: BlattAnimationTyp, completion: (()->Void)?,isGesuchtesDokument:Bool = false){
        self.direction                          = direction
        self.blattAnimationTyp                  = blattAnimationTyp
        self.completion                         = completion
        self.isGesuchtesDokument                = isGesuchtesDokument
    }
}

enum BlattAnimationTyp{ case erscheinen, verschwinden }
enum BlattStueckTyp{
    case scanModul,oberereinzug,UntererEinzug
    static func get(from fromStapel:FachTyp,to toStapel:FachTyp) -> BlattStueckTyp{
        if fromStapel   == .eingabeFach { return .oberereinzug}
        if toStapel     == .eingabeFach { return .UntererEinzug}
        return .scanModul
    }
}
enum Position:String{
    case unten = "unten" ,oben = "oben"
    var oposite:Position{
        switch self{
        case .unten: return .oben
        case .oben:  return .unten
        }
    }
}

enum Direction{
    case left,right,stop
    var opposite:Direction{
        switch self {
        case .left: return .right
        case .right: return .left
        case .stop: return .stop
        }
    }
}
