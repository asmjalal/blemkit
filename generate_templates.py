#!/usr/bin/env python3
"""
Template generator for SynappKit.
Uses DeepSeek to generate UI JSON and inserts into Supabase.

Usage:
  pip install supabase openai
  python generate_templates.py
"""

import os, json, re, time
from openai import OpenAI
from supabase import create_client

SUPABASE_URL = "YOUR_SUPABASE_URL"
SUPABASE_KEY = "YOUR_SUPABASE_SERVICE_KEY"
DEEPSEEK_KEY = "YOUR_DEEPSEEK_KEY"

TEMPLATES = [
    {"name": "Shopping App",       "category": "E-Commerce", "screens": ["Home with banners and product grid", "Product Detail with image, price, add-to-cart", "Cart with item list and checkout button"]},
    {"name": "Food Delivery",      "category": "E-Commerce", "screens": ["Restaurant list with cards and categories", "Menu with items and prices", "Order tracking with status steps"]},
    {"name": "Banking Dashboard",  "category": "Finance",    "screens": ["Dashboard with balance card and quick actions", "Transaction history list", "Transfer money form"]},
    {"name": "Instagram Clone",    "category": "Social",     "screens": ["Feed with posts, likes and comments bar", "Explore grid of images", "Profile with stats and post grid"]},
    {"name": "Music Player",       "category": "Entertainment", "screens": ["Library with playlists", "Now playing with artwork and controls", "Queue list"]},
    {"name": "Fitness Tracker",    "category": "Health",     "screens": ["Dashboard with today stats", "Workout exercise list", "Progress charts"]},
    {"name": "Online Learning",    "category": "Education",  "screens": ["Course catalog grid", "Course detail with curriculum", "Video player with notes"]},
    {"name": "Ride Sharing",       "category": "Transport",  "screens": ["Map home with destination input", "Trip status with driver info", "Trip history list"]},
    {"name": "Task Manager",       "category": "Productivity","screens": ["Project board with Kanban columns", "Task detail with subtasks", "Add task form"]},
    {"name": "Meditation App",     "category": "Health",     "screens": ["Home with featured session", "Session player with timer", "Progress and streak"]},
]

SYSTEM = """You are an expert Flutter UI generator for SynappKit. Output ONLY a single minified JSON object.

SCHEMA: {"version":1,"screens":[{"name":"ScreenName","rootWidget":{...}}]}
Every node: {"id":"unique_snake","type":"TypeName","properties":{},"children":[]}

COLOR FORMAT: AARRGGBB integer string. Examples: white="4294967295" black="4278190080" grey="4280391411"
Common colors: darkBg="4279374234" cardDark="4280163899" accent="4281940984" textMuted="4287137928"

WIDGETS: Scaffold,Row,Column,Stack,Positioned,Container,SizedBox,Spacer,Expanded,Padding,Center,
Text,Icon,Image,CircleAvatar,Chip,Divider,
ElevatedButton,TextButton,IconButton,FloatingActionButton,GestureDetector,
TextField,AppBar,BottomNavigationBar,Card,ListTile,ListView,GridView,SingleChildScrollView,SafeArea,ClipRRect

RULES:
- AppBar MUST be in Scaffold appBar property
- BottomNavigationBar MUST be in Scaffold bottomNavigationBar property  
- Colors MUST be integer strings, NEVER hex or named
- Use dark premium theme: dark backgrounds, cyan/blue accents
- MINIFIED JSON only, no spaces or newlines
- Max 3 screens
- Use realistic dummy data (names, prices, etc)
- Proper padding: Padding nodes with {"left":16,"top":12,"right":16,"bottom":12}
- mainAxisAlignment and crossAxisAlignment on every Row/Column"""

def clean_json(text):
    text = re.sub(r'```json|```', '', text).strip()
    text = re.sub(r'\\([^"\\/bfnrtu])', r'\1', text)
    return text

def generate_template(client, template):
    screens_desc = "\n".join(f"- {s}" for s in template["screens"])
    prompt = f"""Create a complete {template['name']} with these 3 screens:
{screens_desc}

Use a premium dark theme. Make it look exactly like a real {template['name']}."""
    
    print(f"  Generating {template['name']}...")
    resp = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": SYSTEM},
            {"role": "user", "content": prompt}
        ],
        temperature=0.3,
        max_tokens=8192,
        response_format={"type": "json_object"},
    )
    return clean_json(resp.choices[0].message.content)

def main():
    ai = OpenAI(api_key=DEEPSEEK_KEY, base_url="https://api.deepseek.com")
    sb = create_client(SUPABASE_URL, SUPABASE_KEY)

    for t in TEMPLATES:
        try:
            raw = generate_template(ai, t)
            data = json.loads(raw)
            screens = data.get("screens", data.get("rootWidget", []))
            
            sb.table("templates").insert({
                "name": t["name"],
                "category": t["category"],
                "description": f"Complete {t['name']} template with {len(t['screens'])} screens",
                "screens_json": screens,
            }).execute()
            
            print(f"  ✅ Inserted: {t['name']}")
        except Exception as e:
            print(f"  ❌ Failed {t['name']}: {e}")
        
        time.sleep(2)  # rate limit

    print("\nDone! All templates inserted into Supabase.")

if __name__ == "__main__":
    main()
