//
//  ObservableType+Ext.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 06/08/25.
//

import RxSwift

extension ObservableType {
    func pairwise() -> Observable<(Element, Element)> {
        return self.scan([]) { (previous, current) in
            (previous + [current]).suffix(2)
        }
        .filter { $0.count == 2 }
        .map { ($0[0], $0[1]) }
    }
}
