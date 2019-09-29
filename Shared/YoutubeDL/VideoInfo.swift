//
//  VideoInfo.swift
//  YoutubeDL
//
//  Created by mxa on 10.02.2019.
//  Copyright © 2019 0bmxa. All rights reserved.
//

import Foundation

extension YoutubeDL {
    struct VideoInfo {
        let ageLimit: Int?
        let altTitle: PythonRepresentable?
        let annotations: PythonRepresentable?
        let artist: PythonRepresentable?
        let automaticCaptions: [String: PythonRepresentable]?
        let averageRating: PythonRepresentable?
        let categories: [PythonRepresentable?]?
        let channelID: String?
        let channelURL: String?
        let chapters: PythonRepresentable?
        let creator: PythonRepresentable?
        let description: String?
        let dislikeCount: Int?
        let duration: Int?
        let endTime: PythonRepresentable?
        let episodeNumber: PythonRepresentable?
        let extractorKey: String?
        let extractor: String?
        let formats: [YoutubeDL.Format]?
        let ID: String?
        let isLive: PythonRepresentable?
        let license: PythonRepresentable?
        let likeCount: Int?
        let seasonNumber: PythonRepresentable?
        let series: PythonRepresentable?
        let startTime: PythonRepresentable?
        let subtitles: [String: PythonRepresentable]?
        let tags: [PythonRepresentable?]?
        let thumbnail: String?
        let title: String?
        let track: PythonRepresentable?
        let uploadDate: String?
        let uploaderID: String?
        let uploaderURL: String?
        let uploader: String?
        let viewCount: Int?
        let webpageURLBasename: String?
        let webpageURL: String?

        init(_ dict: Python.Dict) {
            self.ageLimit           = (dict["age_limit"] as? Python.Int)?.swiftValue
            self.altTitle           =  dict["alt_title"]
            self.annotations        =  dict["annotations"]
            self.artist             =  dict["artist"]
            self.automaticCaptions  = (dict["automatic_captions"] as? Python.Dict)?.swiftValue
            self.averageRating      =  dict["average_rating"]
            self.categories         = (dict["categories"] as? Python.List)?.swiftValue
            self.channelID          = (dict["channel_id"] as? Python.String)?.swiftValue
            self.channelURL         = (dict["channel_url"] as? Python.String)?.swiftValue
            self.chapters           =  dict["chapters"]
            self.creator            =  dict["creator"]
            self.description        = (dict["description"] as? Python.String)?.swiftValue
            self.dislikeCount       = (dict["dislike_count"] as? Python.Int)?.swiftValue
            self.duration           = (dict["duration"] as? Python.Int)?.swiftValue
            self.endTime            =  dict["end_time"]
            self.episodeNumber      =  dict["episode_number"]
            self.extractorKey       = (dict["extractor_key"] as? Python.String)?.swiftValue
            self.extractor          = (dict["extractor"] as? Python.String)?.swiftValue
            self.ID                 = (dict["id"] as? Python.String)?.swiftValue
            self.isLive             =  dict["is_live"]
            self.license            =  dict["license"]
            self.likeCount          = (dict["like_count"] as? Python.Int)?.swiftValue
            self.seasonNumber       =  dict["season_number"]
            self.series             =  dict["series"]
            self.startTime          =  dict["start_time"]
            self.subtitles          = (dict["subtitles"] as? Python.Dict)?.swiftValue
            self.tags               = (dict["tags"] as? Python.List)?.swiftValue
            self.thumbnail          = (dict["thumbnail"] as? Python.String)?.swiftValue
            self.title              = (dict["title"] as? Python.String)?.swiftValue
            self.track              =  dict["track"]
            self.uploadDate         = (dict["upload_date"] as? Python.String)?.swiftValue
            self.uploaderID         = (dict["uploader_id"] as? Python.String)?.swiftValue
            self.uploaderURL        = (dict["uploader_url"] as? Python.String)?.swiftValue
            self.uploader           = (dict["uploader"] as? Python.String)?.swiftValue
            self.viewCount          = (dict["view_count"] as? Python.Int)?.swiftValue
            self.webpageURLBasename = (dict["webpage_url_basename"] as? Python.String)?.swiftValue
            self.webpageURL         = (dict["webpage_url"] as? Python.String)?.swiftValue
            


            // Get formats list from video info as Swift array
            
            // Convert to format structures
            let formatDictionaries = (dict["formats"] as? Python.List)?.swiftValue as? [Python.Dict]
            self.formats = formatDictionaries?.compactMap {
                guard let dict = $0.swiftValue else { assertionFailure(); return nil }
                return YoutubeDL.Format(dict)
            }
        }
    }
}
