INSERT INTO public.templates (name, description, category, screens_json) VALUES
('Modern Dashboard', 'A beautiful admin template.', 'Admin', '{
  "id": "dashboard_root",
  "type": "Scaffold",
  "properties": {
    "backgroundColor": "#09090B"
  },
  "children": [
    {
      "id": "dash_scroll",
      "type": "ListView",
      "properties": {},
      "children": [
        {
          "id": "header",
          "type": "Container",
          "properties": {
            "padding": "EdgeInsets.all(24)"
          },
          "children": [
            {
              "id": "head_row",
              "type": "Row",
              "properties": {
                "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
              },
              "children": [
                {
                  "id": "title_col",
                  "type": "Column",
                  "properties": {
                    "crossAxisAlignment": "CrossAxisAlignment.start"
                  },
                  "children": [
                    {
                      "id": "title_1",
                      "type": "Text",
                      "properties": {"text": "Welcome back,", "fontSize": 16, "color": "#A1A1AA"},
                      "children": []
                    },
                    {
                      "id": "title_2",
                      "type": "Text",
                      "properties": {"text": "Dashboard Overview", "fontSize": 28, "fontWeight": "FontWeight.bold", "color": "#FAFAFA"},
                      "children": []
                    }
                  ]
                },
                {
                  "id": "bell_icon_container",
                  "type": "Container",
                  "properties": {
                    "width": 48,
                    "height": 48,
                    "color": "#18181B",
                    "borderRadius": 24
                  },
                  "children": [
                    {
                      "id": "bell_center",
                      "type": "Center",
                      "properties": {},
                      "children": [
                        {
                          "id": "bell_icon",
                          "type": "Icon",
                          "properties": {"icon": "Icons.notifications", "color": "#FAFAFA"},
                          "children": []
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "id": "cards_row",
          "type": "Row",
          "properties": {
            "mainAxisAlignment": "MainAxisAlignment.spaceEvenly"
          },
          "children": [
            {
              "id": "card_1",
              "type": "Container",
              "properties": {
                "width": 160,
                "color": "#18181B",
                "padding": "EdgeInsets.all(16)",
                "borderRadius": 16
              },
              "children": [
                {
                  "id": "c1_icon",
                  "type": "Icon",
                  "properties": {"icon": "Icons.attach_money", "color": "#10B981"},
                  "children": []
                },
                {
                  "id": "c1_val",
                  "type": "Text",
                  "properties": {"text": "$24,500", "fontSize": 24, "fontWeight": "FontWeight.bold", "color": "#FAFAFA"},
                  "children": []
                },
                {
                  "id": "c1_lbl",
                  "type": "Text",
                  "properties": {"text": "Total Revenue", "fontSize": 14, "color": "#A1A1AA"},
                  "children": []
                }
              ]
            },
            {
              "id": "card_2",
              "type": "Container",
              "properties": {
                "width": 160,
                "color": "#18181B",
                "padding": "EdgeInsets.all(16)",
                "borderRadius": 16
              },
              "children": [
                {
                  "id": "c2_icon",
                  "type": "Icon",
                  "properties": {"icon": "Icons.group", "color": "#3B82F6"},
                  "children": []
                },
                {
                  "id": "c2_val",
                  "type": "Text",
                  "properties": {"text": "+1,240", "fontSize": 24, "fontWeight": "FontWeight.bold", "color": "#FAFAFA"},
                  "children": []
                },
                {
                  "id": "c2_lbl",
                  "type": "Text",
                  "properties": {"text": "Active Users", "fontSize": 14, "color": "#A1A1AA"},
                  "children": []
                }
              ]
            }
          ]
        },
        {
          "id": "chart_section",
          "type": "Container",
          "properties": {
            "margin": "EdgeInsets.all(24)",
            "padding": "EdgeInsets.all(24)",
            "color": "#18181B",
            "borderRadius": 16
          },
          "children": [
            {
              "id": "chart_title",
              "type": "Text",
              "properties": {"text": "Weekly Activity", "fontSize": 18, "fontWeight": "FontWeight.bold", "color": "#FAFAFA"},
              "children": []
            },
            {
              "id": "chart_bars",
              "type": "Row",
              "properties": {
                "mainAxisAlignment": "MainAxisAlignment.spaceBetween",
                "crossAxisAlignment": "CrossAxisAlignment.end"
              },
              "children": [
                { "type": "Container", "properties": {"width": 30, "height": 100, "color": "#3B82F6", "borderRadius": 8}, "children": [] },
                { "type": "Container", "properties": {"width": 30, "height": 180, "color": "#10B981", "borderRadius": 8}, "children": [] },
                { "type": "Container", "properties": {"width": 30, "height": 140, "color": "#3B82F6", "borderRadius": 8}, "children": [] },
                { "type": "Container", "properties": {"width": 30, "height": 220, "color": "#F59E0B", "borderRadius": 8}, "children": [] },
                { "type": "Container", "properties": {"width": 30, "height": 160, "color": "#3B82F6", "borderRadius": 8}, "children": [] }
              ]
            }
          ]
        }
      ]
    }
  ]
}
'::jsonb),
('High Fidelity Todo', 'A beautiful productivity template.', 'Productivity', '[
  {
    "id": "hf_todo_home",
    "type": "Scaffold",
    "properties": {
      "pageName": "Dashboard",
      "backgroundColor": "4294507000",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "backgroundColor": "4294507000",
          "elevation": 0,
          "leading": { "type": "Padding", "properties": { "padding": 8 }, "children": [ { "type": "CircleAvatar", "properties": { "radius": 20, "backgroundImage": "https://i.pravatar.cc/100?u=hf1" } } ] },
          "title": {
            "type": "Column",
            "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
            "children": [
              { "type": "Text", "properties": { "text": "Hello, Mohamed", "fontSize": 18, "fontWeight": "bold", "color": "4280224059" } },
              { "type": "Text", "properties": { "text": "You have 6 task today", "fontSize": 11, "color": "4287931320" } }
            ]
          },
          "actions": [
            { "type": "IconButton", "properties": { "icon": "Icons.search", "color": "4280224059" } }
          ]
        }
      },
      "floatingActionButton": {
        "type": "FloatingActionButton",
        "properties": {
          "backgroundColor": "4284704497",
          "navigateTo": "hf_todo_add",
          "child": { "type": "Icon", "properties": { "icon": "Icons.add", "color": "4294967295" } }
        }
      }
    },
    "children": [
      {
        "type": "SingleChildScrollView",
        "children": [
          {
            "type": "Column",
            "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
            "children": [
              { "type": "Padding", "properties": { "padding": { "left": 20, "top": 20, "bottom": 10 } }, "children": [ { "type": "Text", "properties": { "text": "Categories", "fontSize": 18, "fontWeight": "bold" } } ] },
              {
                "type": "Container",
                "properties": { "height": 170, "padding": { "left": 20 } },
                "children": [
                  {
                    "type": "ListView",
                    "properties": { "scrollDirection": "horizontal" },
                    "children": [
                      {
                        "type": "Container",
                        "properties": {
                          "width": 160,
                          "borderRadius": 28,
                          "padding": 20,
                          "gradient": { "colors": ["4285888255", "4284704497"], "begin": "Alignment.topLeft", "end": "Alignment.bottomRight" }
                        },
                        "children": [
                          {
                            "type": "Column",
                            "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                            "children": [
                                { "type": "Container", "properties": { "width": 40, "height": 40, "borderRadius": 12, "backgroundColor": "4294967295" }, "children": [ { "type": "Icon", "properties": { "icon": "Icons.laptop_mac", "color": "4284704497", "size": 20 } } ] },
                                { "type": "Spacer" },
                                { "type": "Text", "properties": { "text": "Landing Page \nDesign", "color": "4294967295", "fontWeight": "bold", "fontSize": 16 } },
                                { "type": "Text", "properties": { "text": "16 project", "color": "4294967295", "fontSize": 11 } }
                            ]
                          }
                        ]
                      },
                      { "type": "SizedBox", "properties": { "width": 16 } },
                      {
                        "type": "Container",
                        "properties": {
                          "width": 160,
                          "borderRadius": 28,
                          "padding": 20,
                          "gradient": { "colors": ["4280261314", "4282302391"], "begin": "Alignment.topLeft", "end": "Alignment.bottomRight" }
                        },
                        "children": [
                          {
                            "type": "Column",
                            "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                            "children": [
                                { "type": "Container", "properties": { "width": 40, "height": 40, "borderRadius": 12, "backgroundColor": "4294967295" }, "children": [ { "type": "Icon", "properties": { "icon": "Icons.phone_android", "color": "4280261314", "size": 20 } } ] },
                                { "type": "Spacer" },
                                { "type": "Text", "properties": { "text": "Mobile \nDevelopment", "color": "4294967295", "fontWeight": "bold", "fontSize": 16 } },
                                { "type": "Text", "properties": { "text": "8 project", "color": "4294967295", "fontSize": 11 } }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": { "padding": { "left": 20, "top": 30, "right": 20 } },
                "children": [
                  { "type": "Text", "properties": { "text": "My Task", "fontSize": 18, "fontWeight": "bold" } },
                  { "type": "SizedBox", "properties": { "height": 16 } },
                  {
                    "type": "Row",
                    "properties": { "mainAxisAlignment": "MainAxisAlignment.spaceBetween" },
                    "children": [
                      { "type": "Column", "children": [ { "type": "Text", "properties": { "text": "Today", "color": "4284704497", "fontWeight": "bold" } }, { "type": "Container", "properties": { "width": 4, "height": 4, "borderRadius": 2, "backgroundColor": "4284704497" } } ] },
                      { "type": "Text", "properties": { "text": "Upcoming", "color": "4287931320", "fontSize": 13 } },
                      { "type": "Text", "properties": { "text": "Due Soon", "color": "4287931320", "fontSize": 13 } },
                      { "type": "Text", "properties": { "text": "Completed", "color": "4287931320", "fontSize": 13 } }
                    ]
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": { "padding": { "left": 20, "top": 20, "right": 20, "bottom": 100 } },
                "children": [
                  {
                    "type": "Column",
                    "children": [
                        {
                            "type": "Container",
                            "properties": {
                                "padding": 20,
                                "borderRadius": 24,
                                "backgroundColor": "4294967295",
                                "shadowColor": "4278190080", "shadowBlur": 15, "shadowY": 6, "shadowX": 0
                            },
                            "children": [
                                {
                                    "type": "Row",
                                    "children": [
                                        {
                                            "type": "Column",
                                            "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                                            "children": [
                                                { "type": "Text", "properties": { "text": "SaaS Website", "fontSize": 16, "fontWeight": "bold" } },
                                                { "type": "Text", "properties": { "text": "Create homepage Wireframe", "fontSize": 12, "color": "4287931320" } },
                                                { "type": "SizedBox", "properties": { "height": 12 } },
                                                { "type": "Row", "children": [ { "type": "Icon", "properties": { "icon": "Icons.access_time", "size": 14, "color": "4287931320" } }, { "type": "SizedBox", "properties": { "width": 4 } }, { "type": "Text", "properties": { "text": "9:00 AM - 10:30 AM", "fontSize": 11, "color": "4287931320" } } ] }
                                            ]
                                        },
                                        { "type": "Spacer" },
                                        { "type": "Button", "properties": { "text": "on progress", "fontSize": 10, "fillColor": "4292928504", "width": 85, "height": 28, "borderRadius": 14, "navigateTo": "hf_todo_details" } }
                                    ]
                                }
                            ]
                        },
                        { "type": "SizedBox", "properties": { "height": 16 } },
                        {
                            "type": "Container",
                            "properties": {
                                "padding": 20,
                                "borderRadius": 24,
                                "backgroundColor": "4294967295",
                                "shadowColor": "4278190080", "shadowBlur": 15, "shadowY": 6, "shadowX": 0
                            },
                            "children": [
                                {
                                    "type": "Row",
                                    "children": [
                                        {
                                            "type": "Column",
                                            "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                                            "children": [
                                                { "type": "Text", "properties": { "text": "Finance App", "fontSize": 16, "fontWeight": "bold" } },
                                                { "type": "Text", "properties": { "text": "Create homepage Wireframe", "fontSize": 12, "color": "4287931320" } }
                                            ]
                                        },
                                        { "type": "Spacer" },
                                        { "type": "Button", "properties": { "text": "Pending", "fontSize": 10, "fillColor": "4294944883", "width": 75, "height": 28, "borderRadius": 14, "navigateTo": "hf_todo_details" } }
                                    ]
                                }
                            ]
                        }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "hf_todo_add",
    "type": "Scaffold",
    "properties": {
      "pageName": "Add Task",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "title": { "type": "Text", "properties": { "text": "Add Task", "fontWeight": "bold" } },
          "backgroundColor": "4294507000",
          "centerTitle": true,
          "elevation": 0,
          "leading": { "type": "IconButton", "properties": { "icon": "Icons.arrow_back", "navigateTo": "hf_todo_home" } }
        }
      }
    },
    "children": [
      {
        "type": "Padding",
        "properties": { "padding": 24 },
        "children": [
          {
            "type": "Column",
            "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
            "children": [
              { "type": "Text", "properties": { "text": "Title", "fontSize": 14, "color": "4287931320" } },
              { "type": "TextField", "properties": { "hintText": "Fintech App Design", "fontSize": 20, "fontWeight": "bold" } },
              { "type": "SizedBox", "properties": { "height": 30 } },
              { "type": "Text", "properties": { "text": "Team Member", "fontSize": 14, "color": "4287931320" } },
              { "type": "SizedBox", "properties": { "height": 12 } },
              {
                "type": "Row",
                "children": [
                  { "type": "CircleAvatar", "properties": { "radius": 20, "backgroundImage": "https://i.pravatar.cc/100?u=tm1" } },
                  { "type": "SizedBox", "properties": { "width": 10 } },
                  { "type": "CircleAvatar", "properties": { "radius": 20, "backgroundImage": "https://i.pravatar.cc/100?u=tm2" } },
                  { "type": "SizedBox", "properties": { "width": 10 } },
                  { "type": "CircleAvatar", "properties": { "radius": 20, "backgroundImage": "https://i.pravatar.cc/100?u=tm3" } },
                  { "type": "SizedBox", "properties": { "width": 10 } },
                  { "type": "CircleAvatar", "properties": { "radius": 20, "backgroundColor": "4284704497" }, "children": [ { "type": "Icon", "properties": { "icon": "Icons.add", "color": "4294967295", "size": 20 } } ] }
                ]
              },
              { "type": "SizedBox", "properties": { "height": 30 } },
              { "type": "Text", "properties": { "text": "Date", "fontSize": 14, "color": "4287931320" } },
              { "type": "Row", "children": [ { "type": "Text", "properties": { "text": "4 August 2021", "fontSize": 16, "fontWeight": "bold" } }, { "type": "Spacer" }, { "type": "Icon", "properties": { "icon": "Icons.calendar_today", "size": 20, "color": "4284704497" } } ] },
              { "type": "Divider", "properties": { "height": 30 } },
              {
                "type": "Row",
                "children": [
                    { "type": "Expanded", "children": [ { "type": "Column", "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" }, "children": [ { "type": "Text", "properties": { "text": "Start Time", "fontSize": 14, "color": "4287931320" } }, { "type": "Text", "properties": { "text": "07:00 AM", "fontWeight": "bold", "fontSize": 16 } } ] } ] },
                    { "type": "Expanded", "children": [ { "type": "Column", "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" }, "children": [ { "type": "Text", "properties": { "text": "End Time", "fontSize": 14, "color": "4287931320" } }, { "type": "Text", "properties": { "text": "07:30 AM", "fontWeight": "bold", "fontSize": 16 } } ] } ] }
                ]
              },
              { "type": "SizedBox", "properties": { "height": 30 } },
              { "type": "Text", "properties": { "text": "Description", "fontSize": 14, "color": "4287931320" } },
              { "type": "Text", "properties": { "text": "Software as a service is a way of applications delivery over the internet as a service. Instead of installing and maintaining software, you simply access it via the internet.", "fontSize": 14, "color": "4280224059" } },
              { "type": "Spacer" },
              {
                "type": "Button",
                "properties": {
                  "text": "Create Task",
                  "width": 1000,
                  "height": 56,
                  "fillColor": "4284704497",
                  "borderRadius": 18,
                  "navigateTo": "hf_todo_home"
                }
              }
            ]
          }
        ]
      }
    ]
  }
]
'::jsonb),
('Social Profile', 'A beautiful general template.', 'General', '{
  "id": "social_profile_root",
  "type": "Scaffold",
  "properties": {
    "backgroundColor": "#0F172A"
  },
  "children": [
    {
      "id": "social_scroll",
      "type": "ListView",
      "properties": {},
      "children": [
        {
          "id": "cover_stack",
          "type": "Stack",
          "properties": {},
          "children": [
            {
              "id": "cover_image",
              "type": "Container",
              "properties": {
                "height": 200,
                "color": "#3B82F6",
                "borderRadius": 0
              },
              "children": []
            },
            {
              "id": "avatar_positioned",
              "type": "Container",
              "properties": {
                "margin": "EdgeInsets.only(top: 150, left: 24)",
                "height": 100,
                "width": 100,
                "color": "#0F172A",
                "borderRadius": 50,
                "padding": "EdgeInsets.all(4)"
              },
              "children": [
                {
                  "id": "avatar_inner",
                  "type": "Container",
                  "properties": {
                    "color": "#6366F1",
                    "borderRadius": 46
                  },
                  "children": [
                    {
                      "id": "avatar_icon",
                      "type": "Icon",
                      "properties": {
                        "icon": "Icons.person",
                        "size": 50,
                        "color": "#FFFFFF"
                      },
                      "children": []
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "id": "profile_info",
          "type": "Container",
          "properties": {
            "padding": "EdgeInsets.all(24)"
          },
          "children": [
            {
              "id": "name_text",
              "type": "Text",
              "properties": {
                "text": "Alex Johnson",
                "fontSize": 28,
                "fontWeight": "FontWeight.bold",
                "color": "#F8FAFC"
              },
              "children": []
            },
            {
              "id": "handle_text",
              "type": "Text",
              "properties": {
                "text": "@alexj_design",
                "fontSize": 16,
                "color": "#94A3B8"
              },
              "children": []
            },
            {
              "id": "bio_text",
              "type": "Container",
              "properties": {
                "margin": "EdgeInsets.only(top: 16)"
              },
              "children": [
                {
                  "id": "bio",
                  "type": "Text",
                  "properties": {
                    "text": "Digital creator & Flutter enthusiast. Building beautiful UI experiences every single day. 🚀✨",
                    "fontSize": 16,
                    "color": "#CBD5E1"
                  },
                  "children": []
                }
              ]
            },
            {
              "id": "stats_row",
              "type": "Row",
              "properties": {
                "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
              },
              "children": [
                {
                  "id": "stat_1",
                  "type": "Column",
                  "properties": {},
                  "children": [
                    {
                      "id": "s1_val",
                      "type": "Text",
                      "properties": {"text": "12.5K", "fontSize": 20, "fontWeight": "FontWeight.bold", "color": "#F8FAFC"},
                      "children": []
                    },
                    {
                      "id": "s1_lbl",
                      "type": "Text",
                      "properties": {"text": "Followers", "fontSize": 14, "color": "#64748B"},
                      "children": []
                    }
                  ]
                },
                {
                  "id": "stat_2",
                  "type": "Column",
                  "properties": {},
                  "children": [
                    {
                      "id": "s2_val",
                      "type": "Text",
                      "properties": {"text": "842", "fontSize": 20, "fontWeight": "FontWeight.bold", "color": "#F8FAFC"},
                      "children": []
                    },
                    {
                      "id": "s2_lbl",
                      "type": "Text",
                      "properties": {"text": "Following", "fontSize": 14, "color": "#64748B"},
                      "children": []
                    }
                  ]
                },
                {
                  "id": "stat_3",
                  "type": "Column",
                  "properties": {},
                  "children": [
                    {
                      "id": "s3_val",
                      "type": "Text",
                      "properties": {"text": "156", "fontSize": 20, "fontWeight": "FontWeight.bold", "color": "#F8FAFC"},
                      "children": []
                    },
                    {
                      "id": "s3_lbl",
                      "type": "Text",
                      "properties": {"text": "Posts", "fontSize": 14, "color": "#64748B"},
                      "children": []
                    }
                  ]
                }
              ]
            },
            {
              "id": "action_buttons",
              "type": "Row",
              "properties": {
                "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
              },
              "children": [
                {
                  "id": "follow_btn",
                  "type": "Container",
                  "properties": {
                    "color": "#3B82F6",
                    "width": 160,
                    "height": 48,
                    "borderRadius": 24,
                    "margin": "EdgeInsets.only(top: 24)"
                  },
                  "children": [
                    {
                      "id": "fb_center",
                      "type": "Center",
                      "properties": {},
                      "children": [
                        {
                          "id": "fb_txt",
                          "type": "Text",
                          "properties": {"text": "Follow", "color": "#FFFFFF", "fontSize": 16, "fontWeight": "FontWeight.bold"},
                          "children": []
                        }
                      ]
                    }
                  ]
                },
                {
                  "id": "msg_btn",
                  "type": "Container",
                  "properties": {
                    "color": "#1E293B",
                    "width": 160,
                    "height": 48,
                    "borderRadius": 24,
                    "margin": "EdgeInsets.only(top: 24)"
                  },
                  "children": [
                    {
                      "id": "mb_center",
                      "type": "Center",
                      "properties": {},
                      "children": [
                        {
                          "id": "mb_txt",
                          "type": "Text",
                          "properties": {"text": "Message", "color": "#F8FAFC", "fontSize": 16, "fontWeight": "FontWeight.bold"},
                          "children": []
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
'::jsonb),
('Login Screen', 'A beautiful general template.', 'General', '{
  "type": "Scaffold",
  "properties": {
    "backgroundColor": 4285887743
  },
  "children": [
    {
      "type": "SingleChildScrollView",
      "properties": {},
      "children": [
        {
          "type": "Column",
          "properties": {
            "crossAxisAlignment": "CrossAxisAlignment.stretch"
          },
          "children": [
            {
              "type": "Container",
              "properties": {
                "height": 280.0,
                "padding": { "left": 24.0, "right": 24.0, "top": 40.0, "bottom": 40.0 }
              },
              "children": [
                {
                  "type": "Column",
                  "properties": {
                    "mainAxisAlignment": "MainAxisAlignment.center",
                    "crossAxisAlignment": "CrossAxisAlignment.center"
                  },
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "width": 80.0,
                        "height": 80.0,
                        "color": 4294967295,
                        "borderRadius": 40.0
                      },
                      "children": [
                        {
                          "type": "Center",
                          "properties": {},
                          "children": [
                            {
                              "type": "Icon",
                              "properties": {
                                "icon": "Icons.lock_outline",
                                "size": 40.0,
                                "color": 4285887743
                              },
                              "children": []
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 16.0 },
                      "children": []
                    },
                    {
                      "type": "Text",
                      "properties": {
                        "text": "Welcome Back",
                        "fontSize": 28.0,
                        "fontWeight": "FontWeight.bold",
                        "color": 4294967295
                      },
                      "children": []
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 6.0 },
                      "children": []
                    },
                    {
                      "type": "Text",
                      "properties": {
                        "text": "Sign in to your account",
                        "fontSize": 16.0,
                        "color": 4294967295
                      },
                      "children": []
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "color": 4294967295,
                "borderRadius": 24.0,
                "padding": { "left": 24.0, "right": 24.0, "top": 36.0, "bottom": 24.0 }
              },
              "children": [
                {
                  "type": "Column",
                  "properties": {
                    "crossAxisAlignment": "CrossAxisAlignment.start"
                  },
                  "children": [
                    {
                      "type": "Text",
                      "properties": {
                        "text": "Email",
                        "fontSize": 14.0,
                        "fontWeight": "FontWeight.w600",
                        "color": 4281545544
                      },
                      "children": []
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 8.0 },
                      "children": []
                    },
                    {
                      "type": "TextField",
                      "properties": {
                        "hintText": "Enter your email",
                        "filled": true,
                        "fillColor": 4293848570,
                        "border": "OutlineInputBorder",
                        "prefixIcon": "Icons.email_outlined",
                        "contentPadding": { "left": 16.0, "right": 16.0, "top": 14.0, "bottom": 14.0 }
                      },
                      "children": []
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 20.0 },
                      "children": []
                    },
                    {
                      "type": "Text",
                      "properties": {
                        "text": "Password",
                        "fontSize": 14.0,
                        "fontWeight": "FontWeight.w600",
                        "color": 4281545544
                      },
                      "children": []
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 8.0 },
                      "children": []
                    },
                    {
                      "type": "TextField",
                      "properties": {
                        "hintText": "Enter your password",
                        "filled": true,
                        "fillColor": 4293848570,
                        "border": "OutlineInputBorder",
                        "prefixIcon": "Icons.lock_outline",
                        "contentPadding": { "left": 16.0, "right": 16.0, "top": 14.0, "bottom": 14.0 }
                      },
                      "children": []
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 12.0 },
                      "children": []
                    },
                    {
                      "type": "Row",
                      "properties": { "mainAxisAlignment": "MainAxisAlignment.end" },
                      "children": [
                        {
                          "type": "Text",
                          "properties": {
                            "text": "Forgot Password?",
                            "fontSize": 14.0,
                            "fontWeight": "FontWeight.w600",
                            "color": 4285887743
                          },
                          "children": []
                        }
                      ]
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 28.0 },
                      "children": []
                    },
                    {
                      "type": "Container",
                      "properties": {
                        "height": 54.0,
                        "color": 4285887743,
                        "borderRadius": 12.0
                      },
                      "children": [
                        {
                          "type": "Center",
                          "properties": {},
                          "children": [
                            {
                              "type": "Text",
                              "properties": {
                                "text": "Sign In",
                                "fontSize": 18.0,
                                "fontWeight": "FontWeight.bold",
                                "color": 4294967295
                              },
                              "children": []
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 24.0 },
                      "children": []
                    },
                    {
                      "type": "Row",
                      "properties": { "mainAxisAlignment": "MainAxisAlignment.center" },
                      "children": [
                        {
                          "type": "Text",
                          "properties": {
                            "text": "Don''t have an account?",
                            "fontSize": 14.0,
                            "color": 4288256409
                          },
                          "children": []
                        },
                        {
                          "type": "SizedBox",
                          "properties": { "width": 4.0 },
                          "children": []
                        },
                        {
                          "type": "Text",
                          "properties": {
                            "text": "Sign Up",
                            "fontSize": 14.0,
                            "fontWeight": "FontWeight.bold",
                            "color": 4285887743
                          },
                          "children": []
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}'::jsonb),
('Ecommerce Home', 'A beautiful e-commerce template.', 'E-commerce', '{
  "type": "Scaffold",
  "properties": {
    "backgroundColor": 4293848570,
    "appBar": {
      "type": "AppBar",
      "properties": {
        "title": "ShopEasy",
        "backgroundColor": 4285887743,
        "elevation": 0,
        "centerTitle": true,
        "actions": [
          {
            "type": "IconButton",
            "properties": {
              "icon": {
                "type": "Icon",
                "properties": {
                  "icon": "Icons.notifications_outlined",
                  "color": 4294967295
                }
              },
              "onPressed": "() {}"
            }
          },
          {
            "type": "IconButton",
            "properties": {
              "icon": {
                "type": "Icon",
                "properties": {
                  "icon": "Icons.shopping_bag_outlined",
                  "color": 4294967295
                }
              },
              "onPressed": "() {}"
            }
          }
        ]
      },
      "children": []
    },
    "bottomNavigationBar": {
      "type": "BottomNavigationBar",
      "properties": {
        "selectedItemColor": 4285887743,
        "unselectedItemColor": 4288256409,
        "type": "fixed",
        "items": [
          {
            "icon": {
              "type": "Icon",
              "properties": {
                "icon": "Icons.home_outlined"
              }
            },
            "label": "Home"
          },
          {
            "icon": {
              "type": "Icon",
              "properties": {
                "icon": "Icons.search_outlined"
              }
            },
            "label": "Search"
          },
          {
            "icon": {
              "type": "Icon",
              "properties": {
                "icon": "Icons.shopping_cart_outlined"
              }
            },
            "label": "Cart"
          },
          {
            "icon": {
              "type": "Icon",
              "properties": {
                "icon": "Icons.person_outline"
              }
            },
            "label": "Profile"
          }
        ]
      },
      "children": []
    }
  },
  "children": [
    {
      "type": "SingleChildScrollView",
      "properties": {},
      "children": [
        {
          "type": "Column",
          "properties": {
            "crossAxisAlignment": "CrossAxisAlignment.start"
          },
          "children": [
            {
              "type": "Container",
              "properties": {
                "padding": {
                  "left": 20.0,
                  "right": 20.0,
                  "top": 20.0,
                  "bottom": 10.0
                }
              },
              "children": [
                {
                  "type": "TextField",
                  "properties": {
                    "hintText": "Search for products...",
                    "filled": true,
                    "fillColor": 4294967295,
                    "border": "OutlineInputBorder",
                    "prefixIcon": "Icons.search",
                    "contentPadding": {
                      "left": 16.0,
                      "right": 16.0,
                      "top": 12.0,
                      "bottom": 12.0
                    }
                  },
                  "children": []
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": {
                  "left": 20.0,
                  "top": 20.0,
                  "bottom": 10.0
                }
              },
              "children": [
                {
                  "type": "Text",
                  "properties": {
                    "text": "Categories",
                    "fontSize": 20.0,
                    "fontWeight": "FontWeight.bold",
                    "color": 4281545544
                  },
                  "children": []
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "height": 120.0,
                "margin": {
                  "bottom": 20.0
                }
              },
              "children": [
                {
                  "type": "ListView",
                  "properties": {
                    "scrollDirection": "horizontal",
                    "padding": {
                      "left": 20.0,
                      "right": 20.0
                    }
                  },
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "width": 100.0,
                        "margin": {
                          "right": 15.0
                        },
                        "decoration": {
                          "borderRadius": 16.0,
                          "color": 4285887722
                        }
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": {
                            "mainAxisAlignment": "MainAxisAlignment.center"
                          },
                          "children": [
                            {
                              "type": "Icon",
                              "properties": {
                                "icon": "Icons.phone_android",
                                "size": 32.0,
                                "color": 4294967295
                              },
                              "children": []
                            },
                            {
                              "type": "SizedBox",
                              "properties": {
                                "height": 8.0
                              },
                              "children": []
                            },
                            {
                              "type": "Text",
                              "properties": {
                                "text": "Electronics",
                                "fontSize": 12.0,
                                "fontWeight": "FontWeight.w600",
                                "color": 4294967295,
                                "textAlign": "TextAlign.center"
                              },
                              "children": []
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Container",
                      "properties": {
                        "width": 100.0,
                        "margin": {
                          "right": 15.0
                        },
                        "decoration": {
                          "borderRadius": 16.0,
                          "color": 4294902685
                        }
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": {
                            "mainAxisAlignment": "MainAxisAlignment.center"
                          },
                          "children": [
                            {
                              "type": "Icon",
                              "properties": {
                                "icon": "Icons.checkroom",
                                "size": 32.0,
                                "color": 4294967295
                              },
                              "children": []
                            },
                            {
                              "type": "SizedBox",
                              "properties": {
                                "height": 8.0
                              },
                              "children": []
                            },
                            {
                              "type": "Text",
                              "properties": {
                                "text": "Fashion",
                                "fontSize": 12.0,
                                "fontWeight": "FontWeight.w600",
                                "color": 4294967295,
                                "textAlign": "TextAlign.center"
                              },
                              "children": []
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Container",
                      "properties": {
                        "width": 100.0,
                        "margin": {
                          "right": 15.0
                        },
                        "decoration": {
                          "borderRadius": 16.0,
                          "color": 4290020292
                        }
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": {
                            "mainAxisAlignment": "MainAxisAlignment.center"
                          },
                          "children": [
                            {
                              "type": "Icon",
                              "properties": {
                                "icon": "Icons.home_outlined",
                                "size": 32.0,
                                "color": 4294967295
                              },
                              "children": []
                            },
                            {
                              "type": "SizedBox",
                              "properties": {
                                "height": 8.0
                              },
                              "children": []
                            },
                            {
                              "type": "Text",
                              "properties": {
                                "text": "Home",
                                "fontSize": 12.0,
                                "fontWeight": "FontWeight.w600",
                                "color": 4294967295,
                                "textAlign": "TextAlign.center"
                              },
                              "children": []
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Container",
                      "properties": {
                        "width": 100.0,
                        "margin": {
                          "right": 15.0
                        },
                        "decoration": {
                          "borderRadius": 16.0,
                          "color": 4294944550
                        }
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": {
                            "mainAxisAlignment": "MainAxisAlignment.center"
                          },
                          "children": [
                            {
                              "type": "Icon",
                              "properties": {
                                "icon": "Icons.sports_soccer",
                                "size": 32.0,
                                "color": 4294967295
                              },
                              "children": []
                            },
                            {
                              "type": "SizedBox",
                              "properties": {
                                "height": 8.0
                              },
                              "children": []
                            },
                            {
                              "type": "Text",
                              "properties": {
                                "text": "Sports",
                                "fontSize": 12.0,
                                "fontWeight": "FontWeight.w600",
                                "color": 4294967295,
                                "textAlign": "TextAlign.center"
                              },
                              "children": []
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": {
                  "left": 20.0,
                  "bottom": 10.0
                }
              },
              "children": [
                {
                  "type": "Text",
                  "properties": {
                    "text": "Featured Products",
                    "fontSize": 20.0,
                    "fontWeight": "FontWeight.bold",
                    "color": 4281545544
                  },
                  "children": []
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": {
                  "left": 20.0,
                  "right": 20.0,
                  "bottom": 20.0
                },
                "height": 400.0
              },
              "children": [
                {
                  "type": "GridView",
                  "properties": {
                    "crossAxisCount": 2,
                    "mainAxisSpacing": 16.0,
                    "crossAxisSpacing": 16.0,
                    "childAspectRatio": 0.75,
                    "physics": "NeverScrollableScrollPhysics"
                  },
                  "children": [
                    {
                      "type": "Card",
                      "properties": {
                        "elevation": 4.0,
                        "shape": {
                          "borderRadius": 16.0
                        }
                      },
                      "children": [
                        {
                          "type": "Container",
                          "properties": {
                            "padding": 12.0,
                            "decoration": {
                              "borderRadius": 16.0,
                              "color": 4294967295
                            }
                          },
                          "children": [
                            {
                              "type": "Column",
                              "properties": {
                                "crossAxisAlignment": "CrossAxisAlignment.start"
                              },
                              "children": [
                                {
                                  "type": "Container",
                                  "properties": {
                                    "height": 100.0,
                                    "decoration": {
                                      "borderRadius": 12.0,
                                      "color": 4293256677
                                    }
                                  },
                                  "children": [
                                    {
                                      "type": "Center",
                                      "properties": {},
                                      "children": [
                                        {
                                          "type": "Icon",
                                          "properties": {
                                            "icon": "Icons.phone_android",
                                            "size": 48.0,
                                            "color": 4285887743
                                          },
                                          "children": []
                                        }
                                      ]
                                    }
                                  ]
                                },
                                {
                                  "type": "SizedBox",
                                  "properties": {
                                    "height": 8.0
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "iPhone 15 Pro",
                                    "fontSize": 14.0,
                                    "fontWeight": "FontWeight.w600",
                                    "color": 4281545544
                                  },
                                  "children": []
                                },
                                {
                                  "type": "SizedBox",
                                  "properties": {
                                    "height": 4.0
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "$999.99",
                                    "fontSize": 16.0,
                                    "fontWeight": "FontWeight.bold",
                                    "color": 4285887743
                                  },
                                  "children": []
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Card",
                      "properties": {
                        "elevation": 4.0,
                        "shape": {
                          "borderRadius": 16.0
                        }
                      },
                      "children": [
                        {
                          "type": "Container",
                          "properties": {
                            "padding": 12.0,
                            "decoration": {
                              "borderRadius": 16.0,
                              "color": 4294967295
                            }
                          },
                          "children": [
                            {
                              "type": "Column",
                              "properties": {
                                "crossAxisAlignment": "CrossAxisAlignment.start"
                              },
                              "children": [
                                {
                                  "type": "Container",
                                  "properties": {
                                    "height": 100.0,
                                    "decoration": {
                                      "borderRadius": 12.0,
                                      "color": 4293256677
                                    }
                                  },
                                  "children": [
                                    {
                                      "type": "Center",
                                      "properties": {},
                                      "children": [
                                        {
                                          "type": "Icon",
                                          "properties": {
                                            "icon": "Icons.laptop_mac",
                                            "size": 48.0,
                                            "color": 4285887722
                                          },
                                          "children": []
                                        }
                                      ]
                                    }
                                  ]
                                },
                                {
                                  "type": "SizedBox",
                                  "properties": {
                                    "height": 8.0
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "MacBook Pro",
                                    "fontSize": 14.0,
                                    "fontWeight": "FontWeight.w600",
                                    "color": 4281545544
                                  },
                                  "children": []
                                },
                                {
                                  "type": "SizedBox",
                                  "properties": {
                                    "height": 4.0
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "$1,299.99",
                                    "fontSize": 16.0,
                                    "fontWeight": "FontWeight.bold",
                                    "color": 4285887743
                                  },
                                  "children": []
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Card",
                      "properties": {
                        "elevation": 4.0,
                        "shape": {
                          "borderRadius": 16.0
                        }
                      },
                      "children": [
                        {
                          "type": "Container",
                          "properties": {
                            "padding": 12.0,
                            "decoration": {
                              "borderRadius": 16.0,
                              "color": 4294967295
                            }
                          },
                          "children": [
                            {
                              "type": "Column",
                              "properties": {
                                "crossAxisAlignment": "CrossAxisAlignment.start"
                              },
                              "children": [
                                {
                                  "type": "Container",
                                  "properties": {
                                    "height": 100.0,
                                    "decoration": {
                                      "borderRadius": 12.0,
                                      "color": 4293256677
                                    }
                                  },
                                  "children": [
                                    {
                                      "type": "Center",
                                      "properties": {},
                                      "children": [
                                        {
                                          "type": "Icon",
                                          "properties": {
                                            "icon": "Icons.headphones",
                                            "size": 48.0,
                                            "color": 4290020292
                                          },
                                          "children": []
                                        }
                                      ]
                                    }
                                  ]
                                },
                                {
                                  "type": "SizedBox",
                                  "properties": {
                                    "height": 8.0
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "AirPods Pro",
                                    "fontSize": 14.0,
                                    "fontWeight": "FontWeight.w600",
                                    "color": 4281545544
                                  },
                                  "children": []
                                },
                                {
                                  "type": "SizedBox",
                                  "properties": {
                                    "height": 4.0
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "$249.99",
                                    "fontSize": 16.0,
                                    "fontWeight": "FontWeight.bold",
                                    "color": 4285887743
                                  },
                                  "children": []
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Card",
                      "properties": {
                        "elevation": 4.0,
                        "shape": {
                          "borderRadius": 16.0
                        }
                      },
                      "children": [
                        {
                          "type": "Container",
                          "properties": {
                            "padding": 12.0,
                            "decoration": {
                              "borderRadius": 16.0,
                              "color": 4294967295
                            }
                          },
                          "children": [
                            {
                              "type": "Column",
                              "properties": {
                                "crossAxisAlignment": "CrossAxisAlignment.start"
                              },
                              "children": [
                                {
                                  "type": "Container",
                                  "properties": {
                                    "height": 100.0,
                                    "decoration": {
                                      "borderRadius": 12.0,
                                      "color": 4293256677
                                    }
                                  },
                                  "children": [
                                    {
                                      "type": "Center",
                                      "properties": {},
                                      "children": [
                                        {
                                          "type": "Icon",
                                          "properties": {
                                            "icon": "Icons.watch",
                                            "size": 48.0,
                                            "color": 4294902685
                                          },
                                          "children": []
                                        }
                                      ]
                                    }
                                  ]
                                },
                                {
                                  "type": "SizedBox",
                                  "properties": {
                                    "height": 8.0
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "Apple Watch",
                                    "fontSize": 14.0,
                                    "fontWeight": "FontWeight.w600",
                                    "color": 4281545544
                                  },
                                  "children": []
                                },
                                {
                                  "type": "SizedBox",
                                  "properties": {
                                    "height": 4.0
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "$399.99",
                                    "fontSize": 16.0,
                                    "fontWeight": "FontWeight.bold",
                                    "color": 4285887743
                                  },
                                  "children": []
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
'::jsonb),
('Todo App Professional', 'A beautiful productivity template.', 'Productivity', '[
  {
    "id": "todo_home",
    "type": "Scaffold",
    "properties": {
      "pageName": "Dashboard",
      "backgroundColor": "4294507000",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "backgroundColor": "4294507000",
          "elevation": 0,
          "centerTitle": false,
          "title": {
            "type": "Column",
            "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
            "children": [
              { "type": "Text", "properties": { "text": "Hello, Mohamed!", "fontSize": 14, "color": "4287931320" } },
              { "type": "Text", "properties": { "text": "Today''s Tasks", "fontSize": 24, "fontWeight": "bold", "color": "4280224059" } }
            ]
          },
          "actions": [
            { "type": "IconButton", "properties": { "icon": "Icons.account_circle", "navigateTo": "todo_profile" } }
          ]
        }
      },
      "bottomNavigationBar": {
        "type": "BottomNavigationBar",
        "properties": {
          "items": [
            { "icon": { "type": "Icon", "properties": { "icon": "Icons.home" } }, "label": "Home", "navigateTo": "todo_home" },
            { "icon": { "type": "Icon", "properties": { "icon": "Icons.person" } }, "label": "Profile", "navigateTo": "todo_profile" }
          ],
          "currentIndex": 0
        }
      },
      "floatingActionButton": {
        "type": "FloatingActionButton",
        "properties": {
          "backgroundColor": "4284704497",
          "navigateTo": "todo_add",
          "child": { "type": "Icon", "properties": { "icon": "Icons.add", "color": "4294967295" } }
        }
      }
    },
    "children": [
      {
        "type": "Column",
        "children": [
          {
            "type": "Container",
            "properties": { "height": 40, "paddingLeft": 16, "marginBottom": 16 },
            "children": [
              {
                "type": "ListView",
                "properties": { "scrollDirection": "horizontal" },
                "children": [
                  { "type": "Button", "properties": { "text": "All", "width": 60, "height": 30, "fillColor": "4284704497", "borderRadius": 20 } },
                  { "type": "SizedBox", "properties": { "width": 8 } },
                  { "type": "Button", "properties": { "text": "Work", "width": 80, "height": 30, "fillColor": "4292928504", "borderRadius": 20 } },
                  { "type": "SizedBox", "properties": { "width": 8 } },
                  { "type": "Button", "properties": { "text": "Health", "width": 80, "height": 30, "fillColor": "4292928504", "borderRadius": 20 } }
                ]
              }
            ]
          },
          {
            "type": "Expanded",
            "children": [
              {
                "type": "ListView",
                "properties": { "padding": 16 },
                "children": [
                  {
                    "type": "ListTile",
                    "properties": {
                      "title": "Design System Update",
                      "subtitle": "9:00 AM - 10:30 AM",
                      "leadingIcon": "Icons.check_circle_outline",
                      "leadingIconColor": 4284704497,
                      "trailingIcon": "Icons.chevron_right",
                      "navigateTo": "todo_details"
                    }
                  },
                  { "type": "SizedBox", "properties": { "height": 12 } },
                  {
                    "type": "ListTile",
                    "properties": {
                      "title": "App Architecture Review",
                      "subtitle": "11:00 AM - 12:00 PM",
                      "leadingIcon": "Icons.radio_button_unchecked",
                      "leadingIconColor": 4287931320,
                      "trailingIcon": "Icons.chevron_right",
                      "navigateTo": "todo_details"
                    }
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "todo_add",
    "type": "Scaffold",
    "properties": {
      "pageName": "Add Task",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "title": { "type": "Text", "properties": { "text": "New Task" } },
          "backgroundColor": "4284704497",
          "elevation": 0,
          "leading": {
            "type": "IconButton",
            "properties": { "icon": "Icons.close", "navigateTo": "todo_home" }
          }
        }
      }
    },
    "children": [
      {
        "type": "Padding",
        "properties": { "padding": 24 },
        "children": [
          {
            "type": "Column",
            "children": [
              { "type": "Text", "properties": { "text": "What is to be done?", "fontSize": 16, "fontWeight": "bold" } },
              { "type": "TextField", "properties": { "hintText": "Enter task name..." } },
              { "type": "SizedBox", "properties": { "height": 24 } },
              { "type": "Text", "properties": { "text": "Due Date", "fontSize": 16, "fontWeight": "bold" } },
              { "type": "TextField", "properties": { "hintText": "Pick a date", "icon": "Icons.calendar_today" } },
              { "type": "Spacer" },
              {
                "type": "Button",
                "properties": {
                  "text": "Create Task",
                  "width": 1000,
                  "height": 56,
                  "fillColor": "4284704497",
                  "borderRadius": 16,
                  "navigateTo": "todo_home"
                }
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "todo_details",
    "type": "Scaffold",
    "properties": {
      "pageName": "Task Details",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "title": { "type": "Text", "properties": { "text": "Task Details" } },
          "backgroundColor": "4294507000",
          "elevation": 0,
          "leading": {
            "type": "IconButton",
            "properties": { "icon": "Icons.arrow_back", "navigateTo": "todo_home" }
          }
        }
      }
    },
    "children": [
      {
        "type": "Padding",
        "properties": { "padding": 20 },
        "children": [
            {
                "type": "Column",
                "children": [
                    { "type": "Text", "properties": { "text": "Design System Update", "fontSize": 24, "fontWeight": "bold" } },
                    { "type": "SizedBox", "properties": { "height": 8 } },
                    { "type": "Text", "properties": { "text": "In Progress", "color": "4284704497", "fontWeight": "bold" } },
                    { "type": "SizedBox", "properties": { "height": 32 } },
                    { "type": "Text", "properties": { "text": "Description", "fontSize": 16, "fontWeight": "bold" } },
                    { "type": "Text", "properties": { "text": "Update the core design system for the mobile app project. Focus on the new color palette and typography rules.", "color": "4287931320" } },
                    { "type": "Spacer" },
                    { "type": "Button", "properties": { "text": "Mark as Complete", "width": 1000, "height": 50, "fillColor": "4284704497", "borderRadius": 12, "navigateTo": "todo_home" } }
                ]
            }
        ]
      }
    ]
  },
  {
    "id": "todo_profile",
    "type": "Scaffold",
    "properties": {
      "pageName": "Profile",
      "backgroundColor": "4294507000",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "title": { "type": "Text", "properties": { "text": "My Profile" } },
          "backgroundColor": "4294507000",
          "elevation": 0,
          "leading": {
            "type": "IconButton",
            "properties": { "icon": "Icons.arrow_back", "navigateTo": "todo_home" }
          }
        }
      },
      "bottomNavigationBar": {
        "type": "BottomNavigationBar",
        "properties": {
          "items": [
            { "icon": { "type": "Icon", "properties": { "icon": "Icons.home" } }, "label": "Home", "navigateTo": "todo_home" },
            { "icon": { "type": "Icon", "properties": { "icon": "Icons.person" } }, "label": "Profile", "navigateTo": "todo_profile" }
          ],
          "currentIndex": 1
        }
      }
    },
    "children": [
      {
        "type": "Column",
        "children": [
          { "type": "SizedBox", "properties": { "height": 40 } },
          { "type": "Center", "children": [ { "type": "CircleAvatar", "properties": { "radius": 60, "backgroundColor": "4284704497" } } ] },
          { "type": "SizedBox", "properties": { "height": 16 } },
          { "type": "Center", "children": [ { "type": "Text", "properties": { "text": "Mohamed Jalal", "fontSize": 24, "fontWeight": "bold" } } ] },
          { "type": "Center", "children": [ { "type": "Text", "properties": { "text": "Product Designer", "color": "4287931320" } } ] },
          { "type": "SizedBox", "properties": { "height": 48 } },
          { "type": "ListTile", "properties": { "title": "Settings", "leadingIcon": "Icons.settings", "trailingIcon": "Icons.chevron_right" } },
          { "type": "ListTile", "properties": { "title": "Statistics", "leadingIcon": "Icons.bar_chart", "trailingIcon": "Icons.chevron_right" } },
          { "type": "ListTile", "properties": { "title": "Logout", "leadingIcon": "Icons.logout", "leadingIconColor": 4294931021, "navigateTo": "todo_home" } }
        ]
      }
    ]
  }
]
'::jsonb),
('Settings Screen', 'A beautiful general template.', 'General', '{
  "type": "Scaffold",
  "properties": {
    "backgroundColor": 4293848570,
    "appBar": {
      "type": "AppBar",
      "properties": {
        "title": "Settings",
        "backgroundColor": 4294967295,
        "elevation": 0,
        "centerTitle": false
      },
      "children": []
    }
  },
  "children": [
    {
      "type": "SingleChildScrollView",
      "properties": {},
      "children": [
        {
          "type": "Column",
          "properties": {
            "crossAxisAlignment": "CrossAxisAlignment.start"
          },
          "children": [
            {
              "type": "Container",
              "properties": {
                "margin": { "left": 16.0, "right": 16.0, "top": 16.0, "bottom": 8.0 },
                "padding": { "left": 16.0, "right": 16.0, "top": 20.0, "bottom": 20.0 },
                "decoration": { "color": 4294967295, "borderRadius": 16.0 }
              },
              "children": [
                {
                  "type": "Row",
                  "properties": {},
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "width": 64.0, "height": 64.0,
                        "decoration": { "color": 4292533247, "borderRadius": 32.0 }
                      },
                      "children": [
                        {
                          "type": "Center", "properties": {},
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.person", "size": 32.0, "color": 4285887743 }, "children": [] }
                          ]
                        }
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 16.0 }, "children": [] },
                    {
                      "type": "Column",
                      "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                      "children": [
                        { "type": "Text", "properties": { "text": "John Doe", "fontSize": 18.0, "fontWeight": "FontWeight.bold", "color": 4281545544 }, "children": [] },
                        { "type": "Text", "properties": { "text": "john@example.com", "fontSize": 14.0, "color": 4288256409 }, "children": [] }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": { "padding": { "left": 16.0, "top": 16.0, "bottom": 8.0 } },
              "children": [
                { "type": "Text", "properties": { "text": "GENERAL", "fontSize": 12.0, "fontWeight": "FontWeight.w600", "color": 4288256409 }, "children": [] }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "margin": { "left": 16.0, "right": 16.0, "bottom": 4.0 },
                "decoration": { "color": 4294967295, "borderRadius": 16.0 }
              },
              "children": [
                {
                  "type": "Column",
                  "properties": {},
                  "children": [
                    {
                      "type": "ListTile",
                      "properties": {
                        "title": "Notifications",
                        "leading": { "type": "Icon", "properties": { "icon": "Icons.notifications_outlined", "color": 4285887743 }, "children": [] },
                        "trailing": { "type": "Icon", "properties": { "icon": "Icons.chevron_right", "color": 4288256409 }, "children": [] }
                      },
                      "children": []
                    },
                    {
                      "type": "ListTile",
                      "properties": {
                        "title": "Appearance",
                        "leading": { "type": "Icon", "properties": { "icon": "Icons.palette_outlined", "color": 4285887743 }, "children": [] },
                        "trailing": { "type": "Icon", "properties": { "icon": "Icons.chevron_right", "color": 4288256409 }, "children": [] }
                      },
                      "children": []
                    },
                    {
                      "type": "ListTile",
                      "properties": {
                        "title": "Language",
                        "leading": { "type": "Icon", "properties": { "icon": "Icons.language", "color": 4285887743 }, "children": [] },
                        "trailing": { "type": "Icon", "properties": { "icon": "Icons.chevron_right", "color": 4288256409 }, "children": [] }
                      },
                      "children": []
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": { "padding": { "left": 16.0, "top": 16.0, "bottom": 8.0 } },
              "children": [
                { "type": "Text", "properties": { "text": "ACCOUNT", "fontSize": 12.0, "fontWeight": "FontWeight.w600", "color": 4288256409 }, "children": [] }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "margin": { "left": 16.0, "right": 16.0, "bottom": 4.0 },
                "decoration": { "color": 4294967295, "borderRadius": 16.0 }
              },
              "children": [
                {
                  "type": "Column",
                  "properties": {},
                  "children": [
                    {
                      "type": "ListTile",
                      "properties": {
                        "title": "Edit Profile",
                        "leading": { "type": "Icon", "properties": { "icon": "Icons.edit_outlined", "color": 4285887743 }, "children": [] },
                        "trailing": { "type": "Icon", "properties": { "icon": "Icons.chevron_right", "color": 4288256409 }, "children": [] }
                      },
                      "children": []
                    },
                    {
                      "type": "ListTile",
                      "properties": {
                        "title": "Privacy",
                        "leading": { "type": "Icon", "properties": { "icon": "Icons.privacy_tip_outlined", "color": 4285887743 }, "children": [] },
                        "trailing": { "type": "Icon", "properties": { "icon": "Icons.chevron_right", "color": 4288256409 }, "children": [] }
                      },
                      "children": []
                    },
                    {
                      "type": "ListTile",
                      "properties": {
                        "title": "Security",
                        "leading": { "type": "Icon", "properties": { "icon": "Icons.security", "color": 4285887743 }, "children": [] },
                        "trailing": { "type": "Icon", "properties": { "icon": "Icons.chevron_right", "color": 4288256409 }, "children": [] }
                      },
                      "children": []
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "margin": { "left": 16.0, "right": 16.0, "top": 16.0, "bottom": 24.0 },
                "height": 54.0,
                "decoration": { "color": 4294927872, "borderRadius": 12.0 }
              },
              "children": [
                {
                  "type": "Center", "properties": {},
                  "children": [
                    { "type": "Text", "properties": { "text": "Sign Out", "fontSize": 16.0, "fontWeight": "FontWeight.bold", "color": 4294967295 }, "children": [] }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
'::jsonb),
('Fitlife Tracker', 'A beautiful fitness template.', 'Fitness', '[
  {
    "id": "fit_dashboard",
    "type": "Scaffold",
    "properties": {
      "pageName": "Dashboard",
      "backgroundColor": "4279505940",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "backgroundColor": "4279505940",
          "elevation": 0,
          "leading": {
            "type": "Padding",
            "properties": {
              "padding": 8
            },
            "children": [
              {
                "type": "CircleAvatar",
                "properties": {
                  "radius": 22,
                  "backgroundImage": "https://i.pravatar.cc/100?u=fitlife1"
                }
              }
            ]
          },
          "title": {
            "type": "Column",
            "properties": {
              "crossAxisAlignment": "CrossAxisAlignment.start"
            },
            "children": [
              {
                "type": "Text",
                "properties": {
                  "text": "Good Morning! \ud83d\udd25",
                  "fontSize": 16,
                  "fontWeight": "bold",
                  "color": "4294967295"
                }
              },
              {
                "type": "Text",
                "properties": {
                  "text": "Let''s crush your goals today",
                  "fontSize": 11,
                  "color": "4289309097"
                }
              }
            ]
          },
          "actions": [
            {
              "type": "IconButton",
              "properties": {
                "icon": "Icons.notifications_outlined",
                "color": "4294967295"
              }
            }
          ]
        }
      }
    },
    "children": [
      {
        "type": "SingleChildScrollView",
        "children": [
          {
            "type": "Column",
            "properties": {
              "crossAxisAlignment": "CrossAxisAlignment.start"
            },
            "children": [
              {
                "type": "Container",
                "properties": {
                  "margin": {
                    "left": 20,
                    "right": 20,
                    "top": 16
                  },
                  "padding": 24,
                  "borderRadius": 28,
                  "gradient": {
                    "colors": [
                      "4286259106",
                      "4284572001"
                    ],
                    "begin": "Alignment.topLeft",
                    "end": "Alignment.bottomRight"
                  }
                },
                "children": [
                  {
                    "type": "Column",
                    "properties": {
                      "crossAxisAlignment": "CrossAxisAlignment.start"
                    },
                    "children": [
                      {
                        "type": "Row",
                        "properties": {
                          "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
                        },
                        "children": [
                          {
                            "type": "Text",
                            "properties": {
                              "text": "Today''s Progress",
                              "fontSize": 18,
                              "fontWeight": "bold",
                              "color": "4294967295"
                            }
                          },
                          {
                            "type": "Container",
                            "properties": {
                              "width": 40,
                              "height": 40,
                              "borderRadius": 12,
                              "backgroundColor": "4294967295"
                            },
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.trending_up",
                                  "color": "4286259106",
                                  "size": 22
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 20
                        }
                      },
                      {
                        "type": "Row",
                        "properties": {
                          "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
                        },
                        "children": [
                          {
                            "type": "Column",
                            "children": [
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "2,450",
                                  "fontSize": 28,
                                  "fontWeight": "bold",
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Calories",
                                  "fontSize": 12,
                                  "color": "4294954112"
                                }
                              }
                            ]
                          },
                          {
                            "type": "Column",
                            "children": [
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "8,236",
                                  "fontSize": 28,
                                  "fontWeight": "bold",
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Steps",
                                  "fontSize": 12,
                                  "color": "4294954112"
                                }
                              }
                            ]
                          },
                          {
                            "type": "Column",
                            "children": [
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "45min",
                                  "fontSize": 28,
                                  "fontWeight": "bold",
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Active",
                                  "fontSize": 12,
                                  "color": "4294954112"
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "SizedBox",
                "properties": {
                  "height": 8
                }
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "top": 20,
                    "bottom": 10
                  }
                },
                "children": [
                  {
                    "type": "Text",
                    "properties": {
                      "text": "Quick Stats",
                      "fontSize": 18,
                      "fontWeight": "bold",
                      "color": "4294967295"
                    }
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "right": 20
                  }
                },
                "children": [
                  {
                    "type": "Row",
                    "properties": {
                      "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
                    },
                    "children": [
                      {
                        "type": "Container",
                        "properties": {
                          "width": 100,
                          "height": 110,
                          "borderRadius": 20,
                          "padding": 14,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Column",
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.local_fire_department",
                                  "color": "4294940672",
                                  "size": 28
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "height": 8
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "680",
                                  "fontSize": 18,
                                  "fontWeight": "bold",
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "kcal",
                                  "fontSize": 11,
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "width": 100,
                          "height": 110,
                          "borderRadius": 20,
                          "padding": 14,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Column",
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.water_drop",
                                  "color": "4282682111",
                                  "size": 28
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "height": 8
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "2.1L",
                                  "fontSize": 18,
                                  "fontWeight": "bold",
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "water",
                                  "fontSize": 11,
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "width": 100,
                          "height": 110,
                          "borderRadius": 20,
                          "padding": 14,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Column",
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.bedtime",
                                  "color": "4290148046",
                                  "size": 28
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "height": 8
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "7.5h",
                                  "fontSize": 18,
                                  "fontWeight": "bold",
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "sleep",
                                  "fontSize": 11,
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "top": 24,
                    "bottom": 10
                  }
                },
                "children": [
                  {
                    "type": "Text",
                    "properties": {
                      "text": "Recent Workouts",
                      "fontSize": 18,
                      "fontWeight": "bold",
                      "color": "4294967295"
                    }
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "right": 20,
                    "bottom": 24
                  }
                },
                "children": [
                  {
                    "type": "Column",
                    "children": [
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 16,
                          "borderRadius": 20,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Container",
                                "properties": {
                                  "width": 48,
                                  "height": 48,
                                  "borderRadius": 14,
                                  "backgroundColor": "4294919713"
                                },
                                "children": [
                                  {
                                    "type": "Icon",
                                    "properties": {
                                      "icon": "Icons.directions_run",
                                      "color": "4294967295",
                                      "size": 24
                                    }
                                  }
                                ]
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Expanded",
                                "children": [
                                  {
                                    "type": "Column",
                                    "properties": {
                                      "crossAxisAlignment": "CrossAxisAlignment.start"
                                    },
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Morning Run",
                                          "fontSize": 15,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      },
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "5.2 km  \u2022  35 min  \u2022  320 kcal",
                                          "fontSize": 12,
                                          "color": "4289309097"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.chevron_right",
                                  "color": "4289309097",
                                  "size": 24
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 12
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 16,
                          "borderRadius": 20,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Container",
                                "properties": {
                                  "width": 48,
                                  "height": 48,
                                  "borderRadius": 14,
                                  "backgroundColor": "4284572001"
                                },
                                "children": [
                                  {
                                    "type": "Icon",
                                    "properties": {
                                      "icon": "Icons.fitness_center",
                                      "color": "4294967295",
                                      "size": 24
                                    }
                                  }
                                ]
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Expanded",
                                "children": [
                                  {
                                    "type": "Column",
                                    "properties": {
                                      "crossAxisAlignment": "CrossAxisAlignment.start"
                                    },
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Weight Training",
                                          "fontSize": 15,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      },
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Upper Body  \u2022  50 min  \u2022  410 kcal",
                                          "fontSize": 12,
                                          "color": "4289309097"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.chevron_right",
                                  "color": "4289309097",
                                  "size": 24
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "fit_workouts",
    "type": "Scaffold",
    "properties": {
      "pageName": "Workouts",
      "backgroundColor": "4279505940",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "backgroundColor": "4279505940",
          "elevation": 0,
          "title": {
            "type": "Text",
            "properties": {
              "text": "Workouts",
              "fontSize": 22,
              "fontWeight": "bold",
              "color": "4294967295"
            }
          },
          "actions": [
            {
              "type": "IconButton",
              "properties": {
                "icon": "Icons.tune",
                "color": "4294967295"
              }
            }
          ]
        }
      }
    },
    "children": [
      {
        "type": "SingleChildScrollView",
        "children": [
          {
            "type": "Column",
            "properties": {
              "crossAxisAlignment": "CrossAxisAlignment.start"
            },
            "children": [
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "right": 20,
                    "top": 8
                  }
                },
                "children": [
                  {
                    "type": "Container",
                    "properties": {
                      "height": 50,
                      "borderRadius": 16,
                      "backgroundColor": "4280099887",
                      "padding": {
                        "left": 16
                      }
                    },
                    "children": [
                      {
                        "type": "Row",
                        "children": [
                          {
                            "type": "Icon",
                            "properties": {
                              "icon": "Icons.search",
                              "color": "4289309097",
                              "size": 22
                            }
                          },
                          {
                            "type": "SizedBox",
                            "properties": {
                              "width": 10
                            }
                          },
                          {
                            "type": "Text",
                            "properties": {
                              "text": "Search workouts...",
                              "fontSize": 14,
                              "color": "4289309097"
                            }
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "top": 24,
                    "bottom": 12
                  }
                },
                "children": [
                  {
                    "type": "Text",
                    "properties": {
                      "text": "Categories",
                      "fontSize": 18,
                      "fontWeight": "bold",
                      "color": "4294967295"
                    }
                  }
                ]
              },
              {
                "type": "Container",
                "properties": {
                  "height": 140,
                  "padding": {
                    "left": 20
                  }
                },
                "children": [
                  {
                    "type": "ListView",
                    "properties": {
                      "scrollDirection": "horizontal"
                    },
                    "children": [
                      {
                        "type": "Container",
                        "properties": {
                          "width": 130,
                          "borderRadius": 24,
                          "padding": 18,
                          "gradient": {
                            "colors": [
                              "4294919713",
                              "4294929408"
                            ],
                            "begin": "Alignment.topLeft",
                            "end": "Alignment.bottomRight"
                          }
                        },
                        "children": [
                          {
                            "type": "Column",
                            "properties": {
                              "crossAxisAlignment": "CrossAxisAlignment.start"
                            },
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.directions_run",
                                  "color": "4294967295",
                                  "size": 30
                                }
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Cardio",
                                  "color": "4294967295",
                                  "fontWeight": "bold",
                                  "fontSize": 16
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "12 exercises",
                                  "color": "4294967295",
                                  "fontSize": 11
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "width": 14
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "width": 130,
                          "borderRadius": 24,
                          "padding": 18,
                          "gradient": {
                            "colors": [
                              "4284572001",
                              "4286259106"
                            ],
                            "begin": "Alignment.topLeft",
                            "end": "Alignment.bottomRight"
                          }
                        },
                        "children": [
                          {
                            "type": "Column",
                            "properties": {
                              "crossAxisAlignment": "CrossAxisAlignment.start"
                            },
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.fitness_center",
                                  "color": "4294967295",
                                  "size": 30
                                }
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Strength",
                                  "color": "4294967295",
                                  "fontWeight": "bold",
                                  "fontSize": 16
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "18 exercises",
                                  "color": "4294967295",
                                  "fontSize": 11
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "width": 14
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "width": 130,
                          "borderRadius": 24,
                          "padding": 18,
                          "gradient": {
                            "colors": [
                              "4282682111",
                              "4280793343"
                            ],
                            "begin": "Alignment.topLeft",
                            "end": "Alignment.bottomRight"
                          }
                        },
                        "children": [
                          {
                            "type": "Column",
                            "properties": {
                              "crossAxisAlignment": "CrossAxisAlignment.start"
                            },
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.self_improvement",
                                  "color": "4294967295",
                                  "size": 30
                                }
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Yoga",
                                  "color": "4294967295",
                                  "fontWeight": "bold",
                                  "fontSize": 16
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "9 sessions",
                                  "color": "4294967295",
                                  "fontSize": 11
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "top": 24,
                    "bottom": 12
                  }
                },
                "children": [
                  {
                    "type": "Text",
                    "properties": {
                      "text": "Popular Plans",
                      "fontSize": 18,
                      "fontWeight": "bold",
                      "color": "4294967295"
                    }
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "right": 20,
                    "bottom": 20
                  }
                },
                "children": [
                  {
                    "type": "Column",
                    "children": [
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 20,
                          "borderRadius": 22,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Container",
                                "properties": {
                                  "width": 56,
                                  "height": 56,
                                  "borderRadius": 16,
                                  "backgroundColor": "4294931456"
                                },
                                "children": [
                                  {
                                    "type": "Icon",
                                    "properties": {
                                      "icon": "Icons.bolt",
                                      "color": "4294967295",
                                      "size": 28
                                    }
                                  }
                                ]
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 16
                                }
                              },
                              {
                                "type": "Expanded",
                                "children": [
                                  {
                                    "type": "Column",
                                    "properties": {
                                      "crossAxisAlignment": "CrossAxisAlignment.start"
                                    },
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "HIIT Blaster",
                                          "fontSize": 16,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      },
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "30 min  \u2022  Intense  \u2022  450 kcal",
                                          "fontSize": 12,
                                          "color": "4289309097"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.play_circle_filled",
                                  "color": "4294919713",
                                  "size": 36
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 12
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 20,
                          "borderRadius": 22,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Container",
                                "properties": {
                                  "width": 56,
                                  "height": 56,
                                  "borderRadius": 16,
                                  "backgroundColor": "4278238420"
                                },
                                "children": [
                                  {
                                    "type": "Icon",
                                    "properties": {
                                      "icon": "Icons.spa",
                                      "color": "4294967295",
                                      "size": 28
                                    }
                                  }
                                ]
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 16
                                }
                              },
                              {
                                "type": "Expanded",
                                "children": [
                                  {
                                    "type": "Column",
                                    "properties": {
                                      "crossAxisAlignment": "CrossAxisAlignment.start"
                                    },
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Core & Stretch",
                                          "fontSize": 16,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      },
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "20 min  \u2022  Easy  \u2022  180 kcal",
                                          "fontSize": 12,
                                          "color": "4289309097"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.play_circle_filled",
                                  "color": "4278238420",
                                  "size": 36
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 12
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 20,
                          "borderRadius": 22,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Container",
                                "properties": {
                                  "width": 56,
                                  "height": 56,
                                  "borderRadius": 16,
                                  "backgroundColor": "4290148046"
                                },
                                "children": [
                                  {
                                    "type": "Icon",
                                    "properties": {
                                      "icon": "Icons.pool",
                                      "color": "4294967295",
                                      "size": 28
                                    }
                                  }
                                ]
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 16
                                }
                              },
                              {
                                "type": "Expanded",
                                "children": [
                                  {
                                    "type": "Column",
                                    "properties": {
                                      "crossAxisAlignment": "CrossAxisAlignment.start"
                                    },
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Swim Power",
                                          "fontSize": 16,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      },
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "45 min  \u2022  Medium  \u2022  380 kcal",
                                          "fontSize": 12,
                                          "color": "4289309097"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.play_circle_filled",
                                  "color": "4290148046",
                                  "size": 36
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "fit_activity",
    "type": "Scaffold",
    "properties": {
      "pageName": "Activity",
      "backgroundColor": "4279505940",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "backgroundColor": "4279505940",
          "elevation": 0,
          "title": {
            "type": "Text",
            "properties": {
              "text": "Activity Feed",
              "fontSize": 22,
              "fontWeight": "bold",
              "color": "4294967295"
            }
          },
          "actions": [
            {
              "type": "IconButton",
              "properties": {
                "icon": "Icons.calendar_month",
                "color": "4294967295"
              }
            }
          ]
        }
      }
    },
    "children": [
      {
        "type": "SingleChildScrollView",
        "children": [
          {
            "type": "Column",
            "children": [
              {
                "type": "Container",
                "properties": {
                  "margin": {
                    "left": 20,
                    "right": 20,
                    "top": 8
                  },
                  "padding": 20,
                  "borderRadius": 24,
                  "gradient": {
                    "colors": [
                      "4278238420",
                      "4280793343"
                    ],
                    "begin": "Alignment.topLeft",
                    "end": "Alignment.bottomRight"
                  }
                },
                "children": [
                  {
                    "type": "Row",
                    "children": [
                      {
                        "type": "Expanded",
                        "children": [
                          {
                            "type": "Column",
                            "properties": {
                              "crossAxisAlignment": "CrossAxisAlignment.start"
                            },
                            "children": [
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Weekly Goal",
                                  "fontSize": 14,
                                  "color": "4294954112"
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "4 of 5 days",
                                  "fontSize": 26,
                                  "fontWeight": "bold",
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Keep going! \ud83d\udcaa",
                                  "fontSize": 14,
                                  "color": "4294967295"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "Spacer"
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "width": 64,
                          "height": 64,
                          "borderRadius": 32,
                          "backgroundColor": "4294967295"
                        },
                        "children": [
                          {
                            "type": "Center",
                            "children": [
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "80%",
                                  "fontSize": 18,
                                  "fontWeight": "bold",
                                  "color": "4278238420"
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "top": 24,
                    "bottom": 12
                  }
                },
                "children": [
                  {
                    "type": "Text",
                    "properties": {
                      "text": "Today",
                      "fontSize": 16,
                      "fontWeight": "bold",
                      "color": "4289309097"
                    }
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "right": 20
                  }
                },
                "children": [
                  {
                    "type": "Column",
                    "children": [
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 16,
                          "borderRadius": 18,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "CircleAvatar",
                                "properties": {
                                  "radius": 22,
                                  "backgroundImage": "https://i.pravatar.cc/100?u=fitlife1"
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Expanded",
                                "children": [
                                  {
                                    "type": "Column",
                                    "properties": {
                                      "crossAxisAlignment": "CrossAxisAlignment.start"
                                    },
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Morning Run \u2600\ufe0f",
                                          "fontSize": 15,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      },
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "5.2 km in 35 min",
                                          "fontSize": 12,
                                          "color": "4289309097"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "7:30 AM",
                                  "fontSize": 11,
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 10
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 16,
                          "borderRadius": 18,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "CircleAvatar",
                                "properties": {
                                  "radius": 22,
                                  "backgroundImage": "https://i.pravatar.cc/100?u=fitlife1"
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Expanded",
                                "children": [
                                  {
                                    "type": "Column",
                                    "properties": {
                                      "crossAxisAlignment": "CrossAxisAlignment.start"
                                    },
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Water Intake \ud83d\udca7",
                                          "fontSize": 15,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      },
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "1.5L of 2.5L goal",
                                          "fontSize": 12,
                                          "color": "4289309097"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "12:00 PM",
                                  "fontSize": 11,
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 10
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 16,
                          "borderRadius": 18,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "CircleAvatar",
                                "properties": {
                                  "radius": 22,
                                  "backgroundImage": "https://i.pravatar.cc/100?u=fitlife1"
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Expanded",
                                "children": [
                                  {
                                    "type": "Column",
                                    "properties": {
                                      "crossAxisAlignment": "CrossAxisAlignment.start"
                                    },
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Gym Session \ud83c\udfcb\ufe0f",
                                          "fontSize": 15,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      },
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "Upper body  \u2022  50 min",
                                          "fontSize": 12,
                                          "color": "4289309097"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "5:00 PM",
                                  "fontSize": 11,
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "top": 24,
                    "bottom": 12
                  }
                },
                "children": [
                  {
                    "type": "Text",
                    "properties": {
                      "text": "Yesterday",
                      "fontSize": 16,
                      "fontWeight": "bold",
                      "color": "4289309097"
                    }
                  }
                ]
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "right": 20,
                    "bottom": 24
                  }
                },
                "children": [
                  {
                    "type": "Container",
                    "properties": {
                      "padding": 16,
                      "borderRadius": 18,
                      "backgroundColor": "4280099887"
                    },
                    "children": [
                      {
                        "type": "Row",
                        "children": [
                          {
                            "type": "CircleAvatar",
                            "properties": {
                              "radius": 22,
                              "backgroundImage": "https://i.pravatar.cc/100?u=fitlife1"
                            }
                          },
                          {
                            "type": "SizedBox",
                            "properties": {
                              "width": 14
                            }
                          },
                          {
                            "type": "Expanded",
                            "children": [
                              {
                                "type": "Column",
                                "properties": {
                                  "crossAxisAlignment": "CrossAxisAlignment.start"
                                },
                                "children": [
                                  {
                                    "type": "Text",
                                    "properties": {
                                      "text": "Yoga Session \ud83e\uddd8",
                                      "fontSize": 15,
                                      "fontWeight": "bold",
                                      "color": "4294967295"
                                    }
                                  },
                                  {
                                    "type": "Text",
                                    "properties": {
                                      "text": "Flexibility flow  \u2022  30 min",
                                      "fontSize": 12,
                                      "color": "4289309097"
                                    }
                                  }
                                ]
                              }
                            ]
                          },
                          {
                            "type": "Spacer"
                          },
                          {
                            "type": "Text",
                            "properties": {
                              "text": "6:30 PM",
                              "fontSize": 11,
                              "color": "4289309097"
                            }
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "fit_profile",
    "type": "Scaffold",
    "properties": {
      "pageName": "Profile",
      "backgroundColor": "4279505940",
      "appBar": {
        "type": "AppBar",
        "properties": {
          "backgroundColor": "4279505940",
          "elevation": 0,
          "title": {
            "type": "Text",
            "properties": {
              "text": "Profile",
              "fontSize": 22,
              "fontWeight": "bold",
              "color": "4294967295"
            }
          },
          "actions": [
            {
              "type": "IconButton",
              "properties": {
                "icon": "Icons.settings",
                "color": "4294967295"
              }
            }
          ]
        }
      }
    },
    "children": [
      {
        "type": "SingleChildScrollView",
        "children": [
          {
            "type": "Column",
            "children": [
              {
                "type": "SizedBox",
                "properties": {
                  "height": 20
                }
              },
              {
                "type": "Center",
                "children": [
                  {
                    "type": "CircleAvatar",
                    "properties": {
                      "radius": 52,
                      "backgroundImage": "https://i.pravatar.cc/200?u=fitlife1"
                    }
                  }
                ]
              },
              {
                "type": "SizedBox",
                "properties": {
                  "height": 16
                }
              },
              {
                "type": "Center",
                "children": [
                  {
                    "type": "Text",
                    "properties": {
                      "text": "Mohamed Jalal",
                      "fontSize": 24,
                      "fontWeight": "bold",
                      "color": "4294967295"
                    }
                  }
                ]
              },
              {
                "type": "Center",
                "children": [
                  {
                    "type": "Text",
                    "properties": {
                      "text": "Fitness Enthusiast  \ud83c\udfc6  Elite Member",
                      "fontSize": 14,
                      "color": "4289309097"
                    }
                  }
                ]
              },
              {
                "type": "SizedBox",
                "properties": {
                  "height": 24
                }
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 30,
                    "right": 30
                  }
                },
                "children": [
                  {
                    "type": "Row",
                    "properties": {
                      "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
                    },
                    "children": [
                      {
                        "type": "Column",
                        "children": [
                          {
                            "type": "Text",
                            "properties": {
                              "text": "156",
                              "fontSize": 24,
                              "fontWeight": "bold",
                              "color": "4294919713"
                            }
                          },
                          {
                            "type": "Text",
                            "properties": {
                              "text": "Workouts",
                              "fontSize": 12,
                              "color": "4289309097"
                            }
                          }
                        ]
                      },
                      {
                        "type": "Column",
                        "children": [
                          {
                            "type": "Text",
                            "properties": {
                              "text": "48.2K",
                              "fontSize": 24,
                              "fontWeight": "bold",
                              "color": "4282682111"
                            }
                          },
                          {
                            "type": "Text",
                            "properties": {
                              "text": "Calories",
                              "fontSize": 12,
                              "color": "4289309097"
                            }
                          }
                        ]
                      },
                      {
                        "type": "Column",
                        "children": [
                          {
                            "type": "Text",
                            "properties": {
                              "text": "23",
                              "fontSize": 24,
                              "fontWeight": "bold",
                              "color": "4278238420"
                            }
                          },
                          {
                            "type": "Text",
                            "properties": {
                              "text": "Streak \ud83d\udd25",
                              "fontSize": 12,
                              "color": "4289309097"
                            }
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "SizedBox",
                "properties": {
                  "height": 24
                }
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "right": 20
                  }
                },
                "children": [
                  {
                    "type": "Row",
                    "properties": {
                      "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
                    },
                    "children": [
                      {
                        "type": "Container",
                        "properties": {
                          "width": 150,
                          "height": 48,
                          "borderRadius": 24,
                          "backgroundColor": "4286259106"
                        },
                        "children": [
                          {
                            "type": "Center",
                            "children": [
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Edit Profile",
                                  "color": "4294967295",
                                  "fontSize": 14,
                                  "fontWeight": "bold"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "width": 150,
                          "height": 48,
                          "borderRadius": 24,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Center",
                            "children": [
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Share",
                                  "color": "4294967295",
                                  "fontSize": 14,
                                  "fontWeight": "bold"
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              },
              {
                "type": "SizedBox",
                "properties": {
                  "height": 30
                }
              },
              {
                "type": "Padding",
                "properties": {
                  "padding": {
                    "left": 20,
                    "right": 20,
                    "bottom": 24
                  }
                },
                "children": [
                  {
                    "type": "Column",
                    "children": [
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 18,
                          "borderRadius": 18,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.person_outline",
                                  "color": "4286259106",
                                  "size": 24
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Personal Info",
                                  "fontSize": 15,
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.chevron_right",
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 10
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 18,
                          "borderRadius": 18,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.emoji_events",
                                  "color": "4294931456",
                                  "size": 24
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Achievements",
                                  "fontSize": 15,
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Container",
                                "properties": {
                                  "width": 28,
                                  "height": 28,
                                  "borderRadius": 14,
                                  "backgroundColor": "4294919713"
                                },
                                "children": [
                                  {
                                    "type": "Center",
                                    "children": [
                                      {
                                        "type": "Text",
                                        "properties": {
                                          "text": "12",
                                          "fontSize": 11,
                                          "fontWeight": "bold",
                                          "color": "4294967295"
                                        }
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 10
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 18,
                          "borderRadius": 18,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.notifications_outlined",
                                  "color": "4282682111",
                                  "size": 24
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Notifications",
                                  "fontSize": 15,
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.chevron_right",
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 10
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 18,
                          "borderRadius": 18,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.privacy_tip_outlined",
                                  "color": "4278238420",
                                  "size": 24
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Privacy & Security",
                                  "fontSize": 15,
                                  "color": "4294967295"
                                }
                              },
                              {
                                "type": "Spacer"
                              },
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.chevron_right",
                                  "color": "4289309097"
                                }
                              }
                            ]
                          }
                        ]
                      },
                      {
                        "type": "SizedBox",
                        "properties": {
                          "height": 10
                        }
                      },
                      {
                        "type": "Container",
                        "properties": {
                          "padding": 18,
                          "borderRadius": 18,
                          "backgroundColor": "4280099887"
                        },
                        "children": [
                          {
                            "type": "Row",
                            "children": [
                              {
                                "type": "Icon",
                                "properties": {
                                  "icon": "Icons.logout",
                                  "color": "4294919713",
                                  "size": 24
                                }
                              },
                              {
                                "type": "SizedBox",
                                "properties": {
                                  "width": 14
                                }
                              },
                              {
                                "type": "Text",
                                "properties": {
                                  "text": "Log Out",
                                  "fontSize": 15,
                                  "color": "4294919713"
                                }
                              }
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
]'::jsonb),
('Food Delivery', 'A beautiful food template.', 'Food', '{
  "type": "Scaffold",
  "properties": {
    "backgroundColor": 4294967295,
    "bottomNavigationBar": {
      "type": "BottomNavigationBar",
      "properties": {
        "selectedItemColor": 4294927872,
        "unselectedItemColor": 4288256409,
        "type": "fixed",
        "items": [
          { "icon": { "type": "Icon", "properties": { "icon": "Icons.home_outlined" } }, "label": "Home" },
          { "icon": { "type": "Icon", "properties": { "icon": "Icons.search" } }, "label": "Search" },
          { "icon": { "type": "Icon", "properties": { "icon": "Icons.shopping_bag_outlined" } }, "label": "Orders" },
          { "icon": { "type": "Icon", "properties": { "icon": "Icons.person_outline" } }, "label": "Profile" }
        ]
      },
      "children": []
    }
  },
  "children": [
    {
      "type": "SingleChildScrollView",
      "properties": {},
      "children": [
        {
          "type": "Column",
          "properties": {
            "crossAxisAlignment": "CrossAxisAlignment.start"
          },
          "children": [
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 20.0, "right": 20.0, "top": 20.0, "bottom": 20.0 },
                "decoration": {
                  "color": 4294927872,
                  "borderRadius": 0
                }
              },
              "children": [
                {
                  "type": "Column",
                  "properties": {
                    "crossAxisAlignment": "CrossAxisAlignment.start"
                  },
                  "children": [
                    {
                      "type": "Row",
                      "properties": {
                        "mainAxisAlignment": "MainAxisAlignment.spaceBetween"
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": {
                            "crossAxisAlignment": "CrossAxisAlignment.start"
                          },
                          "children": [
                            {
                              "type": "Text",
                              "properties": {
                                "text": "Deliver to",
                                "fontSize": 14.0,
                                "color": 4294967295
                              },
                              "children": []
                            },
                            {
                              "type": "Row",
                              "properties": {},
                              "children": [
                                {
                                  "type": "Icon",
                                  "properties": {
                                    "icon": "Icons.location_on",
                                    "size": 18.0,
                                    "color": 4294967295
                                  },
                                  "children": []
                                },
                                {
                                  "type": "Text",
                                  "properties": {
                                    "text": "New York, USA",
                                    "fontSize": 16.0,
                                    "fontWeight": "FontWeight.bold",
                                    "color": 4294967295
                                  },
                                  "children": []
                                }
                              ]
                            }
                          ]
                        },
                        {
                          "type": "Icon",
                          "properties": {
                            "icon": "Icons.notifications_outlined",
                            "color": 4294967295,
                            "size": 28.0
                          },
                          "children": []
                        }
                      ]
                    },
                    {
                      "type": "SizedBox",
                      "properties": { "height": 16.0 },
                      "children": []
                    },
                    {
                      "type": "TextField",
                      "properties": {
                        "hintText": "Search for food, restaurants...",
                        "filled": true,
                        "fillColor": 4294967295,
                        "border": "OutlineInputBorder",
                        "prefixIcon": "Icons.search",
                        "contentPadding": { "left": 16.0, "right": 16.0, "top": 12.0, "bottom": 12.0 }
                      },
                      "children": []
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 20.0, "top": 20.0, "bottom": 10.0 }
              },
              "children": [
                {
                  "type": "Text",
                  "properties": {
                    "text": "Categories",
                    "fontSize": 20.0,
                    "fontWeight": "FontWeight.bold",
                    "color": 4281545544
                  },
                  "children": []
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "height": 110.0,
                "margin": { "bottom": 8.0 }
              },
              "children": [
                {
                  "type": "ListView",
                  "properties": {
                    "scrollDirection": "horizontal",
                    "padding": { "left": 20.0, "right": 20.0 }
                  },
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "width": 90.0,
                        "margin": { "right": 12.0 },
                        "decoration": { "color": 4294963398, "borderRadius": 16.0 }
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": { "mainAxisAlignment": "MainAxisAlignment.center" },
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.local_pizza", "size": 32.0, "color": 4294927872 }, "children": [] },
                            { "type": "SizedBox", "properties": { "height": 6.0 }, "children": [] },
                            { "type": "Text", "properties": { "text": "Pizza", "fontSize": 12.0, "fontWeight": "FontWeight.w600", "color": 4281545544, "textAlign": "TextAlign.center" }, "children": [] }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Container",
                      "properties": {
                        "width": 90.0,
                        "margin": { "right": 12.0 },
                        "decoration": { "color": 4294963398, "borderRadius": 16.0 }
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": { "mainAxisAlignment": "MainAxisAlignment.center" },
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.ramen_dining", "size": 32.0, "color": 4294927872 }, "children": [] },
                            { "type": "SizedBox", "properties": { "height": 6.0 }, "children": [] },
                            { "type": "Text", "properties": { "text": "Noodles", "fontSize": 12.0, "fontWeight": "FontWeight.w600", "color": 4281545544, "textAlign": "TextAlign.center" }, "children": [] }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Container",
                      "properties": {
                        "width": 90.0,
                        "margin": { "right": 12.0 },
                        "decoration": { "color": 4294963398, "borderRadius": 16.0 }
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": { "mainAxisAlignment": "MainAxisAlignment.center" },
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.rice_bowl", "size": 32.0, "color": 4294927872 }, "children": [] },
                            { "type": "SizedBox", "properties": { "height": 6.0 }, "children": [] },
                            { "type": "Text", "properties": { "text": "Burgers", "fontSize": 12.0, "fontWeight": "FontWeight.w600", "color": 4281545544, "textAlign": "TextAlign.center" }, "children": [] }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Container",
                      "properties": {
                        "width": 90.0,
                        "margin": { "right": 12.0 },
                        "decoration": { "color": 4294963398, "borderRadius": 16.0 }
                      },
                      "children": [
                        {
                          "type": "Column",
                          "properties": { "mainAxisAlignment": "MainAxisAlignment.center" },
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.local_drink", "size": 32.0, "color": 4294927872 }, "children": [] },
                            { "type": "SizedBox", "properties": { "height": 6.0 }, "children": [] },
                            { "type": "Text", "properties": { "text": "Drinks", "fontSize": 12.0, "fontWeight": "FontWeight.w600", "color": 4281545544, "textAlign": "TextAlign.center" }, "children": [] }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 20.0, "top": 12.0, "bottom": 10.0 }
              },
              "children": [
                {
                  "type": "Text",
                  "properties": {
                    "text": "Popular Restaurants",
                    "fontSize": 20.0,
                    "fontWeight": "FontWeight.bold",
                    "color": 4281545544
                  },
                  "children": []
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 20.0, "right": 20.0, "bottom": 8.0 },
                "decoration": { "color": 4294967295, "borderRadius": 16.0 },
                "margin": { "left": 20.0, "right": 20.0, "bottom": 16.0 }
              },
              "children": [
                {
                  "type": "Column",
                  "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "height": 140.0,
                        "decoration": { "color": 4294963398, "borderRadius": 12.0 }
                      },
                      "children": [
                        {
                          "type": "Center",
                          "properties": {},
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.restaurant", "size": 56.0, "color": 4294927872 }, "children": [] }
                          ]
                        }
                      ]
                    },
                    { "type": "SizedBox", "properties": { "height": 10.0 }, "children": [] },
                    {
                      "type": "Row",
                      "properties": { "mainAxisAlignment": "MainAxisAlignment.spaceBetween" },
                      "children": [
                        {
                          "type": "Text",
                          "properties": { "text": "Mario''s Italian Kitchen", "fontSize": 16.0, "fontWeight": "FontWeight.bold", "color": 4281545544 },
                          "children": []
                        },
                        {
                          "type": "Row",
                          "properties": {},
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.star", "size": 16.0, "color": 4294944550 }, "children": [] },
                            { "type": "Text", "properties": { "text": "4.8", "fontSize": 14.0, "fontWeight": "FontWeight.w600", "color": 4281545544 }, "children": [] }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Row",
                      "properties": {},
                      "children": [
                        { "type": "Icon", "properties": { "icon": "Icons.access_time", "size": 14.0, "color": 4288256409 }, "children": [] },
                        { "type": "SizedBox", "properties": { "width": 4.0 }, "children": [] },
                        { "type": "Text", "properties": { "text": "25-30 min  •  Free delivery", "fontSize": 13.0, "color": 4288256409 }, "children": [] }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 20.0, "right": 20.0, "bottom": 24.0 },
                "decoration": { "color": 4294967295, "borderRadius": 16.0 },
                "margin": { "left": 20.0, "right": 20.0, "bottom": 16.0 }
              },
              "children": [
                {
                  "type": "Column",
                  "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "height": 140.0,
                        "decoration": { "color": 4292533247, "borderRadius": 12.0 }
                      },
                      "children": [
                        {
                          "type": "Center",
                          "properties": {},
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.local_pizza", "size": 56.0, "color": 4285887743 }, "children": [] }
                          ]
                        }
                      ]
                    },
                    { "type": "SizedBox", "properties": { "height": 10.0 }, "children": [] },
                    {
                      "type": "Row",
                      "properties": { "mainAxisAlignment": "MainAxisAlignment.spaceBetween" },
                      "children": [
                        {
                          "type": "Text",
                          "properties": { "text": "Pizza Palace", "fontSize": 16.0, "fontWeight": "FontWeight.bold", "color": 4281545544 },
                          "children": []
                        },
                        {
                          "type": "Row",
                          "properties": {},
                          "children": [
                            { "type": "Icon", "properties": { "icon": "Icons.star", "size": 16.0, "color": 4294944550 }, "children": [] },
                            { "type": "Text", "properties": { "text": "4.6", "fontSize": 14.0, "fontWeight": "FontWeight.w600", "color": 4281545544 }, "children": [] }
                          ]
                        }
                      ]
                    },
                    {
                      "type": "Row",
                      "properties": {},
                      "children": [
                        { "type": "Icon", "properties": { "icon": "Icons.access_time", "size": 14.0, "color": 4288256409 }, "children": [] },
                        { "type": "SizedBox", "properties": { "width": 4.0 }, "children": [] },
                        { "type": "Text", "properties": { "text": "35-45 min  •  $2.99 delivery", "fontSize": 13.0, "color": 4288256409 }, "children": [] }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
'::jsonb),
('Treads App', 'A beautiful general template.', 'General', '{
  "type": "Scaffold",
  "properties": {
    "backgroundColor": "4294967295",
    "appBar": {
      "type": "AppBar",
      "properties": {
        "backgroundColor": "4294967295",
        "elevation": 0,
        "centerTitle": true,
        "title": {
          "type": "Row",
          "properties": {
            "mainAxisAlignment": "MainAxisAlignment.center"
          },
          "children": [
            {
              "type": "Icon",
              "properties": {
                "icon": "Icons.alternate_email",
                "color": "4284704497",
                "size": 28
              }
            },
            {
              "type": "SizedBox",
              "properties": { "width": 8 }
            },
            {
              "type": "Text",
              "properties": {
                "text": "treads.io",
                "fontSize": 24,
                "fontWeight": "w800",
                "color": "4280427050"
              }
            }
          ]
        }
      }
    },
    "bottomNavigationBar": {
      "type": "BottomNavigationBar",
      "properties": {
        "backgroundColor": "4294967295",
        "selectedItemColor": "4284704497",
        "unselectedItemColor": "4287600792",
        "currentIndex": 0,
        "type": "fixed",
        "items": [
          { 
            "icon": { "type": "Icon", "properties": { "icon": "Icons.alternate_email" } }, 
            "label": "Home" 
          },
          { 
            "icon": { "type": "Icon", "properties": { "icon": "Icons.chat_bubble_outline" } }, 
            "label": "Search" 
          },
          { 
            "icon": { "type": "Icon", "properties": { "icon": "Icons.person_outline" } }, 
            "label": "Profile" 
          }
        ]
      }
    },
    "floatingActionButton": {
      "type": "FloatingActionButton",
      "properties": {
        "backgroundColor": "4284704497",
        "child": {
          "type": "Icon",
          "properties": {
            "icon": "Icons.edit",
            "color": "4294967295",
            "size": 20
          }
        }
      }
    }
  },
  "children": [
    {
      "type": "SingleChildScrollView",
      "properties": {},
      "children": [
        {
          "type": "Column",
          "properties": {
            "crossAxisAlignment": "CrossAxisAlignment.start"
          },
          "children": [
            {
              "type": "Container",
              "properties": {
                "height": 110,
                "paddingTop": 12,
                "paddingBottom": 8,
                "backgroundColor": "4294967295"
              },
              "children": [
                {
                  "type": "ListView",
                  "properties": {
                    "scrollDirection": "horizontal",
                    "padding": 16.0
                  },
                  "children": [
                    {
                      "type": "Column",
                      "children": [
                        { "type": "CircleAvatar", "properties": { "backgroundImage": "https://i.pravatar.cc/150?u=12", "radius": 28, "backgroundColor": "4284704497" } },
                        { "type": "SizedBox", "properties": { "height": 4 } },
                        { "type": "Text", "properties": { "text": "Ellie Ma", "fontSize": 10, "color": "4287600792" } }
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 16 } },
                    {
                      "type": "Column",
                      "children": [
                        { "type": "CircleAvatar", "properties": { "backgroundImage": "https://i.pravatar.cc/150?u=22", "radius": 28, "backgroundColor": "4289049852" } },
                        { "type": "SizedBox", "properties": { "height": 4 } },
                        { "type": "Text", "properties": { "text": "Ellie Ma", "fontSize": 10, "color": "4287600792" } }
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 16 } },
                    {
                      "type": "Column",
                      "children": [
                        { "type": "CircleAvatar", "properties": { "backgroundImage": "https://i.pravatar.cc/150?u=33", "radius": 28, "backgroundColor": "4284704497" } },
                        { "type": "SizedBox", "properties": { "height": 4 } },
                        { "type": "Text", "properties": { "text": "Ellie Ma", "fontSize": 10, "color": "4287600792" } }
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 16 } },
                    {
                      "type": "Column",
                      "children": [
                        { "type": "CircleAvatar", "properties": { "backgroundImage": "https://i.pravatar.cc/150?u=44", "radius": 28, "backgroundColor": "4289049852" } },
                        { "type": "SizedBox", "properties": { "height": 4 } },
                        { "type": "Text", "properties": { "text": "Ellie Ma", "fontSize": 10, "color": "4287600792" } }
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 16 } },
                    {
                      "type": "Column",
                      "children": [
                        { "type": "CircleAvatar", "properties": { "backgroundImage": "https://i.pravatar.cc/150?u=66", "radius": 28, "backgroundColor": "4284704497" } },
                        { "type": "SizedBox", "properties": { "height": 4 } },
                        { "type": "Text", "properties": { "text": "Ellie Ma", "fontSize": 10, "color": "4287600792" } }
                      ]
                    }
                  ]
                }
              ]
            },
            { "type": "Divider", "properties": { "height": 1, "color": "4293915128", "thickness": 0.5 } },
            {
              "type": "Container",
              "properties": {
                "padding": 16
              },
              "children": [
                {
                  "type": "Row",
                  "children": [
                    { "type": "CircleAvatar", "properties": { "backgroundImage": "https://i.pravatar.cc/150?u=55", "radius": 18 } },
                    { "type": "SizedBox", "properties": { "width": 12 } },
                    {
                      "type": "Column",
                      "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                      "children": [
                        { "type": "Text", "properties": { "text": "My Name", "fontWeight": "bold", "fontSize": 14 } },
                        { "type": "Text", "properties": { "text": "@noone", "color": "4284704497", "fontSize": 12 } }
                      ]
                    },
                    { "type": "Spacer" },
                    { "type": "Icon", "properties": { "icon": "Icons.more_horiz", "color": "4287600792" } }
                  ]
                },
                { "type": "SizedBox", "properties": { "height": 12 } },
                {
                  "type": "Container",
                  "properties": {
                    "height": 300,
                    "width": 1000,
                    "borderRadius": 16,
                    "backgroundColor": "4293915128"
                  },
                  "children": [
                    {
                      "type": "Image",
                      "properties": {
                        "imageUrl": "https://images.unsplash.com/photo-1541963463532-d68292c34b19?auto=format&fit=crop&q=80&w=1000",
                        "fit": "cover"
                      }
                    }
                  ]
                },
                { "type": "SizedBox", "properties": { "height": 12 } },
                {
                  "type": "Row",
                  "children": [
                    { "type": "Icon", "properties": { "icon": "Icons.favorite_border", "color": "4284704497", "size": 24 } },
                    { "type": "SizedBox", "properties": { "width": 8 } },
                    { "type": "Text", "properties": { "text": "0", "color": "4287600792" } },
                    { "type": "SizedBox", "properties": { "width": 16 } },
                    { "type": "Icon", "properties": { "icon": "Icons.chat_bubble_outline", "color": "4287600792", "size": 24 } },
                    { "type": "SizedBox", "properties": { "width": 8 } },
                    { "type": "Text", "properties": { "text": "[numComments]", "color": "4287600792" } },
                    { "type": "Spacer" },
                    { "type": "Text", "properties": { "text": "[relative]", "color": "4287600792", "fontSize": 12 } }
                  ]
                },
                { "type": "SizedBox", "properties": { "height": 12 } },
                {
                  "type": "Text",
                  "properties": {
                    "text": "I''m back with a super quick Instagram redesign just for the fan. Rounded corners and cute icons, what else do we need, haha.",
                    "fontSize": 14,
                    "color": "4281545523"
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
'::jsonb),
('Chat Screen', 'A beautiful general template.', 'General', '{
  "type": "Scaffold",
  "properties": {
    "backgroundColor": 4293848570,
    "appBar": {
      "type": "AppBar",
      "properties": {
        "title": "Messages",
        "backgroundColor": 4285887743,
        "elevation": 0,
        "centerTitle": false,
        "actions": [
          {
            "type": "IconButton",
            "properties": {
              "icon": { "type": "Icon", "properties": { "icon": "Icons.edit_outlined", "color": 4294967295 } },
              "onPressed": "() {}"
            }
          }
        ]
      },
      "children": []
    }
  },
  "children": [
    {
      "type": "SingleChildScrollView",
      "properties": {},
      "children": [
        {
          "type": "Column",
          "properties": {},
          "children": [
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 16.0, "right": 16.0, "top": 12.0, "bottom": 12.0 },
                "decoration": { "color": 4285887743 }
              },
              "children": [
                {
                  "type": "TextField",
                  "properties": {
                    "hintText": "Search conversations...",
                    "filled": true,
                    "fillColor": 4292533247,
                    "border": "OutlineInputBorder",
                    "prefixIcon": "Icons.search",
                    "contentPadding": { "left": 16.0, "right": 16.0, "top": 10.0, "bottom": 10.0 }
                  },
                  "children": []
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 16.0, "right": 16.0, "top": 12.0, "bottom": 12.0 },
                "decoration": { "color": 4294967295 },
                "margin": { "bottom": 1.0 }
              },
              "children": [
                {
                  "type": "Row",
                  "properties": {},
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "width": 52.0, "height": 52.0,
                        "decoration": { "color": 4285887722, "borderRadius": 26.0 }
                      },
                      "children": [
                        { "type": "Center", "properties": {}, "children": [
                          { "type": "Icon", "properties": { "icon": "Icons.person", "color": 4294967295, "size": 28.0 }, "children": [] }
                        ]}
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 12.0 }, "children": [] },
                    {
                      "type": "Column",
                      "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                      "children": [
                        {
                          "type": "Row",
                          "properties": { "mainAxisAlignment": "MainAxisAlignment.spaceBetween" },
                          "children": [
                            { "type": "Text", "properties": { "text": "Sarah Connor", "fontSize": 16.0, "fontWeight": "FontWeight.bold", "color": 4281545544 }, "children": [] },
                            { "type": "Text", "properties": { "text": "2m ago", "fontSize": 12.0, "color": 4288256409 }, "children": [] }
                          ]
                        },
                        { "type": "SizedBox", "properties": { "height": 4.0 }, "children": [] },
                        { "type": "Text", "properties": { "text": "Hey! Are you free tonight?", "fontSize": 14.0, "color": 4288256409 }, "children": [] }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 16.0, "right": 16.0, "top": 12.0, "bottom": 12.0 },
                "decoration": { "color": 4294967295 },
                "margin": { "bottom": 1.0 }
              },
              "children": [
                {
                  "type": "Row",
                  "properties": {},
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "width": 52.0, "height": 52.0,
                        "decoration": { "color": 4290020292, "borderRadius": 26.0 }
                      },
                      "children": [
                        { "type": "Center", "properties": {}, "children": [
                          { "type": "Icon", "properties": { "icon": "Icons.person", "color": 4294967295, "size": 28.0 }, "children": [] }
                        ]}
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 12.0 }, "children": [] },
                    {
                      "type": "Column",
                      "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                      "children": [
                        {
                          "type": "Row",
                          "properties": { "mainAxisAlignment": "MainAxisAlignment.spaceBetween" },
                          "children": [
                            { "type": "Text", "properties": { "text": "Design Team", "fontSize": 16.0, "fontWeight": "FontWeight.bold", "color": 4281545544 }, "children": [] },
                            { "type": "Text", "properties": { "text": "1h ago", "fontSize": 12.0, "color": 4288256409 }, "children": [] }
                          ]
                        },
                        { "type": "SizedBox", "properties": { "height": 4.0 }, "children": [] },
                        { "type": "Text", "properties": { "text": "New designs are ready for review", "fontSize": 14.0, "color": 4288256409 }, "children": [] }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 16.0, "right": 16.0, "top": 12.0, "bottom": 12.0 },
                "decoration": { "color": 4294967295 },
                "margin": { "bottom": 1.0 }
              },
              "children": [
                {
                  "type": "Row",
                  "properties": {},
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "width": 52.0, "height": 52.0,
                        "decoration": { "color": 4294902685, "borderRadius": 26.0 }
                      },
                      "children": [
                        { "type": "Center", "properties": {}, "children": [
                          { "type": "Icon", "properties": { "icon": "Icons.person", "color": 4294967295, "size": 28.0 }, "children": [] }
                        ]}
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 12.0 }, "children": [] },
                    {
                      "type": "Column",
                      "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                      "children": [
                        {
                          "type": "Row",
                          "properties": { "mainAxisAlignment": "MainAxisAlignment.spaceBetween" },
                          "children": [
                            { "type": "Text", "properties": { "text": "Mike Johnson", "fontSize": 16.0, "fontWeight": "FontWeight.bold", "color": 4281545544 }, "children": [] },
                            { "type": "Text", "properties": { "text": "3h ago", "fontSize": 12.0, "color": 4288256409 }, "children": [] }
                          ]
                        },
                        { "type": "SizedBox", "properties": { "height": 4.0 }, "children": [] },
                        { "type": "Text", "properties": { "text": "The meeting is at 3pm tomorrow", "fontSize": 14.0, "color": 4288256409 }, "children": [] }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "Container",
              "properties": {
                "padding": { "left": 16.0, "right": 16.0, "top": 12.0, "bottom": 12.0 },
                "decoration": { "color": 4294967295 },
                "margin": { "bottom": 1.0 }
              },
              "children": [
                {
                  "type": "Row",
                  "properties": {},
                  "children": [
                    {
                      "type": "Container",
                      "properties": {
                        "width": 52.0, "height": 52.0,
                        "decoration": { "color": 4294944550, "borderRadius": 26.0 }
                      },
                      "children": [
                        { "type": "Center", "properties": {}, "children": [
                          { "type": "Icon", "properties": { "icon": "Icons.person", "color": 4294967295, "size": 28.0 }, "children": [] }
                        ]}
                      ]
                    },
                    { "type": "SizedBox", "properties": { "width": 12.0 }, "children": [] },
                    {
                      "type": "Column",
                      "properties": { "crossAxisAlignment": "CrossAxisAlignment.start" },
                      "children": [
                        {
                          "type": "Row",
                          "properties": { "mainAxisAlignment": "MainAxisAlignment.spaceBetween" },
                          "children": [
                            { "type": "Text", "properties": { "text": "Emma Wilson", "fontSize": 16.0, "fontWeight": "FontWeight.bold", "color": 4281545544 }, "children": [] },
                            { "type": "Text", "properties": { "text": "Yesterday", "fontSize": 12.0, "color": 4288256409 }, "children": [] }
                          ]
                        },
                        { "type": "SizedBox", "properties": { "height": 4.0 }, "children": [] },
                        { "type": "Text", "properties": { "text": "Thanks for the help 😊", "fontSize": 14.0, "color": 4288256409 }, "children": [] }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
'::jsonb);