//
//  CollectionCellsViewModel.swift
//  DigitalisiererAnimation
//
//  Created by Matthias Pochmann on 18.04.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

class DokumentCollectionCellViewModel{
    var dokument:Dokument
    init (dokument:Dokument){
        self.dokument = dokument
        tags = dokument.tagArray
    }
    func getViewModelForDokumentView() -> ScanAnzeigeDokumentViewModel { return ScanAnzeigeDokumentViewModel(scanAnzeigeDokumentModel: ScanAnzeigeDokumentModel(scanAnzeigeTyp: .NurAnsicht,dokument:dokument)) }
    var tags:[Tag]
}

class TagCollectionCellViewModel{
    var tag:Tag
    init (tag:Tag){ self.tag = tag  }
}
