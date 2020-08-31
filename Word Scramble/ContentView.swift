//
//  ContentView.swift
//  Word Scramble
//
//  Created by RANGA REDDY NUKALA on 30/08/20.
//

import SwiftUI

// MARK:- Working with Strings

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    
    var body: some View {

            NavigationView {
                VStack {
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord).textFieldStyle(RoundedBorderTextFieldStyle()).autocapitalization(.none)
                        .padding()
                    List(usedWords,id: \.self) {
                        Image(systemName: "\($0.count).circle")
                        Text($0)
                    }
                    Spacer()
                }.navigationTitle(rootWord)
                .onAppear(perform: startGame)
                .alert(isPresented: $showError) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    
                }
            }
        
            
    }
    
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Not a Original", message: "The word is already used")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Not Possible", message: "This a not a possible word out of actual letters")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Not Real", message: "This isn't Real")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func wordError(title: String,message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
    
    func startGame() {
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
        
            if let fileContents = try? String(contentsOf: fileURL) {
                let letters = fileContents.components(separatedBy: "\n")
                let letter = letters.randomElement()
                let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "@irangareddy"
                
                rootWord = trimmed
                return
            }
            
        }
        fatalError("Could not load start.txt from bundle.")
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
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
