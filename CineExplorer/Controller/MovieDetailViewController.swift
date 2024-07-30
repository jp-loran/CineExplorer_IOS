//
//  MovieDetailViewController.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 28/05/24.
//

import UIKit
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class MovieDetailViewController: UIViewController {

    var movie: Movie?
    let manager = MovieServiceManager()
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieOverview: UITextView!
    @IBOutlet weak var starRating: StarRatingView!
    @IBOutlet weak var movieRelease: UILabel!
    @IBOutlet weak var movieOnlyAdults: UILabel!
    @IBOutlet weak var movieLanguage: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    var isFavorite = false
    
    
    override func viewDidLoad(){
          super.viewDidLoad()
        
          if let movie = movie {


              let currentMovieQuery = db.collection("FavoriteMovie")
                  .whereField("userId", isEqualTo: user?.uid ?? "")
                  .whereField("movieId", isEqualTo: movie.id)
                  
              
              currentMovieQuery.getDocuments { querySnapshot, error in
                  
                  if let error = error {
                      print("Error getting documents: \(error)")
                      return
                  }
                  
                  guard let documents = querySnapshot?.documents else {
                      print("No documents found")
                      return
                  }
                  
                  if documents.first != nil{
                      self.favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                      self.isFavorite=true
                  }else{
                      self.favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
                      self.isFavorite=false
                  }
              }
              
              
              movieTitle.text=movie.title
              let urlString = URL(string: manager.getPoster(posterPath: movie.posterPath))
              moviePoster.sd_setImage(with: urlString)
              movieOverview.isEditable = false
              movieOverview.text = movie.overview
              starRating.voteAverage = movie.voteAverage / 2.0
              movieRelease.text = movie.releaseDate
              movieOnlyAdults.text = movie.adult ? "Yes" : "No"
              movieLanguage.text = movie.originalLanguage.uppercased()
          }
      }
    
    
    @IBAction func favoriteButtonTap(_ sender: Any){
        isFavorite.toggle()
       
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        
            db.collection("FavoriteMovie").addDocument(data: [
                "movieId": movie?.id ?? "",
                "title": movie?.title ?? "",
                "adult": ((movie?.adult) != nil),
                "releaseDate": movie?.releaseDate ?? "",
                "voteAverage": movie?.voteAverage ?? 0,
                "language": movie?.originalLanguage ?? "",
                "posterPath": movie?.posterPath ?? "",
                "overview": movie?.overview ?? "",
                "userId": user?.uid ?? ""
            ]){error in
                if let error = error{
                    print("Error adding docuemnt: \(error)")
                }else{
                    let snackBar = SnackBar(message: "Favorite movie added")
                    snackBar.show(in: self.view)
                }
            }
           
       } else {
           
           favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
           
           guard let movieId = movie?.id else {
               print("Movie ID is nil")
               return
           }
           
           let currentMovieQuery = db.collection("FavoriteMovie")
               .whereField("userId", isEqualTo: user?.uid ?? "")
               .whereField("movieId", isEqualTo: movieId)
           
           currentMovieQuery.getDocuments { querySnapshot, error in
               
               if let error = error {
                   print("Error getting documents: \(error)")
                   return
               }
               
               guard let documents = querySnapshot?.documents else {
                   print("No documents found")
                   return
               }
               
               for document in documents {
                   document.reference.delete { error in
                       if let error = error {
                           print("Error removing document: \(error)")
                       } else {
                           print("Document successfully removed")
                           let snackBar = SnackBar(message: "Favorite movie removed")
                           snackBar.show(in: self.view)
                       }
                   }
               }
           }
       }
    }
}
