import json
import os

# Output file path
SQL_OUTPUT_PATH = "supabase/seed_data.sql"

# Premium slate colors configured for clean light theme by default
BG_DARK = "4294506744"      # 0xFFF8FAFC (Slate 50)
BG_LIGHT = "4294506744"     # 0xFFF8FAFC (Slate 50)
CARD_DARK = "4294967295"     # 0xFFFFFFFF (White)
CARD_LIGHT = "4294967295"    # 0xFFFFFFFF (White)
TEXT_LIGHT = "4279179050"    # 0xFF0F172A (Slate 900)
TEXT_DARK = "4279179050"     # 0xFF0F172A (Slate 900)
TEXT_MUTED = "4284963515"    # 0xFF64748B (Slate 500)
ACCENT_BLUE = "4283385573"   # 0xFF4F46E5 (Indigo 600)
ACCENT_INDIGO = "4283385573" # 0xFF4F46E5 (Indigo 600)
ACCENT_GREEN = "4279294337"  # 0xFF10B981 (Emerald 500)
BORDER_DARK = "4293003504"   # 0xFFE2E8F0 (Slate 200)

def node(id, widget_type, properties=None, children=None, data_binding=None):
    return {
        "id": id,
        "type": widget_type,
        "properties": properties or {},
        "children": children or [],
        **({"dataBinding": data_binding} if data_binding else {})
    }

def scaffold(id, name, app_bar=None, body=None, floating_btn=None, bnb=None, bg_color=BG_DARK):
    props = {
        "pageName": name,
        "backgroundColor": bg_color
    }
    if app_bar:
        props["appBar"] = app_bar
    if floating_btn:
        props["floatingActionButton"] = floating_btn
    if bnb:
        props["bottomNavigationBar"] = bnb
        
    return {
        "id": id,
        "type": "Scaffold",
        "properties": props,
        "children": [body] if body else []
    }

def text_node(id, text, size=14.0, color=TEXT_LIGHT, weight="normal", align="TextAlign.start", max_lines=None, binding_field=None):
    props = {
        "text": text,
        "fontSize": size,
        "color": color,
        "fontWeight": weight,
        "textAlign": align
    }
    if max_lines:
        props["maxLines"] = max_lines
        props["overflow"] = "TextOverflow.ellipsis"
    
    binding = {"text": {"field": binding_field}} if binding_field else None
    return node(id, "Text", props, data_binding=binding)

def icon_node(id, icon_name, color=TEXT_LIGHT, size=24.0):
    return node(id, "Icon", {"icon": icon_name, "color": color, "size": size})

def container_node(id, width=None, height=None, color=None, padding=None, margin=None, border_radius=0.0, children=None, bg_color=None, gradient=None):
    props = {}
    if width is not None: props["width"] = width
    if height is not None: props["height"] = height
    real_color = color or bg_color
    if real_color: props["color"] = real_color
    if padding: props["padding"] = padding
    if margin: props["margin"] = margin
    if border_radius: props["borderRadius"] = border_radius
    if gradient: props["gradient"] = gradient
    return node(id, "Container", props, children)

def row_node(id, children=None, main_align="MainAxisAlignment.start", cross_align="CrossAxisAlignment.center"):
    return node(id, "Row", {"mainAxisAlignment": main_align, "crossAxisAlignment": cross_align}, children)

def column_node(id, children=None, main_align="MainAxisAlignment.start", cross_align="CrossAxisAlignment.center", query_id=None):
    props = {"mainAxisAlignment": main_align, "crossAxisAlignment": cross_align}
    if query_id:
        props["backendQuery"] = {"queryId": query_id}
    return node(id, "Column", props, children)

def listview_node(id, children=None, padding=None, query_id=None):
    props = {}
    if padding: props["padding"] = padding
    if query_id:
        props["backendQuery"] = {"queryId": query_id}
    return node(id, "ListView", props, children)

def gridview_node(id, cross_count=2, spacing=12.0, aspect=0.8, children=None, query_id=None):
    props = {
        "crossAxisCount": cross_count,
        "crossAxisSpacing": spacing,
        "mainAxisSpacing": spacing,
        "childAspectRatio": aspect
    }
    if query_id:
        props["backendQuery"] = {"queryId": query_id}
    return node(id, "GridView", props, children)

def button_node(id, text, bg_color=ACCENT_INDIGO, fg_color=TEXT_LIGHT, height=48.0, border_radius=8.0, navigate_to=None, actions=None):
    props = {
        "text": text,
        "backgroundColor": bg_color,
        "foregroundColor": fg_color,
        "height": height,
        "borderRadius": border_radius
    }
    if actions:
        props["actions"] = actions
    elif navigate_to:
        props["actions"] = [{"type": "navigate", "targetScreenId": navigate_to}]
    return node(id, "ElevatedButton", props)

def textfield_node(id, hint, prefix_icon=None):
    props = {
        "hintText": hint,
        "filled": True,
        "fillColor": CARD_DARK,
        "border": "none"
    }
    if prefix_icon:
        props["prefixIcon"] = prefix_icon
    return node(id, "TextField", props)

def settings_node(queries=None, connection=None):
    return {
        "id": "__settings__",
        "type": "Scaffold",
        "properties": {
            "pageName": "__settings__",
            "activeConnection": connection,
            "queries": queries or []
        },
        "children": []
    }

# ----------------- TEMPLATES COMPILING -----------------

templates_data = []

# 1. E-Commerce & Retail Suite (Customer Mobile + Web Admin)
def build_ecommerce():
    screens = [
        # Customer Storefront (Mobile)
        scaffold(
            "ec_storefront", "Storefront",
            app_bar={
                "id": "ec_store_ab", "type": "AppBar",
                "properties": {
                    "backgroundColor": BG_DARK, "elevation": 0.0,
                    "title": text_node("ec_store_title", "Apex E-Store", size=18.0, weight="bold"),
                    "actions": [
                        node("ec_store_cart_btn", "IconButton", {"icon": "Icons.shopping_cart_outlined", "color": ACCENT_BLUE, "navigateTo": "ec_cart"})
                    ]
                }
            },
            body=listview_node("ec_store_scroll", [
                container_node("ec_hero", height=130.0, color=ACCENT_INDIGO, border_radius=12.0, margin={"left": 16.0, "top": 16.0, "right": 16.0, "bottom": 16.0}, children=[
                    node("ec_hero_pad", "Padding", {"padding": 16.0}, [
                        column_node("ec_hero_col", [
                            text_node("ec_hero_h1", "Limited Release Store", size=18.0, weight="bold"),
                            text_node("ec_hero_h2", "Explore top gadgets directly synced with Supabase.", size=12.0, color=TEXT_LIGHT)
                        ], cross_align="CrossAxisAlignment.start")
                    ])
                ]),
                node("ec_grid_pad", "Padding", {"padding": {"left": 16.0, "right": 16.0, "bottom": 16.0}}, [
                    gridview_node("ec_products_grid", query_id="fetch_products", children=[
                        node("ec_prod_ink", "InkWell", {"navigateTo": "ec_details"}, [
                            node("ec_prod_card", "Card", {"color": CARD_DARK, "borderRadius": 12.0}, [
                                column_node("ec_prod_col", [
                                    node("ec_prod_img", "Image", {"src": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400", "height": 110.0, "fit": "BoxFit.cover"}, data_binding={"src": {"field": "image_url"}}),
                                    node("ec_prod_info", "Padding", {"padding": 8.0}, [
                                        column_node("ec_prod_info_col", [
                                            text_node("ec_prod_name", "Product Name", size=13.0, weight="bold", binding_field="name"),
                                            text_node("ec_prod_price", "$0.00", size=12.0, color=ACCENT_BLUE, weight="bold", binding_field="price")
                                        ], cross_align="CrossAxisAlignment.start")
                                    ])
                                ], cross_align="CrossAxisAlignment.start")
                            ])
                        ])
                    ])
                ])
            ])
        ),
        # Product Details (Mobile)
        scaffold(
            "ec_details", "Product Details",
            app_bar={
                "id": "ec_det_ab", "type": "AppBar",
                "properties": {
                    "backgroundColor": BG_DARK, "elevation": 0.0,
                    "title": text_node("ec_det_title", "Product Specifications", size=16.0, weight="bold")
                }
            },
            body=column_node("ec_det_col", [
                node("ec_det_img", "Image", {"src": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400", "height": 220.0, "width": 400.0, "fit": "BoxFit.cover"}, data_binding={"src": {"field": "image_url"}}),
                node("ec_det_pad", "Padding", {"padding": 16.0}, [
                    column_node("ec_det_desc_col", [
                        text_node("ec_det_name", "Awesome Product", size=20.0, weight="bold", binding_field="name"),
                        text_node("ec_det_price", "$120.00", size=18.0, color=ACCENT_BLUE, weight="bold", binding_field="price"),
                        node("ec_det_sp1", "SizedBox", {"height": 16.0}),
                        text_node("ec_det_lbl", "Overview", size=14.0, weight="bold"),
                        text_node("ec_det_desc", "This high fidelity gadget syncs in real-time. Buy it today!", size=13.0, color=TEXT_LIGHT, binding_field="description"),
                        node("ec_det_sp2", "SizedBox", {"height": 30.0}),
                        button_node("ec_add_cart_btn", "Add to Bag", actions=[
                            {
                                "type": "supabase_insert", "tableName": "cart",
                                "payload": {
                                    "product_id": {"type": "query_data", "value": "id"},
                                    "name": {"type": "query_data", "value": "name"},
                                    "price": {"type": "query_data", "value": "price"},
                                    "image_url": {"type": "query_data", "value": "image_url"}
                                }
                            },
                            {"type": "navigate", "targetScreenId": "ec_cart"}
                        ])
                    ], cross_align="CrossAxisAlignment.start")
                ])
            ], query_id="fetch_product_details")
        ),
        # Shopping Cart (Mobile)
        scaffold(
            "ec_cart", "Shopping Cart",
            app_bar={
                "id": "ec_cart_ab", "type": "AppBar",
                "properties": {
                    "backgroundColor": BG_DARK, "elevation": 0.0,
                    "title": text_node("ec_cart_title", "My Cart", size=18.0, weight="bold")
                }
            },
            body=column_node("ec_cart_main", [
                node("ec_cart_list", "ListView", {"backendQuery": {"queryId": "fetch_cart"}, "padding": 16.0}, [
                    node("ec_cart_tile", "ListTile", {
                        "title": "Cart Item", "subtitle": "$0.00", "tileColor": CARD_DARK,
                        "leading": node("ec_cart_item_img", "Image", {"src": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100", "width": 50.0, "height": 50.0, "fit": "BoxFit.cover"}, data_binding={"src": {"field": "image_url"}}),
                        "trailing": node("ec_cart_item_del", "IconButton", {"icon": "Icons.delete_outline", "color": "4294198070", "actions": [{"type": "supabase_delete", "tableName": "cart"}]})
                    }, data_binding={"title": {"field": "name"}, "subtitle": {"field": "price"}})
                ]),
                node("ec_cart_summary", "Padding", {"padding": 16.0}, [
                    column_node("ec_cart_summary_col", [
                        button_node("ec_place_order_btn", "Submit Checkout", actions=[
                            {
                                "type": "supabase_insert", "tableName": "orders",
                                "payload": {"total_amount": {"type": "static", "value": "120.0"}, "status": {"type": "static", "value": "Pending"}}
                            },
                            {"type": "navigate", "targetScreenId": "ec_success"}
                        ])
                    ])
                ])
            ])
        ),
        # Order Success (Mobile)
        scaffold(
            "ec_success", "Success Screen",
            body=node("ec_suc_center", "Center", {}, [
                column_node("ec_suc_col", [
                    icon_node("ec_suc_icon", "Icons.check_circle_outline", color=ACCENT_GREEN, size=80.0),
                    node("ec_suc_sp1", "SizedBox", {"height": 16.0}),
                    text_node("ec_suc_h1", "Order Confirmed!", size=22.0, weight="bold"),
                    text_node("ec_suc_h2", "Your order has been logged in Supabase.", size=14.0, color=TEXT_LIGHT, align="TextAlign.center"),
                    node("ec_suc_sp2", "SizedBox", {"height": 30.0}),
                    button_node("ec_back_store_btn", "Continue Shopping", navigate_to="ec_storefront")
                ], main_align="MainAxisAlignment.center", cross_align="CrossAxisAlignment.center")
            ])
        ),
        
        # Admin Dashboard (Web/Desktop Responsive Layout)
        scaffold(
            "ec_admin_home", "Admin Dashboard",
            app_bar={
                "id": "ec_admin_ab", "type": "AppBar",
                "properties": {
                    "backgroundColor": BG_DARK, "elevation": 0.0,
                    "title": text_node("ec_admin_title", "Merchant Dashboard (Web Panel)", size=18.0, weight="bold"),
                    "actions": [
                        node("ec_admin_to_prod", "IconButton", {"icon": "Icons.inventory_outlined", "color": ACCENT_BLUE, "navigateTo": "ec_admin_products"}),
                        node("ec_admin_to_ord", "IconButton", {"icon": "Icons.receipt_long_outlined", "color": ACCENT_BLUE, "navigateTo": "ec_admin_orders"})
                    ]
                }
            },
            body=listview_node("ec_admin_scroll", [
                node("ec_admin_metrics", "Padding", {"padding": 16.0}, [
                    row_node("ec_admin_row1", [
                        container_node("ec_m1", width=160, height=100, color=CARD_DARK, border_radius=12.0, children=[
                            node("ec_m1_pad", "Padding", {"padding": 12.0}, [
                                column_node("ec_m1_col", [
                                    text_node("ec_m1_lbl", "Total Orders", size=12.0, color=TEXT_MUTED),
                                    node("ec_m1_sp", "SizedBox", {"height": 8.0}),
                                    text_node("ec_m1_val", "148", size=24.0, weight="bold", color=ACCENT_BLUE)
                                ], cross_align="CrossAxisAlignment.start")
                            ])
                        ]),
                        node("ec_admin_sp1", "SizedBox", {"width": 16.0}),
                        container_node("ec_m2", width=160, height=100, color=CARD_DARK, border_radius=12.0, children=[
                            node("ec_m2_pad", "Padding", {"padding": 12.0}, [
                                column_node("ec_m2_col", [
                                    text_node("ec_m2_lbl", "Revenue (USD)", size=12.0, color=TEXT_MUTED),
                                    node("ec_m2_sp", "SizedBox", {"height": 8.0}),
                                    text_node("ec_m2_val", "$18,450", size=24.0, weight="bold", color=ACCENT_GREEN)
                                ], cross_align="CrossAxisAlignment.start")
                            ])
                        ])
                    ], main_align="MainAxisAlignment.spaceEvenly")
                ]),
                node("ec_admin_section_lbl", "Padding", {"padding": {"left": 16.0, "top": 16.0}}, [
                    text_node("ec_adm_sec_txt", "Real-time Operations Quick Actions", size=15.0, weight="bold")
                ]),
                node("ec_admin_btns_pad", "Padding", {"padding": 16.0}, [
                    column_node("ec_adm_btns", [
                        button_node("ec_admin_manage_p", "Manage Product Inventory", bg_color=ACCENT_INDIGO, navigate_to="ec_admin_products"),
                        node("ec_admin_btn_sp", "SizedBox", {"height": 12.0}),
                        button_node("ec_admin_manage_o", "View & Process Customer Orders", bg_color=CARD_DARK, fg_color=TEXT_LIGHT, navigate_to="ec_admin_orders")
                    ])
                ])
            ])
        ),
        # Admin Products Management (Web/Desktop)
        scaffold(
            "ec_admin_products", "Inventory Manager",
            app_bar={
                "id": "ec_ap_ab", "type": "AppBar",
                "properties": {
                    "backgroundColor": BG_DARK, "elevation": 0.0,
                    "title": text_node("ec_ap_title", "Inventory Catalog", size=16.0, weight="bold")
                }
            },
            body=column_node("ec_ap_col", [
                node("ec_ap_top", "Padding", {"padding": 16.0}, [
                    row_node("ec_ap_hrow", [
                        text_node("ec_ap_head", "Products List", size=14.0, weight="bold"),
                        button_node("ec_ap_add_btn", "Add New Product", bg_color=ACCENT_GREEN, height=36.0, actions=[
                            {
                                "type": "supabase_insert", "tableName": "products",
                                "payload": {
                                    "name": {"type": "static", "value": "New Core Gadget"},
                                    "price": {"type": "static", "value": "199.99"},
                                    "description": {"type": "static", "value": "Premium added item description."},
                                    "image_url": {"type": "static", "value": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400"}
                                }
                            }
                        ])
                    ], main_align="MainAxisAlignment.spaceBetween")
                ]),
                node("ec_ap_list", "ListView", {"backendQuery": {"queryId": "fetch_products"}, "padding": 16.0}, [
                    node("ec_ap_item", "ListTile", {
                        "title": "Inventory Item", "subtitle": "$0.00", "tileColor": CARD_DARK,
                        "trailing": node("ec_ap_del", "IconButton", {"icon": "Icons.delete_outline", "color": "4294198070", "actions": [{"type": "supabase_delete", "tableName": "products"}]})
                    }, data_binding={"title": {"field": "name"}, "subtitle": {"field": "price"}})
                ])
            ])
        ),
        # Admin Orders Management (Web/Desktop)
        scaffold(
            "ec_admin_orders", "Order Fulfillment",
            app_bar={
                "id": "ec_ao_ab", "type": "AppBar",
                "properties": {
                    "backgroundColor": BG_DARK, "elevation": 0.0,
                    "title": text_node("ec_ao_title", "Sales Orders List", size=16.0, weight="bold")
                }
            },
            body=column_node("ec_ao_col", [
                node("ec_ao_list", "ListView", {"backendQuery": {"queryId": "fetch_orders"}, "padding": 16.0}, [
                    node("ec_ao_item", "ListTile", {
                        "title": "Order #XXXX", "subtitle": "Status: Pending", "tileColor": CARD_DARK,
                        "trailing": node("ec_ao_ship", "IconButton", {"icon": "Icons.local_shipping", "color": ACCENT_BLUE, "actions": [
                            {
                                "type": "supabase_insert", "tableName": "orders", # simulate status update by creating a log or simple action
                                "payload": {"total_amount": {"type": "static", "value": "120.0"}, "status": {"type": "static", "value": "Shipped"}}
                            }
                        ]})
                    }, data_binding={"title": {"field": "id"}, "subtitle": {"field": "status"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_products", "name": "Fetch Products", "tableName": "products", "queryType": "select", "selectColumns": "*", "orderBy": "created_at", "ascending": False},
            {"id": "fetch_product_details", "name": "Fetch Product Details", "tableName": "products", "queryType": "select", "selectColumns": "*", "filters": [{"column": "id", "operator": "eq", "value": "idParam"}]},
            {"id": "fetch_cart", "name": "Fetch Cart Items", "tableName": "cart", "queryType": "select", "selectColumns": "*"},
            {"id": "fetch_orders", "name": "Fetch Incoming Orders", "tableName": "orders", "queryType": "select", "selectColumns": "*", "orderBy": "created_at", "ascending": False}
        ])
    ]
    return screens

# 2. Food & Grocery Delivery Suite (Customer Mobile + Merchant Web Dashboard)
def build_food():
    screens = [
        # Customer App Home
        scaffold(
            "fd_home", "Food Delivery storefront",
            app_bar={"id": "fd_h_ab", "type": "AppBar", "properties": {"backgroundColor": BG_DARK, "elevation": 0.0, "title": text_node("fd_h_t", "FastBites Delivery", size=18.0, weight="bold")}},
            body=listview_node("fd_h_lv", [
                textfield_node("fd_search", "Search dishes or restaurants...", prefix_icon="Icons.search"),
                node("fd_cat_pad", "Padding", {"padding": 16.0}, [
                    row_node("fd_cats", [
                        container_node("fd_c1", bg_color=ACCENT_INDIGO, border_radius=10.0, padding=8.0, children=[text_node("fd_c1_t", "🍔 Burgers", size=12.0)]),
                        container_node("fd_c2", bg_color=CARD_DARK, border_radius=10.0, padding=8.0, children=[text_node("fd_c2_t", "🍕 Pizza", size=12.0)]),
                        container_node("fd_c3", bg_color=CARD_DARK, border_radius=10.0, padding=8.0, children=[text_node("fd_c3_t", "🍣 Sushi", size=12.0)])
                    ], main_align="MainAxisAlignment.spaceEvenly")
                ]),
                node("fd_grid_pad", "Padding", {"padding": 16.0}, [
                    gridview_node("fd_dishes", query_id="fetch_dishes", children=[
                        node("fd_dish_ink", "InkWell", {"navigateTo": "fd_menu_details"}, [
                            node("fd_dish_card", "Card", {"color": CARD_DARK, "borderRadius": 12.0}, [
                                column_node("fd_dish_col", [
                                    node("fd_dish_img", "Image", {"src": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400", "height": 100.0, "fit": "BoxFit.cover"}, data_binding={"src": {"field": "image_url"}}),
                                    text_node("fd_dish_name", "Dish Title", size=12.0, weight="bold", binding_field="name"),
                                    text_node("fd_dish_price", "$0.00", size=11.0, color=ACCENT_BLUE, binding_field="price")
                                ], cross_align="CrossAxisAlignment.start")
                            ])
                        ])
                    ])
                ])
            ])
        ),
        # Menu Detail
        scaffold(
            "fd_menu_details", "Dish Details",
            body=column_node("fd_det_col", [
                node("fd_det_img", "Image", {"src": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400", "height": 200.0, "width": 400.0, "fit": "BoxFit.cover"}, data_binding={"src": {"field": "image_url"}}),
                node("fd_det_pad", "Padding", {"padding": 16.0}, [
                    column_node("fd_det_info", [
                        text_node("fd_det_name", "Gourmet Meal", size=20.0, weight="bold", binding_field="name"),
                        text_node("fd_det_price", "$15.00", size=16.0, color=ACCENT_BLUE, weight="bold", binding_field="price"),
                        text_node("fd_det_desc", "Warm burger with fresh ingredients. Order hot now!", size=13.0, binding_field="description"),
                        node("fd_det_sp", "SizedBox", {"height": 30.0}),
                        button_node("fd_add_btn", "Place Delivery Order", actions=[
                            {
                                "type": "supabase_insert", "tableName": "food_orders",
                                "payload": {"dish_name": {"type": "query_data", "value": "name"}, "price": {"type": "query_data", "value": "price"}, "status": {"type": "static", "value": "Ordered"}}
                            },
                            {"type": "navigate", "targetScreenId": "fd_success"}
                        ])
                    ], cross_align="CrossAxisAlignment.start")
                ])
            ], query_id="fetch_dish_details")
        ),
        # Order Confirmed
        scaffold(
            "fd_success", "Order Status",
            body=node("fd_suc_ctr", "Center", {}, [
                column_node("fd_suc_col", [
                    icon_node("fd_suc_ic", "Icons.delivery_dining", color=ACCENT_GREEN, size=80.0),
                    text_node("fd_suc_h1", "On Its Way!", size=22.0, weight="bold"),
                    text_node("fd_suc_h2", "Your chef has started cooking your fast bite.", size=14.0),
                    button_node("fd_suc_home", "Back Storefront", navigate_to="fd_home")
                ], main_align="MainAxisAlignment.center", cross_align="CrossAxisAlignment.center")
            ])
        ),
        # Merchant Dashboard (Web Admin)
        scaffold(
            "fd_admin_home", "Kitchen Dashboard",
            app_bar={"id": "fd_a_ab", "type": "AppBar", "properties": {"backgroundColor": BG_DARK, "title": text_node("fd_a_t", "FastBites Kitchen Console", size=16.0, weight="bold")}},
            body=column_node("fd_a_body", [
                node("fd_a_list_pad", "Padding", {"padding": 16.0}, [
                    text_node("fd_a_list_lbl", "Active Cooking Orders Queue", size=14.0, weight="bold")
                ]),
                node("fd_a_orders", "ListView", {"backendQuery": {"queryId": "fetch_food_orders"}, "padding": 16.0}, [
                    node("fd_a_item", "ListTile", {
                        "title": "Burger Meal", "subtitle": "Status: Cook in progress", "tileColor": CARD_DARK,
                        "trailing": button_node("fd_a_complete", "Ready for Pickup", bg_color=ACCENT_GREEN, height=32.0, actions=[
                            {
                                "type": "supabase_insert", "tableName": "food_orders",
                                "payload": {"dish_name": {"type": "static", "value": "Order Ready"}, "status": {"type": "static", "value": "Ready"}}
                            }
                        ])
                    }, data_binding={"title": {"field": "dish_name"}, "subtitle": {"field": "status"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_dishes", "name": "Fetch Dishes", "tableName": "dishes", "queryType": "select", "selectColumns": "*"},
            {"id": "fetch_dish_details", "name": "Fetch Dish Detail", "tableName": "dishes", "queryType": "select", "selectColumns": "*", "filters": [{"column": "id", "operator": "eq", "value": "idParam"}]},
            {"id": "fetch_food_orders", "name": "Fetch Incoming Orders", "tableName": "food_orders", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 3. Banking & Finance Suite
def build_banking():
    screens = [
        scaffold(
            "bn_home", "Wallet Dashboard",
            app_bar={"id": "bn_h_ab", "type": "AppBar", "properties": {"backgroundColor": BG_DARK, "title": text_node("bn_h_t", "Apex Vault", size=18.0, weight="bold")}},
            body=listview_node("bn_h_lv", [
                container_node("bn_card", height=150.0, color=ACCENT_INDIGO, border_radius=16.0, margin=16.0, children=[
                    node("bn_c_pad", "Padding", {"padding": 16.0}, [
                        column_node("bn_c_col", [
                            text_node("bn_c_lbl", "Total Credit Balance", size=12.0),
                            text_node("bn_c_bal", "$14,820.50", size=32.0, weight="bold"),
                            node("bn_c_sp", "Spacer"),
                            row_node("bn_c_row", [
                                text_node("bn_c_num", "**** **** **** 9012", size=14.0),
                                text_node("bn_c_type", "Platinum Premium", size=14.0, weight="bold")
                            ], main_align="MainAxisAlignment.spaceBetween")
                        ], cross_align="CrossAxisAlignment.start")
                    ])
                ]),
                node("bn_act_pad", "Padding", {"padding": 16.0}, [
                    row_node("bn_actions", [
                        button_node("bn_act_send", "Send Money", bg_color=CARD_DARK, navigate_to="bn_transfer"),
                        button_node("bn_act_view", "Audits Log", bg_color=CARD_DARK, navigate_to="bn_admin_audit")
                    ], main_align="MainAxisAlignment.spaceEvenly")
                ]),
                node("bn_txs_pad", "Padding", {"padding": 16.0}, [
                    text_node("bn_txs_lbl", "Recent Transactions", size=14.0, weight="bold")
                ]),
                node("bn_txs_list", "ListView", {"backendQuery": {"queryId": "fetch_txs"}, "padding": 16.0}, [
                    node("bn_tx_tile", "ListTile", {
                        "title": "Vendor", "subtitle": "Payment", "tileColor": CARD_DARK,
                        "leading": icon_node("bn_tx_ic", "Icons.arrow_upward", color="4294198070")
                    }, data_binding={"title": {"field": "description"}, "subtitle": {"field": "amount"}})
                ])
            ])
        ),
        scaffold(
            "bn_transfer", "Send Funds",
            body=column_node("bn_t_col", [
                node("bn_t_pad", "Padding", {"padding": 24.0}, [
                    column_node("bn_t_form", [
                        text_node("bn_t_head", "Transfer Funds", size=20.0, weight="bold"),
                        node("bn_t_sp1", "SizedBox", {"height": 20.0}),
                        textfield_node("bn_t_dest", "Beneficiary Email"),
                        node("bn_t_sp2", "SizedBox", {"height": 12.0}),
                        textfield_node("bn_t_amt", "Amount (USD)"),
                        node("bn_t_sp3", "SizedBox", {"height": 30.0}),
                        button_node("bn_t_btn", "Confirm Transaction", actions=[
                            {
                                "type": "supabase_insert", "tableName": "transactions",
                                "payload": {"description": {"type": "static", "value": "Transfer to Friend"}, "amount": {"type": "static", "value": "-$50.00"}}
                            },
                            {"type": "navigate", "targetScreenId": "bn_home"}
                        ])
                    ], cross_align="CrossAxisAlignment.start")
                ])
            ])
        ),
        # Financial Auditor Dashboard (Web Admin view)
        scaffold(
            "bn_admin_audit", "Risk Control & Audit Panel",
            body=column_node("bn_a_col", [
                node("bn_a_head", "Padding", {"padding": 16.0}, [
                    text_node("bn_a_h1", "Global System Audits log", size=18.0, weight="bold")
                ]),
                node("bn_a_list", "ListView", {"backendQuery": {"queryId": "fetch_all_txs"}, "padding": 16.0}, [
                    node("bn_a_item", "ListTile", {
                        "title": "Audit log", "subtitle": "Pending check", "tileColor": CARD_DARK,
                        "trailing": button_node("bn_a_ap", "Approve", bg_color=ACCENT_GREEN, height=32.0)
                    }, data_binding={"title": {"field": "description"}, "subtitle": {"field": "amount"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_txs", "name": "Fetch Wallet Transactions", "tableName": "transactions", "queryType": "select", "selectColumns": "*"},
            {"id": "fetch_all_txs", "name": "Fetch System Logs", "tableName": "transactions", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 4. Social Media & Chat (Mobile Client + Moderator Console)
def build_social():
    screens = [
        scaffold(
            "so_home", "Activity Feed",
            app_bar={"id": "so_ab", "type": "AppBar", "properties": {"backgroundColor": BG_DARK, "title": text_node("so_title", "InstaConnect Feed", size=18.0, weight="bold")}},
            body=listview_node("so_feed", query_id="fetch_posts", children=[
                node("so_post_card", "Card", {"color": CARD_DARK, "margin": 16.0, "borderRadius": 12.0}, [
                    column_node("so_post_col", [
                        node("so_post_head", "Padding", {"padding": 12.0}, [
                            row_node("so_post_user", [
                                icon_node("so_pu_avatar", "Icons.account_circle", color=ACCENT_BLUE),
                                node("so_pu_sp", "SizedBox", {"width": 8.0}),
                                text_node("so_pu_name", "Developer User", size=14.0, weight="bold")
                            ])
                        ]),
                        node("so_post_img", "Image", {"src": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600", "height": 180.0, "fit": "BoxFit.cover"}),
                        node("so_post_foot", "Padding", {"padding": 12.0}, [
                            column_node("so_post_foot_col", [
                                text_node("so_post_caption", "Building awesome AI builders on SynappKit!", size=13.0, binding_field="caption"),
                                node("so_post_sp", "SizedBox", {"height": 8.0}),
                                row_node("so_post_actions", [
                                    icon_node("so_pa_like", "Icons.favorite_outline", color="4294198070"),
                                    node("so_pa_sp", "SizedBox", {"width": 16.0}),
                                    icon_node("so_pa_chat", "Icons.chat_bubble_outline", color=TEXT_LIGHT)
                                ])
                            ], cross_align="CrossAxisAlignment.start")
                        ])
                    ], cross_align="CrossAxisAlignment.start")
                ])
            ])
        ),
        scaffold(
            "so_moderation", "Moderator Console",
            body=column_node("so_mod_col", [
                node("so_mod_head", "Padding", {"padding": 16.0}, [
                    text_node("so_mod_h1", "Flagged Post Review Queue", size=18.0, weight="bold")
                ]),
                node("so_mod_list", "ListView", {"backendQuery": {"queryId": "fetch_posts"}, "padding": 16.0}, [
                    node("so_mod_tile", "ListTile", {
                        "title": "Post Caption", "subtitle": "Flags: Spam", "tileColor": CARD_DARK,
                        "trailing": button_node("so_mod_del", "Remove Post", bg_color="4294198070", height=32.0, actions=[
                            {"type": "supabase_delete", "tableName": "posts"}
                        ])
                    }, data_binding={"title": {"field": "caption"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_posts", "name": "Fetch Social Feed", "tableName": "posts", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 5. Healthcare & Fitness (Tracker Mobile + Coach Panel)
def build_health():
    screens = [
        scaffold(
            "he_home", "Tracker Dashboard",
            body=listview_node("he_lv", [
                node("he_hero", "Padding", {"padding": 24.0}, [
                    column_node("he_hero_col", [
                        text_node("he_h1", "Welcome back, Active!", size=14.0, color=TEXT_MUTED),
                        text_node("he_h2", "Your Fitness Metrics", size=24.0, weight="bold")
                    ], cross_align="CrossAxisAlignment.start")
                ]),
                node("he_stats", "Padding", {"padding": 16.0}, [
                    row_node("he_stats_row", [
                        container_node("he_s1", width=140, height=120, color=ACCENT_INDIGO, border_radius=12.0, children=[
                            node("he_s1_pad", "Padding", {"padding": 12.0}, [
                                column_node("he_s1_col", [
                                    icon_node("he_s1_ic", "Icons.local_fire_department", size=20.0),
                                    node("he_s1_sp", "Spacer"),
                                    text_node("he_s1_val", "820 kcal", size=18.0, weight="bold"),
                                    text_node("he_s1_lbl", "Burned", size=10.0)
                                ], cross_align="CrossAxisAlignment.start")
                            ])
                        ]),
                        container_node("he_s2", width=140, height=120, color=CARD_DARK, border_radius=12.0, children=[
                            node("he_s2_pad", "Padding", {"padding": 12.0}, [
                                column_node("he_s2_col", [
                                    icon_node("he_s2_ic", "Icons.directions_run", size=20.0),
                                    node("he_s2_sp", "Spacer"),
                                    text_node("he_s2_val", "6,400 steps", size=18.0, weight="bold"),
                                    text_node("he_s2_lbl", "Today Steps", size=10.0)
                                ], cross_align="CrossAxisAlignment.start")
                            ])
                        ])
                    ], main_align="MainAxisAlignment.spaceEvenly")
                ]),
                node("he_workouts_title", "Padding", {"padding": 16.0}, [
                    text_node("he_w_txt", "Your Workout Plan", size=15.0, weight="bold")
                ]),
                node("he_workouts_list", "ListView", {"backendQuery": {"queryId": "fetch_workouts"}, "padding": 16.0}, [
                    node("he_w_tile", "ListTile", {
                        "title": "Exercise name", "subtitle": "Duration", "tileColor": CARD_DARK,
                        "leading": icon_node("he_w_ic", "Icons.fitness_center", color=ACCENT_BLUE)
                    }, data_binding={"title": {"field": "name"}, "subtitle": {"field": "duration"}})
                ])
            ])
        ),
        scaffold(
            "he_coach", "Trainer Hub",
            body=column_node("he_c_col", [
                node("he_c_head", "Padding", {"padding": 16.0}, [
                    text_node("he_c_h1", "Assigned Workouts Dashboard", size=18.0, weight="bold"),
                    button_node("he_c_add", "Assign New Exercise", bg_color=ACCENT_GREEN, actions=[
                        {
                            "type": "supabase_insert", "tableName": "workouts",
                            "payload": {"name": {"type": "static", "value": "Power Squats"}, "duration": {"type": "static", "value": "20 mins"}}
                        }
                    ])
                ]),
                node("he_c_list", "ListView", {"backendQuery": {"queryId": "fetch_workouts"}, "padding": 16.0}, [
                    node("he_c_tile", "ListTile", {
                        "title": "Exercise name", "subtitle": "Duration", "tileColor": CARD_DARK,
                        "trailing": icon_node("he_c_del", "Icons.delete_outline", color="4294198070")
                    }, data_binding={"title": {"field": "name"}, "subtitle": {"field": "duration"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_workouts", "name": "Fetch Assigned Workouts", "tableName": "workouts", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 6. Education & Learning (Student catalog + Instructor web portal)
def build_education():
    screens = [
        scaffold(
            "ed_catalog", "Student Catalog",
            body=listview_node("ed_cat_lv", [
                node("ed_h_pad", "Padding", {"padding": 24.0}, [
                    column_node("ed_h_col", [
                        text_node("ed_h_h1", "Upgrade Your Skills", size=14.0, color=TEXT_MUTED),
                        text_node("ed_h_h2", "Apex Learning Catalog", size=24.0, weight="bold")
                    ])
                ]),
                node("ed_grid_pad", "Padding", {"padding": 16.0}, [
                    gridview_node("ed_courses", query_id="fetch_courses", children=[
                        node("ed_card", "Card", {"color": CARD_DARK, "borderRadius": 12.0}, [
                            column_node("ed_c_col", [
                                node("ed_c_img", "Image", {"src": "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400", "height": 100.0, "fit": "BoxFit.cover"}),
                                node("ed_c_info", "Padding", {"padding": 8.0}, [
                                    column_node("ed_c_info_col", [
                                        text_node("ed_c_name", "Course Name", size=13.0, weight="bold", binding_field="title"),
                                        text_node("ed_c_inst", "Instructor Name", size=11.0, color=TEXT_MUTED, binding_field="instructor")
                                    ], cross_align="CrossAxisAlignment.start")
                                ])
                            ], cross_align="CrossAxisAlignment.start")
                        ])
                    ])
                ])
            ])
        ),
        scaffold(
            "ed_instructor", "Instructor Portal",
            body=column_node("ed_inst_col", [
                node("ed_i_head", "Padding", {"padding": 16.0}, [
                    text_node("ed_i_h1", "My Published Courses", size=18.0, weight="bold"),
                    button_node("ed_i_add", "Publish New Course", bg_color=ACCENT_INDIGO, actions=[
                        {
                            "type": "supabase_insert", "tableName": "courses",
                            "payload": {"title": {"type": "static", "value": "Introduction to AI Design"}, "instructor": {"type": "static", "value": "Prof. Alan"}}
                        }
                    ])
                ]),
                node("ed_i_list", "ListView", {"backendQuery": {"queryId": "fetch_courses"}, "padding": 16.0}, [
                    node("ed_i_tile", "ListTile", {
                        "title": "Course Title", "subtitle": "Instructor", "tileColor": CARD_DARK,
                        "trailing": icon_node("ed_i_arrow", "Icons.chevron_right", color=ACCENT_BLUE)
                    }, data_binding={"title": {"field": "title"}, "subtitle": {"field": "instructor"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_courses", "name": "Fetch Course List", "tableName": "courses", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 7. Travel & Transport Suite
def build_travel():
    screens = [
        scaffold(
            "tr_home", "Travel Booking",
            body=listview_node("tr_lv", [
                node("tr_banner", "Container", {"height": 180.0, "color": ACCENT_INDIGO}, [
                    node("tr_b_pad", "Padding", {"padding": 24.0}, [
                        column_node("tr_b_col", [
                            text_node("tr_b_h1", "Where to next?", size=26.0, weight="bold"),
                            text_node("tr_b_h2", "Book premium flight tickets and stays.", size=14.0)
                        ], cross_align="CrossAxisAlignment.start")
                    ])
                ]),
                node("tr_form", "Padding", {"padding": 16.0}, [
                    column_node("tr_f_col", [
                        textfield_node("tr_from", "From City", prefix_icon="Icons.flight_takeoff"),
                        node("tr_f_sp1", "SizedBox", {"height": 12.0}),
                        textfield_node("tr_to", "Destination City", prefix_icon="Icons.flight_land"),
                        node("tr_f_sp2", "SizedBox", {"height": 20.0}),
                        button_node("tr_search_btn", "Search Flights", navigate_to="tr_flights")
                    ])
                ])
            ])
        ),
        scaffold(
            "tr_flights", "Flight Results",
            body=column_node("tr_fl_col", [
                node("tr_fl_head", "Padding", {"padding": 16.0}, [
                    text_node("tr_fl_h1", "Available Trips Results", size=16.0, weight="bold")
                ]),
                node("tr_fl_list", "ListView", {"backendQuery": {"queryId": "fetch_flights"}, "padding": 16.0}, [
                    node("tr_fl_tile", "ListTile", {
                        "title": "Flight route", "subtitle": "$0.00", "tileColor": CARD_DARK,
                        "leading": icon_node("tr_fl_ic", "Icons.local_airport", color=ACCENT_BLUE),
                        "trailing": button_node("tr_fl_book", "Book", bg_color=ACCENT_GREEN, height=32.0, actions=[
                            {
                                "type": "supabase_insert", "tableName": "flight_bookings",
                                "payload": {"flight_info": {"type": "query_data", "value": "route"}, "status": {"type": "static", "value": "Confirmed"}}
                            }
                        ])
                    }, data_binding={"title": {"field": "route"}, "subtitle": {"field": "price"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_flights", "name": "Fetch Flights", "tableName": "flights", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 8. Productivity & Tasks Suite
def build_productivity():
    screens = [
        scaffold(
            "pr_board", "Daily Kanban Board",
            body=column_node("pr_b_col", [
                node("pr_b_head", "Padding", {"padding": 24.0}, [
                    row_node("pr_b_hrow", [
                        column_node("pr_b_hcol", [
                            text_node("pr_b_h1", "Workspace Goals", size=22.0, weight="bold"),
                            text_node("pr_b_h2", "Manage your tasks and teammates.", size=12.0, color=TEXT_MUTED)
                        ], cross_align="CrossAxisAlignment.start"),
                        button_node("pr_b_add", "New Goal", bg_color=ACCENT_BLUE, height=36.0, actions=[
                            {
                                "type": "supabase_insert", "tableName": "tasks",
                                "payload": {"title": {"type": "static", "value": "Review UI Design System"}, "status": {"type": "static", "value": "Todo"}}
                            }
                        ])
                    ], main_align="MainAxisAlignment.spaceBetween")
                ]),
                node("pr_b_list", "ListView", {"backendQuery": {"queryId": "fetch_tasks"}, "padding": 16.0}, [
                    node("pr_b_tile", "ListTile", {
                        "title": "Task Title", "subtitle": "Status: Todo", "tileColor": CARD_DARK,
                        "trailing": icon_node("pr_b_arr", "Icons.arrow_forward_ios", color=ACCENT_INDIGO, size=16.0)
                    }, data_binding={"title": {"field": "title"}, "subtitle": {"field": "status"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_tasks", "name": "Fetch Kanban Tasks", "tableName": "tasks", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 9. Real Estate & Property Suite
def build_realestate():
    screens = [
        scaffold(
            "re_catalog", "Real Estate Catalog",
            body=listview_node("re_lv", [
                node("re_h_pad", "Padding", {"padding": 24.0}, [
                    column_node("re_h_col", [
                        text_node("re_h_h1", "Find Luxury Living", size=14.0, color=TEXT_MUTED),
                        text_node("re_h_h2", "Featured Estates Properties", size=24.0, weight="bold")
                    ], cross_align="CrossAxisAlignment.start")
                ]),
                node("re_grid_pad", "Padding", {"padding": 16.0}, [
                    gridview_node("re_properties", query_id="fetch_properties", children=[
                        node("re_card", "Card", {"color": CARD_DARK, "borderRadius": 12.0}, [
                            column_node("re_c_col", [
                                node("re_c_img", "Image", {"src": "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400", "height": 100.0, "fit": "BoxFit.cover"}),
                                node("re_c_info", "Padding", {"padding": 8.0}, [
                                    column_node("re_c_info_col", [
                                        text_node("re_c_name", "Luxury Mansion", size=13.0, weight="bold", binding_field="title"),
                                        text_node("re_c_price", "$0.00", size=11.0, color=ACCENT_BLUE, binding_field="price")
                                    ], cross_align="CrossAxisAlignment.start")
                                ])
                            ], cross_align="CrossAxisAlignment.start")
                        ])
                    ])
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_properties", "name": "Fetch Properties List", "tableName": "properties", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 10. Entertainment & Music Suite
def build_music():
    screens = [
        scaffold(
            "mu_library", "Playlist Hub",
            body=listview_node("mu_lv", [
                node("mu_h_pad", "Padding", {"padding": 24.0}, [
                    text_node("mu_h_t", "Your Audio Library", size=24.0, weight="bold")
                ]),
                node("mu_tracks", "ListView", {"backendQuery": {"queryId": "fetch_tracks"}, "padding": 16.0}, [
                    node("mu_t_tile", "ListTile", {
                        "title": "Track Title", "subtitle": "Artist", "tileColor": CARD_DARK,
                        "leading": icon_node("mu_t_ic", "Icons.music_note", color=ACCENT_BLUE),
                        "trailing": icon_node("mu_t_play", "Icons.play_circle_outline", color=ACCENT_INDIGO)
                    }, data_binding={"title": {"field": "title"}, "subtitle": {"field": "artist"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_tracks", "name": "Fetch Music Tracks", "tableName": "tracks", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 11. News & Blogs Suite
def build_news():
    screens = [
        scaffold(
            "ne_feed", "Article Feed",
            body=listview_node("ne_lv", query_id="fetch_articles", children=[
                node("ne_card", "Card", {"color": CARD_DARK, "margin": 16.0, "borderRadius": 12.0}, [
                    column_node("ne_col", [
                        node("ne_img", "Image", {"src": "https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=400", "height": 130.0, "fit": "BoxFit.cover"}),
                        node("ne_pad", "Padding", {"padding": 12.0}, [
                            column_node("ne_info", [
                                text_node("ne_title", "Daily Tech News Article", size=15.0, weight="bold", binding_field="title"),
                                text_node("ne_desc", "Brief outline of news content fetched in real time.", size=12.0, color=TEXT_MUTED, binding_field="summary")
                            ], cross_align="CrossAxisAlignment.start")
                        ])
                    ], cross_align="CrossAxisAlignment.start")
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_articles", "name": "Fetch News Articles", "tableName": "articles", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 12. Events & Booking Suite
def build_events():
    screens = [
        scaffold(
            "ev_catalog", "Event Discovery",
            body=listview_node("ev_lv", [
                node("ev_h_pad", "Padding", {"padding": 24.0}, [
                    text_node("ev_h_t", "Upcoming Global Events", size=24.0, weight="bold")
                ]),
                node("ev_grid_pad", "Padding", {"padding": 16.0}, [
                    gridview_node("ev_grid", query_id="fetch_events", children=[
                        node("ev_card", "Card", {"color": CARD_DARK, "borderRadius": 12.0}, [
                            column_node("ev_c_col", [
                                node("ev_c_img", "Image", {"src": "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=400", "height": 90.0, "fit": "BoxFit.cover"}),
                                node("ev_c_info", "Padding", {"padding": 8.0}, [
                                    column_node("ev_c_info_col", [
                                        text_node("ev_c_name", "Rock Festival", size=12.0, weight="bold", binding_field="title"),
                                        text_node("ev_c_date", "Date Location", size=10.0, color=TEXT_MUTED, binding_field="date")
                                    ], cross_align="CrossAxisAlignment.start")
                                ])
                            ], cross_align="CrossAxisAlignment.start")
                        ])
                    ])
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_events", "name": "Fetch Global Events", "tableName": "events", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 13. Smart Home & IoT Suite
def build_smarthome():
    screens = [
        scaffold(
            "sh_home", "Devices control room",
            body=listview_node("sh_lv", [
                node("sh_h_pad", "Padding", {"padding": 24.0}, [
                    column_node("sh_h_col", [
                        text_node("sh_h_h1", "Smart Living Administrator", size=12.0, color=TEXT_MUTED),
                        text_node("sh_h_h2", "Apex Connected Home", size=22.0, weight="bold")
                    ], cross_align="CrossAxisAlignment.start")
                ]),
                node("sh_grid_pad", "Padding", {"padding": 16.0}, [
                    gridview_node("sh_grid", query_id="fetch_devices", children=[
                        node("sh_card", "Card", {"color": CARD_DARK, "borderRadius": 12.0}, [
                            node("sh_c_pad", "Padding", {"padding": 12.0}, [
                                column_node("sh_c_col", [
                                    icon_node("sh_c_ic", "Icons.bolt", color=ACCENT_BLUE),
                                    node("sh_c_sp", "Spacer"),
                                    text_node("sh_c_name", "Device Name", size=14.0, weight="bold", binding_field="name"),
                                    text_node("sh_c_status", "Status: Active", size=11.0, color=TEXT_MUTED, binding_field="status")
                                ], cross_align="CrossAxisAlignment.start")
                            ])
                        ])
                    ])
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_devices", "name": "Fetch IoT Devices", "tableName": "devices", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens

# 14. Utilities & Tools Suite
def build_utilities():
    screens = [
        scaffold(
            "ut_home", "QR Creator Dashboard",
            body=column_node("ut_col", [
                node("ut_h_pad", "Padding", {"padding": 24.0}, [
                    text_node("ut_h_h1", "System Utilities Box", size=24.0, weight="bold")
                ]),
                node("ut_form", "Padding", {"padding": 16.0}, [
                    column_node("ut_f_col", [
                        textfield_node("ut_input", "Text payload to convert to QR"),
                        node("ut_f_sp", "SizedBox", {"height": 20.0}),
                        button_node("ut_gen_btn", "Generate System Code QR", bg_color=ACCENT_INDIGO),
                        node("ut_f_sp2", "SizedBox", {"height": 30.0}),
                        container_node("ut_qr_wrap", width=160, height=160, color=CARD_DARK, border_radius=12.0, children=[
                            node("ut_qr_pad", "Padding", {"padding": 16.0}, [
                                icon_node("ut_qr_ic", "Icons.qr_code_2", size=120.0, color=TEXT_LIGHT)
                            ])
                        ])
                    ], cross_align="CrossAxisAlignment.center")
                ])
            ])
        )
    ]
    return screens

# 15. Business & CRM Suite
def build_crm():
    screens = [
        scaffold(
            "bc_leads", "Leads List",
            body=column_node("bc_col", [
                node("bc_h_pad", "Padding", {"padding": 24.0}, [
                    row_node("bc_hrow", [
                        column_node("bc_hcol", [
                            text_node("bc_h_h1", "CRM Dashboard Pipeline", size=18.0, weight="bold"),
                            text_node("bc_h_h2", "Track prospective deals.", size=12.0, color=TEXT_MUTED)
                        ], cross_align="CrossAxisAlignment.start"),
                        button_node("bc_h_add", "New Lead", bg_color=ACCENT_GREEN, height=36.0, actions=[
                            {
                                "type": "supabase_insert", "tableName": "leads",
                                "payload": {"name": {"type": "static", "value": "Apex Corp Enterprise"}, "status": {"type": "static", "value": "Prospect"}}
                            }
                        ])
                    ], main_align="MainAxisAlignment.spaceBetween")
                ]),
                node("bc_leads_list", "ListView", {"backendQuery": {"queryId": "fetch_leads"}, "padding": 16.0}, [
                    node("bc_l_tile", "ListTile", {
                        "title": "Lead Name", "subtitle": "Pipeline: Prospect", "tileColor": CARD_DARK,
                        "leading": icon_node("bc_l_ic", "Icons.business_center", color=ACCENT_BLUE)
                    }, data_binding={"title": {"field": "name"}, "subtitle": {"field": "status"}})
                ])
            ])
        ),
        settings_node(queries=[
            {"id": "fetch_leads", "name": "Fetch Pipeline Leads", "tableName": "leads", "queryType": "select", "selectColumns": "*"}
        ])
    ]
    return screens


# 16. DigitalHR Attendance Suite
def build_attendance():
    # Helper to generate custom bottom bar with active highlights
    def make_custom_bottom_bar(active_tab):
        calendar_is_active = (active_tab == 'calendar')
        calendar_btn = node("bnb_cal", "IconButton", {
            "icon": "Icons.calendar_month", 
            "color": "#1A7BF2" if calendar_is_active else "#FFFFFF",
            "size": 26.0,
            "navigateTo": "hr_leave"
        })
        if calendar_is_active:
            calendar_btn = container_node("bnb_cal_active", width=44.0, height=44.0, color="#11233F", border_radius=22.0, children=[
                node("bnb_cal_ctr", "Center", {}, [calendar_btn])
            ])
        else:
            calendar_btn = container_node("bnb_cal_inactive", width=44.0, height=44.0, children=[
                node("bnb_cal_ctr", "Center", {}, [calendar_btn])
            ])

        home_is_active = (active_tab == 'home')
        home_btn = node("bnb_home", "IconButton", {
            "icon": "Icons.home", 
            "color": "#FFFFFF", 
            "size": 26.0,
            "navigateTo": "hr_check_in_out"
        })
        if home_is_active:
            home_btn = container_node("bnb_home_active", width=52.0, height=52.0, color="#1A7BF2", border_radius=26.0, children=[
                node("bnb_home_ctr", "Center", {}, [home_btn])
            ])
        else:
            home_btn = container_node("bnb_home_inactive", width=44.0, height=44.0, children=[
                node("bnb_home_ctr", "Center", {}, [
                    node("bnb_home_ic", "IconButton", {
                        "icon": "Icons.home", 
                        "color": "#FFFFFF", 
                        "size": 26.0,
                        "navigateTo": "hr_check_in_out"
                    })
                ])
            ])

        bell_is_active = (active_tab == 'bell')
        bell_btn = node("bnb_bell", "IconButton", {
            "icon": "Icons.notifications", 
            "color": "#1A7BF2" if bell_is_active else "#FFFFFF",
            "size": 26.0,
            "navigateTo": "hr_home"
        })
        if bell_is_active:
            bell_btn = container_node("bnb_bell_active", width=44.0, height=44.0, color="#11233F", border_radius=22.0, children=[
                node("bnb_bell_ctr", "Center", {}, [bell_btn])
            ])
        else:
            bell_btn = container_node("bnb_bell_inactive", width=44.0, height=44.0, children=[
                node("bnb_bell_ctr", "Center", {}, [bell_btn])
            ])

        return container_node("custom_bnb", 
            height=68.0, 
            color="#05152F", 
            padding={"left": 36.0, "right": 36.0}, 
            children=[
                row_node("bnb_row", [
                    calendar_btn,
                    home_btn,
                    bell_btn
                ], main_align="MainAxisAlignment.spaceBetween")
            ]
        )

    # Helper to generate standard header layout
    def make_company_header():
        return node("hdr_pad", "Padding", {"padding": {"left": 20.0, "top": 16.0, "right": 20.0, "bottom": 8.0}}, [
            row_node("hdr_row", [
                node("hdr_avatar", "CircleAvatar", {
                    "radius": 22.0, 
                    "backgroundColor": "#F59E0B",
                    "backgroundImage": "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100"
                }),
                node("hdr_sp1", "SizedBox", {"width": 12.0}),
                node("hdr_details_col", "Column", {
                    "mainAxisAlignment": "MainAxisAlignment.center",
                    "crossAxisAlignment": "CrossAxisAlignment.start"
                }, [
                    text_node("hdr_comp_name", "Company Name", size=16.0, color="#FFFFFF", weight="bold"),
                    text_node("hdr_comp_addr", "Company Address", size=12.0, color="#94A3B8")
                ]),
                node("hdr_spacer", "Spacer", {}),
                node("hdr_settings_btn", "IconButton", {
                    "icon": "Icons.settings", 
                    "color": "#FFFFFF", 
                    "size": 24.0,
                    "navigateTo": "hr_settings"
                })
            ], main_align="MainAxisAlignment.spaceBetween")
        ])

    def gradient_body(id_prefix, children):
        return container_node(f"{id_prefix}_grad_body", 
            width="double.infinity",
            height="double.infinity",
            gradient={
                "colors": ["#05152F", "#020B17"], 
                "begin": "Alignment.topCenter", 
                "end": "Alignment.bottomCenter"
            },
            children=[
                node(f"{id_prefix}_scroll", "ListView", {"padding": 0.0}, children)
            ]
        )

    screens = [
        # Screen 1: hr_login
        scaffold(
            "hr_login", "DigitalHR Login",
            bg_color="#020B17",
            body=container_node("hr_login_grad_body", 
                width="double.infinity",
                height="double.infinity",
                gradient={
                    "colors": ["#05152F", "#020B17"], 
                    "begin": "Alignment.topCenter", 
                    "end": "Alignment.bottomCenter"
                },
                children=[
                    node("hr_login_scroll", "ListView", {"padding": 24.0}, [
                        node("hr_login_top_sp", "SizedBox", {"height": 80.0}),
                        node("hr_login_logo_ctr", "Center", {}, [
                            column_node("hr_login_logo_col", [
                                node("hr_login_logo_icon", "Icon", {"icon": "Icons.fingerprint", "color": "#1A7BF2", "size": 80.0}),
                                node("hr_login_logo_sp", "SizedBox", {"height": 12.0}),
                                text_node("hr_login_logo_text", "DigitalHR", size=30.0, color="#FFFFFF", weight="bold")
                            ], cross_align="CrossAxisAlignment.center")
                        ]),
                        node("hr_login_mid_sp", "SizedBox", {"height": 60.0}),
                        text_node("hr_login_form_title", "Login", size=24.0, color="#FFFFFF", weight="bold"),
                        node("hr_login_title_sp", "SizedBox", {"height": 20.0}),
                        container_node("hr_login_email_container", height=56.0, color="#11233F", border_radius=12.0, padding={"left": 16.0, "right": 16.0}, children=[
                            row_node("hr_login_email_row", [
                                node("hr_login_email_icon", "Icon", {"icon": "Icons.email_outlined", "color": "#64748B", "size": 22.0}),
                                node("hr_login_email_sp", "SizedBox", {"width": 12.0}),
                                node("hr_login_email_exp", "Expanded", {}, [
                                    node("hr_login_email_tf", "TextField", {"hintText": "Email", "border": "none", "color": "#FFFFFF", "filled": False})
                                ])
                            ])
                        ]),
                        node("hr_login_field_sp", "SizedBox", {"height": 16.0}),
                        container_node("hr_login_pass_container", height=56.0, color="#11233F", border_radius=12.0, padding={"left": 16.0, "right": 16.0}, children=[
                            row_node("hr_login_pass_row", [
                                node("hr_login_pass_icon", "Icon", {"icon": "Icons.lock_outline", "color": "#64748B", "size": 22.0}),
                                node("hr_login_pass_sp", "SizedBox", {"width": 12.0}),
                                node("hr_login_pass_exp", "Expanded", {}, [
                                    node("hr_login_pass_tf", "TextField", {"hintText": "Password", "border": "none", "color": "#FFFFFF", "obscureText": True, "filled": False})
                                ]),
                                node("hr_login_pass_eye", "IconButton", {"icon": "Icons.visibility_off", "color": "#64748B", "size": 22.0})
                            ])
                        ]),
                        node("hr_login_btn_sp", "SizedBox", {"height": 28.0}),
                        button_node("hr_login_btn", "Login", bg_color="#1A7BF2", fg_color="#FFFFFF", border_radius=12.0, height=52.0, navigate_to="hr_login_loading")
                    ])
                ]
            )
        ),
        
        # Screen 2: hr_login_loading
        scaffold(
            "hr_login_loading", "DigitalHR Login Loading",
            bg_color="#020B17",
            body=node("hr_loading_stack", "Stack", {"alignment": "Alignment.center"}, [
                container_node("hr_loading_bg", 
                    width="double.infinity",
                    height="double.infinity",
                    gradient={
                        "colors": ["#05152F", "#020B17"], 
                        "begin": "Alignment.topCenter", 
                        "end": "Alignment.bottomCenter"
                    },
                    children=[
                        node("hr_loading_bg_scroll", "ListView", {"padding": 24.0}, [
                            node("hr_loading_bg_sp1", "SizedBox", {"height": 80.0}),
                            node("hr_loading_bg_logo", "Center", {}, [
                                column_node("hr_loading_bg_logo_col", [
                                    node("hr_loading_bg_logo_icon", "Icon", {"icon": "Icons.fingerprint", "color": "#0B4B9C", "size": 80.0}),
                                    node("hr_loading_bg_logo_sp", "SizedBox", {"height": 12.0}),
                                    text_node("hr_loading_bg_logo_text", "DigitalHR", size=30.0, color="#64748B", weight="bold")
                                ], cross_align="CrossAxisAlignment.center")
                            ]),
                            node("hr_loading_bg_sp2", "SizedBox", {"height": 60.0}),
                            text_node("hr_loading_bg_form_title", "Login", size=24.0, color="#64748B", weight="bold"),
                            node("hr_loading_bg_title_sp", "SizedBox", {"height": 20.0}),
                            container_node("hr_loading_bg_email", height=56.0, color="#0C1B31", border_radius=12.0, padding={"left": 16.0}, children=[
                                text_node("hr_loading_bg_email_val", "admin@admin.com", color="#64748B", size=16.0)
                            ]),
                            node("hr_loading_bg_field_sp", "SizedBox", {"height": 16.0}),
                            container_node("hr_loading_bg_pass", height=56.0, color="#0C1B31", border_radius=12.0, padding={"left": 16.0}, children=[
                                text_node("hr_loading_bg_pass_val", "••••••••••••••••••••", color="#64748B", size=16.0)
                            ]),
                            node("hr_loading_bg_btn_sp", "SizedBox", {"height": 28.0}),
                            container_node("hr_loading_bg_btn", height=52.0, color="#0A3E7D", border_radius=12.0, children=[
                                node("hr_loading_bg_btn_ctr", "Center", {}, [
                                    text_node("hr_loading_bg_btn_txt", "Login", color="#64748B", weight="bold", size=16.0)
                                ])
                            ])
                        ])
                    ]
                ),
                container_node("hr_loading_overlay", width="double.infinity", height="double.infinity", color="#66000000"),
                node("hr_loading_card_ink", "InkWell", {"navigateTo": "hr_home"}, [
                    container_node("hr_loading_spinner_card", width=140.0, height=140.0, color="#FFFFFF", border_radius=20.0, children=[
                        node("hr_loading_spinner_ctr", "Center", {}, [
                            container_node("hr_spinner_padding", padding=24.0, children=[
                                node("hr_spinner_indicator", "CircularProgressIndicator", {"color": "#1A7BF2", "strokeWidth": 4.0})
                            ])
                        ])
                    ])
                ])
            ])
        ),
        
        # Screen 3: hr_home (Notices)
        scaffold(
            "hr_home", "DigitalHR Notice Board",
            bg_color="#020B17",
            body=gradient_body("hr_home", [
                make_company_header(),
                node("hr_home_content", "Padding", {"padding": 20.0}, [
                    column_node("hr_home_content_col", [
                        text_node("hr_home_section_title", "Notice(s)", size=18.0, color="#FFFFFF", weight="bold"),
                        node("hr_home_sec_sp", "SizedBox", {"height": 16.0}),
                        container_node("hr_notice_card", color="#11233F", border_radius=12.0, padding=16.0, children=[
                            column_node("hr_notice_col", [
                                text_node("hr_notice_title", "Holiday Notice", size=16.0, color="#FFFFFF", weight="bold"),
                                node("hr_notice_inner_sp1", "SizedBox", {"height": 8.0}),
                                text_node("hr_notice_desc", "This is test notice", size=13.0, color="#94A3B8"),
                                node("hr_notice_inner_sp2", "SizedBox", {"height": 12.0}),
                                row_node("hr_notice_date_row", [
                                    text_node("hr_notice_date", "2024/01/07 - 2024/01/07", size=12.0, color="#94A3B8")
                                ], main_align="MainAxisAlignment.end")
                            ], cross_align="CrossAxisAlignment.start")
                        ])
                    ], cross_align="CrossAxisAlignment.start")
                ])
            ]),
            bnb=make_custom_bottom_bar("bell")
        ),
        
        # Screen 4: hr_leave
        scaffold(
            "hr_leave", "DigitalHR Leave Scheduler",
            bg_color="#020B17",
            body=gradient_body("hr_leave", [
                make_company_header(),
                node("hr_leave_content", "Padding", {"padding": 20.0}, [
                    column_node("hr_leave_content_col", [
                        row_node("hr_leave_tabs", [
                            container_node("hr_tab_upcoming", color="#11233F", border_radius=8.0, padding={"left": 16.0, "top": 8.0, "right": 16.0, "bottom": 8.0}, children=[
                                text_node("hr_tab_up_txt", "Upcoming", size=14.0, color="#FFFFFF", weight="bold")
                            ]),
                            node("hr_tab_sp", "SizedBox", {"width": 16.0}),
                            node("hr_tab_past_pad", "Padding", {"padding": {"top": 8.0, "bottom": 8.0}}, [
                                text_node("hr_tab_past_txt", "Past", size=14.0, color="#94A3B8")
                            ])
                        ]),
                        node("hr_leave_list_sp", "SizedBox", {"height": 20.0}),
                        container_node("hr_leave_card", color="#11233F", border_radius=12.0, padding=12.0, children=[
                            row_node("hr_leave_row", [
                                container_node("hr_leave_date_block", width=56.0, height=56.0, color="#1A7BF2", border_radius=8.0, children=[
                                    node("hr_leave_db_ctr", "Center", {}, [
                                        column_node("hr_leave_db_col", [
                                            text_node("hr_leave_db_day", "07", size=18.0, color="#FFFFFF", weight="bold"),
                                            text_node("hr_leave_db_month", "Jan", size=11.0, color="#FFFFFF")
                                        ], cross_align="CrossAxisAlignment.center", main_align="MainAxisAlignment.center")
                                    ])
                                ]),
                                node("hr_leave_card_sp", "SizedBox", {"width": 16.0}),
                                text_node("hr_leave_desc", "Sunday leave", size=16.0, color="#FFFFFF", weight="bold")
                            ])
                        ])
                    ], cross_align="CrossAxisAlignment.start")
                ])
            ]),
            bnb=make_custom_bottom_bar("calendar")
        ),
        
        # Screen 5: hr_check_in_out
        scaffold(
            "hr_check_in_out", "DigitalHR Check-In Board",
            bg_color="#020B17",
            body=gradient_body("hr_punch", [
                make_company_header(),
                node("hr_punch_content", "Padding", {"padding": 20.0}, [
                    column_node("hr_punch_content_col", [
                        node("hr_clock_ctr", "Center", {}, [
                            column_node("hr_clock_col", [
                                row_node("hr_clock_time_row", [
                                    text_node("hr_clock_am", "AM", size=16.0, color="#94A3B8", weight="bold"),
                                    node("hr_clock_sp1", "SizedBox", {"width": 8.0}),
                                    text_node("hr_clock_h_m", "11:04", size=48.0, color="#FFFFFF", weight="bold"),
                                    node("hr_clock_sp2", "SizedBox", {"width": 8.0}),
                                    text_node("hr_clock_sec", "53", size=18.0, color="#FFFFFF", weight="bold")
                                ], main_align="MainAxisAlignment.center"),
                                node("hr_clock_date_sp", "SizedBox", {"height": 8.0}),
                                text_node("hr_clock_date", "Sunday , January 7 , 2024", size=14.0, color="#94A3B8")
                            ], cross_align="CrossAxisAlignment.center")
                        ]),
                        node("hr_punch_banner_sp", "SizedBox", {"height": 20.0}),
                        container_node("hr_punch_banner", color="#11233F", border_radius=8.0, padding=12.0, children=[
                            text_node("hr_punch_banner_txt", "his is test notice ****** This is test notice **", size=13.0, color="#FFFFFF", align="TextAlign.center", max_lines=1)
                        ]),
                        node("hr_punch_grid_sp", "SizedBox", {"height": 20.0}),
                        row_node("hr_grid_row1", [
                            node("hr_btn_checkin_exp", "Expanded", {}, [
                                container_node("hr_btn_checkin", height=140.0, color="#1952B3", border_radius=12.0, children=[
                                    node("hr_ci_pad", "Padding", {"padding": 16.0}, [
                                        column_node("hr_ci_col", [
                                            node("hr_ci_icon", "Icon", {"icon": "Icons.qr_code_scanner", "color": "#FFFFFF", "size": 36.0}),
                                            node("hr_ci_sp1", "Spacer", {}),
                                            text_node("hr_ci_title", "Check In", size=16.0, color="#FFFFFF", weight="bold"),
                                            node("hr_ci_sp2", "SizedBox", {"height": 4.0}),
                                            text_node("hr_ci_sub", "Check-in for your attendance", size=11.0, color="#E0E7FF")
                                        ], cross_align="CrossAxisAlignment.start")
                                    ])
                                ])
                            ]),
                            node("hr_grid_gap1", "SizedBox", {"width": 16.0}),
                            node("hr_btn_checkout_exp", "Expanded", {}, [
                                container_node("hr_btn_checkout", height=140.0, color="#1B6B93", border_radius=12.0, children=[
                                    node("hr_co_pad", "Padding", {"padding": 16.0}, [
                                        column_node("hr_co_col", [
                                            node("hr_co_icon", "Icon", {"icon": "Icons.qr_code_scanner", "color": "#FFFFFF", "size": 36.0}),
                                            node("hr_co_sp1", "Spacer", {}),
                                            text_node("hr_co_title", "Check Out", size=16.0, color="#FFFFFF", weight="bold"),
                                            node("hr_co_sp2", "SizedBox", {"height": 4.0}),
                                            text_node("hr_co_sub", "Check out for your attendance", size=11.0, color="#E0F2FE")
                                        ], cross_align="CrossAxisAlignment.start")
                                    ])
                                ])
                            ])
                        ]),
                        node("hr_punch_grid_row_sp", "SizedBox", {"height": 16.0}),
                        row_node("hr_grid_row2", [
                            node("hr_btn_breakin_exp", "Expanded", {}, [
                                container_node("hr_btn_breakin", height=140.0, color="#40702B", border_radius=12.0, children=[
                                    node("hr_bi_pad", "Padding", {"padding": 16.0}, [
                                        column_node("hr_bi_col", [
                                            node("hr_bi_icon", "Icon", {"icon": "Icons.access_time", "color": "#FFFFFF", "size": 36.0}),
                                            node("hr_bi_sp1", "Spacer", {}),
                                            text_node("hr_bi_title", "Break In", size=16.0, color="#FFFFFF", weight="bold"),
                                            node("hr_bi_sp2", "SizedBox", {"height": 4.0}),
                                            text_node("hr_bi_sub", "Break-in for your attendance", size=11.0, color="#F0FDF4")
                                        ], cross_align="CrossAxisAlignment.start")
                                    ])
                                ])
                            ]),
                            node("hr_grid_gap2", "SizedBox", {"width": 16.0}),
                            node("hr_btn_breakout_exp", "Expanded", {}, [
                                container_node("hr_btn_breakout", height=140.0, color="#707A19", border_radius=12.0, children=[
                                    node("hr_bo_pad", "Padding", {"padding": 16.0}, [
                                        column_node("hr_bo_col", [
                                            node("hr_bo_icon", "Icon", {"icon": "Icons.access_time", "color": "#FFFFFF", "size": 36.0}),
                                            node("hr_bo_sp1", "Spacer", {}),
                                            text_node("hr_bo_title", "Break Out", size=16.0, color="#FFFFFF", weight="bold"),
                                            node("hr_bo_sp2", "SizedBox", {"height": 4.0}),
                                            text_node("hr_bo_sub", "Break-out for your attendance", size=11.0, color="#FEFCE8")
                                        ], cross_align="CrossAxisAlignment.start")
                                    ])
                                ])
                            ])
                        ])
                    ], cross_align="CrossAxisAlignment.stretch")
                ])
            ]),
            bnb=make_custom_bottom_bar("home")
        ),
        
        # Screen 6: hr_company_details
        scaffold(
            "hr_company_details", "DigitalHR Company Details",
            bg_color="#020B17",
            app_bar={
                "id": "hr_details_ab", "type": "AppBar",
                "properties": {
                    "backgroundColor": "#05152F", "elevation": 0.0,
                    "title": text_node("hr_details_title", "Company Details", size=18.0, color="#FFFFFF", weight="bold"),
                    "leading": node("hr_details_back", "IconButton", {
                        "icon": "Icons.arrow_back", "color": "#FFFFFF", "navigateTo": "hr_settings"
                    })
                }
            },
            body=gradient_body("hr_details", [
                node("hr_details_sp1", "SizedBox", {"height": 20.0}),
                node("hr_details_img_ctr", "Center", {}, [
                    node("hr_details_img_stack", "Stack", {"alignment": "Alignment.center"}, [
                        node("hr_details_avatar", "CircleAvatar", {
                            "radius": 54.0, 
                            "backgroundColor": "#F59E0B",
                            "backgroundImage": "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200"
                        }),
                        node("hr_details_edit_pos", "Positioned", {"bottom": 0.0, "right": 0.0}, [
                            container_node("hr_details_edit_btn", width=32.0, height=32.0, color="#1A7BF2", border_radius=16.0, children=[
                                node("hr_details_edit_ctr", "Center", {}, [
                                    node("hr_details_edit_ic", "Icon", {"icon": "Icons.edit", "color": "#FFFFFF", "size": 16.0})
                                ])
                            ])
                        ])
                    ])
                ]),
                node("hr_details_sp2", "SizedBox", {"height": 24.0}),
                
                node("hr_details_fields_pad", "Padding", {"padding": {"left": 24.0, "right": 24.0}}, [
                    column_node("hr_details_fields_col", [
                        container_node("hr_f_name", height=54.0, color="#11233F", border_radius=10.0, padding={"left": 16.0, "right": 16.0}, children=[
                            node("hr_f_name_tf", "TextField", {"hintText": "Company Name", "border": "none", "color": "#FFFFFF", "filled": False})
                        ]),
                        node("hr_f_gap1", "SizedBox", {"height": 12.0}),
                        
                        container_node("hr_f_addr", height=54.0, color="#11233F", border_radius=10.0, padding={"left": 16.0, "right": 16.0}, children=[
                            node("hr_f_addr_tf", "TextField", {"hintText": "Company Address", "border": "none", "color": "#FFFFFF", "filled": False})
                        ]),
                        node("hr_f_gap2", "SizedBox", {"height": 12.0}),
                        
                        container_node("hr_f_email1", height=54.0, color="#11233F", border_radius=10.0, padding={"left": 16.0, "right": 16.0}, children=[
                            node("hr_f_email1_tf", "TextField", {"hintText": "primary_email@gmail.com", "border": "none", "color": "#FFFFFF", "filled": False})
                        ]),
                        node("hr_f_gap3", "SizedBox", {"height": 12.0}),
                        
                        container_node("hr_f_email2", height=54.0, color="#11233F", border_radius=10.0, padding={"left": 16.0, "right": 16.0}, children=[
                            node("hr_f_email2_tf", "TextField", {"hintText": "Secondary Email", "border": "none", "color": "#FFFFFF", "filled": False})
                        ]),
                        node("hr_f_gap4", "SizedBox", {"height": 12.0}),
                        
                        container_node("hr_f_phone", height=54.0, color="#11233F", border_radius=10.0, padding={"left": 16.0, "right": 16.0}, children=[
                            node("hr_f_phone_tf", "TextField", {"hintText": "1234567890", "border": "none", "color": "#FFFFFF", "filled": False})
                        ]),
                        
                        node("hr_f_gap5", "SizedBox", {"height": 30.0}),
                        
                        button_node("hr_details_save_btn", "Save Detail", bg_color="#1A7BF2", fg_color="#FFFFFF", border_radius=12.0, height=50.0, navigate_to="hr_check_in_out")
                    ], cross_align="CrossAxisAlignment.stretch")
                ])
            ])
        ),
        
        # Screen 7: hr_settings
        scaffold(
            "hr_settings", "DigitalHR Settings",
            bg_color="#020B17",
            app_bar={
                "id": "hr_settings_ab", "type": "AppBar",
                "properties": {
                    "backgroundColor": "#05152F", "elevation": 0.0,
                    "title": text_node("hr_settings_title", "Settings", size=18.0, color="#FFFFFF", weight="bold"),
                    "leading": node("hr_settings_back", "IconButton", {
                        "icon": "Icons.arrow_back", "color": "#FFFFFF", "navigateTo": "hr_check_in_out"
                    })
                }
            },
            body=gradient_body("hr_settings", [
                node("hr_settings_sp1", "SizedBox", {"height": 40.0}),
                node("hr_settings_avatar_ctr", "Center", {}, [
                    column_node("hr_settings_avatar_col", [
                        node("hr_settings_avatar", "CircleAvatar", {
                            "radius": 60.0, 
                            "backgroundColor": "#F59E0B",
                            "backgroundImage": "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200"
                        }),
                        node("hr_settings_avatar_sp", "SizedBox", {"height": 16.0}),
                        text_node("hr_settings_comp_name", "Company Name", size=22.0, color="#FFFFFF", weight="bold")
                    ], cross_align="CrossAxisAlignment.center")
                ]),
                node("hr_settings_sp2", "SizedBox", {"height": 30.0}),
                
                node("hr_settings_form_pad", "Padding", {"padding": {"left": 24.0, "right": 24.0}}, [
                    column_node("hr_settings_form_col", [
                        container_node("hr_settings_pass_container", height=54.0, color="#11233F", border_radius=10.0, padding={"left": 16.0, "right": 16.0}, children=[
                            row_node("hr_settings_pass_row", [
                                node("hr_settings_pass_exp", "Expanded", {}, [
                                    node("hr_settings_pass_tf", "TextField", {"hintText": "Enter Password", "border": "none", "color": "#FFFFFF", "obscureText": True, "filled": False})
                                ]),
                                node("hr_settings_pass_arrow", "IconButton", {
                                    "icon": "Icons.arrow_forward", "color": "#FFFFFF", "size": 22.0, "navigateTo": "hr_company_details"
                                })
                            ])
                        ]),
                        node("hr_settings_pass_sp1", "SizedBox", {"height": 24.0}),
                        
                        node("hr_settings_pass_lbl_ctr", "Center", {}, [
                            text_node("hr_settings_pass_lbl", "Password:", size=14.0, color="#FFFFFF", weight="bold")
                        ]),
                        node("hr_settings_pass_sp2", "SizedBox", {"height": 6.0}),
                        node("hr_settings_pass_note_ctr", "Center", {}, [
                            text_node("hr_settings_pass_note", "(Password displayed only in Demo Version)", size=12.0, color="#64748B")
                        ])
                    ], cross_align="CrossAxisAlignment.stretch")
                ])
            ])
        ),
        
        settings_node(queries=[])
    ]
    return screens


# Generate catalog lists
catalog = [
    ("Premium E-Commerce Suite", "Full-featured client storefront app and merchant admin panel.", "E-Commerce & Retail", build_ecommerce()),
    ("Food & Grocery Suite", "Gourmet customer ordering client app and kitchen merchant dispatcher dashboard.", "Food & Grocery Delivery", build_food()),
    ("Apex Banking Portal", "Luxury personal credit wallet and risk controller audit board.", "Banking & Finance", build_banking()),
    ("InstaConnect Social", "User activity feeds, image shares, and admin mod post queue.", "Social Media & Chat", build_social()),
    ("FitLife Health Tracker", "User diet calorie stats tracker and trainer client planner.", "Healthcare & Fitness", build_health()),
    ("Apex Skill Academy", "Student course lists and instructor publishing panel.", "Education & Learning", build_education()),
    ("Atlas Airport Travel", "Flight lookup form and ticket status ledger.", "Travel & Transport", build_travel()),
    ("Kanban Task Master", "Team agile developer Kanban project list.", "Productivity & Tasks", build_productivity()),
    ("Apex Mansions Real Estate", "Luxury property catalog finder.", "Real Estate & Property", build_realestate()),
    ("Apex Audio Library", "Playlists streams list and artists list.", "Entertainment & Music", build_music()),
    ("Daily Chronicle Blogs", "Reader feeds and writer blog editor.", "News & Blogs", build_news()),
    ("Ticket Hub Booking", "Global event discovery board.", "Events & Booking", build_events()),
    ("Connected Smart Home", "IoT client switches control board.", "Smart Home & IoT", build_smarthome()),
    ("Developer QR Utilities", "QR generator converter.", "Utilities & Tools", build_utilities()),
    ("Apex CRM Funnel", "Corporate sales pipeline lead tracking log.", "Business & CRM", build_crm()),
    ("DigitalHR Attendance Suite", "Premium HR check-in/out tracker, notices, and leave scheduler.", "Business & CRM", build_attendance())
]

def main():
    print("Generating seed SQL queries...")
    
    sql_lines = [
        "-- Seeding templates for all 15 categories of Synappkit",
        "DELETE FROM public.templates; -- Clear existing templates before seeding",
        ""
    ]
    
    for name, desc, category, screens in catalog:
        # Convert screens JSON to String
        screens_json_str = json.dumps(screens)
        # Escape single quotes for SQL
        screens_json_escaped = screens_json_str.replace("'", "''")
        
        # Prepare subquery to resolve category_id
        cat_id_subquery = f"(SELECT id FROM public.categories WHERE name = '{category}' LIMIT 1)"
        
        sql = (
            f"INSERT INTO public.templates (name, description, category, category_id, screens_json, status) VALUES\n"
            f"('{name}', '{desc}', '{category}', {cat_id_subquery}, 'screens_escaped'::jsonb, 'published');"
        ).replace("screens_escaped", screens_json_escaped)
        
        sql_lines.append(sql)
        sql_lines.append("")
        
    # Write to SQL File
    os.makedirs(os.path.dirname(SQL_OUTPUT_PATH), exist_ok=True)
    with open(SQL_OUTPUT_PATH, "w") as f:
        f.write("\n".join(sql_lines))
        
    print(f"✅ Seeding SQL written successfully to {SQL_OUTPUT_PATH}!")

if __name__ == "__main__":
    main()
