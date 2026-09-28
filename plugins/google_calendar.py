#!/usr/bin/env python3
import os
import sys
import pickle
import datetime
import subprocess
import textwrap

from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

SCOPES = ["https://www.googleapis.com/auth/calendar.readonly"]

HOME_DIR = os.path.expanduser("~")
GOOGLE_DIR = os.path.join(HOME_DIR, ".config", "sketchybar", "google")
CREDENTIALS_PATH = os.path.join(GOOGLE_DIR, "credentials.json")
TOKEN_PATH = os.path.join(GOOGLE_DIR, "token.pickle")

POPUP_MAX_LINES = 10
WRAP_WIDTH = 32  # adjust if you want more/less text per line

def run_cmd(cmd_list):
    subprocess.run(cmd_list, check=False)

def get_service():
    creds = None

    if os.path.exists(TOKEN_PATH):
        with open(TOKEN_PATH, "rb") as token_file:
            creds = pickle.load(token_file)

    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
            creds = flow.run_local_server(port=0)

        os.makedirs(GOOGLE_DIR, exist_ok=True)
        with open(TOKEN_PATH, "wb") as token_file:
            pickle.dump(creds, token_file)

    return build("calendar", "v3", credentials=creds)

def iso_now_utc():
    return datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()

def start_of_today_local():
    now = datetime.datetime.now()
    return now.replace(hour=0, minute=0, second=0, microsecond=0)

def end_of_today_local():
    now = datetime.datetime.now()
    return now.replace(hour=23, minute=59, second=59, microsecond=0)

def fetch_todays_timed_events(service):
    time_min = start_of_today_local().astimezone().isoformat()
    time_max = end_of_today_local().astimezone().isoformat()

    events_result = service.events().list(
        calendarId="primary",
        timeMin=time_min,
        timeMax=time_max,
        singleEvents=True,
        orderBy="startTime",
        maxResults=50,
    ).execute()

    items = events_result.get("items", [])
    timed = []

    for event in items:
        start = event.get("start", {})
        end = event.get("end", {})

        # Ignore all-day events (they have 'date' instead of 'dateTime')
        if "dateTime" not in start:
            continue

        start_dt = datetime.datetime.fromisoformat(start["dateTime"])
        end_dt = None
        if "dateTime" in end:
            end_dt = datetime.datetime.fromisoformat(end["dateTime"])

        title = event.get("summary", "No Title")
        timed.append((start_dt, end_dt, title))

    timed.sort(key=lambda x: x[0])
    return timed

def fmt_time(dt):
    # "10:30 AM" (no leading 0)
    return dt.strftime("%I:%M %p").lstrip("0")

def build_main_label(timed_events):
    now = datetime.datetime.now().astimezone()

    for s_dt, e_dt, title in timed_events:
        if s_dt >= now:
            return f"{fmt_time(s_dt)}  {title}"

    if timed_events:
        s_dt, e_dt, title = timed_events[0]
        return f"{fmt_time(s_dt)}  {title}"

    return "No events"

def wrap_event_lines(s_dt, e_dt, title):
    if e_dt is not None:
        prefix = f"{fmt_time(s_dt)} - {fmt_time(e_dt)}  "
    else:
        prefix = f"{fmt_time(s_dt)}  "

    # First line includes prefix, remaining lines are indented to align with title text
    first_space = " " * len(prefix)

    wrapped = textwrap.wrap(title, width=WRAP_WIDTH)
    if not wrapped:
        return [prefix.rstrip()]

    lines = []
    lines.append(prefix + wrapped[0])

    for part in wrapped[1:]:
        lines.append(first_space + part)

    return lines

def update_popup_items(timed_events):
    lines = []

    if not timed_events:
        lines.append("No timed events today")
    else:
        for s_dt, e_dt, title in timed_events:
            lines.extend(wrap_event_lines(s_dt, e_dt, title))

    # Fill up to POPUP_MAX_LINES, clear the rest
    for i in range(1, POPUP_MAX_LINES + 1):
        text = lines[i - 1] if i - 1 < len(lines) else ""
        run_cmd(["sketchybar", "--set", f"gcal.line{i}", f"label={text}"])

def update_main_item(label):
    run_cmd(["sketchybar", "--set", "gcal", f"label={label}"])

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""

    service = get_service()
    timed = fetch_todays_timed_events(service)

    if mode == "popup":
        update_popup_items(timed)
        return

    label = build_main_label(timed)
    update_main_item(label)

if __name__ == "__main__":
    main()
