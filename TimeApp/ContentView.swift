import SwiftUI

struct ContentView: View {
    @State private var currentDate: String = "Loading..."
    @State private var currentTime: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .center) {
            Text("Current Date & Time")
                .font(.largeTitle)
                .multilineTextAlignment(.leading)
                .padding(0.0)

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

            Button(action: fetchTime) {
                Text("Refresh Time")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Toggle(isOn: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Is On@*/.constant(true)/*@END_MENU_TOKEN@*/) {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Label@*/Text("Switch")/*@END_MENU_TOKEN@*/
            }
            List {
                Text("Item 1")
                
            }
        }
        .onAppear(perform: fetchTime)
    }

    func fetchTime() {
        let urlString = "http://worldtimeapi.org/api/ip"
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
                    // Parse the date and time
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
        // Extract the date and time from the ISO 8601 datetime string
        let parts = datetime.split(separator: "T")
        guard parts.count == 2 else { return ("Invalid date", "Invalid time") }
        let date = String(parts[0])

        // Extract time part (up to HH:MM)
        let timePart = parts[1].split(separator: ":")
        let time = timePart.count >= 2 ? "\(timePart[0]):\(timePart[1])" : "Invalid time"

        return (date, time)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
