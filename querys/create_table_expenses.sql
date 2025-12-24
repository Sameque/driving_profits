-- Create expenses table

DROP TABLE IF EXISTS expenses;
CREATE TABLE expenses (
  id SERIAL PRIMARY KEY,
  expense_type SMALLINT NOT NULL,
  charge_type SMALLINT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description VARCHAR(20) NOT NULL DEFAULT '',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP NULL
);

-- Create index for better performance
CREATE INDEX idx_expenses_created_at ON expenses(created_at DESC);