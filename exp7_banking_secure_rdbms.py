# ============================================================
# Experiment 7: Develop a Secure RDBMS Solution for a
# Banking Financial Transactions System
# ============================================================
# Install dependencies:
#   pip install Flask Flask-SQLAlchemy Flask-Bcrypt flask-cors

from flask            import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt     import Bcrypt
from flask_cors       import CORS
from sqlalchemy       import Column, Integer, String, Numeric, DateTime
from sqlalchemy.sql   import func

# -------------------------
# App Configuration
# -------------------------
app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI']        = 'sqlite:///banking.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY']                     = 'replace_with_a_secure_random_key'
app.config['BCRYPT_LOG_ROUNDS']              = 12

db     = SQLAlchemy(app)
bcrypt = Bcrypt(app)

# -------------------------
# Models
# -------------------------

class User(db.Model):
    """Stores bank user credentials (passwords hashed with bcrypt)."""
    __tablename__ = 'users'

    id             = Column(Integer,     primary_key=True)
    username       = Column(String(50),  unique=True, nullable=False)
    password       = Column(String(60),  nullable=False)          # bcrypt hash
    account_number = Column(String(20),  unique=True, nullable=False)
    role           = Column(String(20),  nullable=False, default='customer')  # RBAC


class Transaction(db.Model):
    """Records every financial transaction."""
    __tablename__ = 'transactions'

    id               = Column(Integer,      primary_key=True)
    account_number   = Column(String(20),   nullable=False)
    transaction_type = Column(String(10),   nullable=False)   # 'debit' | 'credit'
    amount           = Column(Numeric(12,2),nullable=False)
    timestamp        = Column(DateTime,     server_default=func.now())
    description      = Column(String(255))


class AuditLog(db.Model):
    """Audit trail: logs access attempts and critical changes."""
    __tablename__ = 'audit_log'

    id         = Column(Integer,   primary_key=True)
    username   = Column(String(50))
    action     = Column(String(100))
    timestamp  = Column(DateTime,  server_default=func.now())
    ip_address = Column(String(45))


# Create all tables
with app.app_context():
    db.create_all()

# -------------------------
# Helper: Log audit events
# -------------------------
def log_audit(username, action):
    entry = AuditLog(
        username   = username,
        action     = action,
        ip_address = request.remote_addr
    )
    db.session.add(entry)
    db.session.commit()

# -------------------------
# Routes
# -------------------------

@app.route('/register', methods=['POST'])
def register():
    """Register a new user with a hashed password (RBAC role assigned)."""
    data           = request.get_json()
    username       = data.get('username')
    password       = data.get('password')
    account_number = data.get('account_number', '0000000000000000')
    role           = data.get('role', 'customer')

    if User.query.filter_by(username=username).first():
        return jsonify({'message': 'Username already exists'}), 409

    hashed_pw = bcrypt.generate_password_hash(password).decode('utf-8')
    new_user  = User(
        username       = username,
        password       = hashed_pw,
        account_number = account_number,
        role           = role
    )
    db.session.add(new_user)
    db.session.commit()
    log_audit(username, 'USER_REGISTERED')
    return jsonify({'message': 'User registered successfully'}), 201


@app.route('/login', methods=['POST'])
def login():
    """Authenticate user; compare password against bcrypt hash."""
    data     = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username).first()
    if user and bcrypt.check_password_hash(user.password, password):
        log_audit(username, 'LOGIN_SUCCESS')
        return jsonify({'message': 'Login successful', 'role': user.role})
    else:
        log_audit(username or 'unknown', 'LOGIN_FAILED')
        return jsonify({'message': 'Invalid credentials'}), 401


@app.route('/transaction', methods=['POST'])
def add_transaction():
    """Record a financial transaction (debit or credit)."""
    data = request.get_json()
    txn  = Transaction(
        account_number   = data.get('account_number'),
        transaction_type = data.get('type'),        # 'debit' or 'credit'
        amount           = data.get('amount'),
        description      = data.get('description', '')
    )
    db.session.add(txn)
    db.session.commit()
    log_audit(data.get('account_number'), f"TRANSACTION_{txn.transaction_type.upper()}")
    return jsonify({'message': 'Transaction recorded', 'id': txn.id}), 201


@app.route('/transactions/<account_number>', methods=['GET'])
def get_transactions(account_number):
    """Retrieve all transactions for a given account."""
    txns = Transaction.query.filter_by(account_number=account_number).all()
    result = [
        {
            'id'    : t.id,
            'type'  : t.transaction_type,
            'amount': float(t.amount),
            'time'  : str(t.timestamp),
            'desc'  : t.description
        }
        for t in txns
    ]
    log_audit(account_number, 'VIEW_TRANSACTIONS')
    return jsonify(result)


# -------------------------
# Run Application
# -------------------------
if __name__ == '__main__':
    # Use SSL cert in production; debug=False for deployment
    app.run(debug=True)
    # Example for HTTPS:
    # app.run(ssl_context=('cert.pem', 'key.pem'))
