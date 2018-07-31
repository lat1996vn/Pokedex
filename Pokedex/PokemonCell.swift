//
//  cltvCell.swift
//  Pokedex
//
//  Created by LTT on 7/27/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import UIKit

class PokemonCell: UICollectionViewCell {
    @IBOutlet weak var imgPokemon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    var pokemon: Pokemon!
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 5
    }
    
    func configureCell(pokemon: Pokemon) {
        self.pokemon = pokemon
        imgPokemon.image = UIImage(named: "\(self.pokemon.pokedexID)")
        lblName.text = self.pokemon.name.capitalized
    }
}
