//
//  FavoriteMoviesTableViewController.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 06/06/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FavoriteMoviesTableViewController: UITableViewController {

    var favoriteMovies: [RemoteMovie] = []
    let manager = MovieServiceManager()
    var noFavoritesLabel: UILabel!
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noFavoritesLabel = UILabel()
        noFavoritesLabel.text = "No favorite movies"
        noFavoritesLabel.textAlignment = .center
        noFavoritesLabel.textColor = .gray
        noFavoritesLabel.font = UIFont.systemFont(ofSize: 20)
        
        fetchFavoriteMovies()

    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            fetchFavoriteMovies()
    }
    
    func fetchFavoriteMovies() {
        guard let userId = user?.uid else {
            print("User ID is nil")
            return
        }
        
        let query = db.collection("FavoriteMovie")
            .whereField("userId", isEqualTo: userId)

        query.getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            guard documents.first != nil else{
                self.tableView.backgroundView = self.noFavoritesLabel
                print("No documents found")
                return
            }

            self.favoriteMovies = documents.compactMap { document -> RemoteMovie? in
                let data = document.data()
            
                let movieId = data["movieId"] as? Int
                let userId = data["userId"] as? String
                let title = data["title"] as? String
                let releaseDate = data["releaseDate"] as? String
                let adult = data["adult"] as? Bool
                let voteAverage = data["voteAverage"] as? Double
                let language = data["language"] as? String
                let posterPath = data["posterPath"] as? String
                let overview = data["overview"] as? String
                
                return RemoteMovie(movieId: movieId!, userId: userId!, title: title!, releaseDate: releaseDate!, adult: adult!, voteAverage: voteAverage!, language: language!, posterPath: posterPath!, overview: overview!)
            }
            
            if self.favoriteMovies.isEmpty {
                self.tableView.backgroundView = self.noFavoritesLabel
            } else {
                self.tableView.backgroundView = nil
            }
            
            self.tableView.reloadData()
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMovies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteMovieCell", for: indexPath) as! FavoriteMoviesTableViewCell
        
        let favoriteMovie = favoriteMovies[indexPath.row]
        
        cell.movieTitle?.text = favoriteMovie.title
        
        let posterPath = favoriteMovie.posterPath
        let urlString = manager.getPoster(posterPath: posterPath)
        if let url = URL(string: urlString) {
            cell.movieImage.sd_setImage(with: url)
        }
            
        cell.movieAdult?.text = favoriteMovie.adult ? "Yes" : "No"
        cell.movieLanguage?.text = favoriteMovie.language.uppercased()
        cell.movieRating.voteAverage = favoriteMovie.voteAverage / 2.0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           return "Favorite Movies"
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
               guard let self = self else { return }
               let favoriteMovieToDelete = self.favoriteMovies[indexPath.row]
               
               let currentMovieQuery = db.collection("FavoriteMovie")
                   .whereField("userId", isEqualTo: user?.uid ?? "")
                   .whereField("movieId", isEqualTo: favoriteMovieToDelete.movieId)
               
               currentMovieQuery.getDocuments { querySnapshot, error in
                   
                   if let error = error {
                       print("Error getting documents: \(error)")
                       return
                   }
                   
                   guard let documents = querySnapshot?.documents else {
                       print("No documents found")
                       return
                   }
                   
                   let dispatchGroup = DispatchGroup()
                   
                   for document in documents {
                       dispatchGroup.enter()
                       document.reference.delete { error in
                           if let error = error {
                               print("Error removing document: \(error)")
                           } else {
                               print("Document successfully removed")
                               let snackBar = SnackBar(message: "Favorite movie removed")
                               snackBar.show(in: self.view)
                           }
                           dispatchGroup.leave()
                       }
                   }
                   
                   dispatchGroup.notify(queue: .main) {
                       // Remove the movie from the array
                       self.favoriteMovies.remove(at: indexPath.row)
                       
                       // Update the table view
                       tableView.deleteRows(at: [indexPath], with: .automatic)
                       
                       if self.favoriteMovies.isEmpty {
                           self.tableView.backgroundView = self.noFavoritesLabel
                       }
                       
                       let snackBar = SnackBar(message: "Favorite movie removed")
                       snackBar.show(in: self.view)
                       
                       completionHandler(true)
                   }
               }
           }
           
           deleteAction.backgroundColor = .red
           
           let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
           configuration.performsFirstActionWithFullSwipe = true
           
           return configuration
    }
}
