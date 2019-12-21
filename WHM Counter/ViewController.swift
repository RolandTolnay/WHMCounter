//
//  ViewController.swift
//  WHM Counter
//
//  Created by Roland Tolnay on 31/03/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

  @IBOutlet weak var holdBreathButton: UIButton!
  @IBOutlet weak var counterButton: UIButton!
  @IBOutlet weak var breathCountLabel: UILabel!
  @IBOutlet weak var holdBreathTimerLabel: UILabel!

  private let voiceId = "com.apple.ttsbundle.Daniel-compact"

  private var isHoldingBreath = false {
    didSet {
      if isHoldingBreath {
        holdBreathButton.setTitle("Stop holding", for: .normal)
        startTimer()
      } else {
        holdBreathButton.setTitle("Hold breath", for: .normal)
        stopTimer()
      }
    }
  }
  private var timer: Timer?
  private var holdBreathSeconds: TimeInterval = 0 {
    didSet {
      let components = componentsFrom(timeInterval: holdBreathSeconds)
      DispatchQueue.main.async {
        self.holdBreathTimerLabel.text = String(format: "%02i : %02i", components.minutes, components.seconds)
      }
    }
  }

  private var breathCount = 0 {
    didSet {
      updateBreathCount(breathCount)
    }
  }

  private let speechSynthesizer = AVSpeechSynthesizer()

  override func viewDidLoad() {
    super.viewDidLoad()

    counterButton.layer.cornerRadius = counterButton.frame.height / 2
    counterButton.layer.masksToBounds = true

    holdBreathButton.layer.cornerRadius = holdBreathButton.frame.height / 2
    holdBreathButton.layer.masksToBounds = true
  }

  @IBAction func onBreatheTapped(_ sender: Any) {

    breathCount += 1
  }

  @IBAction func onHoldBreathTapped(_ sender: Any) {

    isHoldingBreath.toggle()
  }

  private func updateBreathCount(_ count: Int) {

    breathCountLabel.text = "Breath count: \(count)"

    guard count > 0 else { return }
    let speechUtterance = AVSpeechUtterance(string: "\(count)")
    speechUtterance.voice = AVSpeechSynthesisVoice(identifier: voiceId)
    speechSynthesizer.speak(speechUtterance)
  }

  private func startTimer() {

    holdBreathSeconds = 0
    breathCount = 0
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in

      guard let welf = self else { return }
      welf.holdBreathSeconds += 1
      if Int(welf.holdBreathSeconds).isMultiple(of: 30) {
        welf.speakSeconds(welf.holdBreathSeconds)
      }
    }
  }

  private func stopTimer() {

    timer?.invalidate()
    timer = nil
    speakSeconds(holdBreathSeconds)
  }

  private func speakSeconds(_ seconds: TimeInterval) {

    let components = componentsFrom(timeInterval: holdBreathSeconds)
    let secondEnding = components.seconds == 1 ? "" : "s"
    var speech = "\(components.seconds) second\(secondEnding)"
    if components.minutes > 0 {
      let minuteEnding = components.minutes == 1 ? "" : "s"
      if components.seconds > 0 {
        speech = "\(components.minutes) minute\(minuteEnding) and \(components.seconds) second\(secondEnding)"
      } else {
        speech = "\(components.minutes) minute\(minuteEnding)"
      }
    }
    let speechUtterance = AVSpeechUtterance(string: speech)
    speechUtterance.voice = AVSpeechSynthesisVoice(identifier: voiceId)
    speechSynthesizer.speak(speechUtterance)
  }
}

func componentsFrom(timeInterval: TimeInterval) -> (minutes: Int, seconds: Int) {
  let minutes = Int(timeInterval) / 60 % 60
  let seconds = Int(timeInterval) % 60

  return (minutes: minutes, seconds: seconds)
}

