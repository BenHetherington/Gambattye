//
//  Array+AppendElementOperator.swift
//  Gambattye
//
//  Created by Ben Hetherington on 02/02/2018.
//  Copyright © 2018 Ben Hetherington. Licenced under the GPL v2 (see LICENCE).
//

import Foundation

extension Array {

    static func += (array: inout [Element], element: Element) {
        array.append(element)
    }
    
}
