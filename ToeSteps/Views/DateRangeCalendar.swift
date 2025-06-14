import SwiftUI

struct DateRangeCalendar: View {
   @Binding var startDate: Date
   @Binding var endDate: Date

   @State private var selectingStart = true
   @State private var tempStart: Date?
   @State private var tempEnd: Date?
   @State private var showMonthYearPicker = false
   @State private var tempPickerMonth: Int = 1 // default, set when showing picker
   @State private var tempPickerYear: Int = 2024 // default, set when showing picker

   let rangeLimitDays = 60
   let calendar = Calendar.current

   private var monthDates: [Date] {
	  let components = calendar.dateComponents([.year, .month], from: startDate)
	  let firstOfMonth = calendar.date(from: components)!
	  let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)!.count
	  return (1...daysInMonth).compactMap {
		 calendar.date(bySetting: .day, value: $0, of: firstOfMonth)
	  }
   }

   var body: some View {
	  VStack(spacing: 8) {
		 HStack {
			Text("Select Date Range")
			   .bold()
			   .font(.title)
			Spacer()
		 }
		 .padding(.bottom, 8)

		 // Month title
		 HStack {
			Button(action: {
			   if let prev = calendar.date(byAdding: .month, value: -1, to: startDate) {
				  startDate = prev
				  endDate = prev
				  selectingStart = true
			   }
			}) {
			   Image(systemName: "chevron.left")
			}
			Spacer()
			Button(action: {
			   tempPickerMonth = calendar.component(.month, from: startDate)
			   tempPickerYear = calendar.component(.year, from: startDate)
			   showMonthYearPicker = true
			}) {
			   Text(monthLabel(from: startDate))
				  .font(.headline)
				  .underline()
			}
			Spacer()
			Button(action: {
			   if let next = calendar.date(byAdding: .month, value: 1, to: startDate) {
				  startDate = next
				  endDate = next
				  selectingStart = true
			   }
			}) {
			   Image(systemName: "chevron.right")
			}
		 }
		 .foregroundColor(.blue)

		 // Day headers
		 LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
			ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
			   Text(day).font(.caption).foregroundColor(.gray)
			}
		 }

		 // Days in month
		 LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
			let firstDate = monthDates.first!
			let weekday = calendar.component(.weekday, from: firstDate)
			// blank spaces at beginning
			ForEach(0..<((weekday + 6) % 7), id: \.self) { _ in
			   Text("")
				  .frame(height: 32)
			}
			ForEach(monthDates, id: \.self) { date in
			   ZStack {
				  if isSelected(date: date) {
					 RoundedRectangle(cornerRadius: 6)
						.fill(Color.blue.opacity(isEdge(date: date) ? 1.0 : 0.25))
						.frame(height: 32)
				  }
				  Text("\(calendar.component(.day, from: date))")
					 .foregroundColor(textColor(date))
					 .bold(isEdge(date: date))
			   }
			   .frame(maxWidth: .infinity, minHeight: 32)
			   .onTapGesture {
				  tap(date: date)
			   }
			}
		 }
		 .padding(.vertical, 8)

		 // Selection info
		 HStack {
			if let s = tempStart {
			   Text("Start: \(formattedDate(s))")
				  .foregroundColor(.green)
			}
			if let e = tempEnd {
			   Text("End: \(formattedDate(e))")
				  .foregroundColor(.orange)
			}
		 }
		 .font(.footnote)
	  }
	  .padding()
	  .background(Color(.systemGray6))
	  .cornerRadius(18)
	  .sheet(isPresented: $showMonthYearPicker) {
		 VStack {
			Text("Jump to Month/Year").font(.title2).bold()
			HStack {
			   // Month picker
			   Picker("Month", selection: $tempPickerMonth) {
				  ForEach(1...12, id: \.self) { monthNum in
					 Text(Calendar.current.monthSymbols[monthNum - 1]).tag(monthNum)
				  }
			   }.pickerStyle(.wheel)
			   // Year picker
			   Picker("Year", selection: $tempPickerYear) {
				  let nowYear = Calendar.current.component(.year, from: Date())
				  ForEach((nowYear-5)...(nowYear+5), id: \.self) { year in
					 Text(String(year)).tag(year)
				  }
			   }.pickerStyle(.wheel)
			}.frame(height: 140)
			Button("Go") {
			   if let picked = calendar.date(from: DateComponents(year: tempPickerYear, month: tempPickerMonth, day: 1)) {
				  // Set both start and end to this month (don't auto-choose range, just change view)
				  startDate = picked
				  endDate = picked
			   }
			   showMonthYearPicker = false
			}
			.padding(.top,12)
		 }
		 .presentationDetents([.medium])
		 .padding()
	  }
	  .onAppear {
		 tempStart = startDate
		 tempEnd = endDate
		 selectingStart = true
	  }
   }

   private func tap(date: Date) {
	  if selectingStart {
		 tempStart = date
		 tempEnd = nil
		 selectingStart = false
	  } else {
		 if let s = tempStart, date >= s {
			tempEnd = date
			// Commit selection!
			startDate = s
			endDate = date
			selectingStart = true
		 } else {
			// If tapped date is before start, start again
			tempStart = date
			tempEnd = nil
			selectingStart = false
		 }
	  }
   }

   private func isSelected(date: Date) -> Bool {
	  if let s = tempStart, let e = tempEnd {
		 return date >= s && date <= e
	  }
	  if let s = tempStart {
		 return calendar.isDate(date, inSameDayAs: s)
	  }
	  return false
   }

   private func isEdge(date: Date) -> Bool {
	  if let s = tempStart, let e = tempEnd {
		 return calendar.isDate(date, inSameDayAs: s) || calendar.isDate(date, inSameDayAs: e)
	  }
	  if let s = tempStart {
		 return calendar.isDate(date, inSameDayAs: s)
	  }
	  return false
   }

   private func textColor(_ date: Date) -> Color {
	  if isSelected(date: date) {
		 return .white
	  }
	  return .primary
   }

   private func formattedDate(_ d: Date) -> String {
	  let f = DateFormatter()
	  f.dateStyle = .medium
	  return f.string(from: d)
   }

   private func monthLabel(from date: Date) -> String {
	  let f = DateFormatter()
	  f.dateFormat = "LLLL yyyy"
	  return f.string(from: date)
   }
}
