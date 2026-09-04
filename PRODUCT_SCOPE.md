# Dubai Move — Master Product Scope

## North star
Dubai Move is a **Dubai relocation operating system**, not a moving-company app. It answers: **What do I need to do next, what is blocking me, where is the official place to do it, and who can help if I do not want to do it myself?**

## Hard boundary
Dubai Move does not provide legal advice, make legal determinations, decide liability, impersonate government/regulatory services, or claim an official action is complete without an authorized integration or user-confirmed official result.

Everything outside that boundary should be made as useful as possible.

## User application
### Entry & setup
Splash; welcome; language; sign in; registration; OTP; reset password; notification/location consent; journey choice; move date; household; current property; new property; map-based address selection.

### Relocation Command Center
Move Readiness Score; blockers; dependencies; next-best-action; move route; important dates; money/refund snapshot; AI Copilot; quick tools; notifications.

### My Move lifecycle
Contract → Ejari → DEWA → cooling → telecom → building permit → lift → mover → move day → inspection → cleaning → keys/handover → deposit, plus new-home setup. Tasks change by journey type.

### Official guidance
Ejari Register/Renew/Cancel; DEWA Move-In/Move-To/Move-Out; cooling; telecom; official Rental Index handoff; building requirements. Each flow shows readiness, requirements, applicable official channel and tracked status. Requirements and fees must be source-versioned in production.

### Services marketplace
Moving; cleaning; painting; maintenance; storage; inspection; pest control; home setup; move permit/lift coordination; deposit assistance; Ejari/DEWA/cooling/telecom assistance where permitted.

Flow: dynamic request → photos/files/video inventory → provider matching → quote → revised quote → compare → provider profile → chat → booking → job status → review/problem.

Regulated services require **service-specific capability verification**. Provider fee and official/government fee are separate.

### Maps & operational intelligence
Real MapKit map; origin/destination; building/community address matching; confidence; route surface; distance/ETA integration point; provider ETA integration point; Move Day Live; lift/access/parking/loading checklist.

### Provider intelligence
Availability; area; capacity; ETA-aware matching; Dubai Move Score; rating; price accuracy; punctuality; response time; cancellation/complaint indicators; fair-price benchmark; hidden-cost risk; no-response recovery; provider substitution with explicit user acceptance.

### AI & evidence
Contract OCR with user-review gate; AI Video Inventory with user-review gate; move-in/move-out room evidence; before/after comparison; AI observations that are never conclusive until confirmed by the user.

### Reports / PDFs
Rental Increase Check; Condition Report; Landlord Handover Pack; Deposit Evidence Pack; Building Access Pack; selected move summaries. Reports clearly identify official source references vs user-entered data vs AI suggestions.

### Handover & deposit
Keys; access cards; remotes; inspection; selected photos; cleaning evidence; final utility status; Ejari evidence; deposit/refund tracking. Private chats, unrelated IDs and unrelated home media are excluded by default.

### Leaving Dubai
Separate **leaving the property** from **leaving the UAE**. Operational checklist covers Ejari, DEWA, cooling, telecom, inspection, cleaning, handover and deposit. Immigration/residence/work-permit topics are official-guidance-only and never legal advice.

### New-home Starter Pack
Internet; cleaning; curtains; AC; handyman; TV mounting; furniture assembly; pest control. Essential / Family / Premium style bundles may be presented; every selected task progresses independently.

### Additional tools
Smart Rescheduling impact preview; Calendar Sync; revocable/expiring Status Share with minimal scope; multi-property; Shared Move/family permissions; Corporate Relocation; Concierge; Emergency/Last-minute Move; packing labels; quote protection; dispute evidence organizer; offline-safe drafts/sync; privacy controls; notifications; support.

## Main iOS navigation
Home · My Move · Services · Documents · Money, with More/Tools as a secondary hub.

## Provider application/portal
Onboarding; company; trade licence; insurance; service capabilities; areas; verification; leads; lead detail; quotes; quote inbox; revisions/expiry/withdrawal; chat; booking; calendar; capacity; ETA; status sequence; access documents; staff; pricing; reviews; performance; complaints; renewals; emergency/replacement opportunities; reschedule response.

## Admin
Users; moves; providers; company/service verification; licences/insurance; buildings; building rules/sources/change history; official-service source registry; service categories/forms; requests/quotes/bookings; complaints/abuse; scoped conversation monitoring; document policies; retention/access logs; guides/FAQ/translations/templates; notification rules/logs; roles/permissions/audit/feature flags; price benchmarks; Move Intelligence; community intelligence/reports; bundles; corporate/property-manager/concierge/emergency operations; address/ETA/recovery/substitution/access-pack/video-inventory QA.

## Interaction rule
No decorative dead controls. Every visible action must navigate, mutate local/app state, call a connected API, open an explicit official handoff, generate/preview an artifact, or clearly be disabled with an explanation.
