//
//  FavoriteMovie.swift
//  CineExplorer
//
//  Created by Juan Pablo Alvarez Loran on 24/07/24.
//

import Foundation

struct RemoteMovie: Codable {
    let movieId: Int
    let userId: String
    let title: String
    let releaseDate: String
    let adult: Bool
    let voteAverage: Double
    let language: String
    let posterPath: String
    let overview: String
}
