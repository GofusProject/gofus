#!/usr/bin/env python3
"""
Script to convert a series of ActionScript files into two CSV files:
- One for questions (D.q)
- One for answers (D.a)
Usage:
    python3 as_to_csv.py <input_directory> <output_questions_csv> <output_answers_csv>
Example:
    python3 as_to_csv.py ./as questions.csv answers.csv
"""
import os
import re
import sys
import csv
from pathlib import Path

# Config
DEBUG = True
QUESTION_PATTERN = re.compile(r'D\.q\[(\d+)\]\s*=\s*"(.*?)(?<!\\)"')
ANSWER_PATTERN = re.compile(r'D\.a\[(\d+)\]\s*=\s*"(.*?)(?<!\\)"')


def log(message):
    if DEBUG:
        print(f"[DEBUG] {message}")


def decode_as_string(s):
    """Decode ActionScript string: handle \\uXXXX escapes without corrupting UTF-8 chars."""
    return re.sub(r'\\u([0-9a-fA-F]{4})', lambda m: chr(int(m.group(1), 16)), s)


def process_file(file_path, questions, answers):
    log(f"Processing file: {file_path}")
    with open(file_path, 'r', encoding='utf-8-sig') as file:
        content = file.read()
        for match in QUESTION_PATTERN.finditer(content):
            question_id = match.group(1)
            question_text = decode_as_string(match.group(2))
            questions[question_id] = question_text
        for match in ANSWER_PATTERN.finditer(content):
            answer_id = match.group(1)
            answer_text = decode_as_string(match.group(2))
            answers[answer_id] = answer_text


def write_csv(output_file, data, fieldnames):
    log(f"Writing CSV: {output_file}")
    with open(output_file, 'w', encoding='utf-8-sig', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for key, value in data.items():
            writer.writerow({'id': key, 'text': value})


def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <input_directory> <output_questions_csv> <output_answers_csv>")
        sys.exit(1)

    input_dir = sys.argv[1]
    output_questions = sys.argv[2]
    output_answers = sys.argv[3]

    if not os.path.isdir(input_dir):
        print(f"Error: Input directory '{input_dir}' does not exist.")
        sys.exit(1)

    questions = {}
    answers = {}

    for file_path in Path(input_dir).glob('*.as'):
        process_file(file_path, questions, answers)

    write_csv(output_questions, questions, ['id', 'text'])
    write_csv(output_answers, answers, ['id', 'text'])
    print(f"Conversion complete. Questions saved to {output_questions}, answers saved to {output_answers}")


if __name__ == "__main__":
    main()