import json
from collections import defaultdict
from datetime import datetime
import matplotlib.pyplot as plt
import pandas as pd
from reportlab.lib.pagesizes import letter, landscape
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image
from reportlab.lib.styles import getSampleStyleSheet
import os

file_path = "data.json"

with open(file_path, 'r') as file:
    json_data = json.load(file)

daily_cost = defaultdict(float)
resource_usage = defaultdict(float)
previous_quantity = defaultdict(float)
increased_usage = defaultdict(float)
cost_per_resource = defaultdict(float)

for entry in json_data:
    date = datetime.strptime(entry["Date"], "%Y-%m-%dT%H:%M:%S").date()
    resource = entry["ServiceResource"]

    cost_per_resource[resource] += float(entry["Cost"])

    daily_cost[date] += float(entry["Cost"])
    resource_usage[resource] += float(entry["Quantity"])

    if previous_quantity[resource]:
        increased_usage[resource] += float(entry["Quantity"]) - previous_quantity[resource]
    previous_quantity[resource] = float(entry["Quantity"])

# Create dataframes for aggregated analytics
daily_cost_df = pd.DataFrame(daily_cost.items(), columns=['Date', 'Cost'])
resource_usage_df = pd.DataFrame(resource_usage.items(), columns=['Resource', 'Usage'])
increased_usage_df = pd.DataFrame(increased_usage.items(), columns=['Resource', 'Increased Usage'])
cost_per_resource_df = pd.DataFrame(cost_per_resource.items(), columns=['Resource', 'Cost'])

# Customize the font size, figure size, and dpi
plt.rc('font', size=10)
figure_size = (15, 5)
dpi = 200

# Define a threshold to group smaller values
threshold = 0.01

# Calculate the total spending
total_spending = cost_per_resource_df['Cost'].sum()

# Add a percentage column to the DataFrame
cost_per_resource_df['Percentage'] = cost_per_resource_df['Cost'] / total_spending

# Create a new DataFrame with the "Others" category
grouped_df = cost_per_resource_df[cost_per_resource_df['Percentage'] > threshold].copy()
others = cost_per_resource_df[cost_per_resource_df['Percentage'] <= threshold]['Cost'].sum()
grouped_df = grouped_df._append({'Resource': 'Others', 'Cost': others, 'Percentage': others / total_spending}, ignore_index=True)

# Plot total cost per resource pie chart
fig, ax = plt.subplots(figsize=figure_size, dpi=dpi)
ax.pie(grouped_df['Cost'], labels=grouped_df['Resource'], autopct='%1.1f%%', startangle=90)
ax.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle
plt.title('Spending Distribution Among Resources')
plt.savefig('cost_distribution.png', dpi=dpi, bbox_inches='tight')  # Save the figure with adjusted bounding box


# Plot daily cost
plt.figure(figsize=figure_size, dpi=dpi)
plt.plot(daily_cost_df['Date'], daily_cost_df['Cost'])
plt.xlabel('Date')
plt.ylabel('Cost')
plt.title('Global Spending Every Day')
plt.xticks(rotation=90, ticks=daily_cost_df['Date'])
plt.grid()
plt.subplots_adjust(bottom=0.3)
plt.savefig('daily_cost.png', dpi=dpi)

# Plot resource usage
plt.figure(figsize=figure_size, dpi=dpi)
resource_usage_df.plot(kind='bar', x='Resource', y='Usage', legend=None, figsize=figure_size)
plt.xlabel('Resource')
plt.ylabel('Usage')
plt.title('Monthly Resource Usage')
plt.xticks(rotation=90)
plt.grid()
plt.subplots_adjust(bottom=0.5)
plt.savefig('resource_usage.png', dpi=dpi)

# Plot increased usage over time
plt.figure(figsize=figure_size, dpi=dpi)
increased_usage_df.plot(kind='bar', x='Resource', y='Increased Usage', legend=None, figsize=figure_size)
plt.xlabel('Resource')
plt.ylabel('Increased Usage')
plt.title('Resource Usage Increase Over Time')
plt.xticks(rotation=90)
plt.grid()
plt.subplots_adjust(bottom=0.5)
plt.savefig('increased_usage.png', dpi=dpi)


# Plot weekly total cost
daily_cost_df['Date'] = pd.to_datetime(daily_cost_df['Date'])
daily_cost_df.set_index('Date', inplace=True)

# Calculate weekly total cost and cumulative cost
weekly_cost_df = daily_cost_df.resample('W').sum()
weekly_cost_df['Cumulative Cost'] = weekly_cost_df['Cost'].cumsum()

plt.figure(figsize=(15, 5), dpi=200)
plt.plot(weekly_cost_df.index, weekly_cost_df['Cost'], label='Weekly Total Cost')
plt.xlabel('Date')
plt.ylabel('Cost')
plt.title('Weekly Total Cost')
plt.xticks(rotation=90)
plt.grid()
plt.legend()
plt.subplots_adjust(bottom=0.3)
plt.savefig('weekly_total_cost.png', dpi=200)

# Plot weekly cumulative spending
plt.figure(figsize=(15, 5), dpi=200)
plt.plot(weekly_cost_df.index, weekly_cost_df['Cumulative Cost'], label='Weekly Cumulative Cost')
plt.xlabel('Date')
plt.ylabel('Cost')
plt.title('Weekly Cumulative Cost')
plt.xticks(rotation=90)
plt.grid()
plt.legend()
plt.subplots_adjust(bottom=0.3)
plt.savefig('weekly_cumulative_cost.png', dpi=200)

# Create a PDF report
start_date = daily_cost_df.index.min().strftime('%Y-%m-%d')
end_date = daily_cost_df.index.max().strftime('%Y-%m-%d')
pdf_file = f"reports/{start_date}TO{end_date}_report.pdf"
doc = SimpleDocTemplate(pdf_file, pagesize=landscape(letter))

story = []

styles = getSampleStyleSheet()


# Add descriptive text
text = '''
Resource Usage and Cost Analysis

This report provides an analysis of resource usage, cost, and trends for a given set of data. The data is visualized using three different graphs, each focusing on a specific aspect of resource consumption and associated costs.

1. Global Spending Every Day: This graph displays the daily costs for the provided data.
2. Monthly Resource Usage: This graph illustrates the total usage of each resource for the given period.
3. Resource Usage Increase Over Time: This graph shows the increase in usage for each resource over time.

The information in this report can help identify trends and patterns in resource usage and spending, ultimately allowing for better management of resources and costs.
'''

story.append(Paragraph(text, styles["Normal"]))
story.append(Spacer(1, 12))

# Add images to the PDF report
story.append(Paragraph("Global Spending Every Day", styles["Heading2"]))
story.append(Image("daily_cost.png", 600, 300))
story.append(Spacer(1, 12))

story.append(Paragraph("Monthly Resource Usage", styles["Heading2"]))
story.append(Image("resource_usage.png", 600, 300))
story.append(Spacer(1, 12))

story.append(Paragraph("Resource Usage Increase Over Time", styles["Heading2"]))
story.append(Image("increased_usage.png", 600, 300))
story.append(Spacer(1, 12))

story.append(Paragraph("Spending Distribution Among Resources", styles["Heading2"]))
story.append(Image("cost_distribution.png", 600, 300))
story.append(Spacer(1, 12))

story.append(Paragraph("Total Spending Weekly Cumulative", styles["Heading2"]))
story.append(Image("weekly_cumulative_cost.png", 600, 300))
story.append(Spacer(1, 12))

story.append(Paragraph("Total Spending Weekly", styles["Heading2"]))
story.append(Image("weekly_total_cost.png", 600, 300))
story.append(Spacer(1, 12))

# Build the PDF report

doc.build(story)
# Remove the image files
os.remove('daily_cost.png')
os.remove('resource_usage.png')
os.remove('increased_usage.png')
os.remove('cost_distribution.png')
os.remove('weekly_cumulative_cost.png')
os.remove('weekly_total_cost.png')