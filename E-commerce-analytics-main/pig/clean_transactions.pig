-- Pig Latin preprocessing for E-Commerce Customer Purchase Analytics
-- Adjust the HDFS input/output paths to match the execution environment.

raw = LOAD '/ecommerce_project/raw/ecommerce_transactions.csv'
      USING PigStorage(',')
      AS (
        order_id:chararray,
        customer_id:chararray,
        purchase_date:chararray,
        product_id:chararray,
        product_name:chararray,
        category:chararray,
        quantity:int,
        unit_price:double,
        discount_pct:double,
        total_amount:double,
        city:chararray,
        payment_method:chararray,
        customer_segment:chararray
      );

-- Remove records missing essential identifiers.
valid = FILTER raw BY
        order_id IS NOT NULL AND
        customer_id IS NOT NULL AND
        product_id IS NOT NULL;

-- Remove exact duplicate records.
dedup = DISTINCT valid;

-- Keep records with valid numeric transaction values.
clean = FILTER dedup BY
        quantity IS NOT NULL AND quantity > 0 AND
        unit_price IS NOT NULL AND unit_price >= 0;

-- Store the cleaned data for Hive processing.
STORE clean INTO '/ecommerce_project/cleaned'
USING PigStorage(',');
