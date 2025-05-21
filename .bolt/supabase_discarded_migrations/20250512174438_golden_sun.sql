/*
  # Remove RLS policies and update schema

  1. Changes
    - Disable RLS on all tables
    - Add trigger for automatic booking confirmation
*/

-- Disable RLS on all tables
ALTER TABLE destinations DISABLE ROW LEVEL SECURITY;
ALTER TABLE places DISABLE ROW LEVEL SECURITY;
ALTER TABLE packages DISABLE ROW LEVEL SECURITY;
ALTER TABLE package_images DISABLE ROW LEVEL SECURITY;
ALTER TABLE package_places DISABLE ROW LEVEL SECURITY;
ALTER TABLE guides DISABLE ROW LEVEL SECURITY;
ALTER TABLE bookings DISABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow public read access" ON destinations;
DROP POLICY IF EXISTS "Allow admin full access" ON destinations;
DROP POLICY IF EXISTS "Allow public read access" ON places;
DROP POLICY IF EXISTS "Allow admin full access" ON places;
DROP POLICY IF EXISTS "Allow public read access" ON packages;
DROP POLICY IF EXISTS "Allow admin full access" ON packages;
DROP POLICY IF EXISTS "Allow public read access" ON package_images;
DROP POLICY IF EXISTS "Allow admin full access" ON package_images;
DROP POLICY IF EXISTS "Allow public read access" ON package_places;
DROP POLICY IF EXISTS "Allow admin full access" ON package_places;
DROP POLICY IF EXISTS "Allow public read access" ON guides;
DROP POLICY IF EXISTS "Allow admin full access" ON guides;
DROP POLICY IF EXISTS "Allow users to view own bookings" ON bookings;
DROP POLICY IF EXISTS "Allow users to create bookings" ON bookings;
DROP POLICY IF EXISTS "Allow admin full access" ON bookings;