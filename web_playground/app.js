// SQL Mastery Web Playground - App Logic

let db = null;

const INITIAL_SQL = `
CREATE TABLE teachers (
    teacher_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    subject TEXT,
    hire_date TEXT,
    salary REAL,
    department TEXT
);

INSERT INTO teachers (first_name, last_name, email, subject, hire_date, salary, department) VALUES
('Emma', 'Stone', 'emma.stone@school.com', 'Mathematics', '2021-06-10', 52000.00, 'Science'),
('Liam', 'Carter', 'liam.carter@school.com', 'History', '2020-08-15', 50000.00, 'Humanities'),
('Noah', 'Brooks', 'noah.brooks@school.com', 'Physics', '2019-02-20', 56000.00, 'Science');

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    department TEXT,
    salary REAL,
    hire_date TEXT,
    is_active INTEGER DEFAULT 1
);

INSERT INTO employees (first_name, last_name, email, department, salary, hire_date, is_active) VALUES
('John', 'Doe', 'john.doe@email.com', 'Engineering', 75000.00, '2024-01-15', 1),
('Jane', 'Smith', 'jane.smith@email.com', 'Marketing', 65000.00, '2024-02-20', 1),
('Bob', 'Johnson', 'bob.johnson@email.com', 'Engineering', 72000.00, '2024-03-01', 1),
('Alice', 'Williams', 'alice.w@email.com', 'HR', 55000.00, '2024-03-10', 1),
('Charlie', 'Brown', 'charlie.b@email.com', 'Finance', 70000.00, '2024-03-15', 0);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name TEXT NOT NULL,
    category TEXT,
    price REAL NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
);

INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('Laptop Pro 15', 'Electronics', 1299.99, 50),
('Wireless Mouse', 'Electronics', 29.99, 200),
('USB-C Hub', 'Electronics', 49.99, 150),
('Mechanical Keyboard', 'Electronics', 89.99, 100),
('Office Chair', 'Furniture', 299.99, 30),
('Standing Desk', 'Furniture', 499.99, 25),
('Notebook Pack', 'Stationery', 12.99, 500),
('Pen Set', 'Stationery', 8.99, 300);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT NOT NULL,
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    order_date TEXT DEFAULT (datetime('now')),
    total_amount REAL,
    status TEXT DEFAULT 'Pending'
);

INSERT INTO orders (customer_name, product_id, quantity, total_amount, status) VALUES
('Alice Johnson', 1, 1, 1299.99, 'Delivered'),
('Bob Smith', 2, 3, 89.97, 'Shipped'),
('Carol Davis', 4, 1, 89.99, 'Processing'),
('David Wilson', 5, 2, 599.98, 'Pending'),
('Eva Martinez', 6, 1, 499.99, 'Delivered'),
('Frank Brown', 3, 2, 99.98, 'Shipped'),
('Grace Lee', 7, 10, 129.90, 'Pending'),
('Jack Anderson', 2, 5, 149.95, 'Cancelled');
`;

const CHALLENGES = [
    {
        id: 1,
        title: "Active Employees by Salary",
        desc: "Return all active employees sorted by salary in descending order.",
        query: "SELECT employee_id, first_name, last_name, department, salary FROM employees WHERE is_active = 1 ORDER BY salary DESC;",
        minRows: 4
    },
    {
        id: 2,
        title: "Top 3 Spending Customers",
        desc: "Find the top 3 customers by total spending across all orders.",
        query: "SELECT customer_name, SUM(total_amount) AS total_spent FROM orders GROUP BY customer_name ORDER BY total_spent DESC LIMIT 3;",
        minRows: 3
    },
    {
        id: 3,
        title: "Products Stock Categorization",
        desc: "Categorize products as 'Low' (<50), 'Medium' (50-150), or 'High' (>150) based on stock quantity.",
        query: "SELECT product_name, stock_quantity, CASE WHEN stock_quantity < 50 THEN 'Low' WHEN stock_quantity BETWEEN 50 AND 150 THEN 'Medium' ELSE 'High' END AS stock_label FROM products;",
        minRows: 8
    },
    {
        id: 4,
        title: "Products Never Ordered",
        desc: "Find products that have never been referenced in any order.",
        query: "SELECT p.product_id, p.product_name FROM products p LEFT JOIN orders o ON p.product_id = o.product_id WHERE o.order_id IS NULL;",
        minRows: 1
    }
];

document.addEventListener('DOMContentLoaded', async () => {
    setupNavigation();
    await initDatabase();
    renderSchemaTree();
    setupEventListeners();
    renderChallengesList();
});

function setupNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    const tabContents = document.querySelectorAll('.tab-content');

    navItems.forEach(item => {
        item.addEventListener('click', () => {
            navItems.forEach(n => n.classList.remove('active'));
            tabContents.forEach(t => t.classList.remove('active'));

            item.classList.add('active');
            const tabId = item.getAttribute('data-tab');
            document.getElementById(tabId).classList.add('active');
        });
    });
}

async function initDatabase() {
    try {
        const config = {
            locateFile: file => `https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/${file}`
        };
        const SQL = await initSqlJs(config);
        db = new SQL.Database();
        db.run(INITIAL_SQL);
        document.getElementById('db-status-text').innerText = "Database Ready (SQLite WASM Engine)";
    } catch (err) {
        console.error("Database initialization failed:", err);
        document.getElementById('db-status-text').innerText = "Database Initialization Failed";
    }
}

function renderSchemaTree() {
    const schemaTree = document.getElementById('schema-tree');
    if (!db) return;

    try {
        const res = db.exec("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");
        if (res.length === 0) {
            schemaTree.innerHTML = "<p>No tables found.</p>";
            return;
        }

        const tables = res[0].values.map(r => r[0]);
        let html = '';

        tables.forEach(tableName => {
            const tableInfo = db.exec(`PRAGMA table_info(${tableName});`);
            const cols = tableInfo[0].values;

            html += `
                <div class="schema-table-item">
                    <div class="schema-table-title" onclick="insertSampleQuery('SELECT * FROM ${tableName};')">
                        <i class="fa-solid fa-table"></i> ${tableName}
                    </div>
                    <ul class="schema-cols">
                        ${cols.map(c => `<li>${c[1]} <i>(${c[2]})</i></li>`).join('')}
                    </ul>
                </div>
            `;
        });

        schemaTree.innerHTML = html;
    } catch (e) {
        schemaTree.innerHTML = `<p style="color: var(--accent-rose);">Error reading schema: ${e.message}</p>`;
    }
}

function setupEventListeners() {
    document.getElementById('btn-run-query').addEventListener('click', runCurrentQuery);
    document.getElementById('btn-sample-queries').addEventListener('click', () => {
        insertSampleQuery("SELECT customer_name, SUM(total_amount) AS total_spent FROM orders GROUP BY customer_name ORDER BY total_spent DESC;");
    });

    document.getElementById('btn-reset-db').addEventListener('click', async () => {
        db.run("DROP TABLE IF EXISTS teachers; DROP TABLE IF EXISTS employees; DROP TABLE IF EXISTS products; DROP TABLE IF EXISTS orders;");
        db.run(INITIAL_SQL);
        renderSchemaTree();
        alert("Database successfully reset to default state!");
    });

    const btnExport = document.getElementById('btn-export-csv');
    if (btnExport) {
        btnExport.addEventListener('click', exportToCSV);
    }

    document.getElementById('sql-input').addEventListener('keydown', (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
            e.preventDefault();
            runCurrentQuery();
        }
    });
}

function insertSampleQuery(sql) {
    const input = document.getElementById('sql-input');
    input.value = sql;
    document.getElementById('nav-editor').click();
    runCurrentQuery();
}

function runCurrentQuery() {
    const sql = document.getElementById('sql-input').value.trim();
    const outputContainer = document.getElementById('results-output');
    const statsBadge = document.getElementById('result-stats');

    if (!sql) {
        outputContainer.innerHTML = `<div class="empty-state"><p>Please enter a query to execute.</p></div>`;
        return;
    }

    try {
        const startTime = performance.now();
        const results = db.exec(sql);
        const endTime = performance.now();
        const duration = (endTime - startTime).toFixed(2);

        if (results.length === 0) {
            outputContainer.innerHTML = `
                <div style="color: var(--accent-emerald); padding: 16px;">
                    <i class="fa-solid fa-circle-check"></i> Query executed successfully. (0 rows returned, ${duration} ms)
                </div>`;
            statsBadge.innerText = `0 rows (${duration} ms)`;
            renderSchemaTree();
            return;
        }

        const columns = results[0].columns;
        const values = results[0].values;

        let tableHtml = `<table class="data-table"><thead><tr>`;
        columns.forEach(col => {
            tableHtml += `<th>${col}</th>`;
        });
        tableHtml += `</tr></thead><tbody>`;

        values.forEach(row => {
            tableHtml += `<tr>`;
            row.forEach(val => {
                tableHtml += `<td>${val !== null ? val : '<i style="color:var(--text-muted)">NULL</i>'}</td>`;
            });
            tableHtml += `</tr>`;
        });
        tableHtml += `</tbody></table>`;

        outputContainer.innerHTML = tableHtml;
        statsBadge.innerText = `${values.length} rows (${duration} ms)`;

        renderSchemaTree();
    } catch (err) {
        outputContainer.innerHTML = `
            <div style="color: var(--accent-rose); padding: 16px; background-color: rgba(239,68,68,0.1); border-radius: var(--radius-sm);">
                <strong><i class="fa-solid fa-triangle-exclamation"></i> SQL Error:</strong> ${err.message}
            </div>`;
        statsBadge.innerText = "Error";
    }
}

function renderChallengesList() {
    const listContainer = document.getElementById('challenge-list-items');
    let html = '';

    CHALLENGES.forEach((c, idx) => {
        html += `
            <div class="challenge-card-item ${idx === 0 ? 'active' : ''}" onclick="selectChallenge(${c.id})">
                <h4>#${c.id}. ${c.title}</h4>
                <p>${c.desc}</p>
            </div>
        `;
    });

    listContainer.innerHTML = html;
    if (CHALLENGES.length > 0) {
        selectChallenge(CHALLENGES[0].id);
    }
}

function selectChallenge(id) {
    const challenge = CHALLENGES.find(c => c.id === id);
    if (!challenge) return;

    const detailPanel = document.getElementById('challenge-detail-content');
    detailPanel.innerHTML = `
        <h3>#${challenge.id}. ${challenge.title}</h3>
        <p style="margin: 12px 0; color: var(--text-secondary);">${challenge.desc}</p>
        
        <div style="margin-top: 20px;">
            <button class="btn btn-primary" onclick="loadChallengeSolution('${encodeURIComponent(challenge.query)}')">
                <i class="fa-solid fa-code"></i> Load Challenge Query
            </button>
        </div>
    `;
}

function loadChallengeSolution(encodedQuery) {
    const query = decodeURIComponent(encodedQuery);
    insertSampleQuery(query);
}

function exportToCSV() {
    const table = document.querySelector('#results-output table');
    if (!table) {
        alert("No results to export.");
        return;
    }

    let csv = [];
    const rows = table.querySelectorAll('tr');
    
    for (let i = 0; i < rows.length; i++) {
        let row = [], cols = rows[i].querySelectorAll('td, th');
        for (let j = 0; j < cols.length; j++) {
            let data = cols[j].innerText.replace(/"/g, '""');
            row.push('"' + data + '"');
        }
        csv.push(row.join(','));
    }

    const csvFile = new Blob([csv.join('\n')], { type: 'text/csv' });
    const downloadLink = document.createElement('a');
    downloadLink.download = 'query_results.csv';
    downloadLink.href = window.URL.createObjectURL(csvFile);
    downloadLink.style.display = 'none';
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}

