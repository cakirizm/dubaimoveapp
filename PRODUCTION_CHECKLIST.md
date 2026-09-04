# Dubai Move — Production Checklist

## Build & Release
- [x] Native SwiftUI project exists
- [x] Shared Xcode scheme exists
- [x] GitHub Actions simulator build gate exists
- [x] Codemagic simulator workflow exists
- [x] Codemagic App Store archive workflow exists
- [ ] App icon asset catalog
- [ ] Final launch artwork
- [ ] App Store signing certificate/profile connected in Codemagic
- [ ] App Store Connect app record matches bundle identifier
- [ ] TestFlight archive and upload pass

## User Experience
- [x] First-launch onboarding wired
- [x] Home / Relocation Command Center
- [x] My Move readiness/dependency flow
- [x] Services marketplace
- [x] Documents
- [x] Money
- [x] MapKit move map
- [x] Ejari / DEWA / Cooling / Telecom guidance shells
- [x] Building intelligence / access pack
- [x] Provider matching / quotes / chat / booking shells
- [x] Inspection / handover / deposit / reports shells
- [x] Leaving Dubai / starter pack / rescheduling / status sharing / multi-property shells
- [ ] Replace remaining demo values with persisted API-backed state
- [ ] Wire profile/more entry point from primary UI
- [ ] Accessibility audit and Dynamic Type pass
- [ ] Arabic localization decision and RTL QA

## Backend / Live Data
- [ ] Authentication API
- [ ] Move/task persistence
- [ ] Building/rules source registry
- [ ] Provider onboarding and service-specific verification
- [ ] Service request / lead / quote / booking persistence
- [ ] Realtime chat ticket/WebSocket flow
- [ ] Private document storage + malware scanning
- [ ] OCR worker and explicit user review
- [ ] Production geocoding/routing/ETA
- [ ] Production AI vision inference with user-review gate
- [ ] PDF renderers for Rental Increase Check, Condition Report and Landlord Handover Pack
- [ ] Push notifications
- [ ] Status-share token expiry/revocation

## Privacy / Safety
- [x] Product legal boundary documented
- [x] Data-minimization rules documented
- [ ] Apple Privacy Manifest based on final SDK/API usage
- [ ] App Store privacy questionnaire based on actual production collection
- [ ] Retention/deletion implementation
- [ ] Account export/delete implementation
- [ ] Provider-scoped document access tests

## Live E2E
- [ ] New user → move → contract review → readiness
- [ ] Ejari official handoff → user-confirmed state
- [ ] DEWA readiness → official handoff → state tracking
- [ ] Service request → provider → quote → chat → booking → completion
- [ ] Provider cancellation → replacement, never auto-accept
- [ ] Move-in/out inspection → user confirmation → PDF
- [ ] Handover → deposit tracking
- [ ] Leaving Dubai complete flow
- [ ] Offline/retry/error states
- [ ] Physical iPhone smoke test
