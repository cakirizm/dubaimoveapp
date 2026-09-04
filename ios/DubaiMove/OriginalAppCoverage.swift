import SwiftUI

enum LegacyScreen: String, CaseIterable, Identifiable {
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
        let map: [LegacyScreen:String] = [
            .welcome:"Welcome", .createAccount:"Create Account", .otpVerification:"OTP Verification", .login:"Log In", .forgotPassword:"Forgot Password",
            .moveSetup:"What Are You Doing?", .movingDate:"Moving Date", .propertyType:"Property Type", .readinessDetail:"Move Readiness Detail",
            .currentHome:"Current Home", .newHome:"New Home", .buildingSearch:"Building Search", .unknownBuilding:"Add Unknown Building",
            .fullChecklist:"Full Checklist", .taskDetail:"Task Detail", .blockedTask:"Blocked Task", .timeline:"Move Timeline",
            .ejariReadiness:"Ejari Readiness", .ejariHandoff:"Ejari Official Handoff", .ejariTracking:"Ejari Tracking",
            .dewaMoveToReadiness:"DEWA Move-To Readiness", .dewaAccount:"DEWA Account Information", .premiseInformation:"Premise Information", .dewaHandoff:"DEWA Official Handoff", .dewaStatus:"DEWA Status",
            .moveInRules:"Move-In Rules", .permitRequirements:"Permit Requirements", .buildingContact:"Building Contact", .reportIncorrectBuilding:"Report Incorrect Information",
            .utilitiesHub:"Utilities Hub", .internetSetup:"Internet Setup", .utilityTaskDetail:"Utility Task Detail", .serviceCategory:"Service Category",
            .mediaUpload:"Photo / Media Upload", .requestConfirmation:"Request Confirmation", .requestCreated:"Request Created", .requestDetail:"Service Request Detail",
            .quoteDetail:"Quote Detail", .messages:"Messages", .updatedQuote:"Updated Quote", .conversationDetails:"Conversation Details", .bookings:"My Bookings",
            .bookingDetail:"Booking Detail", .bookingTracking:"Booking Tracking", .completeJob:"Complete Job", .review:"Review", .reportProblem:"Report Problem",
            .movingRequirements:"Moving Requirements", .movingInventory:"Moving Inventory", .movingQuoteComparison:"Moving Quote Comparison", .oldHomeDashboard:"Old Home Dashboard",
            .handoverReadiness:"Handover Readiness", .startInspection:"Start Inspection", .roomInspection:"Room Inspection", .inspectionIssue:"Inspection Issue", .inspectionSummary:"Inspection Summary",
            .documentDetail:"Document Detail", .uploadDocument:"Upload Document", .expenseDetail:"Expense Detail", .addManualExpense:"Add Manual Expense", .refunds:"Refunds",
            .aiActionResult:"AI Action Result", .notificationDetail:"Notification Detail", .profile:"Profile", .familyMembers:"Family Members", .notificationSettings:"Notification Settings",
            .help:"Help", .supportTicket:"Support Ticket"
        ]
        return map[self] ?? rawValue
    }

    var icon: String {
        switch self {
        case .welcome,.createAccount,.otpVerification,.login,.forgotPassword,.profile,.familyMembers: return "person.crop.circle"
        case .currentHome,.newHome,.buildingSearch,.unknownBuilding,.moveInRules,.permitRequirements,.buildingContact,.reportIncorrectBuilding: return "building.2"
        case .ejariReadiness,.ejariHandoff,.ejariTracking: return "doc.text"
        case .dewaMoveToReadiness,.dewaAccount,.premiseInformation,.dewaHandoff,.dewaStatus,.utilitiesHub,.internetSetup,.utilityTaskDetail: return "bolt"
        case .movingRequirements,.movingInventory,.movingQuoteComparison: return "truck.box"
        case .oldHomeDashboard,.handoverReadiness,.startInspection,.roomInspection,.inspectionIssue,.inspectionSummary: return "camera.viewfinder"
        case .documentDetail,.uploadDocument: return "folder"
        case .expenseDetail,.addManualExpense,.refunds: return "banknote"
        case .aiActionResult: return "sparkles"
        case .notificationDetail,.notificationSettings: return "bell"
        case .help,.supportTicket: return "questionmark.circle"
        default: return "checklist"
        }
    }

    var workflow: [String] {
        switch self {
        case .welcome: return ["Language choice", "Get Started", "Log In"]
        case .createAccount: return ["Name", "Email", "Mobile", "Password", "Consent"]
        case .otpVerification: return ["Verification code", "Resend", "Verify"]
        case .login: return ["Email / mobile", "Password", "Forgot password"]
        case .forgotPassword: return ["Verify identity", "Reset password"]
        case .moveSetup: return ["Within Dubai", "To Dubai", "Leaving Dubai", "Service only", "Manage property"]
        case .movingDate: return ["Exact date", "Flexible target date", "Not sure yet"]
        case .propertyType: return ["Apartment / Villa / Townhouse", "Bedrooms", "Household"]
        case .readinessDetail: return ["Contract", "Government & utilities", "Building", "Services", "Handover", "Money"]
        case .currentHome,.newHome: return ["Address", "Building", "Unit", "Map location"]
        case .buildingSearch: return ["Building autocomplete", "Community", "Unknown building option"]
        case .unknownBuilding: return ["Building name", "Community", "Address", "Admin verification queue"]
        case .fullChecklist: return ["All", "Blocked", "In progress", "Completed", "Category filters"]
        case .taskDetail: return ["Why", "Deadline", "Requirements", "Documents", "Start / Complete"]
        case .blockedTask: return ["Blocking dependency", "Reason", "Go to dependency"]
        case .timeline: return ["Task history", "Deadlines", "Provider events", "Official handoffs"]
        case .ejariReadiness: return ["Tenancy details", "Documents", "Approval status", "Readiness"]
        case .ejariHandoff: return ["Official channel", "What happens outside app", "Return and track"]
        case .ejariTracking: return ["Preparing", "External in progress", "Waiting landlord", "Completed / Problem"]
        case .dewaMoveToReadiness: return ["Existing account", "Move-out date", "9-digit premise", "Valid Ejari", "Move-in date"]
        case .dewaAccount: return ["Contract account number", "Account holder"]
        case .premiseInformation: return ["9-digit premise number", "New property"]
        case .dewaHandoff: return ["Review readiness", "Official DEWA handoff", "Return and track"]
        case .dewaStatus: return ["Submitted", "Payment pending", "Scheduled", "Activated", "Problem"]
        case .moveInRules: return ["Permit", "Lift", "Hours", "Insurance", "Loading / parking"]
        case .permitRequirements: return ["Required docs", "Provider docs", "Readiness"]
        case .buildingContact: return ["Phone", "Email", "Portal", "Office"]
        case .reportIncorrectBuilding: return ["Incorrect field", "Correction", "Evidence", "Submit review"]
        case .utilitiesHub: return ["DEWA", "Internet", "Cooling", "Gas if applicable"]
        case .internetSetup: return ["Transfer", "New connection", "Cancel"]
        case .utilityTaskDetail: return ["Status", "Requirements", "Official / provider action"]
        case .serviceCategory: return ["Sub-services", "Scope", "Start request"]
        case .mediaUpload: return ["Photos", "Video", "Files", "Remove before submit"]
        case .requestConfirmation: return ["Scope", "Addresses", "Date", "Media", "Submit"]
        case .requestCreated: return ["Matching providers", "Status", "Notifications"]
        case .requestDetail: return ["Status", "Quotes", "Messages", "Attachments"]
        case .quoteDetail: return ["Provider fee", "Official fee", "Scope", "Exclusions", "Validity", "Accept / Message / Decline"]
        case .messages: return ["Conversations", "Unread", "Request / booking context"]
        case .updatedQuote: return ["Old price", "New price", "Reason", "Accept latest / Reject"]
        case .conversationDetails: return ["Provider", "Request", "Booking", "Report / Block"]
        case .bookings: return ["Upcoming", "Today", "Completed", "Cancelled"]
        case .bookingDetail: return ["Provider", "Date", "Addresses", "Scope", "Message / Track"]
        case .bookingTracking: return ["Confirmed", "On the way", "Arrived", "In progress", "Provider completed"]
        case .completeJob: return ["Confirm complete", "Report issue", "Evidence"]
        case .review: return ["Overall", "Punctuality", "Price accuracy", "Quality", "Comment"]
        case .reportProblem: return ["Type", "Description", "Evidence", "Complaint"]
        case .movingRequirements: return ["Packing", "Disassembly", "Fragile", "Special items", "Access"]
        case .movingInventory: return ["Rooms", "Furniture", "Boxes", "Special items", "AI video inventory"]
        case .movingQuoteComparison: return ["Price", "Scope", "Crew", "Truck", "Insurance", "Hidden-cost risk"]
        case .oldHomeDashboard: return ["Inspection", "Cleaning", "Utilities", "Keys", "Deposit", "Handover"]
        case .handoverReadiness: return ["Inspection", "Final bills", "Cleaning evidence", "Keys", "Deposit"]
        case .startInspection: return ["Living room", "Kitchen", "Bedrooms", "Bathrooms", "Balcony"]
        case .roomInspection: return ["Photos", "Issue", "Note", "Complete room"]
        case .inspectionIssue: return ["Issue type", "Severity", "Media", "User confirmation"]
        case .inspectionSummary: return ["Rooms", "Issues", "Evidence", "Generate report"]
        case .documentDetail: return ["Metadata", "Linked tasks", "Sharing scope", "Replace / Delete"]
        case .uploadDocument: return ["Type", "File", "Expiry", "Private upload"]
        case .expenseDetail: return ["Category", "Expected", "Actual", "Source", "Edit"]
        case .addManualExpense: return ["Type", "Amount", "Date", "Note"]
        case .refunds: return ["Security deposit", "DEWA", "Cooling", "Expected / received"]
        case .aiActionResult: return ["Answer", "Reason", "Suggested next action", "Deep link"]
        case .notificationDetail: return ["Reason", "Linked entity", "Open task"]
        case .profile: return ["Personal details", "Language", "Family", "Security", "Properties"]
        case .familyMembers: return ["Members", "Permissions", "Invite", "Remove access"]
        case .notificationSettings: return ["Push", "Email", "Transactional fallback", "Marketing separate"]
        case .help: return ["FAQ", "Move guides", "Contact support", "Report problem"]
        case .supportTicket: return ["Category", "Message", "Attachment", "Submit"]
        }
    }
}

struct OriginalAppCoverageView: View {
    let screen: LegacyScreen
    @State private var field = ""
    @State private var completed = false

    var body: some View {
        Form {
            Section {
                Label(screen.title, systemImage: screen.icon).font(.title2.bold()).foregroundStyle(DMTheme.green)
                Text("Restored from the original Dubai Move U-001…U-094 workflow contract.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Workflow") {
                ForEach(screen.workflow, id: \.self) { Label($0, systemImage: "chevron.right.circle.fill") }
            }
            if [.createAccount,.login,.forgotPassword,.unknownBuilding,.reportIncorrectBuilding,.addManualExpense,.supportTicket].contains(screen) {
                Section("Input") { TextField("Enter details", text: $field) }
            }
            Section {
                Button(completed ? "Saved" : primaryAction) { completed = true }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(DMTheme.green)
            }
            Section {
                Text("Government or regulated completion is never simulated. Production integrations execute or hand off real actions; provider access stays scoped to the job.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle(screen.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var primaryAction: String {
        switch screen {
        case .createAccount: return "Create Account"
        case .otpVerification: return "Verify"
        case .login: return "Log In"
        case .forgotPassword: return "Reset Password"
        case .buildingSearch: return "Select Building"
        case .unknownBuilding: return "Submit Building"
        case .blockedTask: return "Go to Dependency"
        case .ejariHandoff,.dewaHandoff: return "Continue to Official Channel"
        case .requestConfirmation: return "Submit Request"
        case .review: return "Submit Review"
        case .reportProblem: return "Submit Complaint"
        case .inspectionSummary: return "Generate Report"
        case .uploadDocument: return "Upload"
        case .addManualExpense: return "Save Expense"
        case .supportTicket: return "Submit Ticket"
        default: return "Continue"
        }
    }
}

struct OriginalScreenIndexView: View {
    var body: some View {
        List(LegacyScreen.allCases) { screen in
            NavigationLink(destination: OriginalAppCoverageView(screen: screen)) {
                Label(screen.title, systemImage: screen.icon)
            }
        }
        .navigationTitle("Original App Coverage")
    }
}
