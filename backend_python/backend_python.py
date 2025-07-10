import firebase_admin
from firebase_admin import credentials, firestore
import json
from datetime import datetime

# Initialize Firestore
def initialize_firestore(service_account_path):
    try:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"Error initializing Firestore: {e}")
        exit(1)

# Load JSON Data
def load_json_data(json_file_path):
    try:
        with open(json_file_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except Exception as e:
        print(f"Error reading JSON file: {e}")
        exit(1)

# Add News to Firestore
def add_news_to_firestore(db, json_data):
    news_collection = db.collection('news')
    for article in json_data:
        try:
            # Ensure critical fields exist
            critical_fields = ['headline', 'imageUrl', 'content', 'category']
            if any(field not in article or not article[field] for field in critical_fields):
                print(f"Skipped (Missing Critical Fields): {article.get('id', 'unknown')}")
                continue

            # Set default values for optional fields
            article['likes'] = article.get('likes', 0)

            # Convert 'Time' to Firestore-compatible timestamp if provided
            if 'Time' in article and article['Time']:
                try:
                    article['Time'] = datetime.strptime(article['Time'], "%Y-%m-%dT%H:%M:%S.%fZ")
                except ValueError:
                    raise ValueError(f"Invalid time format: {article['Time']}")

            # Check if the document with the same 'id' exists
            doc_ref = news_collection.document(article['id'])
            if doc_ref.get().exists:
                print(f"Skipped (Duplicate): {article['headline']}")
            else:
                # Add a new document
                doc_ref.set(article)
                print(f"Added: {article['headline']}")

        except Exception as e:
            print(f"Error processing article {article.get('id', 'unknown')}: {e}")

# Main Function
def main():
    # Path to your service account key file
    service_account_path = "backend_python/google-services.json"
    # Path to your JSON file
    json_file_path = "backend_python/news.json"

    # Initialize Firestore
    db = initialize_firestore(service_account_path)

    # Load JSON data
    json_data = load_json_data(json_file_path)

    # Add news articles to Firestore
    add_news_to_firestore(db, json_data)

# Run the script
if __name__ == "__main__":
    main()
