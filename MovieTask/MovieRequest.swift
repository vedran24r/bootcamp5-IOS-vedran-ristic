//
//  MovieRequest.swift
//  MovieTask
//
//  Created by Vedran Ristic on 10/5/20.
//

import Foundation

enum MovieError:Error{
    case noDataAvailable
    case canNotProcessData
}
struct MovieRequest {
    let resourceURL:URL
    let API_KEY = "2696829a81b1b5827d515ff121700838"
    
    init(title:String, page:Int){
        
        let resourceString = "https://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&query=\(title)&page=\(page)"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        self.resourceURL = resourceURL
    }
    
    
    func getMovies(completion: @escaping(Result<Movies, MovieError>) -> Void){
        let dataTask = URLSession.shared.dataTask(with: resourceURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do {
                let decoder = JSONDecoder()
                let movies = try decoder.decode(Movies.self, from: jsonData)
                //let movie = movies.results
                completion(.success(movies)) //mozda ovdje da vrati cijeli json ili samo movies
            }catch{
                completion(.failure(.canNotProcessData))
            }
        }
        dataTask.resume()
    }
}
