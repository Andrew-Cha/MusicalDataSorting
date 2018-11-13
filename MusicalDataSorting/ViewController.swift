//
//  ViewController.swift
//  MusicalDataSorting
//
//  Created by Andrew on 10/31/18.
//  Copyright © 2018 Andrew. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var uploadButton: NSButton!
    var filePath: URL?
    
    @IBAction func startMusicPrompt(_ sender: NSButton) {
        let fileSelectionPanel = NSOpenPanel()
        fileSelectionPanel.canChooseFiles = true
        fileSelectionPanel.allowsMultipleSelection = false
        fileSelectionPanel.canChooseDirectories = false
        
        fileSelectionPanel.beginSheetModal(for: view.window!) { result in
            if result == .OK {
                self.filePath = fileSelectionPanel.urls[0]
                do {
                    if let filePath = self.filePath {
                        let audioFile = try AVAudioFile(forReading: filePath)
                        let splitAudioFile = audioFile.splitIntoPieces(count: 2)
                        
                        if let splitAudioFile = splitAudioFile {
                            let audioEngine = AVAudioEngine()
                            let audioPlayer = AVAudioPlayerNode()
                            let mainMixer = audioEngine.mainMixerNode
                            let audioFormat = audioFile.processingFormat
                            audioEngine.attach(audioPlayer)
                            audioEngine.connect(audioPlayer, to: mainMixer, format: audioFormat)
                            
                            try audioEngine.start()
                            
                            for audioPiece in splitAudioFile {
                                audioPlayer.scheduleBuffer(audioPiece)
                                audioPlayer.play()
                            }
                        } else {
                            return
                        }
                        /*
                         print(splitAudioFile?.count)
                         self.audioPlayer = try AVAudioPlayer(contentsOf: filePath)
                         self.audioPlayer.prepareToPlay()
                         self.audioPlayer.play()
                         */
                        self.statusLabel.stringValue = "Status - Successful"
                    }
                } catch {
                    self.statusLabel.stringValue = "Status - Failed, try again"
                    print(error.localizedDescription)
                    let newError = NSError(domain: "" , code: 0, userInfo: [NSLocalizedDescriptionKey : "Your computer is about to blow up!\n\n\(error.localizedDescription)\n\nThis is most likely due to the file not being an audio file."])
                    let errorAlert = NSAlert(error: newError)
                    errorAlert.runModal()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

extension AVAudioFile {
    func splitIntoPieces(count: Int) -> [AVAudioPCMBuffer]? {
        let file = self
        
        let processingFormat = file.processingFormat
        let frameCount = AVAudioFrameCount(file.length)
        let bufferLength = Int(frameCount) / count + 1
        
        let pcmBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: frameCount)!
        
        do {
            try file.read(into: pcmBuffer, frameCount: frameCount)
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        let channelCount = Int(pcmBuffer.format.channelCount)
        
        var currentFrame = 0
        var audioBuffers: [AVAudioPCMBuffer] = []
        var currentBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: AVAudioFrameCount(bufferLength))!
        for baseFrame in 0 ..< Int(pcmBuffer.frameLength) {
            for channelNumber in 0 ..< channelCount {
                guard let sample = pcmBuffer.floatChannelData?[channelNumber][baseFrame] else { continue }
                currentBuffer.floatChannelData![channelNumber][currentFrame] = sample
            }
            
            currentFrame += 1
            if (currentFrame == bufferLength) {
                currentFrame = 0
                audioBuffers.append(currentBuffer)
                currentBuffer = AVAudioPCMBuffer(pcmFormat: processingFormat, frameCapacity: AVAudioFrameCount(bufferLength))!
            }
        }
        
        return audioBuffers
    }
}
/*
 extension NSColor {
 class func random() -> NSColor {
 let red =   UInt32.random(in: 0...255)
 let green = UInt32.random(in: 0...255)
 let blue =  UInt32.random(in: 0...255)
 let color = NSColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
 return color
 }
 }
 
 extension NSImage {
 class func makeSwatch(color: NSColor, size: NSSize) -> NSImage {
 let image = NSImage(size: size)
 image.lockFocus()
 color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
 image.unlockFocus()
 return image
 }
 }
 */
