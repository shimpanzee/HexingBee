//
//  HexingBeeDI.swift
//
//  

import Factory

extension Container {
    static let spellinBeAPI = Factory<HexingBeeAPI>() {
        HexingBeeAPI()
    }
}
