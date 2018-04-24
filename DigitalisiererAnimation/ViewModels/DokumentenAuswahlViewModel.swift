//
//  DokumentenAuswahlViewModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 23.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

//DokumentenAuswahlModel
class DokumentenAuswahlModel{
    let tagVerwendung       = MutableProperty<TagVerwendung>(.TagDokumente)
    
    let gefilterteTags      = MutableProperty<[Tag]>([Tag]())
    let gewaehlteTags       = MutableProperty<[Tag]>([Tag]())
    
    let tagsGewaehltAlsFilter   = MutableProperty<[Tag]>([Tag]())
    let tagsGewaehltFuerTagging = MutableProperty<[Tag]>([Tag]())
    
    let gewaehlteDokumente  = MutableProperty<[Dokument]>([Dokument]())
    let gefilterteDokumente = MutableProperty<[Dokument]>([Dokument]())
    
    let einUndAusgabeTitlePart:String
    let dokumentenAuswahlViewTyp:DokumentenAuswahlViewTyp
    
    let updateDokumentenCollectionView  = MutableProperty<Void>(Void())
    init(typ:DokumentenAuswahlViewTyp){
        dokumentenAuswahlViewTyp    = typ
        einUndAusgabeTitlePart      = typ == .Eingabe ? "zuführen" : "herausgeben"
        gefilterteDokumente.value   = Dokument.getFiltered(fuer: typ, tags: [Tag]())
        
        var verwendung:TagVerwendung { return tagVerwendung.value }
        
        
        
        
        //Tags
        gewaehlteTags           <~ tagVerwendung.signal.map{_ in [Tag]()}
        gefilterteTags          <~ tagVerwendung.signal.map{_ in Tag.getAll()}
        
        //Filtern
        tagsGewaehltAlsFilter   <~ tagVerwendung.signal.map{_ in [Tag]()} //zurücksetzen
        tagsGewaehltAlsFilter   <~ gewaehlteTags.signal.filter{_ in verwendung == .Filter}
        gefilterteDokumente     <~ tagsGewaehltAlsFilter.signal.map{Dokument.getFiltered(fuer: typ, tags: $0)}
        
        //Taggen
        var _gewaehlteDokumente:[Dokument]{return gewaehlteDokumente.value}
//        tagsGewaehltFuerTagging <~ tagVerwendung.signal.map{_ in [Tag]()} //zurücksetzen
//        tagsGewaehltFuerTagging <~ gewaehlteTags.signal.filter{ _ in verwendung == .TagDokumente}
//        tagsGewaehltFuerTagging.signal.observeValues {[weak self] tags in
//            Dokument.setTags(tags, for: _gewaehlteDokumente)
//        }
        
        
        
        //Dokumente gewählt -> Tags (allen Dokumenten gleich) setzen
        gewaehlteTags           <~ gewaehlteDokumente.signal.filter{_ in verwendung == .TagDokumente}.map{Dokument.gemeinsameTags(in: $0)}

    }
    
    static func arrayForIndizes<T>(indizes:Set<IndexPath>,array:[T]) -> [T] { return array.enumerated().filter{ indizes.contains(IndexPath.init(row: $0.offset, section: 0)) }.map{$0.element} }
    func dokumenteEinOderAusgeben(){
        switch dokumentenAuswahlViewTyp {
            case .Eingabe:          mainModel.animationen.einlagerung(dokumente: gewaehlteDokumente.value)
            case .Herausfinden:     mainModel.animationen.heraussuchen(dokumente: gewaehlteDokumente.value)
        }
    }
    
    func tagging(neueUserWahl:Set<Tag>){
        guard tagVerwendung.value == .TagDokumente else {
            gewaehlteTags.value = Array(neueUserWahl)
            return}
        let vorUpdate = Set(gewaehlteTags.value)
        guard let difference  = vorUpdate.symmetricDifference(neueUserWahl).first else {return}
        if neueUserWahl.contains(difference)    { Dokument.addTag(difference, to: gewaehlteDokumente.value) }
        else                                    { Dokument.removeTag(difference, to: gewaehlteDokumente.value) }
        gewaehlteTags.value = Array(neueUserWahl)
    }
}

//MARK: ViewModels
//Tags und Dokumentenwahl
class DokumentenAuswahlViewModel{
    let einUndAusgabeBarButtonTitle     = MutableProperty<String>("Dokumente wählen")
    let einUndAusgabeBarButtonIsEnabled = MutableProperty<Bool>(false)
    let tagViewsAreHidden       = MutableProperty<Bool>(true)
    
    //init
    let model:DokumentenAuswahlModel
    init(dokumentenAuswahlModel:DokumentenAuswahlModel){
        model = dokumentenAuswahlModel
        einUndAusgabeBarButtonTitle     <~ dokumentenAuswahlModel.gewaehlteDokumente.signal.map { DokumentenAuswahlViewModel.getEinUndAusgabeBarButtonTitle(gewaehlteDokumente:$0,titlePart:dokumentenAuswahlModel.einUndAusgabeTitlePart)}
        einUndAusgabeBarButtonIsEnabled <~ dokumentenAuswahlModel.gewaehlteDokumente.signal.map {$0.count > 0}
        tagViewsAreHidden.value = dokumentenAuswahlModel.dokumentenAuswahlViewTyp == .Eingabe
    }
    
    //helper
    static func getEinUndAusgabeBarButtonTitle(gewaehlteDokumente:[Dokument],titlePart:String)->String  { return gewaehlteDokumente.count == 0 ? "Dokumente wählen" : "\(gewaehlteDokumente.count) Dokumente " + titlePart }
    
    
    
    //ViewModels
    func getViewModelFuerDokumentenAuswahlCollectionView()->DokumentenAuswahlCollectionViewModel        { return DokumentenAuswahlCollectionViewModel(dokumentenAuswahlModel: model)}
    func getViewModelFuerTagAuswahlAuswahlCollectionView()->TagAuswahlCollectionViewModel               { return TagAuswahlCollectionViewModel(dokumentenAuswahlModel: model)}
    func getViewModelFuerTagsSuchenUndErstellen()->TagsSuchenUndErstellenViewModel                      { return TagsSuchenUndErstellenViewModel(dokumentenAuswahlModel: model)}
    func getViewModelFuerTagsAlsFilter() -> TagsAlsFilterViewModel                                      { return TagsAlsFilterViewModel(dokumentenAuswahlModel: model)}
}

//Dokumentenwahl CollectionView
class DokumentenAuswahlCollectionViewModel{
    let angezeigteDokumente             = MutableProperty<[Dokument]>([Dokument]())
    let collectionViewUpdate            = MutableProperty<Void>(Void())
    private let gewaehlteIndizes        = MutableProperty<Set<IndexPath>>(Set<IndexPath>())

    //init
    init(dokumentenAuswahlModel:DokumentenAuswahlModel){
        angezeigteDokumente                         <~ dokumentenAuswahlModel.gefilterteDokumente.producer
        gewaehlteIndizes                            <~ dokumentenAuswahlModel.gefilterteDokumente.signal.map{_ in Set<IndexPath>()}
        dokumentenAuswahlModel.gewaehlteDokumente   <~ gewaehlteIndizes.signal.map { DokumentenAuswahlModel.arrayForIndizes(indizes: $0, array: dokumentenAuswahlModel.gefilterteDokumente.value) }
        
        
        
        collectionViewUpdate                        <~ angezeigteDokumente.signal.map{_ in Void()}
        collectionViewUpdate                        <~ dokumentenAuswahlModel.gewaehlteTags.signal.map{_ in Void()}
        
    }
    
    
    //helper
    func cellIsSelected(indexPath:IndexPath) -> Bool    { return gewaehlteIndizes.value.contains(indexPath) }
    func didSelect(indexPath:IndexPath)                 { gewaehlteIndizes.value.formSymmetricDifference(Set<IndexPath>([indexPath])) }

    //ViewModels
    func getViewModelForCell(indexPath: IndexPath)  -> DokumentCollectionCellViewModel{ return DokumentCollectionCellViewModel(dokument: angezeigteDokumente.value[indexPath.row]) }
}

//Tags wählen
class TagAuswahlCollectionViewModel{
    let angezeigteTags                      = MutableProperty<[Tag]>([Tag]())
    let angezeigtGewaehlteTags              = MutableProperty<[Tag]>([Tag]())
    let collectionViewUpdate                = MutableProperty<Void>(Void())
    
    //init
    let dokumentenAuswahlModel:DokumentenAuswahlModel
    init(dokumentenAuswahlModel:DokumentenAuswahlModel){
        self.dokumentenAuswahlModel = dokumentenAuswahlModel
        angezeigteTags                          <~ dokumentenAuswahlModel.gefilterteTags.producer
        angezeigtGewaehlteTags                  <~ dokumentenAuswahlModel.gewaehlteTags.signal
        
        collectionViewUpdate                    <~ angezeigteTags.signal.map{_ in Void()}
        collectionViewUpdate                    <~ angezeigtGewaehlteTags.signal.map{_ in Void()}
    }

    //helper
    func cellIsSelected(indexPath:IndexPath) -> Bool    { return angezeigtGewaehlteTags.value.contains(angezeigteTags.value[indexPath.row]) }
    func didSelect(indexPath:IndexPath)                 {
        let neuesSet = Set(dokumentenAuswahlModel.gewaehlteTags.value).symmetricDifference(Set<Tag>([angezeigteTags.value[indexPath.row]]))
        dokumentenAuswahlModel.tagging(neueUserWahl:  neuesSet)
    }
    
    //ViewModels
    func getViewModelForCell(indexPath: IndexPath)  -> TagCollectionCellViewModel { return TagCollectionCellViewModel(tag: angezeigteTags.value[indexPath.row]) }
        

}

//Tags suchen und erstellen
class TagsSuchenUndErstellenViewModel{
    let suchString                  = MutableProperty<String?>(nil)
    let addButtonIsEnabled          = MutableProperty<Bool>(false)
    //init
    init(dokumentenAuswahlModel:DokumentenAuswahlModel){
        dokumentenAuswahlModel.gefilterteTags   <~ suchString.producer.map{TagsSuchenUndErstellenViewModel.filterTags(suchString: $0, ungefiltert: Tag.getAll()) }
        addButtonIsEnabled                      <~ dokumentenAuswahlModel.gefilterteTags.map{$0.count == 0}
    }
    
    static func filterTags(suchString:String?,ungefiltert:[Tag]) -> [Tag]{
        guard let suchString = suchString, !suchString.isEmpty else {return ungefiltert}
        return ungefiltert.filter{($0.title?.uppercased().contains(suchString.uppercased()) ?? false) }
    }
    
    func addButtonAction(){
        _ = Tag.getOrCreate(title: suchString.value)
        suchString.value            = nil
    }
}

//Tags als Filter
class TagsAlsFilterViewModel{
    let tags            = MutableProperty<[Tag]>([Tag]())
    let tagVerwendung   = MutableProperty<TagVerwendung>(.TagDokumente)
    //init
    init(dokumentenAuswahlModel:DokumentenAuswahlModel){
        dokumentenAuswahlModel.tagVerwendung    <~ tagVerwendung.signal
        tags                                    <~ dokumentenAuswahlModel.tagsGewaehltAlsFilter
    }
    //action
    func switchTagVerwendung(){ tagVerwendung.value = tagVerwendung.value.opposite }
}



