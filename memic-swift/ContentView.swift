//
//  ContentView.swift
//  memic-swift
//
//  Created by nate on 6/27/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView{
            VStack {
                Text("memic")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: Translator()){
                    Text("sound like you, anywhere.")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("microphone permissions denied"),
                message: Text("looks like you arent letting me use the mic, go to system settings"),
                dismissButton: .default(Text("OK"))
                )
        }
        .onAppear {
            Task {
                await requestMicrophonePermission()
            }
        }
    }
    func requestMicrophonePermission() async {
        if await AVAudioApplication.requestRecordPermission() {
            print("accepted")
        }
        else {
            showingAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View{
        ContentView()
    }
}

#Preview {
    ContentView()
}

