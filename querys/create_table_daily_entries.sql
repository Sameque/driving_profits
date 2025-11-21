-- Create daily_entries table

DROP TABLE IF EXISTS daily_entries;
CREATE TABLE daily_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  start_date DATE NOT NULL,
  end_date DATE,
  uber_earnings DECIMAL(10, 2) NOT NULL DEFAULT 0,
  tips DECIMAL(10, 2) NOT NULL DEFAULT 0,
  fuel_cost DECIMAL(10, 2) NOT NULL DEFAULT 0,
  food_cost DECIMAL(10, 2) NOT NULL DEFAULT 0,
  cleaning_cost DECIMAL(10, 2) NOT NULL DEFAULT 0,
  other_costs DECIMAL(10, 2) NOT NULL DEFAULT 0,
  fuel_price DECIMAL(10, 2) NOT NULL DEFAULT 0,
  fuel_efficiency DECIMAL(10, 2) NOT NULL DEFAULT 0,
  km_end BIGINT,
  km_start BIGINT,
  start_time TIME,
  end_time TIME,
  status_id SMALLINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
  deleted_at TIMESTAMP NULL
);

-- Create index para melhor performance
CREATE INDEX idx_daily_entries_date ON daily_entries(start_date DESC);
CREATE INDEX idx_daily_entries_status ON daily_entries(statusId);