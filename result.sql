-- Bad example

SELECT
    (SELECT CONCAT(product_name, ": ", desc_length)
     FROM (SELECT product_name, LENGTH(description) AS desc_length
           FROM (SELECT o.order_id, o.order_date, p.product_id, p.product_name, p.description
                 FROM opt_orders o
                 JOIN opt_products p ON o.product_id = p.product_id
                 JOIN opt_clients c ON o.client_id = c.id
                 WHERE o.order_date > '2023-01-01') AS sub1
           GROUP BY product_name, description) AS sub2
     WHERE desc_length = (SELECT MIN(desc_length)
                         FROM (SELECT LENGTH(description) AS desc_length
                               FROM (SELECT o.order_id, o.order_date, p.product_id, p.product_name, p.description
                                     FROM opt_orders o
                                     JOIN opt_products p ON o.product_id = p.product_id
                                     JOIN opt_clients c ON o.client_id = c.id
                                     WHERE o.order_date > '2023-01-01') AS sub3
                               GROUP BY product_name, description) AS sub4)
     LIMIT 1) AS Shortest_Description,

    (SELECT CONCAT(product_name, ": ", desc_length)
     FROM (SELECT product_name, LENGTH(description) AS desc_length
           FROM (SELECT o.order_id, o.order_date, p.product_id, p.product_name, p.description
                 FROM opt_orders o
                 JOIN opt_products p ON o.product_id = p.product_id
                 JOIN opt_clients c ON o.client_id = c.id
                 WHERE o.order_date > '2023-01-01') AS sub1
           GROUP BY product_name, description) AS sub2
     WHERE desc_length = (SELECT MAX(desc_length)
                         FROM (SELECT LENGTH(description) AS desc_length
                               FROM (SELECT o.order_id, o.order_date, p.product_id, p.product_name, p.description
                                     FROM opt_orders o
                                     JOIN opt_products p ON o.product_id = p.product_id
                                     JOIN opt_clients c ON o.client_id = c.id
                                     WHERE o.order_date > '2023-01-01') AS sub3
                               GROUP BY product_name, description) AS sub4)
     LIMIT 1) AS Longest_Description;


-- Good example

CREATE INDEX idx_product_id ON opt_orders(product_id);
CREATE INDEX idx_order_date ON opt_orders(order_date);
CREATE INDEX idx_client_id ON opt_orders(client_id);

WITH FilteredData AS (
    SELECT 
        p.product_name, 
        LENGTH(p.description) AS desc_length
    FROM opt_orders o
    JOIN opt_products p ON o.product_id = p.product_id
    JOIN opt_clients c ON o.client_id = c.id
    WHERE o.order_date > '2023-01-01'
),
DescriptionLengths AS (
    SELECT 
        product_name, 
        MIN(desc_length) AS min_desc_length,
        MAX(desc_length) AS max_desc_length
    FROM FilteredData
    GROUP BY product_name
)

SELECT
    (SELECT CONCAT(product_name, ": ", min_desc_length)
     FROM DescriptionLengths
     ORDER BY min_desc_length ASC
     LIMIT 1) AS Shortest_Description,
    (SELECT CONCAT(product_name, ": ", max_desc_length)
     FROM DescriptionLengths
     ORDER BY max_desc_length DESC
     LIMIT 1) AS Longest_Description;

-- Drop indexes

DROP INDEX idx_product_id ON opt_orders;
DROP INDEX idx_order_date ON opt_orders;
DROP INDEX idx_client_id ON opt_orders;
