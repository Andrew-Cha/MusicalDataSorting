//
//  Play.swift
//  MusicalDataSorting
//
//  Created by Andrew on 11/15/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import AVFoundation

func playFile(at url: URL, with audioPlayerNode: AVAudioPlayerNode) throws {
	do {
		let audioFile = try AVAudioFile(forReading: url)
		let pieces = try audioFile.splitIntoPieces(count: 125000)
		let piecesEnumerated: [(index: Int, buffer: AVAudioPCMBuffer)] = pieces.enumerated().map { $0 }
		
		let selectionSorter = SelectionSort(sorting: piecesEnumerated.shuffled())
		let timer2 = ParkBenchTimer()
		while !selectionSorter.isDone {
			selectionSorter.step()
		}
		print("Took \(timer2.stop()) seconds")
		
		let bubbleSorter = BubbleSort(sorting: piecesEnumerated.shuffled())
		let timer = ParkBenchTimer()
		while !bubbleSorter.isDone {
			bubbleSorter.step()
			//render
		}
		print("Took \(timer.stop()) seconds")
		
		for audioPiece in pieces.shuffled() {
			audioPlayerNode.scheduleBuffer(audioPiece)
		}
		
		audioPlayerNode.play()
	}
}
