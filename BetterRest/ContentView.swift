//
//  ContentView.swift
//  BetterRest
//
//  Created by Oguzhan Ozturk on 30.03.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var dateComponent = DateComponents()
        dateComponent.hour = 7
        dateComponent.minute = 0
        return Calendar.current.date(from: dateComponent) ?? Date.now
    }
    @State private var wakeUp = defaultWakeTime
    @State private var coffeAmount = 1
    @State private var sleepAmount = 8.0
    
    var body: some View {
        NavigationView {
            Form {
                Text("When do you want to wake up?")
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                VStack(alignment: .leading,spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12)
                }
                VStack(alignment: .leading,spacing: 0) {
                    Picker(selection: $coffeAmount, content: {
                        ForEach(4..<13) { value in
                            Text("\(value)")
                        }
                    }) {
                        Text("Deneme").font(.headline)
                    }
                    /*
                    Stepper(coffeAmount == 1 ? "one Cup" : "\(coffeAmount) cups", value: $coffeAmount, in: 1...20)*/
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("calculate",action: calculateBedTime)
        }
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button("Ok") {
                alertTitle = ""
                alertMessage = ""
                showingAlert = false
            }
        }, message: {
            Text(alertMessage)
        })
        
        }
    }
    
    func calculateBedTime() {
        
        do {
            let modelConfig = MLModelConfiguration()
            let model = try SleepCalculator(configuration: modelConfig)
            
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (dateComponents.hour ?? 0) * 60
            let minute = (dateComponents.minute ?? 0) * 60 * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bed time is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            showingAlert = true
        } catch {
            //Throw error
        }
        
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
