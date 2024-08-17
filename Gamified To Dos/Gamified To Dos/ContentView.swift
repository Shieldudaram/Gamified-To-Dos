//
//  ContentView.swift
//  Gamified To Dos
//
//  Created by Christopher Jennison on 8/14/24.
//

import SwiftUI

struct Task: Identifiable, Codable {
    let id = UUID()
    var name: String
    var isCompleted: [Bool]
    var points: Int
}

struct ContentView: View {
    @State private var backgroundColor = Color.blue  // Default background color is blue
    @State private var isCleared = false  // State to track whether the screen is cleared
    @State private var showDailyList = false  // State to track if the daily list is shown
    @State private var tasks: [Task] = []
    @State private var score = 0  // State to track the total score
    @State private var newTaskName = ""  // State to hold the new task name
    @State private var newTaskPoints = ""  // State to hold the new task points as a string
    
    // Keys for UserDefaults
    private let tasksKey = "savedTasks"
    private let scoreKey = "savedScore"
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Points")
                    .font(.largeTitle)
                    .padding(.top, 50)
                    .foregroundColor(.white)
                
                Text("\(getMedievalTitle(score: score))")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                Text("Score: \(score)")
                    .font(.title)
                    .foregroundColor(.yellow)
                    .padding(.top, 10)
                
                Spacer()
                
                if isCleared || showDailyList {
                    VStack {
                        if showDailyList {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach($tasks) { $task in
                                        HStack(alignment: .center) {
                                            HStack {
                                                ForEach(0..<task.isCompleted.count, id: \.self) { index in
                                                    Button(action: {
                                                        if !task.isCompleted[index] {
                                                            score += task.points
                                                        } else {
                                                            score -= task.points
                                                        }
                                                        task.isCompleted[index].toggle()
                                                        saveData()
                                                    }) {
                                                        Image(systemName: task.isCompleted[index] ? "checkmark.square.fill" : "square")
                                                            .foregroundColor(task.isCompleted[index] ? .green : .white)
                                                    }
                                                    .buttonStyle(BorderlessButtonStyle())
                                                }
                                            }
                                            
                                            Text(task.name)
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            // Display the total points earned for this task
                                            Text("\(task.points * task.isCompleted.filter { $0 }.count) pts")
                                                .foregroundColor(.yellow)
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    
                                    // Input fields to add a new task
                                    HStack {
                                        TextField("New Task", text: $newTaskName)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .foregroundColor(.black)
                                        
                                        TextField("Points", text: $newTaskPoints)
                                            .keyboardType(.numberPad)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .foregroundColor(.black)
                                            .frame(width: 80)
                                        
                                        Button(action: {
                                            addNewTask()
                                        }) {
                                            Text("Add")
                                                .padding()
                                                .background(Color.green)
                                                .cornerRadius(10)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.top, 10)
                                    .padding(.horizontal, 20)
                                }
                                .padding(.top, 20)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isCleared = false
                            showDailyList = false
                        }) {
                            Text("Revert Back")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 50)
                    }
                } else {
                    VStack(spacing: 20) {
                        Button(action: {
                            isCleared = true
                            showDailyList = false
                        }) {
                            Text("Priority Window")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isCleared = true
                            showDailyList = false
                        }) {
                            Text("Time Block")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showDailyList = true
                        }) {
                            Text("Daily List")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isCleared = true
                            showDailyList = false
                        }) {
                            Text("Brain Dump")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
            .animation(.default, value: isCleared)
            .animation(.default, value: showDailyList)
            .onAppear {
                loadData()
            }
        }
    }
    
    // Function to add a new task
    func addNewTask() {
        guard !newTaskName.isEmpty, let points = Int(newTaskPoints), points > 0 else {
            return
        }
        
        let newTask = Task(name: newTaskName, isCompleted: [false], points: points)
        tasks.append(newTask)
        
        // Save the updated task list
        saveData()
        
        // Reset the input fields
        newTaskName = ""
        newTaskPoints = ""
    }
    
    // Function to save tasks and score to UserDefaults
    func saveData() {
        do {
            let tasksData = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(tasksData, forKey: tasksKey)
            UserDefaults.standard.set(score, forKey: scoreKey)
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    // Function to load tasks and score from UserDefaults
    func loadData() {
        if let tasksData = UserDefaults.standard.data(forKey: tasksKey) {
            do {
                tasks = try JSONDecoder().decode([Task].self, from: tasksData)
            } catch {
                print("Failed to load tasks: \(error)")
            }
        } else {
            // If no tasks are saved, load the default task list
            tasks = getDefaultTasks()
        }
        score = UserDefaults.standard.integer(forKey: scoreKey)
    }
    
    // Function to get the medieval title based on the current score
    func getMedievalTitle(score: Int) -> String {
        switch score {
        case 0...20:
            return "Peasant"
        case 21...40:
            return "Squire"
        case 41...60:
            return "Knight"
        case 61...80:
            return "Baron"
        case 81...99:
            return "Duke"
        default:
            return "Lord"
        }
    }
    
    // Function to return the default task list
    func getDefaultTasks() -> [Task] {
        return [
            Task(name: "Tea", isCompleted: [false], points: 2),
            Task(name: "Breakfast", isCompleted: [false], points: 2),
            Task(name: "Fiber log", isCompleted: [false, false, false], points: 3),
            Task(name: "Protein log", isCompleted: [false, false, false], points: 3),
            Task(name: "Vitamins", isCompleted: [false], points: 1),
            Task(name: "Shower", isCompleted: [false], points: 2),
            Task(name: "Brain dump", isCompleted: [false], points: 2),
            Task(name: "Time block", isCompleted: [false], points: 2),
            Task(name: "Log H2O", isCompleted: [false, false, false, false], points: 4),
            Task(name: "No Snooze", isCompleted: [false], points: 0),
            Task(name: "Probiotic", isCompleted: [false], points: 1),
            Task(name: "Teeth until 10", isCompleted: [false], points: 1),
            Task(name: "Lucid check", isCompleted: [false], points: 2),
            Task(name: "Prep for tomorrow", isCompleted: [false], points: 4),
            Task(name: "Prep lunch", isCompleted: [false], points: 1),
            Task(name: "Dishes", isCompleted: [false], points: 2),
            Task(name: "Trash", isCompleted: [false], points: 1),
            Task(name: "Clean", isCompleted: [false, false, false], points: 1),
            Task(name: "Finances", isCompleted: [false], points: 3),
            Task(name: "Laundry", isCompleted: [false], points: 3),
            Task(name: "Detoxifier", isCompleted: [false], points: 3),
            Task(name: "Learn", isCompleted: [false, false, false, false, false], points: 3),
            Task(name: "Hobby", isCompleted: [false], points: 3),
            Task(name: "Log H2O before bed", isCompleted: [false], points: 2),
            Task(name: "Dinner by 10", isCompleted: [false], points: 2),
            Task(name: "Focused hour", isCompleted: [false], points: 5),
            Task(name: "Puppy bathroom", isCompleted: [false], points: 5),
            Task(name: "Puppy walk", isCompleted: [false], points: 5),
            Task(name: "Sourdough", isCompleted: [false], points: 3),
            Task(name: "Plants", isCompleted: [false], points: 3),
            Task(name: "Exercise", isCompleted: [false, false, false, false, false], points: 3),
            Task(name: "Kombucha", isCompleted: [false], points: 3),
            Task(name: "Deep Clean 1 Room", isCompleted: [false], points: 10)
        ]
    }
}

#Preview {
    ContentView()
}
