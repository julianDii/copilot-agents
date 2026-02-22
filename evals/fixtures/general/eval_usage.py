# Fixture: eval usage — unsafe code execution
# Expected finding: Blocker — eval() executes arbitrary user input

from flask import request

def calculate(expression: str):
    # Evaluates a user-provided math expression
    result = eval(expression)  # ← directly evaluates user input
    return {"result": result}

