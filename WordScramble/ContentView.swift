//
//  ContentView.swift
//  WordScramble
//
//  Created by Laurent B on 23/10/2019.
//  Copyright © 2019 Laurent B. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .padding()
                    .autocapitalization(.none)
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
               
            }
        .navigationBarTitle(rootWord)
        .navigationBarItems(leading: Button("New Game") {
            self.startGame()
        })
        .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    func addNewWord() {
        let answer =  newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "word used already" , message: "pls be original")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "Check again!")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You cant just make them up you know!")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    func startGame() {
        usedWords = [String]()
        newWord = ""
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("could not load start.txt from bundle")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        if word.count <= 2 {
            return false
        }
        if word == rootWord {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0 , wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle =  title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
