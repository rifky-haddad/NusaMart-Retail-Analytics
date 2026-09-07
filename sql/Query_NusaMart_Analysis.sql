/* =========================================================
   NUSAMART RETAIL SALES & PROFITABILITY ANALYTICS
   SQL ANALYSIS
   ========================================================= */


/* =========================================================
   STEP 1 — DATABASE SETUP
   ========================================================= */


/* ---------------------------------------------------------
   1.1 Create Database
   --------------------------------------------------------- */

CREATE DATABASE nusamart;


/* ---------------------------------------------------------
   1.2 Select Database
   --------------------------------------------------------- */

USE nusamart;


/* =========================================================
   STEP 2 — CREATE CLEAN TABLES
   ========================================================= */

/* ---------------------------------------------------------
   2.1 Customers
   --------------------------------------------------------- */

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    customer_segment VARCHAR(30),
    city VARCHAR(50),
    region VARCHAR(50),
    registration_date DATE
);

DESCRIBE customers;


/* ---------------------------------------------------------
   2.2 Products
   --------------------------------------------------------- */

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_cost DECIMAL(15,2),
    list_price DECIMAL(15,2)
);

DESCRIBE products;


/* ---------------------------------------------------------
   2.3 Stores
   --------------------------------------------------------- */

CREATE TABLE stores (
    store_id VARCHAR(10) PRIMARY KEY,
    store_name VARCHAR(100),
    channel VARCHAR(30),
    city VARCHAR(50),
    region VARCHAR(50),
    store_type VARCHAR(50)
);

DESCRIBE stores;


/* ---------------------------------------------------------
   2.4 Orders
   --------------------------------------------------------- */

CREATE TABLE orders (
    order_id VARCHAR(15) PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(10),
    store_id VARCHAR(10),
    payment_method VARCHAR(30),
    order_status VARCHAR(20),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
);

DESCRIBE orders;


/* ---------------------------------------------------------
   2.5 Order Details
   --------------------------------------------------------- */

CREATE TABLE order_details (
    order_detail_id VARCHAR(15) PRIMARY KEY,
    order_id VARCHAR(15),
    product_id VARCHAR(10),
    quantity INT,
    unit_price DECIMAL(15,2),
    discount_pct DECIMAL(20,17),
    sales_amount DECIMAL(15,2),
    unit_cost DECIMAL(15,2),
    cost_amount DECIMAL(15,2),
    profit_amount DECIMAL(15,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

DESCRIBE order_details;


/* =========================================================
   STEP 3 — CREATE RAW / STAGING TABLES
   ========================================================= */


/* ---------------------------------------------------------
   3.1 Customers Raw
   --------------------------------------------------------- */

CREATE TABLE customers_raw (
    customer_id VARCHAR(10),
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age VARCHAR(10),
    customer_segment VARCHAR(30),
    city VARCHAR(50),
    region VARCHAR(50),
    registration_date DATE
);

/* ---------------------------------------------------------
   3.2 Products Raw
   --------------------------------------------------------- */

CREATE TABLE products_raw (
    product_id VARCHAR(10),
    product_name VARCHAR(100),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_cost VARCHAR(30),
    list_price VARCHAR(30)
);

/* ---------------------------------------------------------
   3.3 Stores Raw
   --------------------------------------------------------- */

CREATE TABLE stores_raw (
    store_id VARCHAR(10),
    store_name VARCHAR(100),
    channel VARCHAR(30),
    city VARCHAR(50),
    region VARCHAR(50),
    store_type VARCHAR(50)
);

/* ---------------------------------------------------------
   3.4 Orders Raw
   --------------------------------------------------------- */

CREATE TABLE orders_raw (
    order_id VARCHAR(15),
    order_date VARCHAR(20),
    customer_id VARCHAR(10),
    store_id VARCHAR(10),
    payment_method VARCHAR(30),
    order_status VARCHAR(20)
);

/* ---------------------------------------------------------
   3.5 Order Details Raw
   --------------------------------------------------------- */

CREATE TABLE order_details_raw (
    order_detail_id VARCHAR(15),
    order_id VARCHAR(15),
    product_id VARCHAR(10),
    quantity VARCHAR(20),
    unit_price VARCHAR(30),
    discount_pct VARCHAR(20),
    sales_amount VARCHAR(30),
    unit_cost VARCHAR(30),
    cost_amount VARCHAR(30),
    profit_amount VARCHAR(30)
);

/* =========================================================
   STEP 4 — CUSTOMERS
   ========================================================= */

/* =========================================================
   4.1 PROFILING CUSTOMERS RAW
   Tujuan:
   - Mengecek jumlah data
   - Mengecek duplicate customer_id
   - Mengecek missing values
   - Mengecek validitas customer segment
   ========================================================= */


/* ---------------------------------------------------------
   4.1.1 Row Count
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_rows
FROM customers_raw;


/* ---------------------------------------------------------
   4.1.2 Duplicate Customer ID
   --------------------------------------------------------- */

SELECT
    customer_id,
    COUNT(*) AS jumlah_data
FROM customers_raw
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY jumlah_data DESC;


/* ---------------------------------------------------------
   4.1.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') 
        AS missing_customer_id,

    SUM(customer_name IS NULL OR TRIM(customer_name) = '') 
        AS missing_customer_name,

    SUM(gender IS NULL OR TRIM(gender) = '') 
        AS missing_gender,

    SUM(age IS NULL OR TRIM(age) = '') 
        AS missing_age,

    SUM(customer_segment IS NULL OR TRIM(customer_segment) = '') 
        AS missing_customer_segment,

    SUM(city IS NULL OR TRIM(city) = '') 
        AS missing_city,

    SUM(region IS NULL OR TRIM(region) = '') 
        AS missing_region,

    SUM(registration_date IS NULL) 
        AS missing_registration_date
FROM customers_raw;


/* ---------------------------------------------------------
   4.1.4 Customer Segment Validation
   --------------------------------------------------------- */

SELECT
    customer_segment,
    COUNT(*) AS jumlah_data
FROM customers_raw
GROUP BY customer_segment
ORDER BY jumlah_data DESC;


/* ---------------------------------------------------------
   4.1.5 Preview Typo pada Customer Segment
   --------------------------------------------------------- */

SELECT
    customer_id,
    customer_segment AS segment_before,

    CASE
        WHEN customer_segment = 'Consumerr'
        THEN 'Consumer'
        ELSE customer_segment
    END AS segment_after

FROM customers_raw
WHERE customer_segment = 'Consumerr';


/* ---------------------------------------------------------
   4.1.6 Preview Missing City
   --------------------------------------------------------- */

SELECT
    customer_id,
    city AS city_before,

    CASE
        WHEN city IS NULL
             OR TRIM(city) = ''
        THEN 'Unknown'
        ELSE city
    END AS city_after

FROM customers_raw
WHERE city IS NULL
   OR TRIM(city) = '';


/* ---------------------------------------------------------
   4.1.7 Age Validation
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_age_rows
FROM customers_raw
WHERE age IS NOT NULL
  AND TRIM(age) <> ''
  AND (
      age NOT REGEXP '^[0-9]+$'
      OR CAST(age AS UNSIGNED) <= 0
      OR CAST(age AS UNSIGNED) > 100
  );


/* =========================================================
   4.2 CLEANING CUSTOMERS
   ========================================================= */


/* ---------------------------------------------------------
   4.2.1 Preview Duplicate Handling
   Menyimpan record dengan registration_date terbaru
   --------------------------------------------------------- */

SELECT
    customer_id,
    customer_name,
    customer_segment,
    city,
    registration_date,

    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY registration_date DESC
    ) AS row_num

FROM customers_raw

WHERE customer_id IN (
    SELECT
        customer_id
    FROM customers_raw
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)

ORDER BY customer_id, row_num;


/* ---------------------------------------------------------
   4.2.2 Preview Jumlah Data Setelah Deduplication
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS calon_customer_clean
FROM (
    SELECT
        customer_id,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY registration_date DESC
        ) AS row_num

    FROM customers_raw
) AS ranked_customers

WHERE row_num = 1;


/* ---------------------------------------------------------
   4.2.3 Insert Clean Customers
   Cleaning Rules:
   - Duplicate customer_id → keep latest registration
   - Consumerr → Consumer
   - Missing city → Unknown
   - Empty age → NULL
   --------------------------------------------------------- */

INSERT INTO customers (
    customer_id,
    customer_name,
    gender,
    age,
    customer_segment,
    city,
    region,
    registration_date
)

SELECT
    customer_id,
    customer_name,
    gender,

    NULLIF(
        TRIM(age),
        ''
    ) AS age,

    CASE
        WHEN customer_segment = 'Consumerr'
        THEN 'Consumer'
        ELSE customer_segment
    END AS customer_segment,

    CASE
        WHEN city IS NULL
             OR TRIM(city) = ''
        THEN 'Unknown'
        ELSE city
    END AS city,

    region,
    registration_date

FROM (
    SELECT
        *,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY registration_date DESC
        ) AS row_num

    FROM customers_raw
) AS ranked_customers

WHERE row_num = 1;



/* =========================================================
   4.3 VALIDATION CLEAN CUSTOMERS
   ========================================================= */


/* ---------------------------------------------------------
   4.3.1 Total Rows
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_clean_customers
FROM customers;


/* ---------------------------------------------------------
   4.3.2 Duplicate Customer ID
   --------------------------------------------------------- */

SELECT
    customer_id,
    COUNT(*) AS jumlah_data
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


/* ---------------------------------------------------------
   4.3.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(customer_name IS NULL) AS missing_customer_name,
    SUM(gender IS NULL) AS missing_gender,
    SUM(age IS NULL) AS missing_age,
    SUM(customer_segment IS NULL) AS missing_customer_segment,
    SUM(city IS NULL) AS missing_city,
    SUM(region IS NULL) AS missing_region,
    SUM(registration_date IS NULL) AS missing_registration_date
FROM customers;


/* ---------------------------------------------------------
   4.3.4 Check Unknown City
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS unknown_city
FROM customers
WHERE city = 'Unknown';


/* ---------------------------------------------------------
   4.3.5 Check Typo Customer Segment
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS remaining_typo
FROM customers
WHERE customer_segment = 'Consumerr';


/* ---------------------------------------------------------
   4.3.6 Customer Segment Distribution
   --------------------------------------------------------- */

SELECT
    customer_segment,
    COUNT(*) AS jumlah_customer
FROM customers
GROUP BY customer_segment
ORDER BY jumlah_customer DESC;


/* =========================================================
   STEP 5 — PRODUCTS
   ========================================================= */

/* =========================================================
   5.1 PROFILING PRODUCTS RAW
   Tujuan:
   - Mengecek jumlah data
   - Mengecek duplicate product_id
   - Mengecek missing values
   - Mengecek validitas harga
   - Melihat distribusi kategori
   ========================================================= */


/* ---------------------------------------------------------
   5.1.1 Row Count
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_rows
FROM products_raw;


/* ---------------------------------------------------------
   5.1.2 Duplicate Product ID
   --------------------------------------------------------- */

SELECT
    product_id,
    COUNT(*) AS jumlah_data
FROM products_raw
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY jumlah_data DESC;


/* ---------------------------------------------------------
   5.1.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(product_id IS NULL OR TRIM(product_id) = '')
        AS missing_product_id,

    SUM(product_name IS NULL OR TRIM(product_name) = '')
        AS missing_product_name,

    SUM(category IS NULL OR TRIM(category) = '')
        AS missing_category,

    SUM(subcategory IS NULL OR TRIM(subcategory) = '')
        AS missing_subcategory,

    SUM(brand IS NULL OR TRIM(brand) = '')
        AS missing_brand,

    SUM(unit_cost IS NULL OR TRIM(unit_cost) = '')
        AS missing_unit_cost,

    SUM(list_price IS NULL OR TRIM(list_price) = '')
        AS missing_list_price

FROM products_raw;


/* ---------------------------------------------------------
   5.1.4 Product Category Distribution
   --------------------------------------------------------- */

SELECT
    category,
    COUNT(*) AS jumlah_product
FROM products_raw
GROUP BY category
ORDER BY jumlah_product DESC;


/* ---------------------------------------------------------
   5.1.5 Numeric Price Validation
   Memastikan unit_cost dan list_price
   memiliki format angka yang valid
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_price_rows
FROM products_raw
WHERE unit_cost NOT REGEXP '^[0-9]+(\.[0-9]+)?$'
   OR list_price NOT REGEXP '^[0-9]+(\.[0-9]+)?$';


/* ---------------------------------------------------------
   5.1.6 Price Logic Validation
   Memastikan list_price tidak lebih rendah
   daripada unit_cost
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS harga_tidak_wajar
FROM products_raw
WHERE CAST(list_price AS DECIMAL(15,2))
    < CAST(unit_cost AS DECIMAL(15,2));


/* =========================================================
   5.2 CLEANING PRODUCTS
   ========================================================= */


/* ---------------------------------------------------------
   5.2.1 Insert Clean Products
   Cleaning Rules:
   - Product ID harus unik
   - Numeric fields dikonversi ke DECIMAL
   - Leading/trailing spaces dibersihkan
   --------------------------------------------------------- */

INSERT INTO products (
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    unit_cost,
    list_price
)

SELECT
    TRIM(product_id) AS product_id,
    TRIM(product_name) AS product_name,
    TRIM(category) AS category,
    TRIM(subcategory) AS subcategory,
    TRIM(brand) AS brand,

    CAST(unit_cost AS DECIMAL(15,2))
        AS unit_cost,

    CAST(list_price AS DECIMAL(15,2))
        AS list_price

FROM products_raw;


/* =========================================================
   5.3 VALIDATION CLEAN PRODUCTS
   ========================================================= */


/* ---------------------------------------------------------
   5.3.1 Total Rows & Product ID Range
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS jumlah_products,
    MIN(product_id) AS product_id_awal,
    MAX(product_id) AS product_id_akhir
FROM products;


/* ---------------------------------------------------------
   5.3.2 Duplicate Product ID
   --------------------------------------------------------- */

SELECT
    COUNT(*) - COUNT(DISTINCT product_id)
        AS duplicate_product_id
FROM products;


/* ---------------------------------------------------------
   5.3.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(product_name IS NULL) AS missing_product_name,
    SUM(category IS NULL) AS missing_category,
    SUM(subcategory IS NULL) AS missing_subcategory,
    SUM(brand IS NULL) AS missing_brand,
    SUM(unit_cost IS NULL) AS missing_unit_cost,
    SUM(list_price IS NULL) AS missing_list_price
FROM products;


/* ---------------------------------------------------------
   5.3.4 Price Logic Validation
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS harga_tidak_wajar
FROM products
WHERE list_price < unit_cost;


/* ---------------------------------------------------------
   5.3.5 Category Distribution
   --------------------------------------------------------- */

SELECT
    category,
    COUNT(*) AS jumlah_product
FROM products
GROUP BY category
ORDER BY jumlah_product DESC;


/* =========================================================
   STEP 6 — STORES
   ========================================================= */

/* =========================================================
   6.1 PROFILING STORES RAW
   Tujuan:
   - Mengecek jumlah data
   - Mengecek duplicate store_id
   - Mengecek missing values
   - Mengecek distribusi channel
   - Mengecek distribusi region
   - Mengecek distribusi store type
   ========================================================= */


/* ---------------------------------------------------------
   6.1.1 Row Count
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_rows
FROM stores_raw;


/* ---------------------------------------------------------
   6.1.2 Duplicate Store ID
   --------------------------------------------------------- */

SELECT
    store_id,
    COUNT(*) AS jumlah_data
FROM stores_raw
GROUP BY store_id
HAVING COUNT(*) > 1
ORDER BY jumlah_data DESC;


/* ---------------------------------------------------------
   6.1.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(store_id IS NULL OR TRIM(store_id) = '')
        AS missing_store_id,

    SUM(store_name IS NULL OR TRIM(store_name) = '')
        AS missing_store_name,

    SUM(channel IS NULL OR TRIM(channel) = '')
        AS missing_channel,

    SUM(city IS NULL OR TRIM(city) = '')
        AS missing_city,

    SUM(region IS NULL OR TRIM(region) = '')
        AS missing_region,

    SUM(store_type IS NULL OR TRIM(store_type) = '')
        AS missing_store_type

FROM stores_raw;


/* ---------------------------------------------------------
   6.1.4 Channel Distribution
   --------------------------------------------------------- */

SELECT
    channel,
    COUNT(*) AS jumlah_store
FROM stores_raw
GROUP BY channel
ORDER BY jumlah_store DESC;


/* ---------------------------------------------------------
   6.1.5 Region Distribution
   --------------------------------------------------------- */

SELECT
    region,
    COUNT(*) AS jumlah_store
FROM stores_raw
GROUP BY region
ORDER BY jumlah_store DESC;


/* ---------------------------------------------------------
   6.1.6 Store Type Distribution
   --------------------------------------------------------- */

SELECT
    store_type,
    COUNT(*) AS jumlah_store
FROM stores_raw
GROUP BY store_type
ORDER BY jumlah_store DESC;


/* ---------------------------------------------------------
   6.1.7 Channel × Store Type
   Untuk memastikan kombinasi kategori valid
   --------------------------------------------------------- */

SELECT
    channel,
    store_type,
    COUNT(*) AS jumlah_store
FROM stores_raw
GROUP BY channel, store_type
ORDER BY channel, jumlah_store DESC;


/* =========================================================
   6.2 CLEANING STORES
   ========================================================= */


/* ---------------------------------------------------------
   6.2.1 Insert Clean Stores
   Cleaning Rules:
   - Store ID harus unik
   - Text fields dibersihkan dari leading/trailing spaces
   --------------------------------------------------------- */

INSERT INTO stores (
    store_id,
    store_name,
    channel,
    city,
    region,
    store_type
)

SELECT
    TRIM(store_id) AS store_id,
    TRIM(store_name) AS store_name,
    TRIM(channel) AS channel,
    TRIM(city) AS city,
    TRIM(region) AS region,
    TRIM(store_type) AS store_type

FROM stores_raw;


/* =========================================================
   6.3 VALIDATION CLEAN STORES
   ========================================================= */


/* ---------------------------------------------------------
   6.3.1 Total Rows
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_clean_stores
FROM stores;


/* ---------------------------------------------------------
   6.3.2 Duplicate Store ID
   --------------------------------------------------------- */

SELECT
    COUNT(*) - COUNT(DISTINCT store_id)
        AS duplicate_store_id
FROM stores;


/* ---------------------------------------------------------
   6.3.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(store_id IS NULL) AS missing_store_id,
    SUM(store_name IS NULL) AS missing_store_name,
    SUM(channel IS NULL) AS missing_channel,
    SUM(city IS NULL) AS missing_city,
    SUM(region IS NULL) AS missing_region,
    SUM(store_type IS NULL) AS missing_store_type
FROM stores;


/* ---------------------------------------------------------
   6.3.4 Channel Distribution
   --------------------------------------------------------- */

SELECT
    channel,
    COUNT(*) AS jumlah_store
FROM stores
GROUP BY channel
ORDER BY jumlah_store DESC;


/* ---------------------------------------------------------
   6.3.5 Region Distribution
   --------------------------------------------------------- */

SELECT
    region,
    COUNT(*) AS jumlah_store
FROM stores
GROUP BY region
ORDER BY jumlah_store DESC;


/* ---------------------------------------------------------
   6.3.6 Store Type Distribution
   --------------------------------------------------------- */

SELECT
    store_type,
    COUNT(*) AS jumlah_store
FROM stores
GROUP BY store_type
ORDER BY jumlah_store DESC;


/* =========================================================
   STEP 7 — ORDERS
   ========================================================= */

/* =========================================================
   7.1 PROFILING ORDERS RAW
   Tujuan:
   - Mengecek jumlah order
   - Mengecek duplicate order_id
   - Mengecek missing values
   - Mengecek order status
   - Mengecek payment method
   - Mengecek rentang tanggal
   - Mengecek foreign key
   ========================================================= */


/* ---------------------------------------------------------
   7.1.1 Row Count
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_rows
FROM orders_raw;


/* ---------------------------------------------------------
   7.1.2 Duplicate Order ID
   --------------------------------------------------------- */

SELECT
    order_id,
    COUNT(*) AS jumlah_data
FROM orders_raw
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY jumlah_data DESC;


/* ---------------------------------------------------------
   7.1.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(order_id IS NULL OR TRIM(order_id) = '')
        AS missing_order_id,

    SUM(order_date IS NULL OR TRIM(order_date) = '')
        AS missing_order_date,

    SUM(customer_id IS NULL OR TRIM(customer_id) = '')
        AS missing_customer_id,

    SUM(store_id IS NULL OR TRIM(store_id) = '')
        AS missing_store_id,

    SUM(payment_method IS NULL OR TRIM(payment_method) = '')
        AS missing_payment_method,

    SUM(order_status IS NULL OR TRIM(order_status) = '')
        AS missing_order_status

FROM orders_raw;


/* ---------------------------------------------------------
   7.1.4 Order Status Distribution
   --------------------------------------------------------- */

SELECT
    order_status,
    COUNT(*) AS jumlah_order
FROM orders_raw
GROUP BY order_status
ORDER BY jumlah_order DESC;


/* ---------------------------------------------------------
   7.1.5 Payment Method Distribution
   --------------------------------------------------------- */

SELECT
    CASE
        WHEN payment_method IS NULL
             OR TRIM(payment_method) = ''
        THEN 'Missing'
        ELSE payment_method
    END AS payment_method_status,

    COUNT(*) AS jumlah_order

FROM orders_raw

GROUP BY
    CASE
        WHEN payment_method IS NULL
             OR TRIM(payment_method) = ''
        THEN 'Missing'
        ELSE payment_method
    END

ORDER BY jumlah_order DESC;


/* ---------------------------------------------------------
   7.1.6 Date Range
   --------------------------------------------------------- */

SELECT
    MIN(order_date) AS tanggal_awal,
    MAX(order_date) AS tanggal_akhir
FROM orders_raw;


/* ---------------------------------------------------------
   7.1.7 Invalid Date Format
   Memastikan seluruh tanggal mengikuti YYYY-MM-DD
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_date_rows
FROM orders_raw
WHERE order_date IS NOT NULL
  AND TRIM(order_date) <> ''
  AND STR_TO_DATE(order_date, '%Y-%m-%d') IS NULL;


/* ---------------------------------------------------------
   7.1.8 Invalid Customer Foreign Key
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_customer_fk
FROM orders_raw o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


/* ---------------------------------------------------------
   7.1.9 Invalid Store Foreign Key
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_store_fk
FROM orders_raw o
LEFT JOIN stores s
    ON o.store_id = s.store_id
WHERE s.store_id IS NULL;


/* =========================================================
   7.2 CLEANING ORDERS
   ========================================================= */


/* ---------------------------------------------------------
   7.2.1 Preview Missing Payment Method
   --------------------------------------------------------- */

SELECT
    order_id,
    payment_method AS payment_before,

    CASE
        WHEN payment_method IS NULL
             OR TRIM(payment_method) = ''
        THEN 'Unknown'
        ELSE payment_method
    END AS payment_after

FROM orders_raw

WHERE payment_method IS NULL
   OR TRIM(payment_method) = '';


/* ---------------------------------------------------------
   7.2.2 Insert Clean Orders
   Cleaning Rules:
   - Convert order_date menjadi DATE
   - Missing payment_method → Unknown
   - Text fields dibersihkan dengan TRIM()
   --------------------------------------------------------- */

INSERT INTO orders (
    order_id,
    order_date,
    customer_id,
    store_id,
    payment_method,
    order_status
)

SELECT
    TRIM(order_id) AS order_id,

    STR_TO_DATE(
        order_date,
        '%Y-%m-%d'
    ) AS order_date,

    TRIM(customer_id) AS customer_id,
    TRIM(store_id) AS store_id,

    CASE
        WHEN payment_method IS NULL
             OR TRIM(payment_method) = ''
        THEN 'Unknown'
        ELSE TRIM(payment_method)
    END AS payment_method,

    TRIM(order_status) AS order_status

FROM orders_raw;


/* =========================================================
   7.3 VALIDATION CLEAN ORDERS
   ========================================================= */


/* ---------------------------------------------------------
   7.3.1 Total Rows
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_clean_orders
FROM orders;


/* ---------------------------------------------------------
   7.3.2 Duplicate Order ID
   --------------------------------------------------------- */

SELECT
    COUNT(*) - COUNT(DISTINCT order_id)
        AS duplicate_order_id
FROM orders;


/* ---------------------------------------------------------
   7.3.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(store_id IS NULL) AS missing_store_id,
    SUM(payment_method IS NULL) AS missing_payment_method,
    SUM(order_status IS NULL) AS missing_order_status
FROM orders;


/* ---------------------------------------------------------
   7.3.4 Payment Method Validation
   --------------------------------------------------------- */

SELECT
    payment_method,
    COUNT(*) AS jumlah_order
FROM orders
GROUP BY payment_method
ORDER BY jumlah_order DESC;


/* ---------------------------------------------------------
   7.3.5 Foreign Key Validation — Customer
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_customer_fk
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


/* ---------------------------------------------------------
   7.3.6 Foreign Key Validation — Store
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_store_fk
FROM orders o
LEFT JOIN stores s
    ON o.store_id = s.store_id
WHERE s.store_id IS NULL;


/* ---------------------------------------------------------
   7.3.7 Order Status Validation
   --------------------------------------------------------- */

SELECT
    order_status,
    COUNT(*) AS jumlah_order
FROM orders
GROUP BY order_status
ORDER BY jumlah_order DESC;


/* ---------------------------------------------------------
   7.3.8 Final Date Range
   --------------------------------------------------------- */

SELECT
    MIN(order_date) AS tanggal_awal,
    MAX(order_date) AS tanggal_akhir
FROM orders;


/* =========================================================
   STEP 8 — ORDER DETAILS
   ========================================================= */

/* =========================================================
   8.1 PROFILING ORDER DETAILS RAW
   Tujuan:
   - Mengecek jumlah data
   - Mengecek duplicate order_detail_id
   - Mengecek missing values
   - Mengecek format numeric
   - Mengecek quantity dan discount
   - Mengecek foreign key
   ========================================================= */


/* ---------------------------------------------------------
   8.1.1 Row Count
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_rows
FROM order_details_raw;


/* ---------------------------------------------------------
   8.1.2 Duplicate Order Detail ID
   --------------------------------------------------------- */

SELECT
    order_detail_id,
    COUNT(*) AS jumlah_data
FROM order_details_raw
GROUP BY order_detail_id
HAVING COUNT(*) > 1
ORDER BY jumlah_data DESC;


/* ---------------------------------------------------------
   8.1.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(order_detail_id IS NULL OR TRIM(order_detail_id) = '')
        AS missing_order_detail_id,

    SUM(order_id IS NULL OR TRIM(order_id) = '')
        AS missing_order_id,

    SUM(product_id IS NULL OR TRIM(product_id) = '')
        AS missing_product_id,

    SUM(quantity IS NULL OR TRIM(quantity) = '')
        AS missing_quantity,

    SUM(unit_price IS NULL OR TRIM(unit_price) = '')
        AS missing_unit_price,

    SUM(discount_pct IS NULL OR TRIM(discount_pct) = '')
        AS missing_discount_pct,

    SUM(sales_amount IS NULL OR TRIM(sales_amount) = '')
        AS missing_sales_amount,

    SUM(unit_cost IS NULL OR TRIM(unit_cost) = '')
        AS missing_unit_cost,

    SUM(cost_amount IS NULL OR TRIM(cost_amount) = '')
        AS missing_cost_amount,

    SUM(profit_amount IS NULL OR TRIM(profit_amount) = '')
        AS missing_profit_amount

FROM order_details_raw;


/* ---------------------------------------------------------
   8.1.4 Numeric Format Validation
   --------------------------------------------------------- */

SELECT
    SUM(quantity NOT REGEXP '^[0-9]+$')
        AS invalid_quantity,

    SUM(unit_price NOT REGEXP '^[0-9]+(\.[0-9]+)?$')
        AS invalid_unit_price,

    SUM(discount_pct NOT REGEXP '^[0-9]+(\.[0-9]+)?$')
        AS invalid_discount_pct,

    SUM(sales_amount NOT REGEXP '^-?[0-9]+(\.[0-9]+)?$')
        AS invalid_sales_amount,

    SUM(unit_cost NOT REGEXP '^[0-9]+(\.[0-9]+)?$')
        AS invalid_unit_cost,

    SUM(cost_amount NOT REGEXP '^-?[0-9]+(\.[0-9]+)?$')
        AS invalid_cost_amount,

    SUM(profit_amount NOT REGEXP '^-?[0-9]+(\.[0-9]+)?$')
        AS invalid_profit_amount

FROM order_details_raw;


/* ---------------------------------------------------------
   8.1.5 Quantity Validation
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_quantity_rows
FROM order_details_raw
WHERE CAST(quantity AS DECIMAL(15,2)) <= 0;


/* ---------------------------------------------------------
   8.1.6 Discount Validation
   Discount harus berada pada rentang 0–1
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_discount_rows
FROM order_details_raw
WHERE CAST(discount_pct AS DECIMAL(20,17)) < 0
   OR CAST(discount_pct AS DECIMAL(20,17)) > 1;


/* ---------------------------------------------------------
   8.1.7 Invalid Order Foreign Key
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_order_fk
FROM order_details_raw od
LEFT JOIN orders o
    ON od.order_id = o.order_id
WHERE o.order_id IS NULL;


/* ---------------------------------------------------------
   8.1.8 Invalid Product Foreign Key
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_product_fk
FROM order_details_raw od
LEFT JOIN products p
    ON od.product_id = p.product_id
WHERE p.product_id IS NULL;


/* =========================================================
   8.2 CLEANING ORDER DETAILS
   ========================================================= */


/* ---------------------------------------------------------
   8.2.1 Preview Duplicate Handling
   Menyimpan satu record untuk setiap
   order_detail_id
   --------------------------------------------------------- */

SELECT
    order_detail_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_pct,

    ROW_NUMBER() OVER (
        PARTITION BY order_detail_id
        ORDER BY order_detail_id
    ) AS row_num

FROM order_details_raw

WHERE order_detail_id IN (
    SELECT
        order_detail_id
    FROM order_details_raw
    GROUP BY order_detail_id
    HAVING COUNT(*) > 1
)

ORDER BY order_detail_id, row_num;


/* ---------------------------------------------------------
   8.2.2 Preview Jumlah Data Setelah Deduplication
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS calon_order_details_clean
FROM (
    SELECT
        order_detail_id,

        ROW_NUMBER() OVER (
            PARTITION BY order_detail_id
            ORDER BY order_detail_id
        ) AS row_num

    FROM order_details_raw
) AS ranked_details

WHERE row_num = 1;


/* ---------------------------------------------------------
   8.2.3 Insert Clean Order Details
   Cleaning Rules:
   - Duplicate order_detail_id → keep one record
   - Numeric fields → convert to DECIMAL / INT
   - Text fields → TRIM()
   --------------------------------------------------------- */

INSERT INTO order_details (
    order_detail_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_pct,
    sales_amount,
    unit_cost,
    cost_amount,
    profit_amount
)

SELECT
    TRIM(order_detail_id) AS order_detail_id,
    TRIM(order_id) AS order_id,
    TRIM(product_id) AS product_id,

    CAST(quantity AS UNSIGNED)
        AS quantity,

    CAST(unit_price AS DECIMAL(15,2))
        AS unit_price,

    CAST(discount_pct AS DECIMAL(20,17))
        AS discount_pct,

    CAST(sales_amount AS DECIMAL(15,2))
        AS sales_amount,

    CAST(unit_cost AS DECIMAL(15,2))
        AS unit_cost,

    CAST(cost_amount AS DECIMAL(15,2))
        AS cost_amount,

    CAST(profit_amount AS DECIMAL(15,2))
        AS profit_amount

FROM (
    SELECT
        *,

        ROW_NUMBER() OVER (
            PARTITION BY order_detail_id
            ORDER BY order_detail_id
        ) AS row_num

    FROM order_details_raw
) AS ranked_details

WHERE row_num = 1;


/* =========================================================
   8.3 VALIDATION CLEAN ORDER DETAILS
   ========================================================= */


/* ---------------------------------------------------------
   8.3.1 Total Rows
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS total_clean_order_details
FROM order_details;


/* ---------------------------------------------------------
   8.3.2 Duplicate Order Detail ID
   --------------------------------------------------------- */

SELECT
    COUNT(*) - COUNT(DISTINCT order_detail_id)
        AS duplicate_order_detail_id
FROM order_details;


/* ---------------------------------------------------------
   8.3.3 Missing Values
   --------------------------------------------------------- */

SELECT
    SUM(order_detail_id IS NULL)
        AS missing_order_detail_id,

    SUM(order_id IS NULL)
        AS missing_order_id,

    SUM(product_id IS NULL)
        AS missing_product_id,

    SUM(quantity IS NULL)
        AS missing_quantity,

    SUM(unit_price IS NULL)
        AS missing_unit_price,

    SUM(discount_pct IS NULL)
        AS missing_discount_pct,

    SUM(sales_amount IS NULL)
        AS missing_sales_amount,

    SUM(unit_cost IS NULL)
        AS missing_unit_cost,

    SUM(cost_amount IS NULL)
        AS missing_cost_amount,

    SUM(profit_amount IS NULL)
        AS missing_profit_amount

FROM order_details;


/* ---------------------------------------------------------
   8.3.4 Quantity Validation
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_quantity_rows
FROM order_details
WHERE quantity <= 0;


/* ---------------------------------------------------------
   8.3.5 Discount Validation
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_discount_rows
FROM order_details
WHERE discount_pct < 0
   OR discount_pct > 1;


/* ---------------------------------------------------------
   8.3.6 Foreign Key Validation — Order
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_order_fk
FROM order_details od
LEFT JOIN orders o
    ON od.order_id = o.order_id
WHERE o.order_id IS NULL;


/* ---------------------------------------------------------
   8.3.7 Foreign Key Validation — Product
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_product_fk
FROM order_details od
LEFT JOIN products p
    ON od.product_id = p.product_id
WHERE p.product_id IS NULL;


/* ---------------------------------------------------------
   8.3.8 Revenue Calculation Validation
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_revenue_calculation
FROM order_details
WHERE ABS(
    sales_amount
    - (
        quantity
        * unit_price
        * (1 - discount_pct)
      )
) > 1;


/* ---------------------------------------------------------
   8.3.9 Cost Calculation Validation
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_cost_calculation
FROM order_details
WHERE ABS(
    cost_amount
    - (
        quantity * unit_cost
      )
) > 1;


/* ---------------------------------------------------------
   8.3.10 Profit Calculation Validation
   --------------------------------------------------------- */

SELECT
    COUNT(*) AS invalid_profit_calculation
FROM order_details
WHERE ABS(
    profit_amount
    - (
        sales_amount - cost_amount
      )
) > 1;


/* ---------------------------------------------------------
   8.3.11 Discount Precision Check
   Memastikan precision discount tetap terjaga
   --------------------------------------------------------- */

SELECT
    MAX(
        LENGTH(
            SUBSTRING_INDEX(
                CAST(discount_pct AS CHAR),
                '.',
                -1
            )
        )
    ) AS max_decimal_places
FROM order_details;

/* =========================================================
   STEP 9 — BUSINESS ANALYSIS
   ========================================================= */

/* =========================================================
   9.1 OVERALL KPI
   ========================================================= */

SELECT

    /* -----------------------------------------------------
       Revenue
       ----------------------------------------------------- */

    ROUND(
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ),
        0
    ) AS total_revenue,


    /* -----------------------------------------------------
       Profit
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ),
        0
    ) AS total_profit,


    /* -----------------------------------------------------
       Profit Margin
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        )
        /
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        )
        * 100,
        2
    ) AS profit_margin_pct,


    /* -----------------------------------------------------
       Completed Orders
       ----------------------------------------------------- */

    COUNT(DISTINCT o.order_id)
        AS completed_orders,


    /* -----------------------------------------------------
       Quantity Sold
       ----------------------------------------------------- */

    SUM(od.quantity)
        AS quantity_sold,


    /* -----------------------------------------------------
       Active Customers
       ----------------------------------------------------- */

    COUNT(DISTINCT o.customer_id)
        AS active_customers,


    /* -----------------------------------------------------
       Average Order Value
       ----------------------------------------------------- */

    ROUND(
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        )
        /
        COUNT(DISTINCT o.order_id),
        0
    ) AS average_order_value


FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

WHERE o.order_status = 'Completed';

/* =========================================================
   9.2 YEARLY PERFORMANCE
   ========================================================= */

SELECT
    YEAR(o.order_date) AS order_year,

    /* -----------------------------------------------------
       Revenue
       ----------------------------------------------------- */

    ROUND(
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ),
        0
    ) AS revenue,


    /* -----------------------------------------------------
       Profit
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ),
        0
    ) AS profit,


    /* -----------------------------------------------------
       Profit Margin
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        )
        /
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        )
        * 100,
        2
    ) AS profit_margin_pct


FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

WHERE o.order_status = 'Completed'

GROUP BY YEAR(o.order_date)

ORDER BY order_year;

/* =========================================================
   9.3 GROWTH ANALYSIS
   ========================================================= */

WITH yearly_performance AS (

    SELECT
        YEAR(o.order_date) AS order_year,

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY YEAR(o.order_date)
),

growth_calculation AS (

    SELECT
        order_year,
        revenue,
        profit,

        LAG(revenue) OVER (
            ORDER BY order_year
        ) AS previous_revenue,

        LAG(profit) OVER (
            ORDER BY order_year
        ) AS previous_profit

    FROM yearly_performance
)

SELECT
    order_year,

    ROUND(revenue, 0) AS revenue,

    ROUND(profit, 0) AS profit,

    ROUND(
        (
            revenue - previous_revenue
        )
        / previous_revenue
        * 100,
        2
    ) AS revenue_growth_pct,

    ROUND(
        (
            profit - previous_profit
        )
        / previous_profit
        * 100,
        2
    ) AS profit_growth_pct,

    ROUND(
        (
            (
                profit - previous_profit
            )
            / previous_profit
            * 100
        )
        -
        (
            (
                revenue - previous_revenue
            )
            / previous_revenue
            * 100
        ),
        2
    ) AS growth_gap_pct

FROM growth_calculation

WHERE previous_revenue IS NOT NULL

ORDER BY order_year;

/* =========================================================
   9.4 MONTHLY TREND
   ========================================================= */

SELECT
    YEAR(o.order_date) AS order_year,

    MONTH(o.order_date) AS order_month,

    /* -----------------------------------------------------
       Revenue
       ----------------------------------------------------- */

    ROUND(
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ),
        0
    ) AS revenue,


    /* -----------------------------------------------------
       Profit
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ),
        0
    ) AS profit,


    /* -----------------------------------------------------
       Profit Margin
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        )
        /
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        )
        * 100,
        2
    ) AS profit_margin_pct


FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)

ORDER BY
    order_year,
    order_month;
    
    
/* =========================================================
   9.5 CATEGORY ANALYSIS
   ========================================================= */

WITH category_performance AS (

    SELECT
        p.category,

        /* -------------------------------------------------
           Revenue
           ------------------------------------------------- */

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,


        /* -------------------------------------------------
           Profit
           ------------------------------------------------- */

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN products p
        ON od.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY p.category
),

total_profit AS (

    SELECT
        SUM(profit) AS total_profit
    FROM category_performance
)

SELECT
    cp.category,

    ROUND(
        cp.revenue,
        0
    ) AS revenue,

    ROUND(
        cp.profit,
        0
    ) AS profit,

    ROUND(
        cp.profit
        / cp.revenue
        * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        cp.profit
        / tp.total_profit
        * 100,
        2
    ) AS profit_contribution_pct

FROM category_performance cp

CROSS JOIN total_profit tp

ORDER BY cp.profit DESC;

/* =========================================================
   9.6 CUSTOMER SEGMENT ANALYSIS
   ========================================================= */

WITH segment_performance AS (

    SELECT
        c.customer_segment,

        /* -------------------------------------------------
           Revenue
           ------------------------------------------------- */

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,


        /* -------------------------------------------------
           Profit
           ------------------------------------------------- */

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'Completed'

    GROUP BY c.customer_segment
),

total_profit AS (

    SELECT
        SUM(profit) AS total_profit
    FROM segment_performance
)

SELECT
    sp.customer_segment,

    ROUND(
        sp.revenue,
        0
    ) AS revenue,

    ROUND(
        sp.profit,
        0
    ) AS profit,

    ROUND(
        sp.profit
        / sp.revenue
        * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        sp.profit
        / tp.total_profit
        * 100,
        2
    ) AS profit_contribution_pct

FROM segment_performance sp

CROSS JOIN total_profit tp

ORDER BY sp.profit DESC;


/* =========================================================
   9.7 CHANNEL ANALYSIS
   ========================================================= */

WITH channel_performance AS (

    SELECT
        s.channel,

        /* -------------------------------------------------
           Revenue
           ------------------------------------------------- */

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,


        /* -------------------------------------------------
           Profit
           ------------------------------------------------- */

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN stores s
        ON o.store_id = s.store_id

    WHERE o.order_status = 'Completed'

    GROUP BY s.channel
),

total_profit AS (

    SELECT
        SUM(profit) AS total_profit
    FROM channel_performance
)

SELECT
    cp.channel,

    ROUND(
        cp.revenue,
        0
    ) AS revenue,

    ROUND(
        cp.profit,
        0
    ) AS profit,

    ROUND(
        cp.profit
        / cp.revenue
        * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        cp.profit
        / tp.total_profit
        * 100,
        2
    ) AS profit_contribution_pct

FROM channel_performance cp

CROSS JOIN total_profit tp

ORDER BY cp.profit DESC;

/* =========================================================
   9.8 REGION ANALYSIS
   ========================================================= */

WITH region_performance AS (

    SELECT
        s.region,

        /* -------------------------------------------------
           Revenue
           ------------------------------------------------- */

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,


        /* -------------------------------------------------
           Profit
           ------------------------------------------------- */

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN stores s
        ON o.store_id = s.store_id

    WHERE o.order_status = 'Completed'

    GROUP BY s.region
),

total_profit AS (

    SELECT
        SUM(profit) AS total_profit
    FROM region_performance
)

SELECT
    rp.region,

    ROUND(
        rp.revenue,
        0
    ) AS revenue,

    ROUND(
        rp.profit,
        0
    ) AS profit,

    ROUND(
        rp.profit
        / rp.revenue
        * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        rp.profit
        / tp.total_profit
        * 100,
        2
    ) AS profit_contribution_pct

FROM region_performance rp

CROSS JOIN total_profit tp

ORDER BY rp.profit DESC;

/* =========================================================
   9.9 DISCOUNT ANALYSIS
   ========================================================= */

WITH discount_performance AS (

    SELECT

        /* -------------------------------------------------
           Discount Band
           ------------------------------------------------- */

        CASE
            WHEN od.discount_pct < 0.05
                THEN '0-5%'

            WHEN od.discount_pct < 0.10
                THEN '5-10%'

            WHEN od.discount_pct < 0.20
                THEN '10-20%'

            WHEN od.discount_pct < 0.30
                THEN '20-30%'

            ELSE '>30%'
        END AS discount_band,


        /* -------------------------------------------------
           Revenue
           ------------------------------------------------- */

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,


        /* -------------------------------------------------
           Profit
           ------------------------------------------------- */

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit,


        /* -------------------------------------------------
           Quantity
           ------------------------------------------------- */

        SUM(od.quantity) AS quantity_sold

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        CASE
            WHEN od.discount_pct < 0.05
                THEN '0-5%'

            WHEN od.discount_pct < 0.10
                THEN '5-10%'

            WHEN od.discount_pct < 0.20
                THEN '10-20%'

            WHEN od.discount_pct < 0.30
                THEN '20-30%'

            ELSE '>30%'
        END
),

total_profit AS (

    SELECT
        SUM(profit) AS total_profit
    FROM discount_performance
)

SELECT

    dp.discount_band,

    ROUND(
        dp.revenue,
        0
    ) AS revenue,

    ROUND(
        dp.profit,
        0
    ) AS profit,

    ROUND(
        dp.profit
        / dp.revenue
        * 100,
        2
    ) AS profit_margin_pct,

    dp.quantity_sold,

    ROUND(
        dp.revenue
        / dp.quantity_sold,
        0
    ) AS revenue_per_unit,

    ROUND(
        dp.profit
        / tp.total_profit
        * 100,
        2
    ) AS profit_contribution_pct

FROM discount_performance dp

CROSS JOIN total_profit tp

ORDER BY
    CASE dp.discount_band
        WHEN '0-5%' THEN 1
        WHEN '5-10%' THEN 2
        WHEN '10-20%' THEN 3
        WHEN '20-30%' THEN 4
        WHEN '>30%' THEN 5
    END;
    
/* =========================================================
   9.10 DEEP DIVE
   ========================================================= */

/* =========================================================
   9.10.1 CATEGORY × CUSTOMER SEGMENT
   ========================================================= */

SELECT
    p.category,
    c.customer_segment,

    /* -----------------------------------------------------
       Revenue
       ----------------------------------------------------- */

    ROUND(
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ),
        0
    ) AS revenue,


    /* -----------------------------------------------------
       Profit
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ),
        0
    ) AS profit,


    /* -----------------------------------------------------
       Profit Margin
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        )
        /
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        )
        * 100,
        2
    ) AS profit_margin_pct

FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

JOIN products p
    ON od.product_id = p.product_id

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.category,
    c.customer_segment

ORDER BY
    profit ASC;
    

/* =========================================================
   9.10.2 ELECTRONICS × CORPORATE
   REGION × DISCOUNT
   ========================================================= */

SELECT

    s.region,

    /* -----------------------------------------------------
       Discount Band
       ----------------------------------------------------- */

    CASE
        WHEN od.discount_pct < 0.05
            THEN '0-5%'

        WHEN od.discount_pct < 0.10
            THEN '5-10%'

        WHEN od.discount_pct < 0.20
            THEN '10-20%'

        WHEN od.discount_pct < 0.30
            THEN '20-30%'

        ELSE '>30%'
    END AS discount_band,


    /* -----------------------------------------------------
       Revenue
       ----------------------------------------------------- */

    ROUND(
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ),
        0
    ) AS revenue,


    /* -----------------------------------------------------
       Profit
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ),
        0
    ) AS profit,


    /* -----------------------------------------------------
       Profit Margin
       ----------------------------------------------------- */

    ROUND(
        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        )
        /
        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        )
        * 100,
        2
    ) AS profit_margin_pct

FROM orders o

JOIN order_details od
    ON o.order_id = od.order_id

JOIN products p
    ON od.product_id = p.product_id

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN stores s
    ON o.store_id = s.store_id

WHERE o.order_status = 'Completed'

  AND p.category = 'Electronics'

  AND c.customer_segment = 'Corporate'

GROUP BY
    s.region,
    discount_band

ORDER BY
    profit ASC;
    
/* =========================================================
   9.11 EXECUTIVE SUMMARY
   ========================================================= */

WITH yearly_performance AS (

    SELECT
        YEAR(o.order_date) AS order_year,

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY YEAR(o.order_date)
),

yearly_growth AS (

    SELECT
        order_year,
        revenue,
        profit,

        LAG(revenue) OVER (
            ORDER BY order_year
        ) AS previous_revenue,

        LAG(profit) OVER (
            ORDER BY order_year
        ) AS previous_profit

    FROM yearly_performance
),

category_performance AS (

    SELECT
        p.category,

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN products p
        ON od.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY p.category
),

segment_performance AS (

    SELECT
        c.customer_segment,

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'Completed'

    GROUP BY c.customer_segment
),

channel_performance AS (

    SELECT
        s.channel,

        SUM(
            od.quantity
            * od.unit_price
            * (1 - od.discount_pct)
        ) AS revenue,

        SUM(
            (
                od.quantity
                * od.unit_price
                * (1 - od.discount_pct)
            )
            -
            (
                od.quantity
                * od.unit_cost
            )
        ) AS profit

    FROM orders o

    JOIN order_details od
        ON o.order_id = od.order_id

    JOIN stores s
        ON o.store_id = s.store_id

    WHERE o.order_status = 'Completed'

    GROUP BY s.channel
)

SELECT
    'Revenue 2024' AS metric,
    ROUND(revenue, 0) AS value
FROM yearly_performance
WHERE order_year = 2024

UNION ALL

SELECT
    'Revenue 2025',
    ROUND(revenue, 0)
FROM yearly_performance
WHERE order_year = 2025

UNION ALL

SELECT
    'Revenue Growth 2025 (%)',
    ROUND(
        (
            revenue - previous_revenue
        )
        / previous_revenue
        * 100,
        2
    )
FROM yearly_growth
WHERE order_year = 2025

UNION ALL

SELECT
    'Profit 2024',
    ROUND(profit, 0)
FROM yearly_performance
WHERE order_year = 2024

UNION ALL

SELECT
    'Profit 2025',
    ROUND(profit, 0)
FROM yearly_performance
WHERE order_year = 2025

UNION ALL

SELECT
    'Profit Growth 2025 (%)',
    ROUND(
        (
            profit - previous_profit
        )
        / previous_profit
        * 100,
        2
    )
FROM yearly_growth
WHERE order_year = 2025

UNION ALL

SELECT
    'Lowest Category Margin',
    CONCAT(
        category,
        ' (',
        ROUND(
            profit / revenue * 100,
            2
        ),
        '%)'
    )
FROM category_performance
WHERE profit / revenue = (
    SELECT
        MIN(profit / revenue)
    FROM category_performance
)

UNION ALL

SELECT
    'Lowest Segment Margin',
    CONCAT(
        customer_segment,
        ' (',
        ROUND(
            profit / revenue * 100,
            2
        ),
        '%)'
    )
FROM segment_performance
WHERE profit / revenue = (
    SELECT
        MIN(profit / revenue)
    FROM segment_performance
)

UNION ALL

SELECT
    'Lowest Channel Margin',
    CONCAT(
        channel,
        ' (',
        ROUND(
            profit / revenue * 100,
            2
        ),
        '%)'
    )
FROM channel_performance
WHERE profit / revenue = (
    SELECT
        MIN(profit / revenue)
    FROM channel_performance
);
