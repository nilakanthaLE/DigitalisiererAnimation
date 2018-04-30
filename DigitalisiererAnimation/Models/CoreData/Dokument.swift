//
//  Dokument.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 26.03.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

import CoreData

extension Dokument{

    
    class func create(title:String) -> Dokument?{
        let request = NSFetchRequest<Dokument>.init(entityName: "Dokument")
        request.predicate = NSPredicate.init(format: "title == %@", title)
        if let dokument = (try? managedContext.fetch(request))?.first{
            return dokument
        }
         let dokument = NSEntityDescription.insertNewObject(forEntityName: "Dokument", into: managedContext) as? Dokument
        dokument?.title = title
        return dokument
    }
    class func getAll() -> [Dokument]{
        let request = NSFetchRequest<Dokument>.init(entityName: "Dokument")
        let all = (try? managedContext.fetch(request)) ?? [Dokument]()
        return all
    }
    
    class func createInitSet() -> [Dokument]{
        guard getAll().count == 0 else { return getAll()}
        
        var alphabet = createAlphabet(start: "a")
        alphabet.append(contentsOf: createAlphabet(start: "A"))
        
        var titles = [String]()
        for i in 0..<5{ titles.append(contentsOf: alphabet.map{"\($0)\(i)"}) }
        
        return titles.map{create(title: $0)!}
    }
    
    class func get(fach:Int) -> [Dokument]{
        let inFach = getAll().filter{$0.fachNr == fach}.sorted{$1.fachPos > $0.fachPos}
        for dokument in inFach.enumerated() { dokument.element.fachPos = Int16(dokument.offset) }
        return inFach
    }
    
    class func getNotInGeraet() -> [Dokument]{
        return getAll().filter{$0.fachNr == -1}.sorted{$0.einlagerungsDatum?.timeIntervalSince1970 ?? 0 > $1.einlagerungsDatum?.timeIntervalSince1970 ?? 0}
    }
    
    class func getInGeraet() -> [Dokument]{
        return getAll().filter{$0.fachNr != -1}.sorted{$0.einlagerungsDatum?.timeIntervalSince1970 ?? 0 > $1.einlagerungsDatum?.timeIntervalSince1970 ?? 0}
    }
    class func get(fach:Int,pos:Int) -> Dokument?{
        return getAll().filter{$0.fachNr == Int(fach) && $0.fachPos == Int(pos)}.first
    }
    
    class private func get(fuer typ:DokumentenAuswahlViewTyp) -> [Dokument]{
        switch typ{
        case .Eingabe: return getNotInGeraet()
        case .Herausfinden: return getInGeraet()
        }
    }
    class func getFiltered(fuer typ:DokumentenAuswahlViewTyp, tags:[Tag]) -> [Dokument]{
        guard tags.count > 0 else { return get(fuer: typ)}
        return get(fuer: typ).filter{$0.tagSet.intersection(Set(tags)) ==  Set(tags) }
    }
    
    func einlagernInFach(fach:Int,position:Int){
        self.fachNr         = Int16(fach)
        self.fachPos        = Int16(position)
        einlagerungsDatum   = Date()
        try? managedObjectContext?.save()
    }
    
    class func getDokumenteInAblagefaecher()->[[Dokument]]{
        //enthält Anzahl der EinlagerungsFaecher
        var ergebnis = [[Dokument]]()
        for i in 0 ..< anzahlEinlagerungsFaecher{ ergebnis.append(get(fach: i)) }
        return ergebnis
    }
    var tagSet:Set<Tag> { return tags as? Set<Tag> ?? Set<Tag>() }
    var tagArray:[Tag]  { return Array(tagSet) }
    

    class func addTag(_ tag:Tag, to dokumente:[Dokument]?){
        for dokument in dokumente ?? [Dokument]() { dokument.addToTags(tag) }
    }
    class func removeTag(_ tag:Tag, to dokumente:[Dokument]?){
        for dokument in dokumente ?? [Dokument]() { dokument.removeFromTags(tag) }
    }
    
    class func gemeinsameTags(in dokumente:[Dokument])-> [Tag]{
        let first = dokumente.first?.tagSet ?? Set<Tag>()
        return Array(dokumente.map{$0.tagSet}.reduce(first) {$0.intersection($1) }) }
    
    func wurdeHerausgegeben(){
        fachPos             = -1
        fachNr              = -1
        tags                = nil
        einlagerungsDatum   = nil
    }
    
}

private func createAlphabet(start:String) -> [String]{
    let aScalars = start.unicodeScalars
    let aCode = aScalars[aScalars.startIndex].value
    let letters: [Character] = (0..<26).map { i in Character(UnicodeScalar(aCode + i)!) }
    return letters.map{String($0)}
}
