//
//  Movie.swift
//  MovieTask
//
//  Created by Vedran Ristic on 10/5/20.
//

import Foundation
struct Movies:Decodable{
    var page: Int?
    var total_pages: Int?
    var total_results: Int?
    var results:[Movie]?
//    init() {
//        self.page = 1
//        self.total_pages = 1
//        self.total_results = 30
//        self.results = [Movie()]
//    }
    
}
struct Movie:Decodable{
    var title: String?
    var overview: String?
    var release_date: String?
    var poster_path: String?
    
//    init(){
//        self.title = "asd"
//        self.overview = "asss"
//        self.release_date = "sasas"
//        self.poster_path = "asdasdasd.jpg"
//    }
}
