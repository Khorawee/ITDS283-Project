"""
seed_questions.py
ใส่คำถามและตัวเลือกลง MySQL
รันครั้งเดียวหลังจาก seed_subjects.sql และ seed_quizzes.sql

วิธีรัน:
    python seed_questions.py
"""

import pymysql
import os
from dotenv import load_dotenv

load_dotenv()

# ── ข้อมูลคำถามทั้งหมด ──────────────────────────────────────────────────────
# โครงสร้าง:
# {
#   'quiz_id': int,
#   'topic': str,
#   'question_text': str,
#   'correct_choice': 'A'|'B'|'C'|'D',
#   'explanation': str,
#   'expected_time': float (วินาที),
#   'choices': [
#       {'label': 'A', 'text': str},
#       {'label': 'B', 'text': str},
#       {'label': 'C', 'text': str},
#       {'label': 'D', 'text': str},
#   ]
# }

QUESTIONS = [

    # ── Quiz 1: Math Basic (Easy) ────────────────────────────────────────────
    {
        'quiz_id': 1,
        'topic': 'Prime Numbers',
        'question_text': 'Which of the following is a prime number?',
        'correct_choice': 'B',
        'explanation': '11 is a prime number because it can only be divided evenly by 1 and 11.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': '9'},
            {'label': 'B', 'text': '11'},
            {'label': 'C', 'text': '15'},
            {'label': 'D', 'text': '21'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Square Root',
        'question_text': 'What is the value of √144?',
        'correct_choice': 'C',
        'explanation': '12 × 12 = 144, so √144 = 12.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': '10'},
            {'label': 'B', 'text': '11'},
            {'label': 'C', 'text': '12'},
            {'label': 'D', 'text': '13'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Basic Algebra',
        'question_text': 'If 2x + 4 = 10, what is x?',
        'correct_choice': 'B',
        'explanation': '2x = 10 - 4 = 6, so x = 3.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': '2'},
            {'label': 'B', 'text': '3'},
            {'label': 'C', 'text': '4'},
            {'label': 'D', 'text': '5'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Properties',
        'question_text': 'Which property states that a + b = b + a?',
        'correct_choice': 'C',
        'explanation': 'The Commutative Property states that order does not change the result.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'Associative'},
            {'label': 'B', 'text': 'Distributive'},
            {'label': 'C', 'text': 'Commutative'},
            {'label': 'D', 'text': 'Identity'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Fractions',
        'question_text': 'What is 3/4 + 1/4?',
        'correct_choice': 'A',
        'explanation': '3/4 + 1/4 = 4/4 = 1.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': '1'},
            {'label': 'B', 'text': '1/2'},
            {'label': 'C', 'text': '3/8'},
            {'label': 'D', 'text': '4/8'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Percentages',
        'question_text': 'What is 20% of 150?',
        'correct_choice': 'B',
        'explanation': '20% of 150 = 0.20 × 150 = 30.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': '25'},
            {'label': 'B', 'text': '30'},
            {'label': 'C', 'text': '35'},
            {'label': 'D', 'text': '40'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Multiplication',
        'question_text': 'What is 7 × 8?',
        'correct_choice': 'C',
        'explanation': '7 × 8 = 56.',
        'expected_time': 15,
        'choices': [
            {'label': 'A', 'text': '48'},
            {'label': 'B', 'text': '54'},
            {'label': 'C', 'text': '56'},
            {'label': 'D', 'text': '64'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Division',
        'question_text': 'What is 144 ÷ 12?',
        'correct_choice': 'B',
        'explanation': '144 ÷ 12 = 12.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': '11'},
            {'label': 'B', 'text': '12'},
            {'label': 'C', 'text': '13'},
            {'label': 'D', 'text': '14'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Order of Operations',
        'question_text': 'What is 2 + 3 × 4?',
        'correct_choice': 'C',
        'explanation': 'Multiply first: 3 × 4 = 12, then add 2 = 14.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': '20'},
            {'label': 'B', 'text': '12'},
            {'label': 'C', 'text': '14'},
            {'label': 'D', 'text': '24'},
        ]
    },
    {
        'quiz_id': 1,
        'topic': 'Geometry',
        'question_text': 'What is the area of a rectangle with width 5 and height 8?',
        'correct_choice': 'D',
        'explanation': 'Area = width × height = 5 × 8 = 40.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': '13'},
            {'label': 'B', 'text': '26'},
            {'label': 'C', 'text': '35'},
            {'label': 'D', 'text': '40'},
        ]
    },

    # ── Quiz 2: Math Advance (Hard) ──────────────────────────────────────────
    {
        'quiz_id': 2,
        'topic': 'Calculus',
        'question_text': 'What is the derivative of f(x) = x³ + 2x² - 5x + 1?',
        'correct_choice': 'A',
        'explanation': "Using the power rule: f'(x) = 3x² + 4x - 5.",
        'expected_time': 45,
        'choices': [
            {'label': 'A', 'text': '3x² + 4x - 5'},
            {'label': 'B', 'text': '3x² + 2x - 5'},
            {'label': 'C', 'text': 'x² + 4x - 5'},
            {'label': 'D', 'text': '3x³ + 4x - 5'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Calculus',
        'question_text': 'What is ∫(2x + 3)dx?',
        'correct_choice': 'B',
        'explanation': '∫(2x + 3)dx = x² + 3x + C by the power rule of integration.',
        'expected_time': 45,
        'choices': [
            {'label': 'A', 'text': '2x² + 3x + C'},
            {'label': 'B', 'text': 'x² + 3x + C'},
            {'label': 'C', 'text': 'x² + 3 + C'},
            {'label': 'D', 'text': '2 + C'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Trigonometry',
        'question_text': 'What is sin²θ + cos²θ equal to?',
        'correct_choice': 'A',
        'explanation': 'This is the Pythagorean identity: sin²θ + cos²θ = 1.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': '1'},
            {'label': 'B', 'text': '0'},
            {'label': 'C', 'text': 'sinθ'},
            {'label': 'D', 'text': '2'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Trigonometry',
        'question_text': 'What is tan(45°)?',
        'correct_choice': 'C',
        'explanation': 'tan(45°) = sin(45°)/cos(45°) = (√2/2)/(√2/2) = 1.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': '0'},
            {'label': 'B', 'text': '√2'},
            {'label': 'C', 'text': '1'},
            {'label': 'D', 'text': '√3'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Linear Algebra',
        'question_text': 'What is the determinant of the matrix [[2, 3], [1, 4]]?',
        'correct_choice': 'B',
        'explanation': 'det = (2×4) - (3×1) = 8 - 3 = 5.',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': '11'},
            {'label': 'B', 'text': '5'},
            {'label': 'C', 'text': '8'},
            {'label': 'D', 'text': '14'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Linear Algebra',
        'question_text': 'If A = [[1, 2], [3, 4]], what is the trace of A?',
        'correct_choice': 'D',
        'explanation': 'The trace is the sum of diagonal elements: 1 + 4 = 5.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': '10'},
            {'label': 'B', 'text': '4'},
            {'label': 'C', 'text': '7'},
            {'label': 'D', 'text': '5'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Probability',
        'question_text': 'A bag has 4 red and 6 blue balls. What is the probability of picking a red ball?',
        'correct_choice': 'A',
        'explanation': 'P(red) = 4 / (4+6) = 4/10 = 2/5.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': '2/5'},
            {'label': 'B', 'text': '3/5'},
            {'label': 'C', 'text': '1/4'},
            {'label': 'D', 'text': '1/2'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Probability',
        'question_text': 'What is the probability of rolling an even number on a fair 6-sided die?',
        'correct_choice': 'B',
        'explanation': 'Even numbers are 2, 4, 6 — that is 3 out of 6 outcomes = 1/2.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': '1/3'},
            {'label': 'B', 'text': '1/2'},
            {'label': 'C', 'text': '2/3'},
            {'label': 'D', 'text': '1/6'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Complex Numbers',
        'question_text': 'What is (3 + 2i) + (1 - 5i)?',
        'correct_choice': 'C',
        'explanation': 'Add real parts: 3+1=4, add imaginary parts: 2i+(-5i)=-3i. Result: 4 - 3i.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': '4 + 3i'},
            {'label': 'B', 'text': '2 - 3i'},
            {'label': 'C', 'text': '4 - 3i'},
            {'label': 'D', 'text': '2 + 7i'},
        ]
    },
    {
        'quiz_id': 2,
        'topic': 'Sequences',
        'question_text': 'What is the sum of the first 10 terms of an arithmetic sequence with a₁=2 and d=3?',
        'correct_choice': 'D',
        'explanation': 'Sₙ = n/2 × (2a₁ + (n-1)d) = 10/2 × (4 + 27) = 5 × 31 = 155.',
        'expected_time': 50,
        'choices': [
            {'label': 'A', 'text': '120'},
            {'label': 'B', 'text': '130'},
            {'label': 'C', 'text': '145'},
            {'label': 'D', 'text': '155'},
        ]
    },

    # ── Quiz 3: Eng Basic (Easy) ─────────────────────────────────────────────
    {
        'quiz_id': 3,
        'topic': 'Vocabulary',
        'question_text': 'What is the synonym of "happy"?',
        'correct_choice': 'A',
        'explanation': '"Joyful" means feeling great happiness, which is a synonym of happy.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'Joyful'},
            {'label': 'B', 'text': 'Sad'},
            {'label': 'C', 'text': 'Angry'},
            {'label': 'D', 'text': 'Tired'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Grammar',
        'question_text': 'Choose the correct sentence.',
        'correct_choice': 'B',
        'explanation': '"She goes to school every day" uses correct subject-verb agreement.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'She go to school every day.'},
            {'label': 'B', 'text': 'She goes to school every day.'},
            {'label': 'C', 'text': 'She going to school every day.'},
            {'label': 'D', 'text': 'She gone to school every day.'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Tenses',
        'question_text': 'Which tense is used in: "I am eating lunch"?',
        'correct_choice': 'C',
        'explanation': '"Am eating" is the present continuous tense, indicating an action happening now.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'Simple Present'},
            {'label': 'B', 'text': 'Simple Past'},
            {'label': 'C', 'text': 'Present Continuous'},
            {'label': 'D', 'text': 'Future Tense'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Vocabulary',
        'question_text': 'What is the antonym of "hot"?',
        'correct_choice': 'B',
        'explanation': '"Cold" is the opposite of hot.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'Warm'},
            {'label': 'B', 'text': 'Cold'},
            {'label': 'C', 'text': 'Cool'},
            {'label': 'D', 'text': 'Mild'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Prepositions',
        'question_text': 'The book is ___ the table.',
        'correct_choice': 'A',
        'explanation': '"On" indicates that the book is resting on top of the table.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'on'},
            {'label': 'B', 'text': 'in'},
            {'label': 'C', 'text': 'at'},
            {'label': 'D', 'text': 'under'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Articles',
        'question_text': 'Choose the correct article: "___ apple a day keeps the doctor away."',
        'correct_choice': 'B',
        'explanation': '"An" is used before words that begin with a vowel sound like "apple".',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'A'},
            {'label': 'B', 'text': 'An'},
            {'label': 'C', 'text': 'The'},
            {'label': 'D', 'text': 'No article'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Pronouns',
        'question_text': 'Which pronoun replaces "John and Mary"?',
        'correct_choice': 'C',
        'explanation': '"They" is the plural pronoun used for two or more people.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'He'},
            {'label': 'B', 'text': 'She'},
            {'label': 'C', 'text': 'They'},
            {'label': 'D', 'text': 'It'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Punctuation',
        'question_text': 'Which sentence uses a comma correctly?',
        'correct_choice': 'A',
        'explanation': 'A comma is used after an introductory phrase like "However".',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'However, I was late.'},
            {'label': 'B', 'text': 'However I was, late.'},
            {'label': 'C', 'text': 'However I was late,'},
            {'label': 'D', 'text': 'However I was late.'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Spelling',
        'question_text': 'Which word is spelled correctly?',
        'correct_choice': 'D',
        'explanation': '"Beautiful" is the correct spelling.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'Beautifull'},
            {'label': 'B', 'text': 'Beutiful'},
            {'label': 'C', 'text': 'Beautful'},
            {'label': 'D', 'text': 'Beautiful'},
        ]
    },
    {
        'quiz_id': 3,
        'topic': 'Vocabulary',
        'question_text': 'What does "abundant" mean?',
        'correct_choice': 'C',
        'explanation': '"Abundant" means existing in large quantities; more than enough.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'Rare'},
            {'label': 'B', 'text': 'Expensive'},
            {'label': 'C', 'text': 'Plentiful'},
            {'label': 'D', 'text': 'Dangerous'},
        ]
    },

    # ── Quiz 4: Eng Advance (Hard) ───────────────────────────────────────────
    {
        'quiz_id': 4,
        'topic': 'Advanced Vocabulary',
        'question_text': 'What does "ephemeral" mean?',
        'correct_choice': 'B',
        'explanation': '"Ephemeral" means lasting for a very short time.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'Everlasting'},
            {'label': 'B', 'text': 'Short-lived'},
            {'label': 'C', 'text': 'Remarkable'},
            {'label': 'D', 'text': 'Widespread'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Advanced Vocabulary',
        'question_text': 'Which word is closest in meaning to "loquacious"?',
        'correct_choice': 'C',
        'explanation': '"Loquacious" means tending to talk a great deal; talkative.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'Silent'},
            {'label': 'B', 'text': 'Aggressive'},
            {'label': 'C', 'text': 'Talkative'},
            {'label': 'D', 'text': 'Intelligent'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Advanced Grammar',
        'question_text': 'Choose the sentence with the correct use of the subjunctive mood.',
        'correct_choice': 'A',
        'explanation': 'The subjunctive uses "were" instead of "was" in hypothetical situations: "If I were you..."',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': 'If I were you, I would study harder.'},
            {'label': 'B', 'text': 'If I was you, I would study harder.'},
            {'label': 'C', 'text': 'If I am you, I would study harder.'},
            {'label': 'D', 'text': 'If I be you, I would study harder.'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Advanced Grammar',
        'question_text': 'Identify the error: "Neither the students nor the teacher were present."',
        'correct_choice': 'B',
        'explanation': 'With "neither...nor", the verb agrees with the closer subject. "Teacher" is singular, so it should be "was".',
        'expected_time': 45,
        'choices': [
            {'label': 'A', 'text': 'Neither'},
            {'label': 'B', 'text': 'were'},
            {'label': 'C', 'text': 'present'},
            {'label': 'D', 'text': 'No error'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Rhetoric',
        'question_text': 'What literary device is used in: "The wind whispered through the trees"?',
        'correct_choice': 'D',
        'explanation': 'Personification gives human qualities (whispering) to a non-human subject (wind).',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'Metaphor'},
            {'label': 'B', 'text': 'Simile'},
            {'label': 'C', 'text': 'Alliteration'},
            {'label': 'D', 'text': 'Personification'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Rhetoric',
        'question_text': 'Which of the following is an example of an oxymoron?',
        'correct_choice': 'C',
        'explanation': '"Deafening silence" is an oxymoron — two contradictory ideas placed together.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'As brave as a lion'},
            {'label': 'B', 'text': 'Time flies'},
            {'label': 'C', 'text': 'Deafening silence'},
            {'label': 'D', 'text': 'Peter Piper picked peppers'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Reading Comprehension',
        'question_text': 'The word "ubiquitous" in academic writing most likely means:',
        'correct_choice': 'A',
        'explanation': '"Ubiquitous" means present, appearing, or found everywhere.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'Present everywhere'},
            {'label': 'B', 'text': 'Extremely rare'},
            {'label': 'C', 'text': 'Highly complex'},
            {'label': 'D', 'text': 'Clearly defined'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Advanced Tenses',
        'question_text': 'Which sentence correctly uses the Past Perfect tense?',
        'correct_choice': 'B',
        'explanation': 'Past Perfect (had + past participle) is used for an action completed before another past action.',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': 'She has finished the report before the meeting.'},
            {'label': 'B', 'text': 'She had finished the report before the meeting started.'},
            {'label': 'C', 'text': 'She finished the report before the meeting will start.'},
            {'label': 'D', 'text': 'She was finishing the report before the meeting.'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Academic Writing',
        'question_text': 'Which sentence is written in passive voice?',
        'correct_choice': 'D',
        'explanation': '"The experiment was conducted by the team" is passive voice — the subject receives the action.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'The team conducted the experiment.'},
            {'label': 'B', 'text': 'The team is conducting the experiment.'},
            {'label': 'C', 'text': 'The team had conducted the experiment.'},
            {'label': 'D', 'text': 'The experiment was conducted by the team.'},
        ]
    },
    {
        'quiz_id': 4,
        'topic': 'Logical Reasoning',
        'question_text': 'Choose the word that does NOT belong: Simile, Metaphor, Hyperbole, Syntax',
        'correct_choice': 'D',
        'explanation': 'Simile, Metaphor, and Hyperbole are all figures of speech. Syntax is a grammatical concept, not a figure of speech.',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': 'Simile'},
            {'label': 'B', 'text': 'Metaphor'},
            {'label': 'C', 'text': 'Hyperbole'},
            {'label': 'D', 'text': 'Syntax'},
        ]
    },

    # ── Quiz 5: Social Studies Basic (Easy) — มัธยม ──────────────────────────
    {
        'quiz_id': 5,
        'topic': 'World Geography',
        'question_text': 'Which is the largest continent by area?',
        'correct_choice': 'A',
        'explanation': 'Asia is the largest continent, covering about 44.6 million km².',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'Asia'},
            {'label': 'B', 'text': 'Africa'},
            {'label': 'C', 'text': 'North America'},
            {'label': 'D', 'text': 'Europe'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'World Geography',
        'question_text': 'Which river is the longest in the world?',
        'correct_choice': 'B',
        'explanation': 'The Nile River in Africa is generally recognized as the longest river at about 6,650 km.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'Amazon'},
            {'label': 'B', 'text': 'Nile'},
            {'label': 'C', 'text': 'Yangtze'},
            {'label': 'D', 'text': 'Mississippi'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'Thai History',
        'question_text': 'Which kingdom was the first unified Thai kingdom?',
        'correct_choice': 'C',
        'explanation': 'Sukhothai Kingdom (ราชอาณาจักรสุโขทัย) is considered the first Thai kingdom, founded around 1238 CE.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'Ayutthaya'},
            {'label': 'B', 'text': 'Lanna'},
            {'label': 'C', 'text': 'Sukhothai'},
            {'label': 'D', 'text': 'Rattanakosin'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'Thai History',
        'question_text': 'King Ramkhamhaeng is credited with creating what important cultural contribution?',
        'correct_choice': 'A',
        'explanation': 'King Ramkhamhaeng created the Thai alphabet in 1283 CE during the Sukhothai period.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'The Thai alphabet'},
            {'label': 'B', 'text': 'The Thai flag'},
            {'label': 'C', 'text': 'The Thai legal code'},
            {'label': 'D', 'text': 'The Thai currency'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'Civics',
        'question_text': 'What type of government does Thailand currently have?',
        'correct_choice': 'B',
        'explanation': 'Thailand is a constitutional monarchy, where the King is the head of state under a constitution.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'Republic'},
            {'label': 'B', 'text': 'Constitutional Monarchy'},
            {'label': 'C', 'text': 'Absolute Monarchy'},
            {'label': 'D', 'text': 'Federal State'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'Civics',
        'question_text': 'How many provinces (จังหวัด) does Thailand have?',
        'correct_choice': 'C',
        'explanation': 'Thailand is divided into 77 provinces including Bangkok as a special administrative area.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': '70'},
            {'label': 'B', 'text': '75'},
            {'label': 'C', 'text': '77'},
            {'label': 'D', 'text': '80'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'World History',
        'question_text': 'Which war is known as the "Great War" or World War I?',
        'correct_choice': 'A',
        'explanation': 'World War I (1914–1918) was called the Great War before World War II occurred.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': '1914–1918'},
            {'label': 'B', 'text': '1939–1945'},
            {'label': 'C', 'text': '1950–1953'},
            {'label': 'D', 'text': '1955–1975'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'World Geography',
        'question_text': 'What is the capital city of Australia?',
        'correct_choice': 'D',
        'explanation': 'Canberra is the capital of Australia, not Sydney or Melbourne as commonly mistaken.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'Sydney'},
            {'label': 'B', 'text': 'Melbourne'},
            {'label': 'C', 'text': 'Brisbane'},
            {'label': 'D', 'text': 'Canberra'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'Economics Basics',
        'question_text': 'What does GDP stand for?',
        'correct_choice': 'B',
        'explanation': 'GDP stands for Gross Domestic Product — the total value of goods and services produced in a country.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'General Domestic Production'},
            {'label': 'B', 'text': 'Gross Domestic Product'},
            {'label': 'C', 'text': 'Global Development Plan'},
            {'label': 'D', 'text': 'Government Debt Payment'},
        ]
    },
    {
        'quiz_id': 5,
        'topic': 'ASEAN',
        'question_text': 'How many member countries are in ASEAN?',
        'correct_choice': 'C',
        'explanation': 'ASEAN has 10 member countries including Thailand, Indonesia, Malaysia, Philippines, Singapore, and others.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': '8'},
            {'label': 'B', 'text': '9'},
            {'label': 'C', 'text': '10'},
            {'label': 'D', 'text': '12'},
        ]
    },

    # ── Quiz 6: Social Studies Advance (Hard) — มัธยม ────────────────────────
    {
        'quiz_id': 6,
        'topic': 'Thai History',
        'question_text': 'The Bowring Treaty (1855) signed between Thailand and Britain primarily affected which sector?',
        'correct_choice': 'B',
        'explanation': 'The Bowring Treaty opened Thailand to free trade, heavily impacting trade and the rice export economy.',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': 'Military affairs'},
            {'label': 'B', 'text': 'International trade'},
            {'label': 'C', 'text': 'Religious institutions'},
            {'label': 'D', 'text': 'Education system'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'Thai History',
        'question_text': 'The 1932 Siamese Revolution changed Thailand from an absolute monarchy to what form of government?',
        'correct_choice': 'A',
        'explanation': 'The 1932 revolution led by the Khana Ratsadon transformed Siam into a constitutional monarchy.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'Constitutional Monarchy'},
            {'label': 'B', 'text': 'Republic'},
            {'label': 'C', 'text': 'Military Dictatorship'},
            {'label': 'D', 'text': 'Federal Democracy'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'World History',
        'question_text': 'The Cold War was primarily a conflict between which two superpowers?',
        'correct_choice': 'C',
        'explanation': 'The Cold War (1947–1991) was a geopolitical tension between the United States and the Soviet Union.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'USA and China'},
            {'label': 'B', 'text': 'UK and Germany'},
            {'label': 'C', 'text': 'USA and Soviet Union'},
            {'label': 'D', 'text': 'France and Soviet Union'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'World History',
        'question_text': 'The United Nations was founded in which year?',
        'correct_choice': 'B',
        'explanation': 'The United Nations was established on 24 October 1945 after World War II to maintain international peace.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': '1918'},
            {'label': 'B', 'text': '1945'},
            {'label': 'C', 'text': '1950'},
            {'label': 'D', 'text': '1960'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'Economics',
        'question_text': 'Which economic system is characterized by private ownership and free market competition?',
        'correct_choice': 'D',
        'explanation': 'Capitalism is defined by private ownership of production means and free market competition for profit.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'Communism'},
            {'label': 'B', 'text': 'Socialism'},
            {'label': 'C', 'text': 'Feudalism'},
            {'label': 'D', 'text': 'Capitalism'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'Geography',
        'question_text': 'The Mekong River passes through how many countries?',
        'correct_choice': 'C',
        'explanation': 'The Mekong River flows through 6 countries: China, Myanmar, Laos, Thailand, Cambodia, and Vietnam.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': '4'},
            {'label': 'B', 'text': '5'},
            {'label': 'C', 'text': '6'},
            {'label': 'D', 'text': '7'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'Civics',
        'question_text': 'Under the Thai constitution, the National Assembly (รัฐสภา) consists of which two bodies?',
        'correct_choice': 'A',
        'explanation': 'Thailand\'s National Assembly consists of the House of Representatives (สภาผู้แทนราษฎร) and the Senate (วุฒิสภา).',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': 'House of Representatives and Senate'},
            {'label': 'B', 'text': 'Cabinet and Parliament'},
            {'label': 'C', 'text': 'Supreme Court and Parliament'},
            {'label': 'D', 'text': 'Council of Ministers and Senate'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'World Geography',
        'question_text': 'Which country has the largest population in the world as of recent years?',
        'correct_choice': 'B',
        'explanation': 'India surpassed China in 2023 to become the world\'s most populous country with over 1.4 billion people.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'China'},
            {'label': 'B', 'text': 'India'},
            {'label': 'C', 'text': 'USA'},
            {'label': 'D', 'text': 'Indonesia'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'Economics',
        'question_text': 'What is "inflation" in economics?',
        'correct_choice': 'C',
        'explanation': 'Inflation is the general increase in price levels over time, resulting in decreased purchasing power of money.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'A decrease in government spending'},
            {'label': 'B', 'text': 'An increase in employment rate'},
            {'label': 'C', 'text': 'A general rise in price levels over time'},
            {'label': 'D', 'text': 'A reduction in national debt'},
        ]
    },
    {
        'quiz_id': 6,
        'topic': 'ASEAN & International',
        'question_text': 'The ASEAN Economic Community (AEC) was officially established in which year?',
        'correct_choice': 'D',
        'explanation': 'The ASEAN Economic Community was formally established on 31 December 2015.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': '2003'},
            {'label': 'B', 'text': '2008'},
            {'label': 'C', 'text': '2012'},
            {'label': 'D', 'text': '2015'},
        ]
    },

    # ── Quiz 7: Programming Basic (Easy) — นักศึกษา ──────────────────────────
    {
        'quiz_id': 7,
        'topic': 'Fundamentals',
        'question_text': 'What does CPU stand for?',
        'correct_choice': 'A',
        'explanation': 'CPU stands for Central Processing Unit — the primary component that executes instructions in a computer.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'Central Processing Unit'},
            {'label': 'B', 'text': 'Core Processing Utility'},
            {'label': 'C', 'text': 'Central Program Unit'},
            {'label': 'D', 'text': 'Computer Processing Unit'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'Python Basics',
        'question_text': 'What is the output of: print(2 ** 3) in Python?',
        'correct_choice': 'B',
        'explanation': 'The ** operator is exponentiation in Python. 2 ** 3 = 2³ = 8.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': '6'},
            {'label': 'B', 'text': '8'},
            {'label': 'C', 'text': '9'},
            {'label': 'D', 'text': '23'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'Python Basics',
        'question_text': 'Which keyword is used to define a function in Python?',
        'correct_choice': 'C',
        'explanation': 'In Python, the "def" keyword is used to define a function, e.g. def my_function():',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'function'},
            {'label': 'B', 'text': 'func'},
            {'label': 'C', 'text': 'def'},
            {'label': 'D', 'text': 'define'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'Data Types',
        'question_text': 'Which of the following is a mutable data type in Python?',
        'correct_choice': 'D',
        'explanation': 'Lists are mutable in Python — their contents can be changed after creation. Strings, tuples, and ints are immutable.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'String'},
            {'label': 'B', 'text': 'Tuple'},
            {'label': 'C', 'text': 'Integer'},
            {'label': 'D', 'text': 'List'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'Control Flow',
        'question_text': 'What does a "for" loop do in programming?',
        'correct_choice': 'A',
        'explanation': 'A "for" loop iterates over a sequence (list, range, string, etc.) and executes the block for each item.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'Iterates over a sequence a fixed number of times'},
            {'label': 'B', 'text': 'Repeats while a condition is True'},
            {'label': 'C', 'text': 'Defines a reusable block of code'},
            {'label': 'D', 'text': 'Handles exceptions'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'Web Basics',
        'question_text': 'What does HTML stand for?',
        'correct_choice': 'B',
        'explanation': 'HTML stands for HyperText Markup Language — the standard language for creating web pages.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'HyperText Modeling Language'},
            {'label': 'B', 'text': 'HyperText Markup Language'},
            {'label': 'C', 'text': 'High Transfer Markup Language'},
            {'label': 'D', 'text': 'HyperText Management Language'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'Database',
        'question_text': 'Which SQL command is used to retrieve data from a database?',
        'correct_choice': 'C',
        'explanation': 'SELECT is used to query and retrieve data from one or more tables in SQL.',
        'expected_time': 20,
        'choices': [
            {'label': 'A', 'text': 'GET'},
            {'label': 'B', 'text': 'FETCH'},
            {'label': 'C', 'text': 'SELECT'},
            {'label': 'D', 'text': 'RETRIEVE'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'Git Basics',
        'question_text': 'What does "git commit" do?',
        'correct_choice': 'A',
        'explanation': '"git commit" saves a snapshot of staged changes to the local repository history with a message.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'Saves staged changes to the local repository'},
            {'label': 'B', 'text': 'Uploads changes to a remote server'},
            {'label': 'C', 'text': 'Creates a new branch'},
            {'label': 'D', 'text': 'Merges two branches together'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'OOP Basics',
        'question_text': 'In Object-Oriented Programming, what is a "class"?',
        'correct_choice': 'D',
        'explanation': 'A class is a blueprint/template for creating objects, defining their attributes and methods.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'A single value stored in memory'},
            {'label': 'B', 'text': 'A built-in Python function'},
            {'label': 'C', 'text': 'A type of loop'},
            {'label': 'D', 'text': 'A blueprint for creating objects'},
        ]
    },
    {
        'quiz_id': 7,
        'topic': 'Algorithms',
        'question_text': 'What is the time complexity of accessing an element in an array by index?',
        'correct_choice': 'B',
        'explanation': 'Accessing an array element by index is O(1) — constant time — regardless of array size.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'O(n)'},
            {'label': 'B', 'text': 'O(1)'},
            {'label': 'C', 'text': 'O(log n)'},
            {'label': 'D', 'text': 'O(n²)'},
        ]
    },

    # ── Quiz 8: Programming Advance (Hard) — นักศึกษา ────────────────────────
    {
        'quiz_id': 8,
        'topic': 'Algorithms',
        'question_text': 'What is the average time complexity of QuickSort?',
        'correct_choice': 'C',
        'explanation': 'QuickSort has an average-case complexity of O(n log n), though worst case is O(n²) with poor pivot selection.',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': 'O(n)'},
            {'label': 'B', 'text': 'O(n²)'},
            {'label': 'C', 'text': 'O(n log n)'},
            {'label': 'D', 'text': 'O(log n)'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'Data Structures',
        'question_text': 'In a stack data structure, which principle governs element removal?',
        'correct_choice': 'A',
        'explanation': 'A stack follows LIFO — Last In, First Out. The most recently added element is removed first.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'LIFO (Last In, First Out)'},
            {'label': 'B', 'text': 'FIFO (First In, First Out)'},
            {'label': 'C', 'text': 'Random access'},
            {'label': 'D', 'text': 'Priority-based removal'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'Python Advanced',
        'question_text': 'What is the output of: [x**2 for x in range(4) if x % 2 == 0]?',
        'correct_choice': 'D',
        'explanation': 'range(4) = [0,1,2,3]. Even numbers: 0, 2. Squared: [0, 4].',
        'expected_time': 45,
        'choices': [
            {'label': 'A', 'text': '[1, 4, 9, 16]'},
            {'label': 'B', 'text': '[0, 1, 4, 9]'},
            {'label': 'C', 'text': '[1, 9]'},
            {'label': 'D', 'text': '[0, 4]'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'OOP',
        'question_text': 'Which OOP principle allows a subclass to provide a specific implementation of a method already defined in its parent class?',
        'correct_choice': 'B',
        'explanation': 'Method Overriding allows a subclass to redefine a parent method, enabling polymorphic behavior.',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': 'Encapsulation'},
            {'label': 'B', 'text': 'Method Overriding'},
            {'label': 'C', 'text': 'Abstraction'},
            {'label': 'D', 'text': 'Method Overloading'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'Database',
        'question_text': 'What does the SQL JOIN clause combine?',
        'correct_choice': 'C',
        'explanation': 'JOIN combines rows from two or more tables based on a related column, allowing cross-table queries.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'Two SQL queries into one result'},
            {'label': 'B', 'text': 'Duplicate rows in a single table'},
            {'label': 'C', 'text': 'Rows from multiple tables based on a related column'},
            {'label': 'D', 'text': 'Multiple databases into one'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'Networking',
        'question_text': 'What is the purpose of the HTTP status code 404?',
        'correct_choice': 'A',
        'explanation': '404 Not Found means the server cannot find the requested resource at the given URL.',
        'expected_time': 25,
        'choices': [
            {'label': 'A', 'text': 'Resource not found'},
            {'label': 'B', 'text': 'Server internal error'},
            {'label': 'C', 'text': 'Request unauthorized'},
            {'label': 'D', 'text': 'Request successful'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'Design Patterns',
        'question_text': 'Which design pattern ensures a class has only one instance throughout the application?',
        'correct_choice': 'D',
        'explanation': 'The Singleton pattern restricts instantiation of a class to a single object, providing a global access point.',
        'expected_time': 40,
        'choices': [
            {'label': 'A', 'text': 'Factory'},
            {'label': 'B', 'text': 'Observer'},
            {'label': 'C', 'text': 'Decorator'},
            {'label': 'D', 'text': 'Singleton'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'Python Advanced',
        'question_text': 'What does the "yield" keyword do in a Python function?',
        'correct_choice': 'B',
        'explanation': '"yield" makes a function a generator, pausing execution and returning a value without destroying local state.',
        'expected_time': 45,
        'choices': [
            {'label': 'A', 'text': 'Terminates the function immediately'},
            {'label': 'B', 'text': 'Pauses the function and returns a value, creating a generator'},
            {'label': 'C', 'text': 'Raises an exception'},
            {'label': 'D', 'text': 'Imports an external module'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'Security',
        'question_text': 'What type of attack involves injecting malicious SQL code into an input field?',
        'correct_choice': 'A',
        'explanation': 'SQL Injection is an attack where malicious SQL is inserted into input fields to manipulate database queries.',
        'expected_time': 35,
        'choices': [
            {'label': 'A', 'text': 'SQL Injection'},
            {'label': 'B', 'text': 'Cross-Site Scripting (XSS)'},
            {'label': 'C', 'text': 'Brute Force Attack'},
            {'label': 'D', 'text': 'Man-in-the-Middle Attack'},
        ]
    },
    {
        'quiz_id': 8,
        'topic': 'System Design',
        'question_text': 'In a REST API, which HTTP method is typically used to UPDATE an existing resource?',
        'correct_choice': 'C',
        'explanation': 'PUT (full update) or PATCH (partial update) are used to update resources. PUT is the most standard for full replacement.',
        'expected_time': 30,
        'choices': [
            {'label': 'A', 'text': 'GET'},
            {'label': 'B', 'text': 'POST'},
            {'label': 'C', 'text': 'PUT'},
            {'label': 'D', 'text': 'DELETE'},
        ]
    },
]




def ensure_unique_constraint(cur):
    """
    FIX: เพิ่ม UNIQUE KEY บน (quiz_id, question_text) ถ้ายังไม่มี
    ป้องกันข้อสอบซ้ำในระดับ DB — รัน seed กี่รอบก็ไม่ซ้ำ
    """
    try:
        cur.execute("""
            SELECT COUNT(*) as cnt
            FROM information_schema.statistics
            WHERE table_schema = DATABASE()
              AND table_name   = 'questions'
              AND index_name   = 'uq_quiz_question'
        """)
        exists = cur.fetchone()['cnt'] > 0
        if not exists:
            cur.execute("""
                ALTER TABLE questions
                ADD UNIQUE KEY uq_quiz_question (quiz_id, question_text(200))
            """)
            print("✅ Added UNIQUE KEY uq_quiz_question on questions table")
        else:
            print("ℹ️  UNIQUE KEY already exists — skipping ALTER")
    except Exception as e:
        print(f"⚠️  Could not add UNIQUE KEY: {e} (continuing anyway)")


def remove_existing_duplicates(cur):
    """
    FIX: ลบข้อซ้ำที่อาจมีอยู่แล้วใน DB ก่อนเพิ่ม UNIQUE KEY
    เก็บ question_id ต่ำสุด (ข้อแรกที่ insert) ลบที่เหลือ
    """
    cur.execute("""
        DELETE q1
        FROM questions q1
        INNER JOIN questions q2
            ON  q1.quiz_id       = q2.quiz_id
            AND q1.question_text = q2.question_text
            AND q1.question_id   > q2.question_id
    """)
    deleted = cur.rowcount
    if deleted > 0:
        print(f"🗑️  Removed {deleted} duplicate question(s) from DB")
    else:
        print("✅ No duplicate questions found")


def seed():
    """รัน seed คำถามและตัวเลือกทั้งหมดลง MySQL
    FIX: ป้องกันซ้ำด้วย INSERT IGNORE + UNIQUE KEY
    """
    conn = pymysql.connect(
        host=os.getenv('DB_HOST', 'localhost'),
        port=int(os.getenv('DB_PORT', 3306)),
        user=os.getenv('DB_USER', 'root'),
        password=os.getenv('DB_PASSWORD', ''),
        database=os.getenv('DB_NAME', 'learnflow'),
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
    )

    try:
        with conn.cursor() as cur:

            # Step 1: ลบซ้ำที่มีอยู่แล้ว (ถ้ารัน seed มาหลายรอบแล้ว)
            print("\n── Step 1: Cleaning duplicates ──")
            remove_existing_duplicates(cur)
            conn.commit()

            # Step 2: เพิ่ม UNIQUE constraint ป้องกันซ้ำในอนาคต
            print("\n── Step 2: Ensuring UNIQUE constraint ──")
            ensure_unique_constraint(cur)
            conn.commit()

            # Step 3: Insert คำถาม
            print(f"\n── Step 3: Inserting {len(QUESTIONS)} questions ──")
            inserted_q = 0
            skipped_q  = 0
            inserted_c = 0

            for q in QUESTIONS:
                # INSERT IGNORE — ถ้าซ้ำ (quiz_id + question_text) จะ skip แทน error
                affected = cur.execute('''
                    INSERT IGNORE INTO questions
                        (quiz_id, topic, question_text, correct_choice,
                         explanation, expected_time)
                    VALUES (%s, %s, %s, %s, %s, %s)
                ''', (
                    q['quiz_id'], q['topic'], q['question_text'],
                    q['correct_choice'], q['explanation'], q['expected_time']
                ))

                if affected == 0:
                    skipped_q += 1
                    continue  # ข้ามการ insert choices ของข้อที่ซ้ำ

                question_id = cur.lastrowid
                inserted_q += 1

                for c in q['choices']:
                    cur.execute('''
                        INSERT IGNORE INTO choices (question_id, choice_label, choice_text)
                        VALUES (%s, %s, %s)
                    ''', (question_id, c['label'], c['text']))
                    inserted_c += 1

            conn.commit()

        print(f'\n✅ Done!')
        print(f'   Inserted : {inserted_q} questions, {inserted_c} choices')
        if skipped_q > 0:
            print(f'   Skipped  : {skipped_q} duplicate questions')

    except Exception as e:
        conn.rollback()
        print(f'❌ Error: {e}')
    finally:
        conn.close()


if __name__ == '__main__':
    seed()