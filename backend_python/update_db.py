import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firestore
def initialize_firestore(service_account_path):
    try:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"Error initializing Firestore: {e}")
        exit(1)

# Edit News in Firestore
def edit_news_in_firestore(db):
    news_collection = db.collection('news')

    try:
        # Get the ID of the document to edit
        news_id = input("Enter the ID of the news to edit: ")
        doc_ref = news_collection.document(news_id)
        doc_snapshot = doc_ref.get()

        if not doc_snapshot.exists:
            print(f"Document with ID '{news_id}' does not exist.")
            return

        # Fetch existing data
        existing_data = doc_snapshot.to_dict()
        print(f"Existing Data: {existing_data}")

        # Get fields to update
        updates = {}
        while True:
            field = input("Enter the field to update (or 'done' to finish): ")
            if field.lower() == 'done':
                break
            value = input(f"Enter the new value for '{field}': ")
            updates[field] = value

        # Apply updates
        doc_ref.update(updates)
        print(f"Updated document with ID '{news_id}'.")

    except Exception as e:
        print(f"Error editing document: {e}")

# Main Function
def main():
    # Path to your service account key file
    service_account_path = "backend_python/google-services.json"

    # Initialize Firestore
    db = initialize_firestore(service_account_path)

    # Edit news in Firestore
    edit_news_in_firestore(db)

# Run the script
if __name__ == "__main__":
    main()
