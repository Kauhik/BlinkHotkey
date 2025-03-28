//
//  ContentView.swift
//  BlinkHotkey
//
//  Created by Kaushik Manian on 28/3/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var blinkDetector: BlinkDetector

    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            VStack(spacing: 10) {
                Text("Select an item").font(.headline)
                Text("Blink Detection Enabled: \(blinkDetector.isDetectionEnabled ? "Yes" : "No")")
                Text("Calibrated: \(blinkDetector.isCalibrated ? "Yes" : "No")")
            }
            .padding()
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
        try? modelContext.save()
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .environmentObject(BlinkDetector())
        .modelContainer(for: Item.self, inMemory: true)
}
