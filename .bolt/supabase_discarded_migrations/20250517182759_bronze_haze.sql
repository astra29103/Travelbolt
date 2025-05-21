/*
  # Add package itinerary table

  1. New Tables
    - package_itinerary
      - id (uuid, primary key)
      - package_id (uuid, foreign key)
      - day_number (integer)
      - description (text)
      - created_at (timestamp)
      - updated_at (timestamp)

  2. Changes
    - Add foreign key constraint to packages table
    - Add index for better query performance
*/

-- Create package_itinerary table
CREATE TABLE IF NOT EXISTS package_itinerary (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  package_id uuid REFERENCES packages(id) ON DELETE CASCADE,
  day_number integer NOT NULL,
  description text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT package_itinerary_day_number_check CHECK (day_number > 0)
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_package_itinerary_package_id ON package_itinerary(package_id);

-- Add trigger for updating updated_at timestamp
CREATE TRIGGER update_package_itinerary_updated_at
  BEFORE UPDATE ON package_itinerary
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();