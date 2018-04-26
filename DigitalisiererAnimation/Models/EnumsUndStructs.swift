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



struct EinlagerungsFachAnimation{
    let geoffentesFachID:Int
    let geoffnetesFachEingabeGestartet:Bool
}
struct OpenedEinlagerungsFach{
    let fachID:Int
    let einzugDirection:Direction
}
struct AngefahrenesFach{
    let typ:BlattBewegungsTyp
    let einzugDirection:Direction
    init(typ:BlattBewegungsTyp,einzugDirection:Direction = .stop){
        self.typ                    = typ
        self.einzugDirection        = einzugDirection
    }
    
    
}


enum BlattBewegungsTyp:Equatable{
    case Eingabe,EingabeZuOben,ObenZuEinlagerung(fachID:Int),EinlagerungZuOben(fachID:Int),EinlagerungZuUnten(fachID:Int),Ausgabe,Initial
    var fachID:Int{
        switch self{
        case .Eingabe: return -1
        case .EingabeZuOben: return -1
        case .ObenZuEinlagerung(let fachID):    return fachID
        case .EinlagerungZuOben(let fachID):    return fachID
        case .EinlagerungZuUnten(let fachID):   return fachID
        case .Ausgabe: return -1
        case .Initial:  return -1
        }
    }
    var positionScanModul:Position{
        switch self{
        case .Eingabe:              return .oben
        case .EingabeZuOben:        return .oben
        case .ObenZuEinlagerung:    return .oben
        case .EinlagerungZuOben:    return .oben
        case .EinlagerungZuUnten:   return .unten
        case .Ausgabe:              return .oben
        case .Initial:              return .oben
        }
    }
    var einzugDirectionEingabeFach:Direction    { return self == .EingabeZuOben ? .right : .stop }
    var einzugDirectionObererEinzug:Direction   { return self == .EingabeZuOben ? .right : .stop }
    var einzugDirectionUntererEinzug:Direction  { return self == .Ausgabe ? .left : .stop }
    var einzugDirectionOberesFach:Direction     {
        switch self{
        case .Eingabe,.EingabeZuOben,.Ausgabe,.Initial,.EinlagerungZuUnten,.EinlagerungZuOben:  return .stop
        case .ObenZuEinlagerung:                                                                return .right
        }
    }
    var einzugDirectionUnteresFach:Direction     {
        switch self{
        case .Eingabe,.EingabeZuOben,.ObenZuEinlagerung,.EinlagerungZuOben,.Initial,.EinlagerungZuUnten:    return .stop
        case .Ausgabe:                                                                                      return .left
        }
    }
    var dauerFuerBlattStueck:TimeInterval       {
        switch self{
        case .Eingabe:              return 0
        case .EingabeZuOben:        return mainModel.animationen.dauerBlattStueckEinzuege
        case .ObenZuEinlagerung:    return mainModel.animationen.dauerBlattStueckScanner
        case .EinlagerungZuOben:    return mainModel.animationen.dauerBlattStueckScanner
        case .EinlagerungZuUnten:   return mainModel.animationen.dauerBlattStueckScanner
        case .Ausgabe:              return mainModel.animationen.dauerBlattStueckEinzuege
        case .Initial:              return 0
        }
    }
    var klappWalzeIsOpen:Bool{
        switch self{
        case .Eingabe,.EingabeZuOben,.ObenZuEinlagerung,.Ausgabe,.Initial:  return false
        case .EinlagerungZuOben,.EinlagerungZuUnten:                        return true
        } 
    }
    var scanModulEinzugDirection:Direction{
        switch self{
        case .Eingabe,.EingabeZuOben,.Ausgabe,.Initial:                     return .stop
        case .ObenZuEinlagerung:                                            return .right
        case .EinlagerungZuOben:                                            return .left
        case .EinlagerungZuUnten:                                           return .left
        }
    }
    
}
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
    var dauer:TimeInterval
    var direction:Direction
    var blattAnimationTyp: BlattAnimationTyp
    var einzelBlattEinzugAnimationBeendet:(()->Void)?
    var completion:(()->Void)? = nil
    var isGesuchtesDokument = false
    
    init(direction: Direction, blattAnimationTyp: BlattAnimationTyp, einzelBlattEinzugAnimationBeendet: (()->Void)?,isGesuchtesDokument:Bool = false,dauer:TimeInterval = mainModel.animationen.blattAnimationDauer){
        self.dauer                              = dauer
        self.direction                          = direction
        self.blattAnimationTyp                  = blattAnimationTyp
        self.einzelBlattEinzugAnimationBeendet  = einzelBlattEinzugAnimationBeendet
        self.isGesuchtesDokument                = isGesuchtesDokument
    }
    init(direction: Direction, blattAnimationTyp: BlattAnimationTyp, completion: (()->Void)?,isGesuchtesDokument:Bool = false,dauer:TimeInterval = mainModel.animationen.blattAnimationDauer){
        self.dauer                              = dauer
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
