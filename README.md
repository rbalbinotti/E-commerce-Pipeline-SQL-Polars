# E-Commerce Data Pipeline: SQL & Polars Portfolio

## Project Overview

This project demonstrates a robust Data Engineering pipeline that efficiently loads and processes Brazilian e-commerce data from CSV files into a MySQL database. The implementation leverages **Polars** for high-performance data processing and **SQLAlchemy** for database connectivity, showcasing skills in data modeling, ETL optimization, and analytical querying.

### Key Technologies

| Technology | Purpose |
|------------|---------|
| **Polars** | High-performance DataFrame library with lazy evaluation for memory-efficient ETL |
| **SQLAlchemy** | SQL toolkit and ORM for Python-MySQL connectivity |
| **MySQL** | Relational database for structured data storage and analytical queries |
| **Podman** | Container runtime for isolated, reproducible database environments |
| **uv** | Fast Python package installer and virtual environment manager |

## 🏗️ Architecture

The pipeline follows a modern data engineering workflow:

```
CSV Files (Raw) → Polars (Lazy Processing) → MySQL Database → Analytical Queries
```

### Data Model

The schema follows a star-like design with dimensions and fact tables:

```
customers ──< orders ──< order_items >── products
     │             │
     │             └──< order_payments
     │
     └── geolocation (via zip_code_prefix)

sellers ──< order_items
     │
     └── geolocation (via zip_code_prefix)

orders ──< order_reviews
```

## 🚀 Getting Started

### Prerequisites

- **Podman** or Docker (container runtime)
- **uv** (Python package manager)
- **Python 3.11+**

---

## 📦 Installation Guide

### 1. Install Podman (Linux/macOS)

#### On macOS (using Homebrew):
```bash
brew install podman
podman machine init
podman machine start
```

#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install podman podman-compose
```

#### On Fedora/RHEL:
```bash
sudo dnf install podman podman-compose
```

#### Verify Installation:
```bash
podman --version
podman-compose --version
```

---

### 2. Install uv (Python Package Manager)

#### On macOS/Linux (Recommended method):
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### On Windows (using PowerShell):
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

#### Verify Installation:
```bash
uv --version
```

---

### 3. Clone and Setup Project

```bash
# Clone the repository
git clone https://github.com/rbalbinotti/ecommerce-data-pipeline.git
cd ecommerce-data-pipeline

# Create Python virtual environment with uv
uv venv

# Activate the virtual environment
# On macOS/Linux:
source .venv/bin/activate

# On Windows:
# .venv\Scripts\activate

# Install project dependencies
uv pip install polars sqlalchemy pymysql pandas notebook
```

---

### 4. Start MySQL Database with Podman

The project includes a `compose.yaml` file for containerized MySQL deployment:

```yaml
services:
  database:
    image: docker.io/library/mysql:latest
    container_name: ecommerce-mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: Ecommerce
    volumes:
      - ./mysql_db:/var/lib/mysql:Z
    restart: always
```

#### Start the database container:
```bash
# Start MySQL container in detached mode
podman-compose up -d

# Verify container is running
podman ps
```

**Expected Output:**
```
CONTAINER ID  IMAGE                    COMMAND     CREATED         STATUS             PORTS                   NAMES
xxxxxxxxxxxx  docker.io/library/mysql  mysqld      10 seconds ago  Up 10 seconds      0.0.0.0:3306->3306/tcp  ecommerce-mysql
```

#### Stopping the database:
```bash
podman-compose down
```

---

### 5. Download Dataset

The project uses the **Brazilian E-Commerce Public Dataset (Olist)**. Download it from Kaggle:

```bash
# Create data directory
mkdir -p archive

# Download dataset (or manually download from Kaggle)
# https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
```

Expected CSV files:
- `olist_customers_dataset.csv`
- `olist_geolocation_dataset.csv`
- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `product_category_name_translation.csv`

---

### 6. Initialize Database Schema

Connect to MySQL and run the schema creation script:

```bash
# Connect to MySQL
mysql -h localhost -P 3306 -u root -prootpass
```

```sql
-- Inside MySQL client, run:
SOURCE create_tables.sql;
-- OR copy and paste the contents of create_tables.sql
```

**Expected Output:**
```
Query OK, 0 rows affected (0.01 sec)
Query OK, 0 rows affected (0.02 sec)
...
```

Alternatively, use a GUI client like DBeaver, MySQL Workbench, or TablePlus to execute the script.

---

### 7. Run the ETL Pipeline

Launch the Jupyter notebook:

```bash
# Start Jupyter Notebook
jupyter notebook sqlalchemy_en.ipynb
```

#### Step-by-step execution in the notebook:

1. **Import Libraries** - Load all required Python packages
2. **Configure Environment** - Set data source path and database connection parameters
3. **Inspect Schema** - Query MySQL metadata to verify table structure
4. **Lazy CSV Loading** - Load CSV files using `pl.scan_csv()` for memory efficiency
5. **Define Load Order** - Set correct table order respecting foreign key constraints
6. **Execute Data Load** - Run the ingestion pipeline with idempotency checks
7. **Validate Queries** - Run analytical queries to verify data integrity

---

## 📊 Data Validation Queries

The notebook includes three validation queries to demonstrate data integrity and analytical capabilities:

### Query 1: Order Details
Retrieves detailed order information including customer, product, and seller data for delivered orders.

### Query 2: Payment Summary
Aggregates payment and review data for orders with total paid amount exceeding 1000.

### Query 3: Missing Geolocation Data
Identifies customers whose zip code prefixes lack corresponding entries in the geolocation table.

---

## 🔧 Troubleshooting

### Container Issues

**Error: Port 3306 already in use**
```bash
# Check what's using port 3306
sudo lsof -i :3306  # Linux/macOS

# Stop conflicting container
podman stop <container_name>
```

**Error: Permission denied on volume**
```bash
# On Linux, fix permission for volume directory
sudo chown -R $USER:$USER ./mysql_db
```

### Database Connection Issues

**Error: Can't connect to MySQL server**
```bash
# Verify container is running
podman ps | grep ecommerce-mysql

# Check container logs
podman logs ecommerce-mysql
```

**Error: Access denied for user**
```bash
# Verify credentials in connection string
DB_USER="root"
DB_PASSWORD="rootpass"
DB_HOST="localhost"
DB_PORT="3306"
```

### Python Environment Issues

**uv not found**
```bash
# Reinstall uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or install via pip
pip install uv
```

**Module not found**
```bash
# Reinstall dependencies
uv pip install --upgrade polars sqlalchemy pymysql pandas notebook
```

---

## 📈 Performance Optimizations

### Polars Lazy Evaluation
The pipeline uses `pl.scan_csv()` to create execution plans without loading data into memory, making it efficient for large datasets.

### Idempotency Checks
Each table is checked for existing data before loading, preventing duplicate entries and ensuring reproducible runs.

### Indexing Strategy
Strategic indexes are created on foreign keys and frequently queried columns to optimize query performance.

---

## 🎯 Skills Demonstrated

- **Data Modeling**: Star schema design with proper foreign key constraints
- **ETL Pipeline**: Efficient CSV ingestion with Polars and SQLAlchemy
- **Containerization**: Isolated database environment with Podman
- **Dependency Management**: Modern Python environment with uv
- **Database Optimization**: Index creation for query performance
- **Data Quality**: Validation queries and missing data detection
- **Documentation**: Comprehensive setup and usage instructions

---

## 📝 Additional Resources

- [Polars Documentation](https://pola-rs.github.io/polars-book/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Podman Documentation](https://docs.podman.io/)
- [uv Documentation](https://docs.astral.sh/uv/)
- [Olist Dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## 📬 Contact

**Developed as part of a Data Engineering & AI Portfolio**

For questions or collaboration opportunities, please reach out via:
- LinkedIn: [[LinkedIn](https://www.linkedin.com/in/roberto-balbinotti/)]
- GitHub: [[GitHub](https://github.com/rbalbinotti)]
- Email: [balbinotti@proton.me](mailto:balbinotti@proton.me)

---

*Built with ❤️ using Python, Polars, and open-source technologies.*