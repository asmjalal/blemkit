import json
import glob
import os

files = glob.glob('lib/templates/*.json')

sql_lines = []
sql_lines.append("INSERT INTO public.templates (name, description, category, screens_json) VALUES")

values = []
for file in files:
    filename = os.path.basename(file)
    name = filename.replace('.json', '').replace('_', ' ').title()
    category = "General"
    if "ecommerce" in filename: category = "E-commerce"
    elif "food" in filename: category = "Food"
    elif "todo" in filename: category = "Productivity"
    elif "fitlife" in filename: category = "Fitness"
    elif "dashboard" in filename: category = "Admin"
    
    with open(file, 'r') as f:
        data = f.read()
    
    # Escape single quotes for SQL
    json_str = data.replace("'", "''")
    
    values.append(f"('{name}', 'A beautiful {category.lower()} template.', '{category}', '{json_str}'::jsonb)")

sql_lines.append(",\n".join(values) + ";")

with open('insert_templates.sql', 'w') as f:
    f.write("\n".join(sql_lines))

print("SQL generated successfully.")
