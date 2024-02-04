import json
import os
import subprocess
from datetime import datetime


# Function to read JSON file
def read_json(file_path):
    with open(file_path, 'r') as json_file:
        data = json.load(json_file)
    return data

# Function to read config file
def read_config(file_path):
    with open(file_path, 'r') as config_file:
        config = json.load(config_file)
    return config

# Function to read template file
def read_template(file_path):
    with open(file_path, 'r') as template_file:
        template = template_file.read()
    return template

# Function to create a template from the JSON data
def create_template(name, data, template):
    return template.format(name.replace(' ', '_'), data['location']['latitude'], data['location']['longitude'], datetime.utcfromtimestamp(data['location']['timeStamp'] / 1000.0).strftime("%Y-%m-%dT%H:%M:%SZ"))

# Function to copy file to web server using scp
def copy_to_web_server(file_path, destination_directory):
    subprocess.run(['scp', file_path, f'ok@center.dyndns.biz:{destination_directory}/data'])

# Main script
json_file_path = '/Users/oleg/Library/Caches/com.apple.findmy.fmipcore/Items.data'
config_file_path = 'config.json'  # Replace with your actual config file path
template_file_path = 'template.txt'  # Replace with your actual template file path

# Read JSON file
json_data = read_json(json_file_path)

# Read config file
config_data = read_config(config_file_path)

# Read template file
template_content = read_template(template_file_path)

# Iterate through each object in the JSON data
for obj in json_data:
    object_name = obj['name']
    
    # Check if object has a corresponding section in the config file
    if object_name in config_data:
        # Create a template using the JSON data
        output_content = create_template(object_name, obj, template_content)

        # Write the template to a file
        output_file_path = f'airtagdata_{object_name}.gpx'.replace(' ', '_')
        with open(output_file_path, 'w') as output_file:
            output_file.write(output_content)

        # Copy the file to the web server
        destination_directory = config_data[object_name]['directory']
        copy_to_web_server(output_file_path, destination_directory)

        # Remove the temporary file
        os.remove(output_file_path)
