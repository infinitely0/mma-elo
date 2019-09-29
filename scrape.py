from wikitables import import_tables
import wikipedia
from bs4 import BeautifulSoup
import re
import numpy as np
import unicodedata


def clean(string):
    """
    Removes bracketed substrings, trailing whitespace, and non-breaking chars.
    Strips things like "(c)" and "(ci)" from name of fighter.
    Strips things like "(2015-01-01)" and "[1]" from Wikipedia date strings.
    Replaces non-breaking space added by BeautifulSoup with whitespace.
    """
    string = re.sub(r"[\[\(].*?[\)\]]", "", string).rstrip()
    return unicodedata.normalize("NFKD", string)


def extract_results(html):
    """Finds results table in wikipedia page html. Returns data in array."""

    soup = BeautifulSoup(html, 'html.parser')
    try:
        table = soup.find(id="Results").parent.next_sibling.next_sibling
    except AttributeError:
        raise

    # Get date from infobox
    infoboxes = soup.findAll(class_="infobox")
    for infobox in infoboxes:
        try:
            event_date = infobox.find("th", string="Date").next_sibling.text
            event_date = clean(event_date)
            date_found = True
            break
        except AttributeError:
            event_date = None

    if event_date is None:
        print("Could not find event date")

    results = []
    # Fight number is the ordinal number of the fight for the event
    fight_number = 1
    for row in reversed(table.findAll("tr")):
        cells = row.findAll("td")
        if (len(cells) != 0):
            # Table columns:
            # 1 fighter 2 result 3 opponent 4 method
            result = [clean(cells[i].text) for i in range(1, 5)]
            result.append(event_date)
            result.append(fight_number)
            results.insert(0, result)
            fight_number += 1

    return(results)


def find_event_links():
    """Find url links to all events"""

    events = import_tables("List of UFC events")[1]
    event_links = []
    for event in events.rows:
        name = str(event["Event"])
        # Wikipedia markup links are either [link] or [link|text]
        link = re.findall(r"\[\[(.*?)\|", name)
        if (link):
            event_links.append(link[0])
            continue

        link = re.findall(r"\[\[(.*?)\]\]", name)
        if (link):
            event_links.append(link[0])
            continue

        event_links.append(name)

    return event_links


if __name__ == "__main__":
    links = find_event_links()
    results = [["Fighter", "Result", "Opponent",
                "Method", "Date", "Fight Number"]]
    fails = []

    for link in links:
        print("Parsing results for " + link)
        try:
            html = wikipedia.page(link).html()
        except wikipedia.exceptions.PageError:
            print("Skipping event - page not found")
            fails.append(link)
            continue

        try:
            results = np.concatenate((results, extract_results(html)))
        except AttributeError:
            print("Skipping event - no results table found")
            fails.append(link)

    results = np.array(results)
    np.savetxt("results.csv", results, delimiter=";", fmt="%s")

    print("\nScrape complete. "
          "The following pages were skipped:\n" + "\n".join(fails))
