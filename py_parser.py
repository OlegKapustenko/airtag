import json
import os
import subprocess
from datetime import datetime, timedelta


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
    subprocess.run(['scp', file_path, f'ok@center.dyndns.biz:{destination_directory}'])


# Main script
file_path = '/Users/oleg/Library/Caches/com.apple.findmy.fmipcore/Items.data'
json_file_path = '/tmp/collect.json'
config_file_path = 'config.json'  # Replace with your actual config file path
template_file_path = 'template.txt'  # Replace with your actual template file path

the_day = datetime.now().day
current_date = datetime.now()

# Get tomorrow's date by adding one day
tomorrow_date = current_date + timedelta(days=1)

# Get the day of the month for tomorrow
day_of_tomorrow = tomorrow_date.day

subprocess.run(['cp', file_path, json_file_path])

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
        # output_content = create_template(object_name, obj, template_content)

        the_line = "{} {} {} {}".format(obj['location']['latitude'], obj['location']['longitude'], obj['location']['altitude'], datetime.utcfromtimestamp(obj['location']['timeStamp'] / 1000.0).strftime("%Y-%m-%dT%H:%M:%SZ"))
        output_file_path = f'web/airtagdata_{object_name}_{the_day}.txt'.replace(' ', '_')
        tomorrow_file_path = f'web/airtagdata_{object_name}_{day_of_tomorrow}.txt'.replace(' ', '_')
        txt_file_path = f'airtagdata_{object_name}.txt'.replace(' ', '_')
        try:
            os.remove(tomorrow_file_path)
            print(f"File {tomorrow_file_path} removed successfully.")
        except FileNotFoundError:
            # print(f"File {tomorrow_file_path} not found. No action taken.")
            pass
        except Exception as e:
            print(f"An error occurred: {e}")
                
        # print ("output_file_path: {}".format(output_file_path))
        try:
            with open(output_file_path, 'r') as file:
                # Read all lines into a list and get the last line
                last_line = list(file)[-1]
                # print(last_line)
        except FileNotFoundError:
            print(f"File not found: {output_file_path}")
            last_line = ''
        except IndexError:
            print(f"File is empty: {output_file_path}")
            last_line = ''

        if the_line.strip() == last_line.strip():
            # print ("nothing changed for {}".format(object_name))
            continue

        # Write the template to a file
        with open(output_file_path, 'a') as output_file:
            output_file.write(the_line + "\n")

        # Copy the file to the web server
        destination_directory = config_data[object_name]['directory']
        # print ("destination_directory: {}".format(destination_directory))
        # print ("debug {}".format(destination_directory + '/' + txt_file_path))
        print ("%s".format(datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")))
        copy_to_web_server(output_file_path, f'{destination_directory}/data/{txt_file_path}')
        copy_to_web_server(output_file_path, f'{destination_directory}/data/')
