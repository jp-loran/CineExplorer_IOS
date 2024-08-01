//
//  MovieServiceManager.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 13/05/24.
//

import Foundation
import Alamofire

class MovieServiceManager {
    private var movies: [Movie] = []

    func fetchTrendingMovies(page: Int, completion: @escaping ([Movie]?) -> Void) {
        let url =  "\(Constants.movieApiUrl)trending/movie/day?page=\(page)"
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": MovieApiKey.movieApiKey
        ]

        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: TrendingMoviesResponse.self) { response in
                switch response.result {
                case .success(let moviesResponse):
                    self.movies = moviesResponse.results
                    completion(self.movies)
                case .failure(let error):
                    print("Failed to fetch movies: \(error)")
                    completion(nil)
                }
            }
    }
    
    func getMovies() -> [Movie] {
        return self.movies
    }
    
    func getPoster(posterPath: String) -> String {
        return "\(Constants.movieImageApiUrl)\(posterPath)"
    }
    
}

struct TrendingMoviesResponse: Codable {
    let results: [Movie]
}
