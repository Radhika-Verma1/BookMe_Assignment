-- =============================================================================
-- CS 543 Web Services — Assignment 2
-- Project: BookMe (AI-Powered Multi-Vendor Event Service Booking Platform)
-- Benchmark Database Schema Definition (PostgreSQL DDL)
--
-- Team 11:
-- 1. Radhika Verma    (20251651075) - Auth Service
-- 2. Nandini Kanaujiya(20251651061) - Vendor Service
-- 3. Alka Jha         (20251651013) - Event & Booking Service
-- 4. Alok Mishra      (20251651014) - Payment & Feedback Service
--
-- SERVICE BOUNDARY RULE:
-- Each microservice strictly owns its database schema and tables.
-- Under no circumstances may any table belong to more than one service,
-- nor may any database foreign key cross service boundaries.
-- Inter-service relationships are modeled strictly via logical UUID/string
-- references validated through authenticated HTTP/REST API contracts.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- 1. AUTH SERVICE SCHEMA
-- Owned by: Radhika Verma (Lead / Person A)
-- Data Ownership: User identity, hashed credentials, and authentication sessions.
-- =============================================================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(120) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role VARCHAR(30) NOT NULL CHECK (role IN ('customer', 'vendor', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_credentials (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(64) NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);


-- =============================================================================
-- 2. VENDOR SERVICE SCHEMA
-- Owned by: Nandini Kanaujiya (Lead / Person B)
-- Data Ownership: Vendor marketplace profiles, service catalog, pricing packages,
-- and calendar slot availability.
-- =============================================================================

CREATE TABLE IF NOT EXISTS vendors (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL UNIQUE, -- Logical Reference to Auth Service (users.id)
    business_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL CHECK (category IN ('catering', 'photography', 'decoration', 'dj', 'venue', 'planning')),
    description TEXT,
    location VARCHAR(255) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    rating NUMERIC(3, 2) DEFAULT NULL CHECK (rating IS NULL OR (rating >= 1.00 AND rating <= 5.00)),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS services (
    id VARCHAR(50) PRIMARY KEY,
    vendor_id VARCHAR(50) NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    base_price NUMERIC(10, 2) NOT NULL CHECK (base_price >= 0.00),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS packages (
    id VARCHAR(50) PRIMARY KEY,
    vendor_id VARCHAR(50) NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0.00),
    service_ids VARCHAR(50)[] NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS availability (
    id VARCHAR(50) PRIMARY KEY,
    vendor_id VARCHAR(50) NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'BLOCKED' CHECK (status IN ('AVAILABLE', 'BLOCKED', 'TENTATIVE')),
    reason VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_vendor_date UNIQUE (vendor_id, date)
);

CREATE INDEX IF NOT EXISTS idx_vendors_category ON vendors(category);
CREATE INDEX IF NOT EXISTS idx_vendors_location ON vendors(location);
CREATE INDEX IF NOT EXISTS idx_services_vendor_id ON services(vendor_id);
CREATE INDEX IF NOT EXISTS idx_packages_vendor_id ON packages(vendor_id);
CREATE INDEX IF NOT EXISTS idx_availability_vendor_date ON availability(vendor_id, date);


-- =============================================================================
-- 3. EVENT & BOOKING SERVICE SCHEMA
-- Owned by: Alka Jha (Lead / Person C)
-- Data Ownership: Customer events, guest checklists, budget tracking, and the
-- core booking lifecycle state machine.
-- =============================================================================

CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id VARCHAR(255) NOT NULL, -- Logical Reference to Auth Service (users.id)
    name VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    budget NUMERIC(15, 2) NOT NULL CHECK (budget >= 0.00),
    guest_count INTEGER NOT NULL CHECK (guest_count >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    vendor_id VARCHAR(255) NOT NULL,   -- Logical Reference to Vendor Service (vendors.id)
    package_id VARCHAR(255) NOT NULL,  -- Logical Reference to Vendor Service (packages.id)
    date DATE NOT NULL,
    vendor_name_snapshot VARCHAR(255) NOT NULL, -- Immutable snapshot preserving contract integrity
    price_snapshot NUMERIC(15, 2) NOT NULL CHECK (price_snapshot >= 0.00),
    status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS checklist_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    task VARCHAR(255) NOT NULL,
    done BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_events_customer_id ON events(customer_id);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(date);
CREATE INDEX IF NOT EXISTS idx_bookings_event_id ON bookings(event_id);
CREATE INDEX IF NOT EXISTS idx_bookings_vendor_id ON bookings(vendor_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_date ON bookings(date);
CREATE INDEX IF NOT EXISTS idx_checklist_items_event_id ON checklist_items(event_id);


-- =============================================================================
-- 4. PAYMENT & FEEDBACK SERVICE SCHEMA
-- Owned by: Alok Mishra (Lead / Person D)
-- Data Ownership: Escrow payments, vendor payouts, customer reviews, and disputes.
-- =============================================================================

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id VARCHAR(255) NOT NULL UNIQUE, -- Logical Reference to Booking Service (bookings.id)
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0.00),
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('card', 'upi', 'netbanking', 'escrow_wallet')),
    payment_status VARCHAR(50) NOT NULL CHECK (payment_status IN ('pending', 'authorized', 'captured', 'failed', 'refunded')),
    gateway_txn_ref VARCHAR(255) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id VARCHAR(255) NOT NULL,  -- Logical Reference to Vendor Service (vendors.id)
    booking_id VARCHAR(255) NOT NULL, -- Logical Reference to Booking Service (bookings.id)
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0.00),
    payout_status VARCHAR(50) NOT NULL CHECK (payout_status IN ('pending', 'processing', 'completed', 'failed')),
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id VARCHAR(255) NOT NULL,         -- Logical Reference to Vendor Service (vendors.id)
    customer_id VARCHAR(255) NOT NULL,       -- Logical Reference to Auth Service (users.id)
    booking_id VARCHAR(255) NOT NULL UNIQUE, -- Logical Reference to Booking Service (bookings.id)
    rating NUMERIC(2, 1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id VARCHAR(255) NOT NULL,  -- Logical Reference to Booking Service (bookings.id)
    customer_id VARCHAR(255) NOT NULL, -- Logical Reference to Auth Service (users.id)
    vendor_id VARCHAR(255) NOT NULL,   -- Logical Reference to Vendor Service (vendors.id)
    issue_category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    resolution_status VARCHAR(50) NOT NULL DEFAULT 'open' CHECK (resolution_status IN ('open', 'under_review', 'resolved', 'rejected')),
    filed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(payment_status);
CREATE INDEX IF NOT EXISTS idx_payouts_vendor_id ON payouts(vendor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_vendor_id ON reviews(vendor_id);
CREATE INDEX IF NOT EXISTS idx_complaints_booking_id ON complaints(booking_id);
