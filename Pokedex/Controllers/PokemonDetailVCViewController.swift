//
//  PokemonDetailVCViewController.swift
//  Pokedex
//
//  Created by LTT on 7/30/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import UIKit

class PokemonDetailVC: UIViewController {
    var pokemon: Pokemon!
   
    @IBAction func btnBackPressed() {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
