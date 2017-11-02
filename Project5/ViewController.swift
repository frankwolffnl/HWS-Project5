//
//  ViewController.swift
//  Project5
//
//  Created by Frank Wolff on 02/11/2017.
//  Copyright © 2017 Frank Wolff. All rights reserved.
//  Next page to do: https://www.hackingwithswift.com/read/5/2/reading-from-disk-contentsoffile

import UIKit
import GameplayKit

class ViewController: UITableViewController {
	var allWords = [String]()
	var usedWords = [String]()
	
	override func viewDidLoad() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
		super.viewDidLoad()
		
		if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
			if let startWords = try? String(contentsOfFile: startWordsPath) {
				allWords = startWords.components(separatedBy: "\n")
			}
		} else {
			allWords = ["silkworm"]
		}
		startGame()
	}
	
	@objc func promptForAnswer() {
		let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
		ac.addTextField()
		
		let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
			let answer = ac.textFields![0]
			self.submit(answer: answer.text!)
		}
		
		ac.addAction(submitAction)
		present(ac, animated: true)
	}
	
	func submit(answer: String) {
		let lowerAnswer = answer.lowercased()
		
		if isPossible(word: lowerAnswer) {
			if isOriginal(word: lowerAnswer) {
				if isReal(word: lowerAnswer) {
					usedWords.insert(answer, at: 0)
					
					let indexPath = IndexPath(row: 0, section: 0)
					tableView.insertRows(at: [indexPath], with: .automatic)
					
					return
				} else {
					showErrorMessage(type: "real")
				}
			} else {
				showErrorMessage(type: "original")
			}
		} else {
			showErrorMessage(type: "possible")
		}
	}
	
	func showErrorMessage(type: String) {
		let errorTitle: String
		let errorMessage: String
		
		switch type {
		case "possible":
			errorTitle = "Word not possible"
			errorMessage = "You can't spell that word from '\(title!.lowercased())'!"
		case "original":
			errorTitle = "Word used already"
			errorMessage = "Be more orignal!"
		case "real":
			errorTitle = "Word not recognised"
			errorMessage = "You can't just make them up, you know!"
		default:
			errorTitle = ""
			errorMessage = ""
		}
		let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}
	
	func startGame() {
		allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
		title = allWords[0]
		usedWords.removeAll(keepingCapacity: true)
		tableView.reloadData()
	}
	
	func isPossible(word: String) -> Bool {
		var tempWord = title!.lowercased()
		
		for letter in word {
			if let pos = tempWord.range(of: String(letter)) {
				tempWord.remove(at: pos.lowerBound)
			} else {
				return false
			}
		}
		
		return true
	}
	
	func isOriginal(word: String) -> Bool {
		return !usedWords.contains(word) && (word != title!)
	}
	
	func isReal(word: String) -> Bool {
		let checker = UITextChecker()
		let range = NSMakeRange(0, word.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
		
		if word == "" {
			return false
		}
		
		return misspelledRange.location == NSNotFound
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return usedWords.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
		cell.textLabel?.text = usedWords[indexPath.row]
		return cell
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}


}

