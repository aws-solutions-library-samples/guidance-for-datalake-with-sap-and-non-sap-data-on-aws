import os

# Define the key parameters (replace with yours)
YOUR_GLUE_IAM_ROLE_ARN = "<YOUR_GLUE_IAM_ROLE_ARN>"
YOUR_GLUE_ASSETS_BUCKET = "<YOUR_GLUE_ASSETS_BUCKET>"
YOUR_S3_RAW_BUCKET = "<YOUR_S3_RAW_BUCKET>"
YOUR_ENRICHED_GLUE_CATALOG_DB = "<YOUR_ENRICHED_GLUE_CATALOG_DB>"
YOUR_CURATED_GLUE_CATALOG_DB = "<YOUR_CURATED_GLUE_CATALOG_DB>"

# Base directory containing the folders with JSON files
BASE_DIR = 'Glue Jobs'

def replace_placeholders_in_json_files(base_dir, replacements_map):
    # Iterate through each subdirectory and process JSON files
    for subdir, replacements in replacements_map.items():
        template_dir = os.path.join(base_dir, subdir)
        output_dir = os.path.join(base_dir, f"{subdir} (Processed)")

        # Check if the template directory exists
        if not os.path.exists(template_dir):
            print(f"Directory {template_dir} does not exist. Skipping.")
            continue

        # List JSON files in the template directory
        json_files = [f for f in os.listdir(template_dir) if f.endswith('.json')]

        # Skip if there are no JSON files
        if not json_files:
            print(f"No JSON files found in {template_dir}. Skipping.")
            continue

        # Create output directory if it doesn't exist and there are files to process
        os.makedirs(output_dir, exist_ok=True)

        print(f"Start proccessing files in {subdir}...")
        # Process each JSON template file in the template directory
        for filename in json_files:
            file_path = os.path.join(template_dir, filename)
            output_filename = os.path.join(output_dir, filename)

            # Check if the output file already exists
            if os.path.exists(output_filename):
                print(f"Skipping {filename} as it already exists in {output_dir}.")
                continue

            # Load the JSON template
            with open(file_path, 'r') as file:
                template = file.read()

            # Perform the replacements
            for placeholder, replacement in replacements.items():
                template = template.replace(placeholder, replacement)

            # Write the modified JSON to the output directory
            with open(output_filename, 'w') as output_file:
                output_file.write(template)

            print(f"Successfully processed {filename} to {output_dir}")
            
        print(f"Successfully processed files in {subdir}.\n")

# Define the replacements for each type of JSON file
replacements_map = {
    'LtoR': {
        "<your_glue_iam_role_arn>": YOUR_GLUE_IAM_ROLE_ARN,
        "<your_glue_assets_bucket>": YOUR_GLUE_ASSETS_BUCKET,
        "<your_s3_raw_bucket>": YOUR_S3_RAW_BUCKET
    },
    'RtoE': {
        "<your_glue_iam_role_arn>": YOUR_GLUE_IAM_ROLE_ARN,
        "<your_glue_assets_bucket>": YOUR_GLUE_ASSETS_BUCKET,
        "<your_s3_raw_bucket>": YOUR_S3_RAW_BUCKET,
        "<your_enriched_glue_catalog_db>": YOUR_ENRICHED_GLUE_CATALOG_DB
    },
    'RtoC': {
        "<your_glue_iam_role_arn>": YOUR_GLUE_IAM_ROLE_ARN,
        "<your_glue_assets_bucket>": YOUR_GLUE_ASSETS_BUCKET,
        "<your_s3_raw_bucket>": YOUR_S3_RAW_BUCKET,
        "<your_curated_glue_catalog_db>": YOUR_CURATED_GLUE_CATALOG_DB
    },
    'EtoC': {
        "<your_glue_iam_role_arn>": YOUR_GLUE_IAM_ROLE_ARN,
        "<your_glue_assets_bucket>": YOUR_GLUE_ASSETS_BUCKET,
        "<your_s3_raw_bucket>": YOUR_S3_RAW_BUCKET,
        "<your_curated_glue_catalog_db>": YOUR_CURATED_GLUE_CATALOG_DB,
        "<your_enriched_glue_catalog_db>": YOUR_ENRICHED_GLUE_CATALOG_DB
    }
}

# Run the function
replace_placeholders_in_json_files(BASE_DIR, replacements_map)