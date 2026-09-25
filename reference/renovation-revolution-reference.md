# Renovation Revolution: Canonical Reference

The single source of truth for the case study used throughout Software Engineer's Library. Use these exact names in every chapter, worksheet, and figure. Do not invent new names, and do not reword an existing one: if a screen or table is missing, add it here first.

## Naming rules

1. Page names never carry the word "Page". The surrounding heading or label already says it. Write "Room Capture", not "Room Capture Page".
2. Page names are title case and used verbatim, including in page flows: Available Projects Summary -> Project Detail (Pre-Contract) -> Project Bidding.
3. Project Detail takes a parenthesized qualifier when the distinction matters: Project Detail (Pre-Contract) and Project Detail (Post-Contract). Nothing else takes a qualifier.
4. Table and column names are lowercase snake_case, tables plural, foreign keys named <table_singular>_id.
5. Money is stored in cents as an integer, and any column holding cents ends in _cents.
6. Roles are exactly: homeowner, contractor, vendor, admin. In user stories the homeowner is written as "customer", which is the voice the reader hears; everywhere else in the product it is "homeowner".

---

## 1. Pages

24 pages, grouped by the role that uses them. Derived from the user stories on the Designer Worksheet.

### Shared (2)

1. **Login / Account.** Secure sign-in with role-based access for every stakeholder.
2. **Order & Delivery Tracking.** Follow every order and delivery through to installation day. Used by homeowners and contractors alike.

### Homeowner (9)

1. **Homeowner Profile.** Manage account details, style preferences, and saved projects.
2. **Room Capture.** Scan a room with the phone to build a 3D model of the space.
3. **Room Suggestions.** Show every possible upgrade the app finds for a scanned room.
4. **Style Quiz.** Capture the homeowner's taste before showing options.
5. **Upgrade Preview.** View upgrade options on the 3D model or as a list.
6. **Item Selection.** Pick specific items from a curated, style-matched list.
7. **Order Review.** Confirm required parts are included and nothing is incompatible.
8. **Contractors Directory.** Browse contractors by service, area, and availability to choose who receives a project.
9. **Send to Contractor.** Submit the final selections for the contractor to finalize.

### Contractor (10)

1. **Contractor Onboarding.** Sign up a new contractor and collect licensing, insurance, and service area before they can bid.
2. **Contractor Profile.** Introduce the contractor with previous work, insurance info, and specialties so homeowners can learn about them.
3. **Available Projects Summary.** Browse open projects with size and estimates to bid on.
4. **Project Bidding.** Review the details and commit to a project.
5. **Current Projects Summary.** Track all active projects at a glance.
6. **Project Detail.** Manage a won project room by room. Seen pre-contract as a limited preview while bidding, and post-contract with full homeowner contact details.
7. **Room Detail.** Inspect one room of a won project in detail, with its images, items, and work to be done.
8. **Purchase Review.** Review all purchases before they are made to catch mistakes.
9. **Upsell Suggestions.** Offer additional renovations to grow project value.
10. **Supplier Deals.** Use aggregated purchasing data to negotiate better supplier deals.

### Vendor (3)

1. **Product Catalog.** Manage the products offered to homeowners.
2. **Featured Products.** Promote the highest-margin products to interested homeowners.
3. **Homeowner Interest Insights.** See which homeowners are most interested.

---

## 2. User Stories

The sample stories every other worksheet builds on. Format: As a [role], I want [capability] so that [outcome].

### Customer (8)

1. As a customer, I want to scan my room with my phone so that the app can create a 3D model of my space.
2. As a customer, I want the app to analyze my room and provide a comprehensive list of all possible upgrades so that I can see all my renovation options in one place.
3. As a customer, I want to take a style quiz before viewing options, so the app can recommend items that fit my taste and reduce decision fatigue.
4. As a customer, I want to view upgrade options visually on the 3D model or as a list, so I can easily understand what each change would look like in my space.
5. As a customer, I want to select specific items for each upgrade from a curated, style-matched list, so I am not overwhelmed by too many choices.
6. As a customer, I want the app to ensure that all required additional or supporting parts are included in my order so that nothing is forgotten on installation day.
7. As a customer, I want the app to prevent me from selecting incompatible items, so my renovation choices will fit together seamlessly.
8. As a customer, I want to send my final selections directly to my contractor so they can review and finalize the order without confusion.

### Contractor (8)

1. As a contractor, I want to review a project's size so that I can commit to only the most profitable ones.
2. As a contractor, I want customers to learn about me when they are ready to renovate so that I can have a ready-made customer pipeline.
3. As a contractor, I want to review all purchases before they are made so that I can correct any mistakes.
4. As a contractor, I want the app to ensure all necessary components are included in the order, so there are no delays due to missing items.
5. As a contractor, I want to upsell clients on additional renovations to increase my project value.
6. As a contractor, I want to minimize the time I spend answering questions so I can focus on executing renovations.
7. As a contractor, I want to track all orders and deliveries through the app to ensure everything arrives on time and nothing is overlooked.
8. As a contractor, I want to use aggregated purchasing data to negotiate better deals with suppliers, so that I can improve my profit margins.

### Vendor (1)

1. As a vendor, I want to make my highest-margin products visible to highly interested customers so I can increase my revenue.

---

## 3. Database Tables

Built from the objects behind the screens. PK is the primary key, FK points to another table, IDX means indexed for faster lookup.

### Accounts & Access

**`users`** One row per person, whatever their role

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `email` | varchar | IDX | unique, used to sign in |
| `password_hash` | varchar |  |  |
| `name` | varchar |  |  |
| `phone` | varchar |  |  |
| `role` | varchar | IDX | homeowner, contractor, vendor, admin |
| `contact_preference` | varchar |  | email or phone |
| `created_at` | timestamptz |  |  |

**`contractor_profiles`** The public profile a homeowner compares when bidding opens

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `user_id` | uuid | FK | references users, unique |
| `company_name` | varchar | IDX |  |
| `services` | varchar[] | IDX | structured categories, not free text |
| `availability` | varchar | IDX | open, limited, booked |
| `insurance_expires_on` | date |  |  |
| `service_area` | varchar | IDX |  |

**`vendor_profiles`** Suppliers who list products in the catalog

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `user_id` | uuid | FK | references users, unique |
| `company_name` | varchar | IDX |  |
| `ships_to` | varchar[] |  |  |

### Projects & Rooms

**`projects`** A renovation owned by one homeowner

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `user_id` | uuid | FK | references users, the owner |
| `name` | varchar |  |  |
| `address` | varchar |  |  |
| `budget_low` | integer |  | stored in cents |
| `budget_high` | integer |  | stored in cents |
| `status` | varchar | IDX | draft, open_for_bids, active, complete |
| `created_at` | timestamptz | IDX |  |

**`project_team`** Who else can reach a project, and as what

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `project_id` | uuid | FK | references projects |
| `user_id` | uuid | FK | references users |
| `role` | varchar |  | contractor, designer, viewer |
| `invited_at` | timestamptz |  |  |
| `accepted_at` | timestamptz |  | null until they accept |

**`rooms`** One scanned space inside a project

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `project_id` | uuid | FK | references projects |
| `name` | varchar |  | kitchen, primary bath |
| `scan_model_url` | text |  | the 3D model built from the scan |
| `square_feet` | numeric |  |  |

**`images`** Photos captured during a room scan

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `room_id` | uuid | FK | references rooms |
| `uploaded_by` | uuid | FK | references users |
| `file_url` | text |  |  |
| `created_at` | timestamptz |  |  |

**`image_metadata`** What the camera and the scan recorded about an image

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `image_id` | uuid | FK | references images, unique |
| `captured_at` | timestamptz |  |  |
| `width_px` | integer |  |  |
| `height_px` | integer |  |  |
| `camera_position` | jsonb |  | where the phone was in the room |

**`visible_items`** Something the scan recognized in the room

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `room_id` | uuid | FK | references rooms |
| `image_id` | uuid | FK | references images |
| `label` | varchar | IDX | countertop, faucet, cabinet |
| `bounding_box` | jsonb |  | where it sits in the image |
| `confidence` | numeric |  | how sure the scan is |

**`renovation_items`** An upgrade proposed for a visible item

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `visible_item_id` | uuid | FK | references visible_items |
| `product_id` | uuid | FK | references products |
| `status` | varchar | IDX | suggested, selected, ordered |
| `selected_at` | timestamptz |  |  |
| `price_cents` | integer |  | captured when it was selected |

**`accessories`** Smaller parts a renovation item needs to work

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `renovation_item_id` | uuid | FK | references renovation_items |
| `product_id` | uuid | FK | references products |
| `required` | boolean |  | flagged on the Order Review page |

### Style & Suggestions

**`quiz_results`** The style quiz answers that filter every suggestion

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `user_id` | uuid | FK | references users |
| `answers` | jsonb |  |  |
| `style_match` | varchar | IDX | modern, farmhouse, traditional |
| `completed_at` | timestamptz |  |  |

**`suggestions`** What the app offers for a room before the homeowner picks

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `room_id` | uuid | FK | references rooms |
| `product_id` | uuid | FK | references products |
| `style_match` | varchar | IDX | matched against quiz_results |
| `rank` | integer |  | order shown on the page |

### Bidding

**`bids`** A contractor committing to a project

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `project_id` | uuid | FK | references projects |
| `contractor_id` | uuid | FK | references users |
| `amount_cents` | integer |  |  |
| `estimated_days` | integer |  |  |
| `status` | varchar | IDX | submitted, withdrawn, won, lost |
| `submitted_at` | timestamptz | IDX |  |

### Catalog & Orders

**`product_categories`** The structured service and product categories

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `parent_id` | uuid | FK | references product_categories, null at the top |
| `name` | varchar | IDX |  |
| `definition` | text |  | plain-language help shown in the app |

**`products`** Everything a vendor lists for selection

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `vendor_id` | uuid | FK | references vendor_profiles |
| `category_id` | uuid | FK | references product_categories |
| `name` | varchar | IDX |  |
| `sku` | varchar | IDX | unique per vendor |
| `price_cents` | integer | IDX |  |
| `style_tags` | varchar[] | IDX | used to match quiz results |
| `featured` | boolean | IDX | drives the Featured Products page |
| `lead_time_days` | integer |  |  |

**`orders`** One purchase submitted from a project

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `project_id` | uuid | FK | references projects |
| `placed_by` | uuid | FK | references users |
| `status` | varchar | IDX | draft, placed, shipped, delivered |
| `total_cents` | integer |  |  |
| `placed_at` | timestamptz | IDX |  |

**`order_items`** The line items inside an order

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `order_id` | uuid | FK | references orders |
| `product_id` | uuid | FK | references products |
| `renovation_item_id` | uuid | FK | references renovation_items |
| `quantity` | integer |  |  |
| `unit_price_cents` | integer |  |  |

**`deliveries`** Tracking for the Order & Delivery page

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `order_id` | uuid | FK | references orders |
| `carrier` | varchar |  |  |
| `tracking_number` | varchar | IDX |  |
| `status` | varchar | IDX | pending, in_transit, delivered |
| `expected_on` | date | IDX |  |
| `delivered_at` | timestamptz |  |  |

### Reviews & Insights

**`reviews`** Homeowner feedback shown on a contractor profile

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `project_id` | uuid | FK | references projects |
| `contractor_id` | uuid | FK | references users |
| `author_id` | uuid | FK | references users |
| `rating` | integer | IDX | 1 to 5 |
| `body` | text |  |  |
| `created_at` | timestamptz |  |  |

**`supplier_deals`** Negotiated pricing built from aggregated purchasing

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `vendor_id` | uuid | FK | references vendor_profiles |
| `category_id` | uuid | FK | references product_categories |
| `discount_percent` | numeric |  |  |
| `min_volume` | integer |  |  |
| `starts_on` | date |  |  |
| `ends_on` | date |  |  |

**`interest_events`** What vendors see on the Homeowner Interest page

| Column | Type | Key | Notes |
| --- | --- | --- | --- |
| `id` | uuid | PK |  |
| `user_id` | uuid | FK | references users |
| `product_id` | uuid | FK | references products |
| `event_type` | varchar | IDX | viewed, saved, selected |
| `occurred_at` | timestamptz | IDX |  |

