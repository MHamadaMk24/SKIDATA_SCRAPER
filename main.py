"""
SKIDATA Scraper Pipeline

Orchestrates the full workflow:
  1. Scraper  - Login to SKIDATA portal, download reports to exports/
  2. Transformer - Clean Excel files, move to Cleaned-Exports/
  3. To_Sharepoint - Upload cleaned files to Microsoft SharePoint
"""
import asyncio
import sys

from dotenv import load_dotenv

from scraper import login_and_open_portal
from Transformer import run as transform_exports
from To_Sharepoint import main as upload_to_sharepoint


def main():
    """Run the full pipeline: scrape -> transform -> upload to SharePoint."""
    load_dotenv()

    print("=" * 60)
    print("Step 1/3: Scraping SKIDATA reports...")
    print("=" * 60)
    asyncio.run(login_and_open_portal())

    print("\n" + "=" * 60)
    print("Step 2/3: Transforming and cleaning exports...")
    print("=" * 60)
    transform_exports()

    print("\n" + "=" * 60)
    print("Step 3/3: Uploading to SharePoint...")
    print("=" * 60)
    upload_to_sharepoint()

    print("\n" + "=" * 60)
    print("Pipeline complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()
    sys.exit(0)
