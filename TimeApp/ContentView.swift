import SwiftUI
import CoreBluetooth

struct ContentView: View {
    var body: some View {
        TabView {
            BluetoothScreen()
                .tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Bluetooth")
                }
            
            TimeScreen()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Time")
                }
            
            
            DeviceScreen()
                .tabItem {
                    Image(systemName: "cpu.fill")
                    Text("Device")
                }
            
            EMScreen()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Usage")
                }
        }
    }
}

// BluetoothScreen
struct BluetoothScreen: View {
    @State private var availableDevices: [String] = []
    @State private var connectedDevices: [String] = []
    @State private var scanning = false
    
    var body: some View {
        VStack {
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .padding()
            
            Button(action: toggleScanning) {
                Text(scanning ? "Stop Scanning" : "Scan for Devices")
                    .padding()
                    .background(scanning ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            List {
                Section(header: Text("Available Devices")) {
                    ForEach(availableDevices, id: \.self) { device in
                        HStack {
                            Text(device)
                            Spacer()
                            Button("Connect") {
                                connectToDevice(device)
                            }
                            .padding(5)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        }
                    }
                }
                
                Section(header: Text("Connected Devices")) {
                    ForEach(connectedDevices, id: \.self) { device in
                        Text(device)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: [.blue, .white]).opacity(0.65))
    }
    
    func toggleScanning() {
        scanning.toggle()
        if scanning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                availableDevices = ["Smart Switch 1", "Wall Socket A", "Smart Bulb 3"]
            }
        } else {
            availableDevices = []
        }
    }
    
    func connectToDevice(_ device: String) {
        if !connectedDevices.contains(device) {
            connectedDevices.append(device)
        }
        availableDevices.removeAll { $0 == device }
    }
}

// TimeScreen
struct TimeScreen: View {
    @State private var selectedTimeZone: String = "America/New_York"
    @State private var timeZones: [String] = [
        "America/New_York",
        "America/Chicago",
        "America/Denver",
        "America/Los_Angeles",
        "America/Phoenix",
        "America/Anchorage",
        "America/Adak",
        "Pacific/Honolulu"
    ]
    @State private var currentDate: String = "Loading..."
    @State private var currentTime: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("Select Time Zone")
                .font(.largeTitle)
                .padding()

            Picker("Time Zone", selection: $selectedTimeZone) {
                ForEach(timeZones, id: \.self) { timeZone in
                    Text(timeZone).tag(timeZone)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()

            Button(action: fetchTime) {
                Text("Get Date & Time")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                Text("Date: \(currentDate)")
                    .font(.title2)
                    .padding()

                Text("Time: \(currentTime)")
                    .font(.title2)
                    .padding()
            }

            Spacer()
        }
        .onAppear(perform: fetchTime)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: [.teal, .white]).opacity(0.65))
    }

    func fetchTime() {
        let urlString = "http://worldtimeapi.org/api/timezone/\(selectedTimeZone)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network Error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let datetime = json["datetime"] as? String {
                    let parsedDateTime = parseDateTime(datetime)
                    DispatchQueue.main.async {
                        currentDate = parsedDateTime.date
                        currentTime = parsedDateTime.time
                        errorMessage = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Unexpected response format"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Parsing Error: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }

    func parseDateTime(_ datetime: String) -> (date: String, time: String) {
        let parts = datetime.split(separator: "T")
        guard parts.count == 2 else { return ("Invalid date", "Invalid time") }
        let date = String(parts[0])

        let timePart = parts[1].split(separator: ":")
        let time = timePart.count >= 2 ? "\(timePart[0]):\(timePart[1])" : "Invalid time"

        return (date, time)
    }
}

// EMScreen
struct EMScreen: View {
    var body: some View {
        VStack {
            Text("Welcome to Usage Screen")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: [.teal, .brown, .white]).opacity(0.65))
    }
}


// DeviceScreen
struct DeviceScreen: View {
    @State private var connectedDevices: [String] = []
    
    var body: some View {
        VStack {
            Text("Connected Devices")
                .font(.largeTitle)
                .padding()
            
            List(connectedDevices, id: \.self) { device in
                Text(device)
            }
            
            Spacer()
        }
        .onAppear {
            fetchConnectedDevices()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Gradient(colors: [.teal, .green, .white]).opacity(0.65))
    }
    
    func fetchConnectedDevices() {
        connectedDevices = ["Smart Switch 1", "Wall Socket A"]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
