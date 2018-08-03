//
//  Pokemon.swift
//  Pokedex
//
//  Created by LTT on 7/27/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexID: Int!
    private var _pokemonURL: String!
    private var _height: Int!
    private var _weight: Int!
    private var _defense: Int!
    private var _attack: Int!
    private var _type: String!
    private var _description: String!
    private var _nextEvolutionID: Int!
    private var _nextEvolution: String!
    
    var name: String {
        return _name
    }
    var pokedexID: Int {
        return _pokedexID
    }
    var pokemonURL: String {
        return _pokemonURL
    }
    var height: Int {
        return _height
    }
    var weight: Int {
        return _weight
    }
    var defense: Int {
        return _defense
    }
    var attack: Int {
        return _attack
    }
    var type: String {
        return _type
    }
    var description: String {
        if _description == nil {
            return ""
        }
        return _description
    }
    var nextEvolution: String {
        if _nextEvolution == nil {
            return ""
        }
        return _nextEvolution
    }
    var nextEvolutionID: Int{
        if _nextEvolutionID == nil {
            return 0
        }
        return _nextEvolutionID
    }
    
    init(name: String, pokedexID: Int) {
        self._name = name
        self._pokedexID = pokedexID
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexID)"
    }
    func downloadPokemonData(completed: @escaping DownloadComplete) {
        Alamofire.request(_pokemonURL).responseJSON { respone in
            let result = respone.result
            if let dict = result.value as? Dictionary<String, AnyObject> {
                //print(dict)
                if let height = dict["height"] as? Int {
                    self._height = height
                }
                if let weight = dict["weight"] as? Int {
                    self._weight = weight
                }
                if let stats = dict["stats"] as? [Dictionary<String, AnyObject>] {
                    if let defense = stats[3]["base_stat"] as? Int {
                        self._defense = defense
                    }
                }
                if let stats = dict["stats"] as? [Dictionary<String, AnyObject>] {
                    if let attack = stats[4]["base_stat"] as? Int {
                        self._attack = attack
                    }
                }
                if let types = dict["types"] as? [Dictionary<String,
                    AnyObject>], types.count > 0 {
                    for element in types {
                        if let type = element["type"] as? Dictionary<String, String>, type["name"] != nil {
                            if (self._type == nil){
                                self._type = type["name"]?.capitalized
                            } else {
                                self._type.append("/\(type["name"]?.capitalized ?? "???")")
                            }
                        }
                    }
                }
                if let species = dict["species"] as? Dictionary<String, String> {
                    if let url = species["url"] {
                        Alamofire.request(url).responseJSON{ respone in
                            let result = respone.result
                            if let dict = result.value as? Dictionary<String, AnyObject> {
                                if let descriptions = dict["flavor_text_entries"] as? [Dictionary<String, AnyObject>]{
                                    for element in descriptions {
                                        if let language = element["language"] as? Dictionary<String, String>, language["name"] == "en" {
                                            if let description = element["flavor_text"] as? String {
                                                self._description = ""
                                                self._description.append(description)
                                                completed()
                                                break
                                            }
                                        }
                                    }
                                }
                                if let evolution_chain = dict["evolution_chain"] as? Dictionary<String, String> {
                                    //print("s")
                                    if let url = evolution_chain["url"] {
                                        Alamofire.request(url).responseJSON{ respone in
                                            let result = respone.result
                                            if let dict = result.value as? Dictionary<String, AnyObject> {
                                                //print(dict)
                                                if let chain = dict["chain"] as? Dictionary<String, AnyObject> {
                                                    self.checkChain(chain: chain)
                                                }
                                            }
                                            completed()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            completed()
        }
    }
    func checkChain(chain: Dictionary<String, AnyObject>) {
        
        if let species = chain["species"] as? Dictionary<String, String> {
            if let name = species["name"], name == self.name {
                if let evolves_to = chain["evolves_to"] as? [Dictionary<String, AnyObject>]{
                    if evolves_to.isEmpty {
                        self._nextEvolution = "Max Evolution"
                        print("????")
                    }
                    else {
                        self._nextEvolution = "Next Evolution: "
                        if let nextPoke = evolves_to[0]["species"] as? Dictionary<String, String> {
                            if let name = nextPoke["name"] {
                                self._nextEvolution.append(" \(name.capitalized) LVL ")
                            }
                            if let evolution_details = evolves_to[0]["evolution_details"] as? [Dictionary<String, AnyObject>]{
                                if let LVL = evolution_details[0]["min_level"] as? Int {
                                    self._nextEvolution.append("\(LVL)")
                                    
                                } else {
                                    self._nextEvolution.append("???")
                                }
                                if let nextEvolutionID = nextPoke["url"] {
                                    print(nextEvolutionID)
                                    self._nextEvolutionID = Int(nextEvolutionID.replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "").replacingOccurrences(of: "/", with: ""))!
                                    print(self._nextEvolutionID)
                                }
                            }
                        }
                    }
                } else {
                    self._nextEvolution = "Max Evolution"
                }
            }
            else if let name = species["name"], name != self.name{
                if let evolves_to = chain["evolves_to"] as? [Dictionary<String, AnyObject>] {
                    checkChain(chain: evolves_to[0])
                }
            }
        }
    }
}
