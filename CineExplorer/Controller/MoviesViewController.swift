//
//  MoviesViewController.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 13/05/24.
//

import UIKit
import SDWebImage

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var storedMovies: [Movie] = []
    let manager = MovieServiceManager()
    @IBOutlet weak var moviesTable: UITableView!
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           moviesTable.dataSource = self
           moviesTable.delegate = self
           
           manager.fetchTrendingMovies { movies in
               if let movies = movies {
                   self.storedMovies = movies
                   self.moviesTable.reloadData()
               } else {
                   print("Failed to fetch movies or no movies available.")
               }
           }
       }

       // UITableViewDataSource methods
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return storedMovies.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
           let movie = storedMovies[indexPath.row]
           
           let posterPath = storedMovies[indexPath.row].posterPath
           let urlString = manager.getPoster(posterPath: posterPath)
           if let url = URL(string: urlString) {
               cell.poster.sd_setImage(with: url)
           }
           
           cell.titleLabel.text = movie.title
           cell.starRating.voteAverage = movie.voteAverage / 2.0
           return cell
       }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
              performSegue(withIdentifier: "movieDetailSegue", sender: indexPath)
          }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "movieDetailSegue" {
                    if let destinationVC = segue.destination as? MovieDetailViewController,
                       let indexPath = sender as? IndexPath {
                        destinationVC.movie = storedMovies[indexPath.row]
                        destinationVC.hidesBottomBarWhenPushed = true
                    }
                }
            }
}
