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
    @State private var score = 0
    @State private var questionN0 = 1
    
    
    init(){
        UITableView.appearance().backgroundColor = .clear
       }
    
    var body: some View {

            NavigationView {
                VStack {
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord).textFieldStyle(RoundedBorderTextFieldStyle()).autocapitalization(.none)
                        .padding()
                    
                    Form {
                        Section(header: Text("Your words")) {
                            List(usedWords,id: \.self) {
                                    Image(systemName: "\($0.count).circle")
                                    Text($0)
                            }
                        }
                    }
                    
                    Text("Score: \(score)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
                    Spacer()
                }.navigationTitle(rootWord)
                .onAppear(perform: startGame)
                .navigationBarItems(leading: Text("\(questionN0)/10")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
                    ,trailing: Button(action: {
                    if questionN0<=10 {
                        startGame()
                        questionN0+=1
                    } else {
                        questionN0 = 1
                        gameOver()
                    }
                    usedWords.removeAll()
                }, label: {
                    Image(systemName: "shuffle")
                        .foregroundColor(Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)))
                }))
                
                .alert(isPresented: $showError) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    
                }
            }
        
            
    }
    
    func gameOver() {
        errorTitle = "Game Over"
        errorMessage = "Your Score is \(score)"
        showError = true
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            if score > 0 {
                score-=1
            }
            wordError(title: "Not a Original", message: "The word is already used")
            return
        }
        
        guard isPossible(word: answer) else {
            if score > 0 {
                score-=1
            }
            wordError(title: "Not Possible", message: "This a not a possible word out of actual letters")
            return
        }
        
        guard isReal(word: answer) else {
            if score > 0 {
                score-=1
            }
            wordError(title: "Not Real", message: "This isn't Real")
            return
        }
        
        score+=1
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
        if word.count >= 3 {
        
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            return misspelledRange.location == NSNotFound
        }
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
