import pandas as pd
import psycopg2 as p2
import os
import glob
from decimal import Decimal
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import textwrap
from PIL import Image
import datetime as dt

conn = p2.connect(dbname='postgres', user='postgres', password=input('password?'), port=5432)

cur=conn.cursor()

#path = '/Users/myrsmpb/Documents/extend_project/Revenue_Analytics_Takehome_Assessment/sql'
#file_list = glob.glob(os.path.join(path , '*.sql'))

rank = "SELECT * FROM extend.rank;"

xct = cur.execute(rank)
fetch_rank = cur.fetchall()
cols = ['store_name','store_type','warranty_revenue','order_count','extend_revenue'
        ,'warranty_rank','order_rank','extend_rank']
rank_df = pd.DataFrame(fetch_rank, columns=cols)

#print(file_list)

def add_title_page(pdf):
    fig = plt.figure(figsize=(12,9))
    fig.patch.set_facecolor('white')

    plt.axis('off')

    plt.text(
        0.1,0.65,
        "Extend Warranty Case Study",
        fontsize=28,
        weight='bold'
    )

    plt.text(
        0.1,0.55,
        "Senior Data Scientist",
        fontsize=16
    )

    plt.text(
        0.1,0.35,
        "Prepared by Richard salmon 2026/04/27",
        fontsize=12
    )

    pdf.savefig(fig)
    plt.close()

def add_summary_page(pdf, df):
    fig = plt.figure(figsize=(12,9))
    gs = fig.add_gridspec(nrows=4, ncols=1, height_ratios=[0.8,0.8,2,4])

    ax_title = fig.add_subplot(gs[0])
    ax_title.axis('off')
    ax_title.text(0,0.5, "Executive Summary", fontsize=20, weight='bold')

    ax_headline = fig.add_subplot(gs[1])
    ax_headline.axis('off')
    headline = ("Extend warranty sales are being driven by Sports & Fitness Equipment." \
    " There is opportunity to grow the segments of Consumer Electronics and Home Security.")
    wrapped = "\n".join(textwrap.wrap(headline,90))
    ax_headline.text(0,0.5, wrapped, fontsize=14, style='italic', va='center')

    ax_body = fig.add_subplot(gs[2])
    ax_body.axis('off')
    body = """
Attach rate and revenue growth in May has exploded. Performance is being driven by Sports & Fitness Equipment 
that has almost 1:1 warranty attachment with each item order. When exploring other categories we see that 
Consumer Electronics and Home Security have a lot of room to grow. The attach rate for Consumer Electronics 
has room to grow. Home Security attach rate is close to Spors & Fitness Equipment but the overall revenue and 
volume of orders has room to grow.
"""
    wrapped = "\n".join(textwrap.wrap(body,110))
    ax_body.text(0,1,wrapped, fontsize=12, va='top')

    ax_table = fig.add_subplot(gs[3])
    ax_table.axis('off')
    
    display_df = df.copy()
    display_df = display_df.rename(columns={
        'store_name':'Merchant'
        , 'store_type':'Industry'
        , 'warranty_revenue':'Warranty Revenue'
        , 'order_count':'Order Count'
        , 'extend_revenue':'Extend Revenue'
        , 'warranty_rank' : 'Warranty Rank'
        , 'order_rank' : 'Order Volume Rank'
        , 'extend_rank' : 'Extend Revenue Rank'
    })

    table = ax_table.table(
        cellText=display_df.values,
        colLabels=display_df.columns,
        loc='center'
    )

    table.auto_set_font_size(False)
    table.set_fontsize(7)
    table.scale(1, 1.4)

    for (row, col), cell in table.get_celld().items():
        cell.set_linewidth(0)

    for col in range(len(display_df.columns)):
        header_cell = table[0, col]
        header_cell.set_text_props(weight='bold')
        header_cell.set_facecolor('#f5f5f5')
        header_cell.set_linewidth(1)
    
    for row in range(1, len(display_df) +1):
        for col in range(len(display_df.columns)):
            cell = table[row, col]
            cell.visible_edges = 'B'
            cell.set_linewidth(0.5)
    
    plt.tight_layout()
    pdf.savefig(fig)
    plt.close()


def next_steps_page(pdf):
    fig = plt.figure(figsize=(12,9))
    gs = fig.add_gridspec(nrows=4, ncols=1, height_ratios=[0.8,0.8,2,4])

    ax_title = fig.add_subplot(gs[0])
    ax_title.axis('off')
    ax_title.text(0,0.5, "Next Steps", fontsize=20, weight='bold')

    ax_headline = fig.add_subplot(gs[1])
    ax_headline.axis('off')
    headline = ("There are opporuntities to go further with this analysis." \
    " We expolored one dimmension of the business and there are many more inputs that influece financial outcomes.")
    wrapped = "\n".join(textwrap.wrap(headline,90))
    ax_headline.text(0,0.5, wrapped, fontsize=14, style='italic', va='center')

    ax_body = fig.add_subplot(gs[2])
    ax_body.axis('off')
    body = """
The data included many quirks; like line_item_id was a low quality column to match. I had to trim() sortkey to extract store_id.
The orders tables was high level but provided very little beyond being a key to link merchants to line_item_id but there was not much there.
I would like to look into the financial reconciliation and really dive into the profitability question. There is data but it doesn't appear to 
relate from one table to the next. And I was unable to fully reconcile the accounting (I understand it is dummy data). I would like to look at detailed 
order records to make that investigation sound.
"""
    wrapped = "\n".join(textwrap.wrap(body,110))
    ax_body.text(0,1,wrapped, fontsize=12, va='top')

    ax_section = fig.add_subplot(gs[3])
    ax_section.axis('off')
    
    question = ("What does varient_id represesnt?" \
    "What does plan_id represent?" \
    "What is the difference between enabled and approved for merchants?" \
    "What is the difference between is_warrantable and is_warranty?" \
    "The financial numbers are a bit challenging to reconcile. Total, Subtotal, Purchase Price, Discount how do they relate?" \
    "The details of order_lines was confusing to parse, am I looking at an individual item within an order, a collection of items, a subset?" \
    "Contracts was interesting but there was not a lot I could do with the limited data I had; what did the variant_id represent, what about plan_id?" \
    "What happened in late April early May? The KPI's jump pretty significantly during that time.")

    wrapped = "\n".join(textwrap.wrap(question,110))
    ax_section.text(0,1,wrapped, fontsize=12, va='top')

    
    plt.tight_layout()
    pdf.savefig(fig)
    plt.close()

def add_page(pdf, title, headline, body, img_path):
    fig = plt.figure(figsize=(12,9))
    gs = fig.add_gridspec(nrows=4, ncols=1, height_ratios=[0.8,0.6,4,2])

    ax_title = fig.add_subplot(gs[0])
    ax_title.axis('off')
    ax_title.text(0,0.5, title, fontsize=18, weight='bold', va='center')

    ax_headline = fig.add_subplot(gs[1])
    ax_headline.axis('off')
    wrapped_headline = "\n".join(textwrap.wrap(headline, 90))
    ax_headline.text(0,0.5, wrapped_headline, fontsize=14, style='italic', va='center')

    ax_img = fig.add_subplot(gs[2])
    ax_img.axis('off')
    img = Image.open(img_path)
    ax_img.imshow(img)

    ax_body = fig.add_subplot(gs[3])
    ax_body.axis('off')
    wrapped_body = "\n".join(textwrap.wrap(body, 110))
    ax_body.text(0,1, wrapped_body, fontsize=12, va='top')

    plt.tight_layout()
    pdf.savefig(fig)
    plt.close()


def create_pdf():
    with PdfPages("extend_case.pdf") as pdf:
        add_title_page(pdf)
        add_summary_page(pdf, rank_df)

        add_page(
            pdf,
            title="Attachment Rate",
            headline="Attachment Rate by Month",
            body="The monthly attach rate spiked going into May. The underlying data indicates the trend begins in late April " ,
            img_path="Revenue_Analytics_Takehome_Assessment/visualization/attach.png"
            )
        add_page(
            pdf,
            title="Warranty Revenue",
            headline="Warranty Revenue by Month",
            body="This is a similar story to the attachment rate. There is a big jump happening going into May " ,
            img_path="Revenue_Analytics_Takehome_Assessment/visualization/revenue.png"
            )
        add_page(
            pdf,
            title="Market Size",
            headline="Revenue & Attachment Rate by Industry",
            body="x-axis is total item revenue, y-axis is the attach rate for the industry, size of the bubble is the warranty revenue generated. " ,
            img_path="Revenue_Analytics_Takehome_Assessment/visualization/market.png"
            )
        add_page(
            pdf,
            title="Industry Rank",
            headline="Industry Ranked by Revenue Cut to Extend",
            body="Here we can clearly see the leading industries based on the revenue cut to Extend: (warranty sales * (1 - merchantcut)) " ,
            img_path="Revenue_Analytics_Takehome_Assessment/visualization/industry.png"
            )
        next_steps_page(pdf)

create_pdf()