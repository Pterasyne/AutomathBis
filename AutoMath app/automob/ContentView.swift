//
//  ContentView.swift
//  automob
//
//  Created by Pterasyne on 30/09/2026.
//

import SwiftUI
import SwiftData
import Charts
import Foundation
import TabularData

@Model
class Performance { //final
    var id: UUID
    var seance: Int
    var n1: Int
    var n2: Int
    var answer: Int
    var reaction_time: Double
    var result: String
    var date_fr: String
    
    init(seance: Int, n1: Int, n2: Int, answer: Int, reaction_time: Double, result: String, date_fr: String) {
        self.id = UUID()
        self.seance = seance
        self.n1 = n1
        self.n2 = n2
        self.answer = answer
        self.reaction_time = reaction_time
        self.result = result
        self.date_fr = date_fr
    }

}

struct ContentView: View {
    enum WhichViews {
        case home
        case xp
        case progression
    }
    @State private var whichView = WhichViews.home
    var body: some View {
        switch whichView {
        case .home:
                HomeView(whichView : $whichView)
            case .xp:
                XPView(whichView : $whichView)
            case .progression:
                ProgView(whichView : $whichView)
        }
            
        
    }
}

struct HomeView: View {
    @Binding var whichView : ContentView.WhichViews
    
    var body: some View {
        VStack {
            Spacer()
            Button("Commencer") {
                withAnimation {
                    whichView = .xp
                }
            }
            .frame(width: 350, height: 100)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(100)
            .font(.custom("MarelleBaton-Regular", size: 50))
            .fontWeight(.bold)
            .padding(30)
            Spacer()
            HStack (spacing:50) {
                Button("Menu", systemImage: "house.fill") {
                    withAnimation {
                        whichView = .home
                    }
                }
                .font(.custom("MarelleBaton-Regular", size: 20))
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 60).fill(.blue).opacity(0.3))
                .foregroundColor(.white)
                .disabled(true)
                Button("Mes progrès", systemImage: "chart.bar.fill") {
                    withAnimation {
                        whichView = .progression
                    }
                }
                .font(.custom("MarelleBaton-Regular", size: 20))
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 60).stroke(.blue))
                .foregroundColor(.blue)
                
            }
            .frame(alignment: .bottom)
        }

    }
}

struct XPView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var performances: [Performance]
    @Binding var whichView : ContentView.WhichViews
    
    @State private var lastSess : Int = 0
    
    func lastSession(){
        for performance in performances {
            let currentPerf = performance.seance
            if currentPerf > lastSess {
                lastSess = currentPerf
            }
        }
    }

    let wrongDuration : TimeInterval = 3
    let rightDuration : TimeInterval = 1
    @State private var unClickable : Bool = false
    @State private var tints : [Color] = Array(repeating: .black, count: 10)
    
    @State private var first : Int = 1
    @State private var second : Int = 1
    @State private var tooLong : Task<Void, Never>? = nil
    func tooLongCheck() {
        tooLong?.cancel()
        tooLong = Task {
            try? await Task.sleep(for: .seconds(30))
            guard !Task.isCancelled else { return }
            let parisFormat = DateFormatter()
            parisFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            parisFormat.timeZone = TimeZone(identifier: "Europe/Paris")
            parisFormat.locale = Locale(identifier: "fr_FR")
            let newPerf = Performance(seance: lastSess + 1, n1: first, n2: second, answer: -1, reaction_time: -1, result: "noAnswer", date_fr: parisFormat.string(from: Date()))
            modelContext.insert(newPerf)
            var expectedResult : Int = (first + second)
            tints = Array(repeating: .red, count: 10)
            tints[expectedResult-1] = .green
            unClickable = true
            DispatchQueue.main.asyncAfter(deadline: .now() + wrongDuration) {
                self.tints = Array(repeating: .black, count: 10)
                self.unClickable = false
                endTrial()
            }
        }
    }
    
    func newSet(){
        var nextFirst = Int.random(in: 1...10)
        var nextSecond = Int.random(in: 1...10-first+1)
        if(nextFirst+nextSecond>10 ||
           (first == nextFirst && second == nextSecond)){
            newSet()
        } else {
            first = nextFirst
            second = nextSecond
        }
    }
    
    
    @State private var result = 0 //State is to track basically ig
    @State private var startTimer : Date = Date()
    
    @State private var trueEnd : Bool = false
    func endTrial(){
        if trueEnd {
            tooLong?.cancel()
            withAnimation{
                whichView = .progression
            }
        } else {
            newSet()
            startTimer = Date()
            tooLongCheck()
        }
    }

    
    var body: some View {
        VStack {
            Text("\(first) + \(second) = ?")
                .font(.custom("MarelleBaton-Regular", size: 72))
                .fontWeight(.bold)
                .padding()
                .cornerRadius(20)
                .padding()
                .padding()
            HStack {
                ForEach(1..<10+1, id: \.self) {i in
                    ZStack {
                        Circle()
                            .fill(tints[i-1])
                            .opacity(0.15)
                            .frame(maxWidth: .infinity)
                        Button("\(i)"){
                            tooLong?.cancel()
                            let parisFormat = DateFormatter()
                            parisFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            parisFormat.timeZone = TimeZone(identifier: "Europe/Paris")
                            parisFormat.locale = Locale(identifier: "fr_FR")
                            let newPerf = Performance(seance: lastSess + 1, n1: first, n2: second, answer: i, reaction_time: Date().timeIntervalSince(startTimer), result: i == (first+second) ? "correct" : "incorrect", date_fr: parisFormat.string(from: Date()))
                            modelContext.insert(newPerf)
                            result = Int(i)
                            var expectedResult : Int = (first + second)
                            if result == first + second {
                                tints[i-1] = .green
                                unClickable = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + rightDuration) {
                                    self.tints = Array(repeating: .black, count: 10)
                                    self.unClickable = false
                                    endTrial()
                                }
                            } else {
                                tints[expectedResult-1] = .green
                                tints[i-1] = .red
                                unClickable = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + wrongDuration) {
                                    self.tints = Array(repeating: .black, count: 10)
                                    self.unClickable = false
                                    endTrial()
                                }
                            }
                        }
                        .foregroundColor(tints[i-1])
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .disabled(unClickable)
                        .font(.custom("MarelleBaton-Regular", size: 42))
                        .contentShape(Circle())
                    }
                }
                
            }
        }
        .padding(.horizontal, 20)
        .statusBarHidden()
        .onAppear() {
            Task {
                lastSession()
                newSet()
                startTimer = Date()
                tooLongCheck()
                try? await Task.sleep(for: .seconds(300)) //try? before
                trueEnd = true
            }
        }
    }
}

struct ProgView: View {
    @Query(sort: \Performance.date_fr) var performances: [Performance]
    @Binding var whichView : ContentView.WhichViews
    @State private var fingerOn: Int?
    @State private var password = ""

    func toCSV(performances: [Performance]) -> URL {
        var ids: [String] = []
        var seances: [Int] = []
        var n1s: [Int] = []
        var n2s: [Int] = []
        var answers: [Int] = []
        var reactionTimes: [Double] = []
        var results: [String] = []
        var dates: [String] = []
        for perf in performances {
            ids.append(perf.id.uuidString)
            seances.append(perf.seance)
            n1s.append(perf.n1)
            n2s.append(perf.n2)
            answers.append(perf.answer)
            reactionTimes.append(perf.reaction_time)
            results.append(perf.result)
            dates.append(perf.date_fr)
        }
        var df = DataFrame()
        df.append(column: Column(name: "id", contents: ids))
        df.append(column: Column(name: "seance", contents: seances))
        df.append(column: Column(name: "n1", contents: n1s))
        df.append(column: Column(name: "n2", contents: n2s))
        df.append(column: Column(name: "answer", contents: answers))
        df.append(column: Column(name: "reaction_time", contents: reactionTimes))
        df.append(column: Column(name: "result", contents: results))
        df.append(column: Column(name: "date_fr", contents: dates))
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("00.csv")
        print(url)
        try? df.writeCSV(to: url)
        return url
    }

        
    struct TabletData: Identifiable {
        let id: Int
        let numberOfCorrect: Int
    }
    
    var tabletData: [TabletData] {
        var tempTabletData: [TabletData] = []
        var uniqueSess: [Int] = []
        for performance in performances {
            if !uniqueSess.contains(performance.seance) {
                uniqueSess.append(performance.seance)
            }
        }
        for sess in uniqueSess {
            var countingCorrect = 0
            for performance in performances {
                if performance.seance == sess && performance.result == "correct"{
                    countingCorrect += 1
                }
            }
            tempTabletData.append(TabletData(id: sess, numberOfCorrect: countingCorrect))
        }
        return tempTabletData
    }
    

    var maxID: Int {
        var tempMaxID: Int = 1
        for data in tabletData {
            if data.id > tempMaxID {
                tempMaxID = data.id
            }
        }
        return tempMaxID
    }

    

    var body: some View {
        VStack (){
            Text("Mes progrès")
                .font(.custom("MarelleBaton-Regular", size: 40))
                .fontWeight(.bold)
            Spacer()

            Chart (tabletData, id: \.id) { bar in
                    BarMark(
                        x: .value("Session",bar.id),
                        y: .value("Correct", bar.numberOfCorrect),
                        width: .fixed(min(80, CGFloat(400/(maxID))))
                    )
                    .clipShape(Capsule())
                    .foregroundStyle(fingerOn == bar.id ? .green : .blue)
                if let fingerOn,
                   let selectedBar = tabletData.first(where: {$0.id == fingerOn }) {
                    PointMark(
                        x: .value("Session", fingerOn),
                        y: .value("Correct", selectedBar.numberOfCorrect)
                    )
                    .foregroundStyle(.clear) 
                    .annotation(position: .top,
                        alignment: .center, spacing: 8,
                        overflowResolution: .init(x: .fit, y: .disabled)
                    ) {
                        VStack(spacing: 4) {
                            Text("Séance \(selectedBar.id) :")
                                .font(.custom("MarelleBaton-Regular", size: 16))
                                .foregroundStyle(.white)
                            Text("\(selectedBar.numberOfCorrect) bonne\(selectedBar.numberOfCorrect > 1 ? "s":"") réponse\(selectedBar.numberOfCorrect > 1 ? "s":"")")
                                .font(.custom("MarelleBaton-Regular", size: 24))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .padding(15)
                        .background(Capsule().fill(Color.green))
                    }
                }
            }
            .animation(.smooth(), value: fingerOn)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 200)
            .padding(.vertical, 20)
            .chartXScale(domain: 1...maxID)
            .chartXSelection(value: $fingerOn) //magic $ to write :)
            .chartXAxis {
                AxisMarks() {
                    AxisGridLine()
                    AxisTick(length: 10)
                    AxisValueLabel()
                        .font(.custom("MarelleBaton-Regular", size: 18))
                        .foregroundStyle(.black)
                }
            }
            .chartXAxisLabel(alignment: .center) {
                Text("Mes séances")
                    .font(.custom("MarelleBaton-Regular", size: 24))
                    .foregroundStyle(.black)
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick(length: 40).foregroundStyle(.clear)
                    AxisValueLabel()
                        .font(.custom("MarelleBaton-Regular", size: 18))
                        .foregroundStyle(.blue)
                }
            }
            .chartYAxisLabel(position: .leading, alignment: .center) {
                Text("Nombre de bonnes réponses")
                    .font(.custom("MarelleBaton-Regular", size: 24))
                    .foregroundStyle(.blue)
                    .rotationEffect(.degrees(180))
                    .padding(20)
            }
            .padding(.leading, -160)
            Spacer()
            Spacer()
            HStack(){
                if password == "secret" {
                    ShareLink(item: toCSV(performances: performances)) {
                        Label("", systemImage: "square.and.arrow.down")
                    }
                }
                SecureField("Résultats", text: $password)
                    .font(.custom("MarelleBaton-Regular", size: 18))
                    .frame(width: 100, height: 5)
                    .opacity(0.4)
            }
            Spacer()
            Spacer()
            HStack (spacing:50) {
                Button("Menu", systemImage: "house.fill") {
                    withAnimation {
                        whichView = .home
                    }
                }
                .font(.custom("MarelleBaton-Regular", size: 20))
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 60).stroke(.blue))
                .foregroundColor(.blue)
                Button("Mes progrès", systemImage: "chart.bar.fill") {
                    withAnimation {
                        whichView = .progression
                    }
                }
                .font(.custom("MarelleBaton-Regular", size: 20))
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 60).fill(.blue).opacity(0.3))
                .foregroundColor(.white)
                .disabled(true)
            }
        }
        }


}

#Preview {
    ContentView()
}
