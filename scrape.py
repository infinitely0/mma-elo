from wikitables import import_tables
import wikipedia
from bs4 import BeautifulSoup
import re
import numpy as np


def clean(string):
    """Strips things like "(c)" and "(ci)" from name of fighter."""
    return re.sub(r"\(.*?\)", "", string).rstrip()


def extract_results(html):
    """Finds results table in wikipedia page html. Returns data in array."""

    soup = BeautifulSoup(html, 'html.parser')
    try:
        table = soup.find(id="Results").parent.next_sibling.next_sibling
    except AttributeError:
        raise ValueError("Could not find results table") from None

    results = []
    for row in table.findAll("tr"):
        cells = row.findAll("td")
        if (len(cells) != 0):
            results.append([clean(cells[i].text) for i in [1, 2, 3]])

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


links = find_event_links()
results = [["Fighter", "Result", "Opponent"]]
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
    except ValueError:
        print("Skipping event - no results table found")
        fails.append(link)

results = np.array(results)
np.savetxt("results.csv", results, delimiter=",", fmt="%s")

print("\nScrape complete. "
      "The following pages were skipped:\n" + "\n".join(fails))
