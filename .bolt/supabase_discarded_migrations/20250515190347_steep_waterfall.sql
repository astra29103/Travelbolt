/*
  # Fix User Management

  1. Changes
    - Remove custom users table (we use auth.users instead)
    - Create profiles table for additional user information
    - Update bookings table to reference auth.users
    - Add RLS policies for profiles

  2. Security
    - Enable RLS on profiles table
    - Add appropriate policies for user access
*/

-- Drop the custom users table if it exists
DROP TABLE IF EXISTS users CASCADE;

-- Create profiles table for additional user information
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name text,
  age integer,
  location text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Update bookings table to reference auth.users directly
ALTER TABLE bookings
DROP CONSTRAINT IF EXISTS bookings_user_id_fkey,
ADD CONSTRAINT bookings_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES auth.users(id) 
  ON DELETE CASCADE;

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles
CREATE POLICY "Users can view own profile"
  ON profiles
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Create trigger for updating updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();