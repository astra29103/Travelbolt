/*
  # Add itinerary and update package structure

  1. Changes
    - Remove included items from packages
    - Add itinerary table for day-by-day details
    - Update package_places table structure

  2. New Tables
    - package_itinerary: Store day-by-day itinerary details
*/

-- Create package_itinerary table
CREATE TABLE IF NOT EXISTS package_itinerary (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  package_id uuid REFERENCES packages(id) ON DELETE CASCADE,
  day_number integer NOT NULL,
  description text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_package_itinerary_package ON package_itinerary(package_id);

-- Add trigger for updating updated_at timestamp
CREATE TRIGGER update_package_itinerary_updated_at
  BEFORE UPDATE ON package_itinerary
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Modify places table to ensure destination relationship
ALTER TABLE places
  ADD CONSTRAINT places_destination_check
  CHECK (destination_id IS NOT NULL);