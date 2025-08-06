//
//  UIImageViews+Ext.swift
//  TheMovieDatabase
//
//  Created by Adlan Aufar on 05/08/25.
//

import Nuke
import UIKit

extension UIImageView {
    func setImage(with url: URL?, placeholder: UIImage? = nil) {
        guard let url = url else {
            self.image = placeholder
            return
        }
        self.image = placeholder
        Task {
            do {
                let image = try await ImagePipeline.shared.image(for: url)
                self.image = image
            } catch {
                self.image = placeholder
            }
        }
    }
}
