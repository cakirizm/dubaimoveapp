import SwiftUI

enum LegacyScreen: String, CaseIterable, Hashable, Identifiable {
    case welcome, createAccount, otpVerification, login, forgotPassword, moveSetup, movingDate, propertyType
    case readinessDetail, currentHome, newHome, buildingSearch, unknownBuilding, fullChecklist, taskDetail, blockedTask, timeline
    case ejariReadiness, ejariHandoff, ejariTracking, dewaMoveToReadiness, dewaAccount, premiseInformation, dewaHandoff, dewaStatus
    case moveInRules, permitRequirements, buildingContact, reportIncorrectBuilding, utilitiesHub, internetSetup, utilityTaskDetail
    case serviceCategory, mediaUpload, requestConfirmation, requestCreated, requestDetail, quoteDetail, messages, updatedQuote, conversationDetails
    case bookings, bookingDetail, bookingTracking, completeJob, review, reportProblem, movingRequirements, movingInventory, movingQuoteComparison
    case oldHomeDashboard, handoverReadiness, startInspection, roomInspection, inspectionIssue, inspectionSummary
    case documentDetail, uploadDocument, expenseDetail, addManualExpense, refunds, aiActionResult, notificationDetail, profile, familyMembers
    case notificationSettings, help, supportTicket

    var id: String { rawValue }

    var title: String {
        switch self {
        case .welcome: "Welcome"
        case .createAccount: "Create Account"
        case .otpVerification: "OTP Verification"
        case .login: "Log In"
        case .forgotPassword: "Forgot Password"
        case .moveSetup: "What Are You Doing?"
        case .movingDate: "Moving Date"
        case .propertyType: "Property Type"
        case .readinessDetail: "Move Readiness Detail"
        case .currentHome: "Current Home"
        case .newHome: "New Home"
        case .buildingSearch: "Building Search"
        case .unknownBuilding: "Add Unknown Building"
        case .fullChecklist: "Full Checklist"
        case .taskDetail: "Task Detail"
        case .blockedTask: "Blocked Task"
        case .timeline: "Move Timeline"
        case .ejariReadiness: "Ejari Readiness"
        case .ejariHandoff: "Ejari Official Handoff"
        case .ejariTracking: "Ejari Tracking"
        case .dewaMoveToReadiness: "DEWA Move-To Readiness"
        case .dewaAccount: "DEWA Account Information"
        case .premiseInformation: "Premise Information"
        case .dewaHandoff: "DEWA Official Handoff"
        case .dewaStatus: "DEWA Status"
        case .moveInRules: "Move-In Rules"
        case .permitRequirements: "Permit Requirements"
        case .buildingContact: "Building Contact"
        case .reportIncorrectBuilding: "Report Incorrect Information"
        case .utilitiesHub: "Utilities Hub"
        case .internetSetup: "Internet Setup"
        case .utilityTaskDetail: "Utility Task Detail"
        case .serviceCategory: "Service Category"
        case .mediaUpload: "Photo / Media Upload"
        case .requestConfirmation: "Request Confirmation"
        case .requestCreated: "Request Created"
        case .requestDetail: "Service Request Detail"
        case .quoteDetail: "Quote Detail"
        case .messages: "Messages"
        case .updatedQuote: "Updated Quote"
        case .conversationDetails: "Conversation Details"
        case .bookings: "My Bookings"
        case .bookingDetail: "Booking Detail"
        case .bookingTracking: "Booking Tracking"
        case .completeJob: "Complete Job"
        case .review: "Review"
        case .reportProblem: "Report Problem"
        case .movingRequirements: "Moving Requirements"
        case .movingInventory: "Moving Inventory"
        case .movingQuoteComparison: "Moving Quote Comparison"
        case .oldHomeDashboard: "Old Home Dashboard"
        case .handoverReadiness: "Handover Readiness"
        case .startInspection: "Start Inspection"
        case .roomInspection: "Room Inspection"
        case .inspectionIssue: "Inspection Issue"
        case .inspectionSummary: "Inspection Summary"
        case .documentDetail: "Document Detail"
        case .uploadDocument: "Upload Document"
        case .expenseDetail: "Expense Detail"
        case .addManualExpense: "Add Manual Expense"
        case .refunds: "Refunds"
        case .aiActionResult: "AI Action Result"
        case .notificationDetail: "Notification Detail"
        case .profile: "Profile"
        case .familyMembers: "Family Members"
        case .notificationSettings: "Notification Settings"
        case .help: "Help"
        case .supportTicket: "Support Ticket"
        }
    }

    var icon: String {
        switch self {
        case .welcome, .createAccount, .otpVerification, .login, .forgotPassword, .profile, .familyMembers: "person.crop.circle"
        case .currentHome, .newHome, .buildingSearch, .unknownBuilding, .moveInRules, .permitRequirements, .buildingContact, .reportIncorrectBuilding: "building.2"
        case .ejariReadiness, .ejariHandoff, .ejariTracking: "doc.text"
        case .dewaMoveToReadiness, .dewaAccount, .premiseInformation, .dewaHandoff, .dewaStatus, .utilitiesHub, .internetSetup, .utilityTaskDetail: "bolt"
        case .serviceCategory, .mediaUpload, .requestConfirmation, .requestCreated, .requestDetail, .quoteDetail, .messages, .updatedQuote, .conversationDetails, .bookings, .bookingDetail, .bookingTracking, .completeJob, .review, .reportProblem: "square.grid.2x2"
        case .movingRequirements, .movingInventory, .movingQuoteComparison: "truck.box"
        case .oldHomeDashboard, .handoverReadiness, .startInspection, .roomInspection, .inspectionIssue, .inspectionSummary: "camera.viewfinder"
        case .documentDetail, .uploadDocument: "folder"
        case .expenseDetail, .addManualExpense, .refunds: "banknote"
        case .aiActionResult: "sparkles"
        case .notificationDetail, .notificationSettings: "bell"
        case .help, .supportTicket: "questionmark.circle"
        default: "checklist"
        }
    }

    var rows: [String] {
        switch self {
        case .welcome: ["English / Arabic language choice", "Get Started", "Log In"]
        case .createAccount: ["Full name", "Email", "Mobile", "Password", "Required consent"]
        case .otpVerification: ["6-digit verification code", "Resend code", "Verify account"]
        case .login: ["Email or mobile", "Password", "Log In", "Forgot Password"]
        case .forgotPassword: ["Identity verification", "Reset password", "Return to login"]
        case .moveSetup: ["Moving within Dubai", "Moving to Dubai", "Leaving Dubai", "Home service only", "Manage existing property"]
        case .movingDate: ["Choose move date", "I am not sure yet", "Flexible target date"]
        case .propertyType: ["Apartment / Villa / Townhouse", "Bedrooms", "Occupancy / household"]
        case .readinessDetail: ["Contract", "Government & utilities", "Building", "Services", "Old-home handover", "Money"]
        case .currentHome: ["Address", "Building", "Unit", "Current tenancy status"]
        case .newHome: ["Address", "Building", "Unit", "Move-in date"]
        case .buildingSearch: ["Search building or community", "Recent choices", "Can't find my building"]
        case .unknownBuilding: ["Building name", "Community", "Address details", "Submit for verification"]
        case .fullChecklist: ["All tasks", "Blocked", "In progress", "Completed", "Filter by category"]
        case .taskDetail: ["Why this task matters", "Deadline", "Requirements", "Documents", "Start / Complete"]
        case .blockedTask: ["Blocking dependency", "Why it is blocked", "Go to dependency", "Return after completion"]
        case .timeline: ["Move events", "Deadlines", "Provider events", "Official handoff events"]
        case .ejariReadiness: ["Tenancy information", "Required documents", "Landlord approval state", "Continue when ready"]
        case .ejariHandoff: ["Official channel", "What happens outside Dubai Move", "Return and update status"]
        case .ejariTracking: ["Preparing", "External in progress", "Waiting landlord", "Completed / Problem"]
        case .dewaMoveToReadiness: ["Existing DEWA account", "Move-out date", "9-digit premise number", "Valid Ejari", "Move-in date"]
        case .dewaAccount: ["Contract account number", "Account holder", "Save securely"]
        case .premiseInformation: ["9-digit premise number", "New property", "Validate before handoff"]
        case .dewaHandoff: ["Official DEWA channel", "Review data before leaving app", "Return and track"]
        case .dewaStatus: ["Submitted", "Payment pending", "Scheduled", "Activated", "Problem"]
        case .moveInRules: ["Move permit", "Lift reservation", "Moving hours", "Mover insurance", "Loading / parking"]
        case .permitRequirements: ["Required building documents", "Provider documents", "Readiness", "Submit / mark complete"]
        case .buildingContact: ["Management phone", "Email", "Portal", "Office details"]
        case .reportIncorrectBuilding: ["Choose incorrect field", "Describe correction", "Attach evidence", "Submit for review"]
        case .utilitiesHub: ["DEWA", "Internet", "Cooling", "Gas if applicable", "Utility status"]
        case .internetSetup: ["Transfer", "New connection", "Cancel", "Provider handoff"]
        case .utilityTaskDetail: ["Current status", "Requirements", "Official/provider action", "Mark progress"]
        case .serviceCategory: ["Choose sub-service", "See scope", "Start request"]
        case .mediaUpload: ["Photos", "Video", "Files", "Remove before submission"]
        case .requestConfirmation: ["Scope", "Addresses", "Date", "Media", "Submit request"]
        case .requestCreated: ["Matching providers", "Request status", "Notifications", "View request"]
        case .requestDetail: ["Request status", "Quotes", "Messages", "Attachments", "Cancel if eligible"]
        case .quoteDetail: ["Provider fee", "Official fee if applicable", "Scope", "Exclusions", "Validity", "Accept / Message / Decline"]
        case .messages: ["Active conversations", "Unread count", "Booking / request context"]
        case .updatedQuote: ["Old price", "New price", "Revision reason", "Accept latest / Reject"]
        case .conversationDetails: ["Provider", "Linked request", "Linked booking", "Report / Block"]
        case .bookings: ["Upcoming", "Today", "Completed", "Cancelled"]
        case .bookingDetail: ["Provider", "Date and time", "Addresses", "Scope", "Message / Track"]
        case .bookingTracking: ["Confirmed", "On the way", "Arrived", "In progress", "Provider completed"]
        case .completeJob: ["Confirm complete", "Something is wrong", "Add evidence"]
        case .review: ["Overall rating", "Punctuality", "Price accuracy", "Service quality", "Comment"]
        case .reportProblem: ["Problem type", "Description", "Photos / files", "Submit complaint"]
        case .movingRequirements: ["Packing", "Disassembly", "Fragile items", "Special items", "Access constraints"]
        case .movingInventory: ["Rooms", "Furniture", "Boxes", "Special items", "AI video inventory"]
        case .movingQuoteComparison: ["Price", "Scope", "Crew", "Truck", "Insurance", "Hidden-cost risk"]
        case .oldHomeDashboard: ["Inspection", "Cleaning", "Utilities", "Keys", "Deposit", "Handover"]
        case .handoverReadiness: ["Inspection", "Final bills", "Cleaning evidence", "Keys", "Deposit status"]
        case .startInspection: ["Living room", "Kitchen", "Bedrooms", "Bathrooms", "Balcony"]
        case .roomInspection: ["Take photos", "Record issue", "Add note", "Mark room complete"]
        case .inspectionIssue: ["Issue type", "Severity", "Photo / video", "User confirmation"]
        case .inspectionSummary: ["Room status", "Issues", "Evidence count", "Generate condition report"]
        case .documentDetail: ["File metadata", "Linked tasks", "Sharing scope", "Replace", "Delete"]
        case .uploadDocument: ["Document type", "File", "Expiry date if relevant", "Upload privately"]
        case .expenseDetail: ["Category", "Expected amount", "Actual amount", "Provider / source", "Edit"]
        case .addManualExpense: ["Expense type", "Amount", "Date", "Note", "Save"]
        case .refunds: ["Security deposit", "DEWA refund", "Cooling refund", "Expected / received", "Update status"]
        case .aiActionResult: ["Answer", "Why", "Suggested next action", "Open linked screen"]
        case .notificationDetail: ["Why you received this", "Linked move item", "Open task"]
        case .profile: ["Personal details", "Language", "Family", "Security", "My properties"]
        case .familyMembers: ["Members", "Permissions", "Invite member", "Remove access"]
        case .notificationSettings: ["Push", "Email", "Transactional fallback", "Marketing consent kept separate"]
        case .help: ["FAQs", "Move guides", "Contact support", "Report a problem"]
        case .supportTicket: ["Category", "Message", "Attachment", "Submit ticket"]
        }
    }
}

struct OriginalAppCoverageView: View {
    let screen: LegacyScreen
    @State private var text = ""
    @State private var enabled = true

    var body: some View {
        Form {
            Section {
                HStack(spacing: 14) {
                    Image(systemName: screen.icon).font(.title2).foregroundStyle(DMTheme.green)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(screen.title).font(.title2.bold())
                        Text("Original Dubai Move workflow restored in the iOS architecture").font(.caption).foregroundStyle(.secondary)
                    }
                }.padding(.vertical, 8)
            }
            Section("Workflow") {
                ForEach(screen.rows, id: \.self) { row in
                    HStack {
                        Image(systemName: "chevron.right.circle.fill").foregroundStyle(DMTheme.green)
                        Text(row)
                    }
                }
            }
            if [.createAccount, .login, .forgotPassword, .unknownBuilding, .reportIncorrectBuilding, .supportTicket, .addManualExpense].contains(screen) {
                Section("Input") { TextField("Enter details", text: $text) }
            }
            if [.notificationSettings, .familyMembers].contains(screen) {
                Section("Settings") { Toggle("Enabled", isOn: $enabled) }
            }
            Section {
                Button(primaryAction) { }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(DMTheme.green)
            }
            Section {
                Text("Active controls are intentionally wired as interaction points. Production API/storage actions are attached in the integration layer; legal or government completion is never simulated.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle(screen.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var primaryAction: String {
        switch screen {
        case .welcome: "Get Started"
        case .createAccount: "Create Account"
        case .otpVerification: "Verify"
        case .login: "Log In"
        case .forgotPassword: "Reset Password"
        case .moveSetup, .movingDate, .propertyType: "Continue"
        case .currentHome, .newHome, .dewaAccount, .premiseInformation, .notificationSettings: "Save"
        case .buildingSearch: "Select Building"
        case .unknownBuilding: "Submit Building"
        case .fullChecklist, .timeline, .messages, .bookings: "Open Selected Item"
        case .blockedTask: "Go to Dependency"
        case .ejariHandoff, .dewaHandoff: "Continue to Official Channel"
        case .requestConfirmation: "Submit Request"
        case .requestCreated, .requestDetail: "View Request"
        case .quoteDetail, .updatedQuote: "Review Latest Quote"
        case .completeJob: "Confirm Completion"
        case .review: "Submit Review"
        case .reportProblem: "Submit Complaint"
        case .inspectionSummary: "Generate Report"
        case .uploadDocument: "Upload"
        case .addManualExpense: "Save Expense"
        case .supportTicket: "Submit Ticket"
        default: "Continue"
        }
    }
}

struct OriginalScreenIndexView: View {
    var body: some View {
        List {
            Section {
                Text("Original User App coverage")
                    .font(.headline)
                Text("Restored screens that were separate in the first U-001…U-094 architecture and were previously merged or missing in the SwiftUI rebuild.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            ForEach(LegacyScreen.allCases) { screen in
                NavigationLink(value: AppRoute.legacy(screen)) {
                    Label(screen.title, systemImage: screen.icon)
                }
            }
        }
        .navigationTitle("Original App Screens")
        .navigationDestination(for: AppRoute.self) { FeatureRouter(route: $0) }
    }
}
