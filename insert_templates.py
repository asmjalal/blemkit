import urllib.request
import urllib.error
import json
import time

URL = "https://yqrdwakbgywgzffcrquv.supabase.co/rest/v1/templates"
KEY = "sb_publishable_TRsLIE9_DTvXTMZBfswgTQ_XfGmsFi2"

HEADERS = {
    "apikey": KEY,
    "Authorization": f"Bearer {KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}

# Premium Light Theme Color Constants
BG_LIGHT = "4294967295"       # 0xFFFFFFFF (Pure White backdrop)
CARD_LIGHT = "4294967295"     # 0xFFFFFFFF (White cards)
TEXT_PRIMARY = "4279179050"   # 0xFF0F172A (Slate 900 text)
TEXT_MUTED = "4284963515"     # 0xFF64748B (Slate 500 subtext)
BORDER_COLOR = "4293003504"   # 0xFFE2E8F0 (Slate 200 border)
FIELD_COLOR = "4294047225"    # 0xFFF1F5F9 (Slate 100 input field)

# Soft pastels for Notes Tag Cards
PASTEL_YELLOW = "4294897802"  # 0xFFFEF08A
PASTEL_PURPLE = "4293514751"  # 0xFFE9D5FF
PASTEL_GREEN = "4290443216"   # 0xFFBBF7D0
PASTEL_BLUE = "4290903806"    # 0xFFC0F0FE

# Clean branding accent colors
COLOR_INDIGO = "4283385573"   # 0xFF4F46E5
COLOR_VIOLET = "4287323126"   # 0xFF8B5CF6
COLOR_CYAN = "4279166441"     # 0xFF0EA5E9
COLOR_EMERALD = "4279294337"  # 0xFF10B981
COLOR_ROSE = "4294197086"     # 0xFFF43F5E
COLOR_AMBER = "4294303243"    # 0xFFF59E0B

# Builder Helpers
def node(id, type_name, properties=None, children=None):
    return {
        "id": id,
        "type": type_name,
        "properties": properties or {},
        "children": children or []
    }

def ScaffoldNode(id, page_name, appBar=None, bottomNavigationBar=None, children=None):
    props = {
        "backgroundColor": BG_LIGHT,
        "pageName": page_name
    }
    if appBar:
        props["appBar"] = appBar
    if bottomNavigationBar:
        props["bottomNavigationBar"] = bottomNavigationBar
    return {
        "id": id,
        "type": "Scaffold",
        "properties": props,
        "children": children or []
    }

def AppBarNode(id, title_text, actions=None, leading=None):
    props = {
        "backgroundColor": CARD_LIGHT,
        "elevation": 0,
        "title": {
            "id": f"{id}_title",
            "type": "Text",
            "properties": {
                "text": title_text,
                "fontSize": 18,
                "color": TEXT_PRIMARY,
                "fontWeight": "bold"
            },
            "children": []
        },
        "actions": actions or []
    }
    if leading:
        props["leading"] = leading
    return {
        "id": id,
        "type": "AppBar",
        "properties": props
    }

def BottomNavBarNode(id, items):
    nav_items = []
    for i, item_data in enumerate(items):
        if len(item_data) == 3:
            icon_name, label, navigateTo = item_data
        else:
            icon_name, label = item_data
            navigateTo = None
            
        item_props = {
            "icon": {
                "id": f"{id}_item_icon_{i}",
                "type": "Icon",
                "properties": {"icon": icon_name},
                "children": []
            },
            "label": label
        }
        if navigateTo:
            item_props["navigateTo"] = navigateTo
        nav_items.append(item_props)
        
    return {
        "id": id,
        "type": "BottomNavigationBar",
        "properties": {
            "backgroundColor": CARD_LIGHT,
            "selectedItemColor": COLOR_INDIGO,
            "unselectedItemColor": TEXT_MUTED,
            "currentIndex": 0,
            "type": "fixed",
            "items": nav_items
        }
    }

def ContainerNode(id, width=None, height=None, bg_color=None, padding=None, margin=None, border_radius=None, gradient=None, border_width=None, border_color=None, children=None):
    props = {}
    if width is not None: props["width"] = width
    if height is not None: props["height"] = height
    if bg_color is not None: props["backgroundColor"] = bg_color
    if padding is not None: props["padding"] = padding
    if margin is not None: props["margin"] = margin
    if border_radius is not None: props["borderRadius"] = border_radius
    if gradient is not None: props["gradient"] = gradient
    if border_width is not None: props["borderWidth"] = border_width
    if border_color is not None: props["borderColor"] = border_color
    return node(id, "Container", props, children)

def PaddingNode(id, padding, children=None):
    return node(id, "Padding", {"padding": padding}, children)

def TextNode(id, text, font_size=None, color=None, font_weight=None, align=None, max_lines=None, overflow=None):
    props = {"text": text}
    if font_size is not None: props["fontSize"] = font_size
    if color is not None: props["color"] = color
    if font_weight is not None: props["fontWeight"] = font_weight
    if align is not None: props["textAlign"] = align
    if max_lines is not None: props["maxLines"] = max_lines
    if overflow is not None: props["overflow"] = overflow
    return node(id, "Text", props)

def IconNode(id, icon, color=None, size=None):
    props = {"icon": icon}
    if color is not None: props["color"] = color
    if size is not None: props["size"] = size
    return node(id, "Icon", props)

def IconButtonNode(id, icon, color=None, size=None, navigateTo=None):
    props = {"icon": icon}
    if color is not None: props["color"] = color
    if size is not None: props["size"] = size
    if navigateTo is not None: props["navigateTo"] = navigateTo
    return node(id, "IconButton", props)

def RowNode(id, children=None, main_axis="MainAxisAlignment.start", cross_axis="CrossAxisAlignment.center"):
    return node(id, "Row", {"mainAxisAlignment": main_axis, "crossAxisAlignment": cross_axis}, children)

def ColumnNode(id, children=None, main_axis="MainAxisAlignment.start", cross_axis="CrossAxisAlignment.center"):
    return node(id, "Column", {"mainAxisAlignment": main_axis, "crossAxisAlignment": cross_axis}, children)

def SingleChildScrollViewNode(id, children=None, scroll_direction="Axis.vertical", padding=None):
    props = {"scrollDirection": scroll_direction}
    if padding: props["padding"] = padding
    return node(id, "SingleChildScrollView", props, children)

def SizedBoxNode(id, width=None, height=None, children=None):
    props = {}
    if width is not None: props["width"] = width
    if height is not None: props["height"] = height
    return node(id, "SizedBox", props, children)

def ExpandedNode(id, child=None, flex=1):
    return node(id, "Expanded", {"flex": flex}, [child] if child else [])

def CardNode(id, color=CARD_LIGHT, border_radius=16, margin=None, elevation=0, children=None):
    props = {"color": color, "borderRadius": border_radius, "elevation": elevation}
    if margin: props["margin"] = margin
    return node(id, "Card", props, children)

def ImageNode(id, src, width=None, height=None, fit="BoxFit.cover", border_radius=None):
    props = {"src": src, "fit": fit}
    if width is not None: props["width"] = width
    if height is not None: props["height"] = height
    if border_radius is not None: props["borderRadius"] = border_radius
    return node(id, "Image", props)

def CircleAvatarNode(id, radius=24, imageUrl=None, bg_color=None):
    props = {"radius": radius}
    if imageUrl: props["imageUrl"] = imageUrl
    if bg_color: props["backgroundColor"] = bg_color
    return node(id, "CircleAvatar", props)

def DividerNode(id, color=BORDER_COLOR, thickness=1, height=16):
    return node(id, "Divider", {"color": color, "thickness": thickness, "height": height})

def ElevatedButtonNode(id, text, bg_color=COLOR_INDIGO, fg_color=CARD_LIGHT, height=48, width=None, border_radius=12, navigateTo=None):
    props = {
        "text": text,
        "backgroundColor": bg_color,
        "foregroundColor": fg_color,
        "height": height,
        "borderRadius": border_radius
    }
    if width is not None: props["width"] = width
    if navigateTo is not None: props["navigateTo"] = navigateTo
    return node(id, "ElevatedButton", props)

def TextFieldNode(id, hint_text, prefix_icon=None, filled=True, fill_color=FIELD_COLOR):
    props = {
        "hintText": hint_text,
        "filled": filled,
        "fillColor": fill_color,
        "border": "none"
    }
    if prefix_icon: props["prefixIcon"] = prefix_icon
    return node(id, "TextField", props)

def GridViewNode(id, cross_axis_count=2, cross_axis_spacing=12, main_axis_spacing=12, child_aspect_ratio=1.0, children=None):
    return node(id, "GridView", {
        "crossAxisCount": cross_axis_count,
        "crossAxisSpacing": cross_axis_spacing,
        "mainAxisSpacing": main_axis_spacing,
        "childAspectRatio": child_aspect_ratio
    }, children)

def ListViewNode(id, scroll_direction="Axis.vertical", padding=None, children=None):
    props = {"scrollDirection": scroll_direction}
    if padding: props["padding"] = padding
    return node(id, "ListView", props, children)

def GradientMap(colors, begin="Alignment.topLeft", end="Alignment.bottomRight"):
    return {
        "colors": colors,
        "begin": begin,
        "end": end
    }

def InkWellNode(id, child=None, navigateTo=None):
    props = {}
    if navigateTo is not None: props["navigateTo"] = navigateTo
    return node(id, "InkWell", props, [child] if child else [])

def SpacerNode(id):
    return node(id, "Spacer")

def CenterNode(id, child=None):
    return node(id, "Center", {}, [child] if child else [])

# ==========================================
# TEMPLATE 1: E-Commerce Store (SynShop Premium)
# ==========================================
def build_shopping_app():
    # Helper for Bottom Navigation Bar shared across Home, Favorites, and Order History
    shared_bnb = BottomNavBarNode("sa_bnb", [
        ("Icons.home", "Home", "sa_home"),
        ("Icons.favorite_outline", "Favorites", "sa_favorites"),
        ("Icons.shopping_bag_outlined", "Orders", "sa_order_history"),
        ("Icons.person_outline", "Profile", "sa_login")
    ])

    # 1. LOGIN SCREEN
    login_body = SingleChildScrollViewNode("sa_log_scsv", [
        PaddingNode("sa_log_pad", {"left": 24, "top": 60, "right": 24, "bottom": 24}, [
            ColumnNode("sa_log_col", [
                # Modern circular logo container
                ContainerNode("sa_log_logo_wrap", width=70, height=70, bg_color=COLOR_INDIGO, border_radius=35, children=[
                    PaddingNode("sa_log_logo_pad", {"left": 18, "top": 18, "right": 18, "bottom": 18}, [
                        IconNode("sa_log_logo_icon", "Icons.shopping_bag", color=CARD_LIGHT, size=34)
                    ])
                ]),
                SizedBoxNode("sa_log_sp1", height=32),
                TextNode("sa_log_title", "Welcome Back", font_size=26, font_weight="bold", color=TEXT_PRIMARY),
                SizedBoxNode("sa_log_sp2", height=8),
                TextNode("sa_log_subtitle", "Sign in to continue your premium shopping experience", font_size=14, color=TEXT_MUTED),
                SizedBoxNode("sa_log_sp3", height=40),
                
                # Input Form
                TextFieldNode("sa_log_email", "Email Address", prefix_icon="Icons.mail_outline"),
                SizedBoxNode("sa_log_sp4", height=16),
                TextFieldNode("sa_log_password", "Password", prefix_icon="Icons.lock_outline"),
                SizedBoxNode("sa_log_sp5", height=12),
                
                # Forgot password link
                RowNode("sa_log_forgot_row", [
                    SpacerNode("sa_log_forgot_sp"),
                    TextNode("sa_log_forgot_lbl", "Forgot Password?", font_size=13, color=COLOR_INDIGO, font_weight="bold")
                ]),
                SizedBoxNode("sa_log_sp6", height=32),
                
                # Sign In CTA
                ElevatedButtonNode("sa_log_btn", "Sign In", bg_color=COLOR_INDIGO, height=52, border_radius=14, navigateTo="sa_home"),
                SizedBoxNode("sa_log_sp7", height=24),
                
                # Redirect
                RowNode("sa_log_signup_row", [
                    TextNode("sa_log_signup_lbl1", "Don't have an account? ", font_size=13, color=TEXT_MUTED),
                    TextNode("sa_log_signup_lbl2", "Sign Up", font_size=13, color=COLOR_INDIGO, font_weight="bold")
                ], main_axis="MainAxisAlignment.center")
            ], cross_axis="CrossAxisAlignment.center")
        ])
    ])
    login_screen = ScaffoldNode("sa_login", "Login", children=[login_body])

    # 2. STOREFRONT (HOME) SCREEN
    home_appbar = AppBarNode("sa_home_ab", "SynShop Premium", actions=[
        IconButtonNode("sa_home_cart", "Icons.shopping_cart_outlined", color=TEXT_PRIMARY, size=24, navigateTo="sa_cart")
    ])
    
    home_body = SingleChildScrollViewNode("sa_home_scsv", [
        ColumnNode("sa_home_col", [
            PaddingNode("sa_search_pad", {"left": 16, "top": 16, "right": 16, "bottom": 8}, [
                TextFieldNode("sa_search_tf", "Search exclusive products...", "Icons.search")
            ]),
            # Hero promo banner (Linear Gradient Indigo to Cyan)
            ContainerNode(
                "sa_banner", 
                height=150, 
                border_radius=16, 
                gradient=GradientMap([COLOR_INDIGO, COLOR_CYAN]),
                margin={"left": 16, "top": 8, "right": 16, "bottom": 16}, 
                children=[
                    PaddingNode("sa_banner_pad", {"left": 24, "top": 0, "right": 24, "bottom": 0}, [
                        ColumnNode("sa_banner_col", [
                            TextNode("sa_banner_t1", "Summer Collection", font_size=20, font_weight="bold", color=CARD_LIGHT),
                            TextNode("sa_banner_t2", "Elevate your style up to 40% off", font_size=13, color=CARD_LIGHT),
                            SizedBoxNode("sa_banner_sp", height=12),
                            ElevatedButtonNode("sa_banner_btn", "Explore Now", bg_color=CARD_LIGHT, fg_color=COLOR_INDIGO, height=34, border_radius=17)
                        ], main_axis="MainAxisAlignment.center", cross_axis="CrossAxisAlignment.start")
                    ])
                ]
            ),
            PaddingNode("sa_cat_title_pad", {"left": 16, "top": 0, "right": 16, "bottom": 12}, [
                TextNode("sa_cat_title", "Shop Categories", font_size=16, font_weight="bold")
            ]),
            # Categories horizontal scroll
            SizedBoxNode("sa_cat_sb", height=42, children=[
                ListViewNode("sa_cat_lv", scroll_direction="Axis.horizontal", padding={"left": 16, "top": 0, "right": 16, "bottom": 0}, children=[
                    ContainerNode("sa_cat1", bg_color=COLOR_INDIGO, border_radius=20, padding={"left": 18, "top": 8, "right": 18, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                        TextNode("sa_cat1_t", "All Products", font_size=13, font_weight="bold", color=CARD_LIGHT)
                    ]),
                    ContainerNode("sa_cat2", bg_color=BG_LIGHT, border_radius=20, border_width=1, border_color=BORDER_COLOR, padding={"left": 18, "top": 8, "right": 18, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                        TextNode("sa_cat2_t", "Sneakers", font_size=13, color=TEXT_MUTED)
                    ]),
                    ContainerNode("sa_cat3", bg_color=BG_LIGHT, border_radius=20, border_width=1, border_color=BORDER_COLOR, padding={"left": 18, "top": 8, "right": 18, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                        TextNode("sa_cat3_t", "Apparel", font_size=13, color=TEXT_MUTED)
                    ]),
                    ContainerNode("sa_cat4", bg_color=BG_LIGHT, border_radius=20, border_width=1, border_color=BORDER_COLOR, padding={"left": 18, "top": 8, "right": 18, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                        TextNode("sa_cat4_t", "Watches", font_size=13, color=TEXT_MUTED)
                    ])
                ])
            ]),
            PaddingNode("sa_feat_pad", {"left": 16, "top": 20, "right": 16, "bottom": 12}, [
                TextNode("sa_feat_title", "Featured Products", font_size=16, font_weight="bold")
            ]),
            # Product Grid
            PaddingNode("sa_grid_pad", {"left": 16, "top": 0, "right": 16, "bottom": 16}, [
                GridViewNode("sa_grid", cross_axis_count=2, cross_axis_spacing=12, main_axis_spacing=12, child_aspect_ratio=0.68, children=[
                    InkWellNode("sa_p1_ink", CardNode("sa_p1", children=[
                        ColumnNode("sa_p1_col", [
                            ImageNode("sa_p1_img", "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400", height=130),
                            PaddingNode("sa_p1_info", {"left": 12, "top": 8, "right": 12, "bottom": 12}, [
                                ColumnNode("sa_p1_inner_col", [
                                    TextNode("sa_p1_name", "Speed Runner Red", font_size=13, font_weight="bold", max_lines=1, overflow="TextOverflow.ellipsis"),
                                    RowNode("sa_p1_rating_row", [
                                        IconNode("sa_p1_star", "Icons.star", color=COLOR_AMBER, size=14),
                                        TextNode("sa_p1_rating", " 4.9 (124)", font_size=11, color=TEXT_MUTED)
                                    ]),
                                    SizedBoxNode("sa_p1_sp", height=8),
                                    RowNode("sa_p1_price_row", [
                                        TextNode("sa_p1_price", "$120.00", font_size=14, color=COLOR_INDIGO, font_weight="bold"),
                                        IconNode("sa_p1_fav", "Icons.favorite_border", color=TEXT_MUTED, size=18)
                                    ], main_axis="MainAxisAlignment.spaceBetween")
                                ], cross_axis="CrossAxisAlignment.start")
                            ])
                        ], cross_axis="CrossAxisAlignment.start")
                    ]), navigateTo="sa_detail"),
                    
                    InkWellNode("sa_p2_ink", CardNode("sa_p2", children=[
                        ColumnNode("sa_p2_col", [
                            ImageNode("sa_p2_img", "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400", height=130),
                            PaddingNode("sa_p2_info", {"left": 12, "top": 8, "right": 12, "bottom": 12}, [
                                ColumnNode("sa_p2_inner_col", [
                                    TextNode("sa_p2_name", "Zen Chronograph", font_size=13, font_weight="bold", max_lines=1, overflow="TextOverflow.ellipsis"),
                                    RowNode("sa_p2_rating_row", [
                                        IconNode("sa_p2_star", "Icons.star", color=COLOR_AMBER, size=14),
                                        TextNode("sa_p2_rating", " 4.8 (94)", font_size=11, color=TEXT_MUTED)
                                    ]),
                                    SizedBoxNode("sa_p2_sp", height=8),
                                    RowNode("sa_p2_price_row", [
                                        TextNode("sa_p2_price", "$185.00", font_size=14, color=COLOR_INDIGO, font_weight="bold"),
                                        IconNode("sa_p2_fav", "Icons.favorite_border", color=TEXT_MUTED, size=18)
                                    ], main_axis="MainAxisAlignment.spaceBetween")
                                ], cross_axis="CrossAxisAlignment.start")
                            ])
                        ], cross_axis="CrossAxisAlignment.start")
                    ]), navigateTo="sa_detail")
                ])
            ])
        ], cross_axis="CrossAxisAlignment.start")
    ])
    home_screen = ScaffoldNode("sa_home", "Storefront", appBar=home_appbar, bottomNavigationBar=shared_bnb, children=[home_body])

    # 3. PRODUCT DETAILS SCREEN
    det_appbar = AppBarNode("sa_det_ab", "Product Details", leading=IconButtonNode("sa_det_back", "Icons.arrow_back", color=TEXT_PRIMARY, size=20, navigateTo="sa_home"))
    det_body = SingleChildScrollViewNode("sa_det_col", [
        ColumnNode("sa_det_col_inner", [
            ImageNode("sa_det_img", "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600", width="double.infinity", height=280),
            PaddingNode("sa_det_info_pad", {"left": 20, "top": 20, "right": 20, "bottom": 20}, [
                ColumnNode("sa_det_info_col", [
                    RowNode("sa_det_title_row", [
                        TextNode("sa_det_name", "Zen Chronograph", font_size=20, font_weight="bold"),
                        IconButtonNode("sa_det_fav", "Icons.favorite_border", color=COLOR_ROSE, size=24)
                    ], main_axis="MainAxisAlignment.spaceBetween"),
                    SizedBoxNode("sa_det_sp1", height=6),
                    RowNode("sa_det_rating_row", [
                        IconNode("sa_det_star", "Icons.star", color=COLOR_AMBER, size=16),
                        TextNode("sa_det_rating_t", " 4.8 (94 reviews)", font_size=13, color=TEXT_MUTED)
                    ]),
                    DividerNode("sa_det_div"),
                    TextNode("sa_det_price", "$185.00", font_size=22, color=COLOR_INDIGO, font_weight="bold"),
                    SizedBoxNode("sa_det_sp2", height=16),
                    TextNode("sa_det_size_lbl", "Select Size", font_size=14, font_weight="bold"),
                    SizedBoxNode("sa_det_sp3", height=8),
                    RowNode("sa_det_sizes", [
                        ContainerNode("sa_sz1", bg_color=BG_LIGHT, border_radius=8, border_width=1, border_color=BORDER_COLOR, padding={"left": 16, "top": 8, "right": 16, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                            TextNode("sa_sz1_t", "S", font_size=13, color=TEXT_PRIMARY, font_weight="bold")
                        ]),
                        ContainerNode("sa_sz2", bg_color=COLOR_INDIGO, border_radius=8, padding={"left": 16, "top": 8, "right": 16, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                            TextNode("sa_sz2_t", "M", font_size=13, color=CARD_LIGHT, font_weight="bold")
                        ]),
                        ContainerNode("sa_sz3", bg_color=BG_LIGHT, border_radius=8, border_width=1, border_color=BORDER_COLOR, padding={"left": 16, "top": 8, "right": 16, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                            TextNode("sa_sz3_t", "L", font_size=13, color=TEXT_PRIMARY, font_weight="bold")
                        ])
                    ]),
                    SizedBoxNode("sa_det_sp4", height=16),
                    TextNode("sa_det_desc_lbl", "Description", font_size=14, font_weight="bold"),
                    SizedBoxNode("sa_det_sp5", height=6),
                    TextNode("sa_det_desc", "Meticulously crafted premium chronograph watch with a genuine leather strap, sapphire crystal glass, and Japanese quartz movement. Water-resistant up to 50m.", font_size=13, color=TEXT_MUTED),
                    SizedBoxNode("sa_det_sp6", height=24),
                    ElevatedButtonNode("sa_det_add_btn", "Add to Shopping Cart", bg_color=COLOR_INDIGO, height=48, border_radius=12, navigateTo="sa_cart")
                ], cross_axis="CrossAxisAlignment.start")
            ])
        ], cross_axis="CrossAxisAlignment.start")
    ])
    detail_screen = ScaffoldNode("sa_detail", "Product Details", appBar=det_appbar, children=[det_body])

    # 4. SHOPPING CART SCREEN
    cart_appbar = AppBarNode("sa_cart_ab", "Shopping Cart", leading=IconButtonNode("sa_cart_back", "Icons.arrow_back", color=TEXT_PRIMARY, size=20, navigateTo="sa_home"))
    cart_body = SingleChildScrollViewNode("sa_cart_scsv", [
        ColumnNode("sa_cart_col", [
            # Cart Item List (Flat visual card)
            PaddingNode("sa_ci_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                CardNode("sa_ci1", children=[
                    RowNode("sa_ci1_row", [
                        ImageNode("sa_ci1_img", "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=150", width=80, height=80, border_radius=8),
                        SizedBoxNode("sa_ci1_wsp", width=12),
                        ExpandedNode("sa_ci1_exp", ColumnNode("sa_ci1_col", [
                            TextNode("sa_ci1_title", "Zen Chronograph", font_size=14, font_weight="bold"),
                            TextNode("sa_ci1_sz", "Size: M", font_size=11, color=TEXT_MUTED),
                            SizedBoxNode("sa_ci1_hsp", height=6),
                            RowNode("sa_ci1_ctrls", [
                                TextNode("sa_ci1_price", "$185.00", font_size=14, color=COLOR_INDIGO, font_weight="bold"),
                                RowNode("sa_ci1_qty", [
                                    IconButtonNode("sa_ci1_minus", "Icons.remove_circle_outline", color=TEXT_MUTED, size=20),
                                    TextNode("sa_ci1_qty_num", "1", font_weight="bold"),
                                    IconButtonNode("sa_ci1_plus", "Icons.add_circle_outline", color=COLOR_INDIGO, size=20)
                                ])
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ], cross_axis="CrossAxisAlignment.start"))
                    ])
                ], margin={"left": 0, "top": 0, "right": 0, "bottom": 12})
            ]),
            # Order Summary Details Card
            PaddingNode("sa_sum_pad", {"left": 16, "top": 0, "right": 16, "bottom": 24}, [
                ColumnNode("sa_sum_outer_col", [
                    CardNode("sa_sum_card", children=[
                        PaddingNode("sa_sum_inner", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                            ColumnNode("sa_sum_col", [
                                TextNode("sa_sum_title", "Order Summary", font_size=15, font_weight="bold"),
                                SizedBoxNode("sa_sum_sp1", height=12),
                                RowNode("sa_sum_row1", [
                                    TextNode("sa_sum_sb_lbl", "Subtotal", color=TEXT_MUTED),
                                    TextNode("sa_sum_sb", "$185.00", font_weight="bold")
                                ], main_axis="MainAxisAlignment.spaceBetween"),
                                SizedBoxNode("sa_sum_sp2", height=8),
                                RowNode("sa_sum_row2", [
                                    TextNode("sa_sum_ship_lbl", "Shipping", color=TEXT_MUTED),
                                    TextNode("sa_sum_ship", "$10.00", font_weight="bold")
                                ], main_axis="MainAxisAlignment.spaceBetween"),
                                DividerNode("sa_sum_div"),
                                RowNode("sa_sum_row3", [
                                    TextNode("sa_sum_tot_lbl", "Total Amount", font_size=15, font_weight="bold"),
                                    TextNode("sa_sum_tot", "$195.00", font_size=16, color=COLOR_INDIGO, font_weight="bold")
                                ], main_axis="MainAxisAlignment.spaceBetween")
                            ], cross_axis="CrossAxisAlignment.start")
                        ])
                    ]),
                    SizedBoxNode("sa_sum_sp3", height=24),
                    ElevatedButtonNode("sa_checkout_btn", "Proceed to Checkout", bg_color=COLOR_INDIGO, height=48, border_radius=12, navigateTo="sa_checkout")
                ], cross_axis="CrossAxisAlignment.stretch")
            ])
        ])
    ])
    cart_screen = ScaffoldNode("sa_cart", "Shopping Cart", appBar=cart_appbar, children=[cart_body])

    # 5. FAVORITES SCREEN
    fav_appbar = AppBarNode("sa_fav_ab", "My Favorites")
    fav_body = SingleChildScrollViewNode("sa_fav_scsv", [
        PaddingNode("sa_fav_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
            ColumnNode("sa_fav_col", [
                TextNode("sa_fav_lbl", "Saved Items (2)", font_size=15, font_weight="bold"),
                SizedBoxNode("sa_fav_sp1", height=16),
                
                # Grid of favorite items
                GridViewNode("sa_fav_grid", cross_axis_count=2, cross_axis_spacing=12, main_axis_spacing=12, child_aspect_ratio=0.68, children=[
                    CardNode("sa_f1", children=[
                        ColumnNode("sa_f1_col", [
                            ImageNode("sa_f1_img", "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400", height=130),
                            PaddingNode("sa_f1_info", {"left": 12, "top": 8, "right": 12, "bottom": 12}, [
                                ColumnNode("sa_f1_inner_col", [
                                    TextNode("sa_f1_name", "Speed Runner Red", font_size=13, font_weight="bold", max_lines=1, overflow="TextOverflow.ellipsis"),
                                    RowNode("sa_f1_rating_row", [
                                        IconNode("sa_f1_star", "Icons.star", color=COLOR_AMBER, size=14),
                                        TextNode("sa_f1_rating", " 4.9", font_size=11, color=TEXT_MUTED)
                                    ]),
                                    SizedBoxNode("sa_f1_sp", height=8),
                                    RowNode("sa_f1_price_row", [
                                        TextNode("sa_f1_price", "$120.00", font_size=14, color=COLOR_INDIGO, font_weight="bold"),
                                        IconNode("sa_f1_fav", "Icons.favorite", color=COLOR_ROSE, size=18)
                                    ], main_axis="MainAxisAlignment.spaceBetween")
                                ], cross_axis="CrossAxisAlignment.start")
                            ])
                        ], cross_axis="CrossAxisAlignment.start")
                    ]),
                    
                    CardNode("sa_f2", children=[
                        ColumnNode("sa_f2_col", [
                            ImageNode("sa_f2_img", "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400", height=130),
                            PaddingNode("sa_f2_info", {"left": 12, "top": 8, "right": 12, "bottom": 12}, [
                                ColumnNode("sa_f2_inner_col", [
                                    TextNode("sa_f2_name", "Zen Chronograph", font_size=13, font_weight="bold", max_lines=1, overflow="TextOverflow.ellipsis"),
                                    RowNode("sa_f2_rating_row", [
                                        IconNode("sa_f2_star", "Icons.star", color=COLOR_AMBER, size=14),
                                        TextNode("sa_f2_rating", " 4.8", font_size=11, color=TEXT_MUTED)
                                    ]),
                                    SizedBoxNode("sa_f2_sp", height=8),
                                    RowNode("sa_f2_price_row", [
                                        TextNode("sa_f2_price", "$185.00", font_size=14, color=COLOR_INDIGO, font_weight="bold"),
                                        IconNode("sa_f2_fav", "Icons.favorite", color=COLOR_ROSE, size=18)
                                    ], main_axis="MainAxisAlignment.spaceBetween")
                                ], cross_axis="CrossAxisAlignment.start")
                            ])
                        ], cross_axis="CrossAxisAlignment.start")
                    ])
                ])
            ], cross_axis="CrossAxisAlignment.start")
        ])
    ])
    favorites_screen = ScaffoldNode("sa_favorites", "Favorites", appBar=fav_appbar, bottomNavigationBar=shared_bnb, children=[fav_body])

    # 6. PLACE ORDER (CHECKOUT) SCREEN
    checkout_appbar = AppBarNode("sa_chk_ab", "Checkout", leading=IconButtonNode("sa_chk_back", "Icons.arrow_back", color=TEXT_PRIMARY, size=20, navigateTo="sa_cart"))
    checkout_body = SingleChildScrollViewNode("sa_chk_scsv", [
        PaddingNode("sa_chk_pad", {"left": 16, "top": 16, "right": 16, "bottom": 24}, [
            ColumnNode("sa_chk_col", [
                TextNode("sa_chk_sh_title", "Shipping Address", font_size=15, font_weight="bold"),
                SizedBoxNode("sa_chk_sp1", height=10),
                CardNode("sa_chk_addr_card", children=[
                    PaddingNode("sa_chk_addr_inner", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                        RowNode("sa_chk_addr_row", [
                            IconNode("sa_chk_pin", "Icons.location_on_outlined", color=COLOR_INDIGO, size=24),
                            SizedBoxNode("sa_chk_addr_wsp", width=12),
                            ExpandedNode("sa_chk_addr_exp", ColumnNode("sa_chk_addr_col", [
                                TextNode("sa_chk_name", "John Doe", font_size=14, font_weight="bold"),
                                SizedBoxNode("sa_chk_addr_sp", height=4),
                                TextNode("sa_chk_street", "123 Luxury Way, New York, NY 10001", font_size=12, color=TEXT_MUTED)
                            ], cross_axis="CrossAxisAlignment.start")),
                            IconButtonNode("sa_chk_addr_edit", "Icons.edit_outlined", color=TEXT_MUTED, size=20)
                        ])
                    ])
                ], margin={"left": 0, "top": 0, "right": 0, "bottom": 24}),
                
                TextNode("sa_chk_pm_title", "Payment Method", font_size=15, font_weight="bold"),
                SizedBoxNode("sa_chk_sp2", height=10),
                
                # Visual credit card with Indigo/Violet gradient
                ContainerNode("sa_chk_cc", height=160, border_radius=16, gradient=GradientMap([COLOR_INDIGO, COLOR_VIOLET]), margin={"left": 0, "top": 0, "right": 0, "bottom": 24}, children=[
                    PaddingNode("sa_chk_cc_pad", {"left": 20, "top": 20, "right": 20, "bottom": 20}, [
                        ColumnNode("sa_chk_cc_col", [
                            RowNode("sa_chk_cc_hrow", [
                                TextNode("sa_chk_cc_type", "Gold Premium Card", font_size=14, color=CARD_LIGHT, font_weight="bold"),
                                IconNode("sa_chk_cc_logo", "Icons.credit_card", color=CARD_LIGHT, size=24)
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            SpacerNode("sa_chk_cc_sp1"),
                            TextNode("sa_chk_cc_num", "**** **** **** 8899", font_size=18, color=CARD_LIGHT, font_weight="bold"),
                            SpacerNode("sa_chk_cc_sp2"),
                            RowNode("sa_chk_cc_brow", [
                                ColumnNode("sa_chk_cc_h1", [
                                    TextNode("sa_chk_cc_lbl1", "CARD HOLDER", font_size=9, color=CARD_LIGHT),
                                    TextNode("sa_chk_cc_name", "JOHN DOE", font_size=12, color=CARD_LIGHT, font_weight="bold")
                                ], cross_axis="CrossAxisAlignment.start"),
                                ColumnNode("sa_chk_cc_h2", [
                                    TextNode("sa_chk_cc_lbl2", "EXPIRES", font_size=9, color=CARD_LIGHT),
                                    TextNode("sa_chk_cc_date", "12/28", font_size=12, color=CARD_LIGHT, font_weight="bold")
                                ], cross_axis="CrossAxisAlignment.start")
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ], cross_axis="CrossAxisAlignment.stretch")
                    ])
                ]),
                
                CardNode("sa_chk_summary_card", children=[
                    PaddingNode("sa_chk_sm_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                        ColumnNode("sa_chk_sm_col", [
                            RowNode("sa_chk_sm_row1", [
                                TextNode("sa_chk_sm_lbl1", "Order Total", font_size=14, color=TEXT_MUTED),
                                TextNode("sa_chk_sm_val1", "$185.00", font_size=14, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            SizedBoxNode("sa_chk_sm_sp1", height=8),
                            RowNode("sa_chk_sm_row2", [
                                TextNode("sa_chk_sm_lbl2", "Delivery Fee", font_size=14, color=TEXT_MUTED),
                                TextNode("sa_chk_sm_val2", "$10.00", font_size=14, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            DividerNode("sa_chk_sm_div"),
                            RowNode("sa_chk_sm_row3", [
                                TextNode("sa_chk_sm_lbl3", "Payable Amount", font_size=15, font_weight="bold"),
                                TextNode("sa_chk_sm_val3", "$195.00", font_size=16, color=COLOR_INDIGO, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ])
                    ])
                ]),
                SizedBoxNode("sa_chk_sp3", height=24),
                ElevatedButtonNode("sa_chk_pay_btn", "Confirm & Place Order", bg_color=COLOR_INDIGO, height=50, border_radius=14, navigateTo="sa_success")
            ], cross_axis="CrossAxisAlignment.stretch")
        ])
    ])
    checkout_screen = ScaffoldNode("sa_checkout", "Checkout", appBar=checkout_appbar, children=[checkout_body])

    # 7. ORDER SUCCESS SCREEN
    success_body = CenterNode("sa_suc_ctr", 
        PaddingNode("sa_suc_pad", {"left": 24, "top": 0, "right": 24, "bottom": 0}, [
            ColumnNode("sa_suc_col", [
                CenterNode("sa_suc_badge_ctr", ContainerNode("sa_suc_badge", width=80, height=80, bg_color=COLOR_EMERALD, border_radius=40, children=[
                    PaddingNode("sa_suc_ic_pad", {"left": 20, "top": 20, "right": 20, "bottom": 20}, [
                        IconNode("sa_suc_check", "Icons.check", color=CARD_LIGHT, size=40)
                    ])
                ])),
                SizedBoxNode("sa_suc_sp1", height=24),
                CenterNode("sa_suc_t_ctr", TextNode("sa_suc_title", "Order Placed Successfully!", font_size=22, font_weight="bold", color=TEXT_PRIMARY)),
                SizedBoxNode("sa_suc_sp2", height=8),
                TextNode("sa_suc_subtitle", "Your order #SYN-9982 has been successfully recorded and is preparing for dispatch.", font_size=14, color=TEXT_MUTED, align="TextAlign.center"),
                SizedBoxNode("sa_suc_sp3", height=32),
                
                CardNode("sa_suc_card", children=[
                    PaddingNode("sa_suc_card_pad", {"left": 20, "top": 16, "right": 20, "bottom": 16}, [
                        ColumnNode("sa_suc_card_col", [
                            RowNode("sa_suc_cr1", [
                                TextNode("sa_suc_clbl1", "Estimated Delivery", font_size=12, color=TEXT_MUTED),
                                TextNode("sa_suc_cval1", "Tomorrow, May 21", font_size=13, font_weight="bold", color=COLOR_EMERALD)
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            SizedBoxNode("sa_suc_csp1", height=8),
                            RowNode("sa_suc_cr2", [
                                TextNode("sa_suc_clbl2", "Shipment Method", font_size=12, color=TEXT_MUTED),
                                TextNode("sa_suc_cval2", "Premium Overnight", font_size=13, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ])
                    ])
                ]),
                SizedBoxNode("sa_suc_sp4", height=40),
                ElevatedButtonNode("sa_suc_home_btn", "Continue Shopping", bg_color=COLOR_INDIGO, height=48, border_radius=12, navigateTo="sa_home"),
                SizedBoxNode("sa_suc_sp5", height=12),
                ElevatedButtonNode("sa_suc_det_btn", "View Order Details", bg_color=BG_LIGHT, fg_color=COLOR_INDIGO, height=48, border_radius=12, navigateTo="sa_order_detail")
            ], cross_axis="CrossAxisAlignment.stretch")
        ])
    )
    success_screen = ScaffoldNode("sa_success", "Order Success", children=[success_body])

    # 8. ORDER HISTORY SCREEN
    history_appbar = AppBarNode("sa_his_ab", "My Orders")
    history_body = SingleChildScrollViewNode("sa_his_scsv", [
        PaddingNode("sa_his_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
            ColumnNode("sa_his_col", [
                TextNode("sa_his_title", "Recent Orders", font_size=15, font_weight="bold"),
                SizedBoxNode("sa_his_sp1", height=16),
                
                # Active Order Card
                InkWellNode("sa_his_card1_ink", CardNode("sa_his_card1", children=[
                    PaddingNode("sa_his_c1_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                        ColumnNode("sa_his_c1_col", [
                            RowNode("sa_his_c1_r1", [
                                TextNode("sa_his_c1_num", "Order #SYN-9982", font_size=14, font_weight="bold"),
                                ContainerNode("sa_his_c1_badge", bg_color=PASTEL_BLUE, border_radius=6, padding={"left": 8, "top": 4, "right": 8, "bottom": 4}, children=[
                                    TextNode("sa_his_c1_badg_t", "In Transit", font_size=10, color=COLOR_CYAN, font_weight="bold")
                                ])
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            SizedBoxNode("sa_his_c1_sp1", height=8),
                            RowNode("sa_his_c1_r2", [
                                TextNode("sa_his_c1_date", "Placed on May 20, 2026", font_size=12, color=TEXT_MUTED),
                                TextNode("sa_his_c1_price", "$195.00", font_size=14, color=COLOR_INDIGO, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            DividerNode("sa_his_c1_div"),
                            RowNode("sa_his_c1_thumbs", [
                                ImageNode("sa_his_c1_img1", "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100", width=40, height=40, border_radius=6),
                                SizedBoxNode("sa_his_c1_wsp", width=12),
                                TextNode("sa_his_c1_qty", "Zen Chronograph (1 Item)", font_size=12, color=TEXT_PRIMARY)
                            ])
                        ], cross_axis="CrossAxisAlignment.stretch")
                    ])
                ]), navigateTo="sa_order_detail"),
                
                SizedBoxNode("sa_his_sp2", height=12),
                
                # Past Order Card
                InkWellNode("sa_his_card2_ink", CardNode("sa_his_card2", children=[
                    PaddingNode("sa_his_c2_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                        ColumnNode("sa_his_c2_col", [
                            RowNode("sa_his_c2_r1", [
                                TextNode("sa_his_c2_num", "Order #SYN-9812", font_size=14, font_weight="bold"),
                                ContainerNode("sa_his_c2_badge", bg_color=PASTEL_GREEN, border_radius=6, padding={"left": 8, "top": 4, "right": 8, "bottom": 4}, children=[
                                    TextNode("sa_his_c2_badg_t", "Delivered", font_size=10, color=COLOR_EMERALD, font_weight="bold")
                                ])
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            SizedBoxNode("sa_his_c2_sp1", height=8),
                            RowNode("sa_his_c2_r2", [
                                TextNode("sa_his_c2_date", "Placed on May 12, 2026", font_size=12, color=TEXT_MUTED),
                                TextNode("sa_his_c2_price", "$120.00", font_size=14, color=COLOR_INDIGO, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            DividerNode("sa_his_c2_div"),
                            RowNode("sa_his_c2_thumbs", [
                                ImageNode("sa_his_c2_img1", "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100", width=40, height=40, border_radius=6),
                                SizedBoxNode("sa_his_c2_wsp", width=12),
                                TextNode("sa_his_c2_qty", "Speed Runner Red (1 Item)", font_size=12, color=TEXT_PRIMARY)
                            ])
                        ], cross_axis="CrossAxisAlignment.stretch")
                    ])
                ]), navigateTo="sa_order_detail")
            ], cross_axis="CrossAxisAlignment.stretch")
        ])
    ])
    history_screen = ScaffoldNode("sa_order_history", "Order History", appBar=history_appbar, bottomNavigationBar=shared_bnb, children=[history_body])

    # 9. ORDER DETAIL SCREEN
    order_detail_appbar = AppBarNode("sa_od_ab", "Order Details", leading=IconButtonNode("sa_od_back", "Icons.arrow_back", color=TEXT_PRIMARY, size=20, navigateTo="sa_order_history"))
    order_detail_body = SingleChildScrollViewNode("sa_od_scsv", [
        PaddingNode("sa_od_pad", {"left": 16, "top": 16, "right": 16, "bottom": 24}, [
            ColumnNode("sa_od_col", [
                RowNode("sa_od_hdr", [
                    TextNode("sa_od_hdr_num", "Order #SYN-9982", font_size=15, font_weight="bold"),
                    TextNode("sa_od_hdr_dt", "May 20, 2026", font_size=12, color=TEXT_MUTED)
                ], main_axis="MainAxisAlignment.spaceBetween"),
                SizedBoxNode("sa_od_sp1", height=20),
                
                # Tracking Timeline Section
                CardNode("sa_od_track", children=[
                    PaddingNode("sa_od_track_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                        ColumnNode("sa_od_track_col", [
                            TextNode("sa_od_track_lbl", "Shipment Tracking", font_size=14, font_weight="bold"),
                            SizedBoxNode("sa_od_track_sp1", height=16),
                            
                            # Step 1: Placed
                            RowNode("sa_od_ts1", [
                                ContainerNode("sa_od_dot1", width=12, height=12, bg_color=COLOR_EMERALD, border_radius=6),
                                SizedBoxNode("sa_od_tsp1", width=12),
                                ColumnNode("sa_od_tc1", [
                                    TextNode("sa_od_tt1", "Order Placed", font_size=13, font_weight="bold"),
                                    TextNode("sa_od_tsub1", "May 20, 09:30 AM", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")
                            ]),
                            PaddingNode("sa_od_l1_pad", {"left": 5, "top": 4, "right": 0, "bottom": 4}, [
                                ContainerNode("sa_od_line1", width=2, height=20, bg_color=COLOR_EMERALD)
                            ]),
                            
                            # Step 2: Shipped
                            RowNode("sa_od_ts2", [
                                ContainerNode("sa_od_dot2", width=12, height=12, bg_color=COLOR_EMERALD, border_radius=6),
                                SizedBoxNode("sa_od_tsp2", width=12),
                                ColumnNode("sa_od_tc2", [
                                    TextNode("sa_od_tt2", "Shipped from Facility", font_size=13, font_weight="bold"),
                                    TextNode("sa_od_tsub2", "May 20, 02:45 PM", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")
                            ]),
                            PaddingNode("sa_od_l2_pad", {"left": 5, "top": 4, "right": 0, "bottom": 4}, [
                                ContainerNode("sa_od_line2", width=2, height=20, bg_color=COLOR_CYAN)
                            ]),
                            
                            # Step 3: Out for Delivery (Active step)
                            RowNode("sa_od_ts3", [
                                ContainerNode("sa_od_dot3", width=12, height=12, bg_color=COLOR_CYAN, border_radius=6),
                                SizedBoxNode("sa_od_tsp3", width=12),
                                ColumnNode("sa_od_tc3", [
                                    TextNode("sa_od_tt3", "In Transit (Near Destination)", font_size=13, font_weight="bold", color=COLOR_CYAN),
                                    TextNode("sa_od_tsub3", "May 20, 07:15 PM", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")
                            ]),
                            PaddingNode("sa_od_l3_pad", {"left": 5, "top": 4, "right": 0, "bottom": 4}, [
                                ContainerNode("sa_od_line3", width=2, height=20, bg_color=BORDER_COLOR)
                            ]),
                            
                            # Step 4: Delivered (Muted/Future step)
                            RowNode("sa_od_ts4", [
                                ContainerNode("sa_od_dot4", width=12, height=12, bg_color=BORDER_COLOR, border_radius=6),
                                SizedBoxNode("sa_od_tsp4", width=12),
                                ColumnNode("sa_od_tc4", [
                                    TextNode("sa_od_tt4", "Delivered", font_size=13, color=TEXT_MUTED),
                                    TextNode("sa_od_tsub4", "Estimated Tomorrow", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")
                            ])
                        ], cross_axis="CrossAxisAlignment.stretch")
                    ])
                ]),
                SizedBoxNode("sa_od_sp2", height=16),
                
                # Items card
                CardNode("sa_od_items", children=[
                    PaddingNode("sa_od_items_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                        ColumnNode("sa_od_items_col", [
                            TextNode("sa_od_items_lbl", "Items Purchased", font_size=14, font_weight="bold"),
                            SizedBoxNode("sa_od_items_sp1", height=12),
                            RowNode("sa_od_item1", [
                                ImageNode("sa_od_item1_img", "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100", width=50, height=50, border_radius=6),
                                SizedBoxNode("sa_od_item1_wsp", width=12),
                                ExpandedNode("sa_od_item1_exp", ColumnNode("sa_od_item1_col", [
                                    TextNode("sa_od_item1_title", "Zen Chronograph", font_size=13, font_weight="bold"),
                                    TextNode("sa_od_item1_sz", "Size: M", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")),
                                TextNode("sa_od_item1_price", "$185.00", font_size=13, font_weight="bold")
                            ])
                        ], cross_axis="CrossAxisAlignment.stretch")
                    ])
                ]),
                SizedBoxNode("sa_od_sp3", height=16),
                
                # Price info summary card
                CardNode("sa_od_price", children=[
                    PaddingNode("sa_od_price_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                        ColumnNode("sa_od_price_col", [
                            RowNode("sa_od_pr1", [
                                TextNode("sa_od_plbl1", "Subtotal", font_size=13, color=TEXT_MUTED),
                                TextNode("sa_od_pval1", "$185.00", font_size=13, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            SizedBoxNode("sa_od_psp1", height=6),
                            RowNode("sa_od_pr2", [
                                TextNode("sa_od_plbl2", "Shipping", font_size=13, color=TEXT_MUTED),
                                TextNode("sa_od_pval2", "$10.00", font_size=13, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween"),
                            DividerNode("sa_od_pdiv"),
                            RowNode("sa_od_pr3", [
                                TextNode("sa_od_plbl3", "Total Paid", font_size=14, font_weight="bold"),
                                TextNode("sa_od_pval3", "$195.00", font_size=15, color=COLOR_INDIGO, font_weight="bold")
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ])
                    ])
                ]),
                SizedBoxNode("sa_od_sp4", height=24),
                ElevatedButtonNode("sa_od_home_btn", "Back to Home Store", bg_color=COLOR_INDIGO, height=48, border_radius=12, navigateTo="sa_home")
            ], cross_axis="CrossAxisAlignment.stretch")
        ])
    ])
    order_detail_screen = ScaffoldNode("sa_order_detail", "Order Details", appBar=order_detail_appbar, children=[order_detail_body])

    return [login_screen, home_screen, detail_screen, cart_screen, favorites_screen, checkout_screen, success_screen, history_screen, order_detail_screen]


# ==========================================
# TEMPLATE 2: Notes App (ZenNotes Premium)
# ==========================================
def build_notes_app():
    # 1. Home Screen
    appbar = AppBarNode("nt_appbar", "ZenNotes", [CircleAvatarNode("nt_user_avatar", radius=16, imageUrl="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100")])
    
    home_body = SingleChildScrollViewNode("nt_home_scsv", [
        ColumnNode("nt_home_col", [
            PaddingNode("nt_search_pad", {"left": 16, "top": 16, "right": 16, "bottom": 8}, [
                TextFieldNode("nt_search_tf", "Search note contents...", "Icons.search")
            ]),
            PaddingNode("nt_tags_pad", {"left": 16, "top": 8, "right": 16, "bottom": 12}, [
                SizedBoxNode("nt_tags_sb", height=38, children=[
                    ListViewNode("nt_tags_lv", scroll_direction="Axis.horizontal", children=[
                        ContainerNode("nt_tag1", bg_color=COLOR_INDIGO, border_radius=12, padding={"left": 16, "top": 8, "right": 16, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                            TextNode("nt_tag1_t", "All Notes", font_size=12, font_weight="bold", color=CARD_LIGHT)
                        ]),
                        ContainerNode("nt_tag2", bg_color=CARD_LIGHT, border_radius=12, border_width=1, border_color=BORDER_COLOR, padding={"left": 16, "top": 8, "right": 16, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                            TextNode("nt_tag2_t", "💡 Ideas", font_size=12, color=TEXT_MUTED)
                        ]),
                        ContainerNode("nt_tag3", bg_color=CARD_LIGHT, border_radius=12, border_width=1, border_color=BORDER_COLOR, padding={"left": 16, "top": 8, "right": 16, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                            TextNode("nt_tag3_t", "💼 Work", font_size=12, color=TEXT_MUTED)
                        ]),
                        ContainerNode("nt_tag4", bg_color=CARD_LIGHT, border_radius=12, border_width=1, border_color=BORDER_COLOR, padding={"left": 16, "top": 8, "right": 16, "bottom": 8}, margin={"left": 0, "top": 0, "right": 8, "bottom": 0}, children=[
                            TextNode("nt_tag4_t", "🛒 Personal", font_size=12, color=TEXT_MUTED)
                        ])
                    ])
                ])
            ]),
            # Notes Grid representation
            PaddingNode("nt_grid_pad", {"left": 16, "top": 8, "right": 16, "bottom": 16}, [
                GridViewNode("nt_grid", cross_axis_count=2, cross_axis_spacing=12, main_axis_spacing=12, child_aspect_ratio=0.85, children=[
                    # Note 1 (Pastel Yellow Background)
                    ContainerNode("nt_n1", bg_color=PASTEL_YELLOW, border_radius=16, padding={"left": 14, "top": 14, "right": 14, "bottom": 14}, children=[
                        ColumnNode("nt_n1_col", [
                            TextNode("nt_n1_title", "💡 App UI Design Ideas", font_size=14, font_weight="bold"),
                            SizedBoxNode("nt_n1_sp1", height=6),
                            TextNode("nt_n1_desc", "Clean light theme designs, warm cards, rounded buttons, simple spacing, custom charts...", font_size=11, color=TEXT_PRIMARY, max_lines=4, overflow="TextOverflow.ellipsis"),
                            SpacerNode("nt_n1_spc"),
                            RowNode("nt_n1_footer", [
                                ContainerNode("nt_n1_tag", bg_color="4294967040", border_radius=6, padding={"left": 6, "top": 2, "right": 6, "bottom": 2}, children=[
                                    TextNode("nt_n1_tag_t", "Ideas", font_size=9, font_weight="bold", color=TEXT_PRIMARY)
                                ]),
                                TextNode("nt_n1_date", "May 20", font_size=10, color=TEXT_MUTED)
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ], cross_axis="CrossAxisAlignment.start")
                    ]),
                    # Note 2 (Pastel Purple Background)
                    ContainerNode("nt_n2", bg_color=PASTEL_PURPLE, border_radius=16, padding={"left": 14, "top": 14, "right": 14, "bottom": 14}, children=[
                        ColumnNode("nt_n2_col", [
                            TextNode("nt_n2_title", "💼 Project Meeting", font_size=14, font_weight="bold"),
                            SizedBoxNode("nt_n2_sp1", height=6),
                            TextNode("nt_n2_desc", "Implement dynamic SQLite templates. Clear db rows, seed light-theme layouts, test icons resolution...", font_size=11, color=TEXT_PRIMARY, max_lines=4, overflow="TextOverflow.ellipsis"),
                            SpacerNode("nt_n2_spc"),
                            RowNode("nt_n2_footer", [
                                ContainerNode("nt_n2_tag", bg_color="4294303231", border_radius=6, padding={"left": 6, "top": 2, "right": 6, "bottom": 2}, children=[
                                    TextNode("nt_n2_tag_t", "Work", font_size=9, font_weight="bold", color=TEXT_PRIMARY)
                                ]),
                                TextNode("nt_n2_date", "May 19", font_size=10, color=TEXT_MUTED)
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ], cross_axis="CrossAxisAlignment.start")
                    ]),
                    # Note 3 (Pastel Green Background)
                    ContainerNode("nt_n3", bg_color=PASTEL_GREEN, border_radius=16, padding={"left": 14, "top": 14, "right": 14, "bottom": 14}, children=[
                        ColumnNode("nt_n3_col", [
                            TextNode("nt_n3_title", "🛒 Grocery Shopping", font_size=14, font_weight="bold"),
                            SizedBoxNode("nt_n3_sp1", height=6),
                            TextNode("nt_n3_desc", "Fresh spinach, organic eggs, Greek yogurt, whole grain oats, specialty light roast coffee beans...", font_size=11, color=TEXT_PRIMARY, max_lines=4, overflow="TextOverflow.ellipsis"),
                            SpacerNode("nt_n3_spc"),
                            RowNode("nt_n3_footer", [
                                ContainerNode("nt_n3_tag", bg_color="4290043136", border_radius=6, padding={"left": 6, "top": 2, "right": 6, "bottom": 2}, children=[
                                    TextNode("nt_n3_tag_t", "Personal", font_size=9, font_weight="bold", color=TEXT_PRIMARY)
                                ]),
                                TextNode("nt_n3_date", "May 18", font_size=10, color=TEXT_MUTED)
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ], cross_axis="CrossAxisAlignment.start")
                    ]),
                    # Note 4 (Pastel Blue Background)
                    ContainerNode("nt_n4", bg_color=PASTEL_BLUE, border_radius=16, padding={"left": 14, "top": 14, "right": 14, "bottom": 14}, children=[
                        ColumnNode("nt_n4_col", [
                            TextNode("nt_n4_title", "📚 Books to Read", font_size=14, font_weight="bold"),
                            SizedBoxNode("nt_n4_sp1", height=6),
                            TextNode("nt_n4_desc", "Atomic Habits by James Clear, Designing Systems at Scale, The Creative Act by Rick Rubin...", font_size=11, color=TEXT_PRIMARY, max_lines=4, overflow="TextOverflow.ellipsis"),
                            SpacerNode("nt_n4_spc"),
                            RowNode("nt_n4_footer", [
                                ContainerNode("nt_n4_tag", bg_color="4290435327", border_radius=6, padding={"left": 6, "top": 2, "right": 6, "bottom": 2}, children=[
                                    TextNode("nt_n4_tag_t", "Personal", font_size=9, font_weight="bold", color=TEXT_PRIMARY)
                                ]),
                                TextNode("nt_n4_date", "May 15", font_size=10, color=TEXT_MUTED)
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ], cross_axis="CrossAxisAlignment.start")
                    ])
                ])
            ])
        ], cross_axis="CrossAxisAlignment.start")
    ])
    
    # Floating Action Button to Add Notes
    home_screen = ScaffoldNode("nt_home", "My Notes", appBar=appbar, children=[
        home_body
    ])
    home_screen["children"] = [
        node("nt_home_stack", "Stack", children=[
            home_body,
            node("nt_fab_align", "Align", {
                "alignment": "Alignment.bottomRight"
            }, [
                PaddingNode("nt_fab_pad", {"left": 0, "top": 0, "right": 20, "bottom": 20}, [
                    ContainerNode("nt_fab", width=56, height=56, bg_color=COLOR_INDIGO, border_radius=28, children=[
                        IconButtonNode("nt_fab_btn", "Icons.add", color=CARD_LIGHT, size=28)
                    ])
                ])
            ])
        ])
    ]
    
    # 2. Editor Screen
    ed_appbar = AppBarNode("nt_ed_ab", "Edit Note", [
        IconButtonNode("nt_ed_save", "Icons.check", color=COLOR_INDIGO),
        IconButtonNode("nt_ed_delete", "Icons.delete_outline", color=TEXT_MUTED)
    ])
    ed_body = SingleChildScrollViewNode("nt_ed_scsv", [
        PaddingNode("nt_ed_pad", {"left": 20, "top": 20, "right": 20, "bottom": 20}, [
            ColumnNode("nt_ed_col", [
                TextFieldNode("nt_ed_title", "💡 App UI Design Ideas", filled=False),
                SizedBoxNode("nt_ed_sp1", height=8),
                RowNode("nt_ed_tag_row", [
                    ContainerNode("nt_ed_tag_chip", bg_color=PASTEL_YELLOW, border_radius=8, padding={"left": 10, "top": 4, "right": 10, "bottom": 4}, children=[
                        TextNode("nt_ed_tag_txt", "Ideas", font_size=12, font_weight="bold")
                    ]),
                    SizedBoxNode("nt_ed_tag_sp", width=12),
                    TextNode("nt_ed_date_txt", "Edited May 20, 10:15 AM", font_size=12, color=TEXT_MUTED)
                ]),
                DividerNode("nt_ed_div"),
                TextFieldNode("nt_ed_body", "Build a low-code Flutter app builder with cloud storage and templates. Focus on premium light theme UI/UX designs featuring soft shadows, warm pastels tags, simple category controls and highly polished layout trees.", filled=False)
            ], cross_axis="CrossAxisAlignment.start")
        ])
    ])
    editor_screen = ScaffoldNode("nt_editor", "Note Editor", appBar=ed_appbar, children=[ed_body])
    
    return [home_screen, editor_screen]


# ==========================================
# TEMPLATE 3: Expense Tracker (SpendWave Luxury)
# ==========================================
def build_expense_tracker():
    # 1. Dashboard Screen
    appbar = AppBarNode("xp_appbar", "SpendWave Wallet", [IconButtonNode("xp_notif", "Icons.notifications_none")])
    bnb = BottomNavBarNode("xp_bnb", [
        ("Icons.home", "Home"),
        ("Icons.show_chart", "Analytics"),
        ("Icons.add", "Add Pay"),
        ("Icons.person_outline", "Profile")
    ])
    
    dash_body = SingleChildScrollViewNode("xp_dash_scsv", [
        ColumnNode("xp_dash_col", [
            # Metallic Luxury Card with diagonal linear gradient (Indigo to Violet)
            PaddingNode("xp_card_pad", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                ContainerNode(
                    "xp_card", 
                    height=180, 
                    border_radius=20, 
                    gradient=GradientMap([COLOR_INDIGO, COLOR_VIOLET]),
                    padding={"left": 24, "top": 24, "right": 24, "bottom": 24}, 
                    children=[
                        ColumnNode("xp_card_col", [
                            TextNode("xp_card_lbl", "Total Balance", font_size=13, color=CARD_LIGHT),
                            SizedBoxNode("xp_card_sp1", height=6),
                            TextNode("xp_card_bal", "$12,450.80", font_size=26, font_weight="bold", color=CARD_LIGHT),
                            SpacerNode("xp_card_spc"),
                            RowNode("xp_card_details", [
                                ColumnNode("xp_card_no_col", [
                                    TextNode("xp_card_no_lbl", "Card Number", font_size=10, color=CARD_LIGHT),
                                    TextNode("xp_card_no", "**** **** **** 8824", font_size=13, font_weight="w600", color=CARD_LIGHT)
                                ], cross_axis="CrossAxisAlignment.start"),
                                ColumnNode("xp_card_name_col", [
                                    TextNode("xp_card_name_lbl", "Card Holder", font_size=10, color=CARD_LIGHT),
                                    TextNode("xp_card_name", "Mohamed Jalal", font_size=13, font_weight="w600", color=CARD_LIGHT)
                                ], cross_axis="CrossAxisAlignment.start")
                            ], main_axis="MainAxisAlignment.spaceBetween")
                        ], cross_axis="CrossAxisAlignment.start")
                    ]
                )
            ]),
            # Quick Actions Row
            PaddingNode("xp_actions_pad", {"left": 16, "top": 0, "right": 16, "bottom": 16}, [
                RowNode("xp_actions_row", [
                    # Send
                    ColumnNode("xp_act_send_col", [
                        ContainerNode("xp_act_send_c", width=50, height=50, bg_color=FIELD_COLOR, border_radius=25, children=[
                            IconButtonNode("xp_act_send_btn", "Icons.send", color=COLOR_INDIGO)
                        ]),
                        SizedBoxNode("xp_act_send_sp", height=6),
                        TextNode("xp_act_send_t", "Send", font_size=12, font_weight="w600")
                    ]),
                    # Receive
                    ColumnNode("xp_act_rec_col", [
                        ContainerNode("xp_act_rec_c", width=50, height=50, bg_color=FIELD_COLOR, border_radius=25, children=[
                            IconButtonNode("xp_act_rec_btn", "Icons.call_received", color=COLOR_CYAN)
                        ]),
                        SizedBoxNode("xp_act_rec_sp", height=6),
                        TextNode("xp_act_rec_t", "Receive", font_size=12, font_weight="w600")
                    ]),
                    # Analytics
                    ColumnNode("xp_act_chart_col", [
                        ContainerNode("xp_act_chart_c", width=50, height=50, bg_color=FIELD_COLOR, border_radius=25, children=[
                            IconButtonNode("xp_act_chart_btn", "Icons.show_chart", color=COLOR_VIOLET)
                        ]),
                        SizedBoxNode("xp_act_chart_sp", height=6),
                        TextNode("xp_act_chart_t", "Analytics", font_size=12, font_weight="w600")
                    ]),
                    # Settings
                    ColumnNode("xp_act_set_col", [
                        ContainerNode("xp_act_set_c", width=50, height=50, bg_color=FIELD_COLOR, border_radius=25, children=[
                            IconButtonNode("xp_act_set_btn", "Icons.settings", color=TEXT_MUTED)
                        ]),
                        SizedBoxNode("xp_act_set_sp", height=6),
                        TextNode("xp_act_set_t", "Settings", font_size=12, font_weight="w600")
                    ])
                ], main_axis="MainAxisAlignment.spaceAround")
            ]),
            PaddingNode("xp_tx_title_pad", {"left": 16, "top": 12, "right": 16, "bottom": 12}, [
                TextNode("xp_tx_title", "Recent Transactions", font_size=16, font_weight="bold")
            ]),
            # Transactions List
            PaddingNode("xp_tx_pad", {"left": 16, "top": 0, "right": 16, "bottom": 16}, [
                ColumnNode("xp_tx_col", [
                    CardNode("xp_tx1_card", children=[
                        PaddingNode("xp_tx1_inner", {"left": 14, "top": 14, "right": 14, "bottom": 14}, [
                            RowNode("xp_tx1_row", [
                                ContainerNode("xp_tx1_icon_c", width=42, height=42, bg_color=FIELD_COLOR, border_radius=8, children=[
                                    IconNode("xp_tx1_icon", "Icons.tv", color=COLOR_ROSE, size=20)
                                ]),
                                SizedBoxNode("xp_tx1_wsp", width=12),
                                ExpandedNode("xp_tx1_exp", ColumnNode("xp_tx1_col", [
                                    TextNode("xp_tx1_title", "Netflix Premium", font_size=14, font_weight="bold"),
                                    TextNode("xp_tx1_cat", "Entertainment • May 20", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")),
                                TextNode("xp_tx1_amt", "-$15.49", font_size=14, color=COLOR_ROSE, font_weight="bold")
                            ])
                        ])
                    ], margin={"left": 0, "top": 0, "right": 0, "bottom": 10}),
                    CardNode("xp_tx2_card", children=[
                        PaddingNode("xp_tx2_inner", {"left": 14, "top": 14, "right": 14, "bottom": 14}, [
                            RowNode("xp_tx2_row", [
                                ContainerNode("xp_tx2_icon_c", width=42, height=42, bg_color=FIELD_COLOR, border_radius=8, children=[
                                    IconNode("xp_tx2_icon", "Icons.payments", color=COLOR_EMERALD, size=20)
                                ]),
                                SizedBoxNode("xp_tx2_wsp", width=12),
                                ExpandedNode("xp_tx2_exp", ColumnNode("xp_tx2_col", [
                                    TextNode("xp_tx2_title", "Salary Deposit", font_size=14, font_weight="bold"),
                                    TextNode("xp_tx2_cat", "Income • May 18", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")),
                                TextNode("xp_tx2_amt", "+$4,800.00", font_size=14, color=COLOR_EMERALD, font_weight="bold")
                            ])
                        ])
                    ], margin={"left": 0, "top": 0, "right": 0, "bottom": 10}),
                    CardNode("xp_tx3_card", children=[
                        PaddingNode("xp_tx3_inner", {"left": 14, "top": 14, "right": 14, "bottom": 14}, [
                            RowNode("xp_tx3_row", [
                                ContainerNode("xp_tx3_icon_c", width=42, height=42, bg_color=FIELD_COLOR, border_radius=8, children=[
                                    IconNode("xp_tx3_icon", "Icons.restaurant", color=COLOR_AMBER, size=20)
                                ]),
                                SizedBoxNode("xp_tx3_wsp", width=12),
                                ExpandedNode("xp_tx3_exp", ColumnNode("xp_tx3_col", [
                                    TextNode("xp_tx3_title", "Starbucks Coffee", font_size=14, font_weight="bold"),
                                    TextNode("xp_tx3_cat", "Food & Dining • May 17", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")),
                                TextNode("xp_tx3_amt", "-$6.80", font_size=14, color=COLOR_ROSE, font_weight="bold")
                            ])
                        ])
                    ])
                ], cross_axis="CrossAxisAlignment.stretch")
            ])
        ], cross_axis="CrossAxisAlignment.start")
    ])
    dash_screen = ScaffoldNode("xp_dash", "Wallet Dashboard", appBar=appbar, bottomNavigationBar=bnb, children=[dash_body])
    
    # 2. Analytics Screen
    an_appbar = AppBarNode("xp_an_ab", "Spending Analytics")
    an_body = SingleChildScrollViewNode("xp_an_scsv", [
        ColumnNode("xp_an_col", [
            # Timeframes scroll chips
            PaddingNode("xp_an_tf_pad", {"left": 16, "top": 16, "right": 16, "bottom": 12}, [
                RowNode("xp_an_tf_row", [
                    ContainerNode("xp_an_tf1", bg_color=CARD_LIGHT, border_radius=10, border_width=1, border_color=BORDER_COLOR, padding={"left": 20, "top": 8, "right": 20, "bottom": 8}, children=[
                        TextNode("xp_an_tf1_t", "Week", font_size=12, color=TEXT_MUTED)
                    ]),
                    ContainerNode("xp_an_tf2", bg_color=COLOR_INDIGO, border_radius=10, padding={"left": 20, "top": 8, "right": 20, "bottom": 8}, children=[
                        TextNode("xp_an_tf2_t", "Month", font_size=12, color=CARD_LIGHT, font_weight="bold")
                    ]),
                    ContainerNode("xp_an_tf3", bg_color=CARD_LIGHT, border_radius=10, border_width=1, border_color=BORDER_COLOR, padding={"left": 20, "top": 8, "right": 20, "bottom": 8}, children=[
                        TextNode("xp_an_tf3_t", "Year", font_size=12, color=TEXT_MUTED)
                    ])
                ], main_axis="MainAxisAlignment.spaceBetween")
            ]),
            # Category column/bar graph mockup card
            PaddingNode("xp_an_g_pad", {"left": 16, "top": 8, "right": 16, "bottom": 16}, [
                CardNode("xp_an_g_card", children=[
                    PaddingNode("xp_an_g_inner", {"left": 16, "top": 16, "right": 16, "bottom": 16}, [
                        ColumnNode("xp_an_g_col", [
                            TextNode("xp_an_g_title", "Monthly Overview", font_size=15, font_weight="bold"),
                            SizedBoxNode("xp_an_g_sp1", height=24),
                            RowNode("xp_an_g_rows", [
                                # Food column
                                ColumnNode("xp_g_c1", [
                                    ContainerNode("xp_g_c1_bar", width=22, height=120, bg_color=COLOR_EMERALD, border_radius=6),
                                    SizedBoxNode("xp_g_c1_sp", height=6),
                                    TextNode("xp_g_c1_lbl", "Food", font_size=10, color=TEXT_MUTED)
                                ]),
                                # Bills column
                                ColumnNode("xp_g_c2", [
                                    ContainerNode("xp_g_c2_bar", width=22, height=80, bg_color=COLOR_ROSE, border_radius=6),
                                    SizedBoxNode("xp_g_c2_sp", height=6),
                                    TextNode("xp_g_c2_lbl", "Bills", font_size=10, color=TEXT_MUTED)
                                ]),
                                # Shopping column
                                ColumnNode("xp_g_c3", [
                                    ContainerNode("xp_g_c3_bar", width=22, height=100, bg_color=COLOR_VIOLET, border_radius=6),
                                    SizedBoxNode("xp_g_c3_sp", height=6),
                                    TextNode("xp_g_c3_lbl", "Shop", font_size=10, color=TEXT_MUTED)
                                ]),
                                # Travel column
                                ColumnNode("xp_g_c4", [
                                    ContainerNode("xp_g_c4_bar", width=22, height=50, bg_color=COLOR_CYAN, border_radius=6),
                                    SizedBoxNode("xp_g_c4_sp", height=6),
                                    TextNode("xp_g_c4_lbl", "Travel", font_size=10, color=TEXT_MUTED)
                                ])
                            ], main_axis="MainAxisAlignment.spaceAround", cross_axis="CrossAxisAlignment.bottom")
                        ], cross_axis="CrossAxisAlignment.start")
                    ])
                ])
            ]),
            # Breakdown List
            PaddingNode("xp_an_b_pad", {"left": 16, "top": 8, "right": 16, "bottom": 16}, [
                ColumnNode("xp_an_b_col", [
                    TextNode("xp_an_b_lbl", "Category Breakdown", font_size=16, font_weight="bold"),
                    SizedBoxNode("xp_an_b_sp", height=12),
                    CardNode("xp_b1", children=[
                        PaddingNode("xp_b1_inner", {"left": 14, "top": 14, "right": 14, "bottom": 14}, [
                            RowNode("xp_b1_row", [
                                IconNode("xp_b1_ic", "Icons.restaurant", color=COLOR_EMERALD, size=20),
                                SizedBoxNode("xp_b1_wsp", width=12),
                                ExpandedNode("xp_b1_exp", ColumnNode("xp_b1_col", [
                                    TextNode("xp_b1_title", "Food & Dining", font_size=14, font_weight="bold"),
                                    TextNode("xp_b1_pct", "35% of total budget", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")),
                                TextNode("xp_b1_amt", "$540.00", font_size=14, font_weight="bold")
                            ])
                        ])
                    ], margin={"left": 0, "top": 0, "right": 0, "bottom": 10}),
                    CardNode("xp_b2", children=[
                        PaddingNode("xp_b2_inner", {"left": 14, "top": 14, "right": 14, "bottom": 14}, [
                            RowNode("xp_b2_row", [
                                IconNode("xp_b2_ic", "Icons.shopping_bag_outlined", color=COLOR_VIOLET, size=20),
                                SizedBoxNode("xp_b2_wsp", width=12),
                                ExpandedNode("xp_b2_exp", ColumnNode("xp_b2_col", [
                                    TextNode("xp_b2_title", "Shopping", font_size=14, font_weight="bold"),
                                    TextNode("xp_b2_pct", "25% of total budget", font_size=11, color=TEXT_MUTED)
                                ], cross_axis="CrossAxisAlignment.start")),
                                TextNode("xp_b2_amt", "$380.00", font_size=14, font_weight="bold")
                            ])
                        ])
                    ], margin={"left": 0, "top": 0, "right": 0, "bottom": 10})
                ], cross_axis="CrossAxisAlignment.start")
            ])
        ], cross_axis="CrossAxisAlignment.start")
    ])
    analytics_screen = ScaffoldNode("xp_analytics", "Analytics", appBar=an_appbar, children=[an_body])
    
    # 3. Add Transaction Screen
    add_appbar = AppBarNode("xp_add_ab", "Add Transaction")
    add_body = SingleChildScrollViewNode("xp_add_scsv", [
        PaddingNode("xp_add_pad", {"left": 20, "top": 24, "right": 20, "bottom": 24}, [
            ColumnNode("xp_add_col", [
                TextNode("xp_add_val_lbl", "Enter Amount", font_size=13, color=TEXT_MUTED, align="TextAlign.center"),
                SizedBoxNode("xp_add_sp1", height=12),
                TextNode("xp_add_val", "$120.00", font_size=42, font_weight="bold", color=COLOR_INDIGO, align="TextAlign.center"),
                SizedBoxNode("xp_add_sp2", height=32),
                TextNode("xp_add_cat_lbl", "Select Category", font_size=14, font_weight="bold"),
                SizedBoxNode("xp_add_sp3", height=12),
                GridViewNode("xp_add_cat_grid", cross_axis_count=2, cross_axis_spacing=12, main_axis_spacing=12, child_aspect_ratio=1.6, children=[
                    ContainerNode("xp_c1", bg_color=FIELD_COLOR, border_radius=12, children=[
                        ColumnNode("xp_c1_col", [
                            IconNode("xp_c1_ic", "Icons.restaurant", color=COLOR_EMERALD, size=20),
                            SizedBoxNode("xp_c1_sp", height=6),
                            TextNode("xp_c1_t", "Food & Dining", font_size=12, font_weight="bold")
                        ], main_axis="MainAxisAlignment.center")
                    ]),
                    ContainerNode("xp_c2", bg_color=COLOR_INDIGO, border_radius=12, children=[
                        ColumnNode("xp_c2_col", [
                            IconNode("xp_c2_ic", "Icons.shopping_bag_outlined", color=CARD_LIGHT, size=20),
                            SizedBoxNode("xp_c2_sp", height=6),
                            TextNode("xp_c2_t", "Shopping", font_size=12, font_weight="bold", color=CARD_LIGHT)
                        ], main_axis="MainAxisAlignment.center")
                    ]),
                    ContainerNode("xp_c3", bg_color=FIELD_COLOR, border_radius=12, children=[
                        ColumnNode("xp_c3_col", [
                            IconNode("xp_c3_ic", "Icons.tv", color=COLOR_ROSE, size=20),
                            SizedBoxNode("xp_c3_sp", height=6),
                            TextNode("xp_c3_t", "Entertainment", font_size=12, font_weight="bold")
                        ], main_axis="MainAxisAlignment.center")
                    ]),
                    ContainerNode("xp_c4", bg_color=FIELD_COLOR, border_radius=12, children=[
                        ColumnNode("xp_c4_col", [
                            IconNode("xp_c4_ic", "Icons.directions_car", color=COLOR_CYAN, size=20),
                            SizedBoxNode("xp_c4_sp", height=6),
                            TextNode("xp_c4_t", "Transportation", font_size=12, font_weight="bold")
                        ], main_axis="MainAxisAlignment.center")
                    ])
                ]),
                SizedBoxNode("xp_add_sp4", height=24),
                TextFieldNode("xp_add_note", "Add a brief note (e.g. Shopping sneakers)", prefix_icon="Icons.edit_outlined"),
                SizedBoxNode("xp_add_sp5", height=28),
                ElevatedButtonNode("xp_add_save", "Save Transaction Details", bg_color=COLOR_INDIGO, height=48, border_radius=12)
            ], cross_axis="CrossAxisAlignment.stretch")
        ])
    ])
    add_screen = ScaffoldNode("xp_add", "Add Expense", appBar=add_appbar, children=[add_body])
    
    return [dash_screen, analytics_screen, add_screen]

# Dictionary of all template generators (FOCUSED ONLY ON 3 PREMIUM LIGHT-THEMED APP FLOWS)
GENERATORS = {
    "E-Commerce Store": ("Sophisticated light-themed retail product shopping, item detail, and shopping cart checkout flows.", "E-Commerce", build_shopping_app),
    "Notes App": ("Clean minimalist personal notes keeper with custom tag cards, notes grid, and editor screens.", "Productivity", build_notes_app),
    "Expense Tracker": ("Luxury personal wallet analytics dashboard, spending category metrics, and quick payment details.", "Finance", build_expense_tracker),
}

def main():
    print("SynappKit Database Seeder starting...")
    
    # 1. Clear ALL templates from the database first
    delete_all_url = f"{URL}?id=not.is.null"
    try:
        req = urllib.request.Request(delete_all_url, headers=HEADERS, method="DELETE")
        with urllib.request.urlopen(req) as resp:
            print("Successfully deleted all existing templates from database to ensure a clean slate.")
    except Exception as e:
        print(f"Warning: Could not clear existing templates: {e}")
        
    inserted = 0
    failed = 0
    
    # 2. Insert the three premium templates
    for name, (desc, category, builder_fn) in GENERATORS.items():
        print(f"Building: {name}...")
        try:
            screens = builder_fn()
            
            payload = {
                "name": name,
                "description": desc,
                "category": category,
                "screens_json": screens
            }
            
            # Post directly to Supabase via REST endpoint
            req = urllib.request.Request(
                URL,
                data=json.dumps(payload).encode(),
                headers=HEADERS,
                method="POST"
            )
            
            with urllib.request.urlopen(req) as resp:
                print(f"  ✅ Inserted successfully: {name}")
                inserted += 1
                
        except urllib.error.HTTPError as e:
            err_body = e.read().decode()
            print(f"  ❌ HTTP Error inserting {name}: {e.code} - {err_body}")
            failed += 1
        except Exception as e:
            print(f"  ❌ Error inserting {name}: {e}")
            failed += 1
            
        time.sleep(0.5) # small rate limit safety
        
    print(f"\nSeeding complete. Success: {inserted}, Failed: {failed}")

if __name__ == "__main__":
    main()
