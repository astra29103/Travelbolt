/*
  # Initial Schema Setup for TravelQuest

  1. New Tables
    - `destinations`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `category` (text)
      - `image_url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `places`
      - `id` (uuid, primary key)
      - `destination_id` (uuid, foreign key)
      - `name` (text)
      - `description` (text)
      - `image_url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `packages`
      - `id` (uuid, primary key)
      - `destination_id` (uuid, foreign key)
      - `title` (text)
      - `description` (text)
      - `duration` (integer)
      - `price` (numeric)
      - `rating` (numeric)
      - `main_image_url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `guides`
      - `id` (uuid, primary key)
      - `name` (text)
      - `email` (text)
      - `experience_years` (integer)
      - `languages` (text[])
      - `rating` (numeric)
      - `price_per_day` (numeric)
      - `image_url` (text)
      - `destination_id` (uuid, foreign key)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users and admin access
*/

-- Create destinations table
CREATE TABLE IF NOT EXISTS destinations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  category text NOT NULL,
  image_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create places table
CREATE TABLE IF NOT EXISTS places (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  destination_id uuid REFERENCES destinations(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text NOT NULL,
  image_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create packages table
CREATE TABLE IF NOT EXISTS packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  destination_id uuid REFERENCES destinations(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text NOT NULL,
  duration integer NOT NULL,
  price numeric NOT NULL,
  rating numeric DEFAULT 0,
  main_image_url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create guides table
CREATE TABLE IF NOT EXISTS guides (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  experience_years integer NOT NULL,
  languages text[] NOT NULL,
  rating numeric DEFAULT 0,
  price_per_day numeric NOT NULL,
  image_url text NOT NULL,
  destination_id uuid REFERENCES destinations(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE destinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE places ENABLE ROW LEVEL SECURITY;
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE guides ENABLE ROW LEVEL SECURITY;

-- Create policies for destinations
CREATE POLICY "Allow public read access" ON destinations
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON destinations
  FOR ALL USING (auth.jwt() ->> 'email' = 'admin@example.com');

-- Create policies for places
CREATE POLICY "Allow public read access" ON places
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON places
  FOR ALL USING (auth.jwt() ->> 'email' = 'admin@example.com');

-- Create policies for packages
CREATE POLICY "Allow public read access" ON packages
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON packages
  FOR ALL USING (auth.jwt() ->> 'email' = 'admin@example.com');

-- Create policies for guides
CREATE POLICY "Allow public read access" ON guides
  FOR SELECT USING (true);

CREATE POLICY "Allow admin full access" ON guides
  FOR ALL USING (auth.jwt() ->> 'email' = 'admin@example.com');

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_destinations_updated_at
  BEFORE UPDATE ON destinations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_places_updated_at
  BEFORE UPDATE ON places
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_packages_updated_at
  BEFORE UPDATE ON packages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_guides_updated_at
  BEFORE UPDATE ON guides
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();