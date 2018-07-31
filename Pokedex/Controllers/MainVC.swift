//
//  ViewController.swift
//  Pokedex
//
//  Created by LTT on 7/25/18.
//  Copyright © 2018 LTT. All rights reserved.
//

import UIKit
import AVFoundation

class MainVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    @IBOutlet weak var cltvPokemon: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemons = [Pokemon]()
    var musicPlayer: AVAudioPlayer!
    var filteredPokemon = [Pokemon]()
    var isSearchMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        searchBar.returnKeyType = UIReturnKeyType.done
        parserPokemonCSV()
        initAudio()
    }
    
    func initAudio() {
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    func parserPokemonCSV() {
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            for row in rows {
                guard let id = row["id"], let name = row["identifier"], let pokeID = Int(id) else {
                    print("something wrong with file .csv")
                    return
                }
                let pokemon = Pokemon(name: name, pokedexID: pokeID)
                self.pokemons.append(pokemon)
            }
        } catch let err as NSError {
            print(err.debugDescription)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearchMode {
            return filteredPokemon.count
        }
        	return pokemons.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pokeCell", for: indexPath) as? PokemonCell {
            if isSearchMode == false {
                let pokemon = pokemons[indexPath.row]
                cell.configureCell(pokemon: pokemon)
            }
            else {
                let pokemon = filteredPokemon[indexPath.row]
                cell.configureCell(pokemon: pokemon)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var pokemon: Pokemon!
        if isSearchMode {
            pokemon = filteredPokemon[indexPath.row]
        }
        else {
            pokemon = pokemons[indexPath.row]
        }
        let cell = collectionView.cellForItem(at: indexPath) as? PokemonCell
        //cell?.imgPokemon.alpha = 0.5
        //print("?: \(pokemon.name)")
        performSegue(withIdentifier: "MainToPokemonDetail", sender: pokemon)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 115, height: 145)
    }
    
    // Animation when pressed cell
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            if let cell = collectionView.cellForItem(at: indexPath) as? PokemonCell {
                cell.imgPokemon.alpha = 0.2
                cell.contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            if let cell = collectionView.cellForItem(at: indexPath) as? PokemonCell {
                cell.imgPokemon.alpha = 1
                cell.contentView.backgroundColor = .clear
            }
        }
    }
    @IBAction func btnMusicPressed(_ sender: UIButton) {
        if musicPlayer.isPlaying == true {
            musicPlayer.pause()
            sender.alpha = 0.2
        } else {
            musicPlayer.play()
            sender.alpha = 1
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearchMode = false
            cltvPokemon.reloadData()
            view.endEditing(true)
        }
        else {
            isSearchMode = true
            let textInSearchBar = searchBar.text!.lowercased()
            filteredPokemon = pokemons.filter({$0.name.range(of: textInSearchBar) != nil})
            cltvPokemon.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToPokemonDetail" {
            if let detailVC = segue.destination as? PokemonDetailVC {
                if let pokemon = sender as? Pokemon {
                    detailVC.pokemon = pokemon
                    //print("?: \(pokemon.name)")
                }
            }
        }
    }

    
}

