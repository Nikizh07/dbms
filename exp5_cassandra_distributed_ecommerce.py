from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider
import uuid

# Connect to Cassandra
auth_provider = PlainTextAuthProvider(username='your_username', password='your_password')
cluster = Cluster(['127.0.0.1'], auth_provider=auth_provider)
session = cluster.connect()

# Create keyspace and tables
session.execute("""
    CREATE KEYSPACE IF NOT EXISTS ecommerce
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
""")

session.execute(""" USE ecommerce; """)

session.execute("""
    CREATE TABLE IF NOT EXISTS products (
        product_id UUID PRIMARY KEY,
        name TEXT,
        price DECIMAL
    );
""")

session.execute("""
    CREATE TABLE IF NOT EXISTS orders (
        order_id UUID PRIMARY KEY,
        product_id UUID,
        quantity INT,
        total_price DECIMAL
    );
""")

# Sample data insertion
session.execute("""
    INSERT INTO products (product_id, name, price) VALUES (uuid(), 'Product A', 19.99);
""")

# Sample order processing
def process_order(order_id, product_id, quantity):
    product_info = session.execute("""
        SELECT * FROM products WHERE product_id = %s;
    """, (product_id,)).one()

    if product_info:
        total_price = product_info.price * quantity
        session.execute("""
            INSERT INTO orders (order_id, product_id, quantity, total_price)
            VALUES (%s, %s, %s, %s);
        """, (order_id, product_id, quantity, total_price))
        print(f"Order {order_id} processed successfully.")
    else:
        print(f"Product with ID {product_id} not found.")

# Example order processing
order_id = uuid.uuid4()
product_id = uuid.uuid4()  # Replace with an existing product_id
quantity = 2
process_order(order_id, product_id, quantity)

# Close the connection
cluster.shutdown()
