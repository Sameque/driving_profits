-- Create entry_expenses table

DROP TABLE IF EXISTS entry_expenses;
CREATE TABLE entry_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID NOT NULL REFERENCES daily_entries(id) ON DELETE CASCADE,
  expense_type SMALLINT NOT NULL,
  charge_type SMALLINT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description VARCHAR(255) NOT NULL DEFAULT '',
  calculated BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP NULL
);

-- Create index for better performance
CREATE INDEX idx_entry_expenses_entry_id ON entry_expenses(entry_id);