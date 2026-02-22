# Snapshot: general-eval-usage
# Agent: code-review
# Fixture: fixtures/general/eval_usage.py
# Date: 2026-02-22
# Rubric score: 8/8 ✅

## Summary
- Single route evaluates a user-provided string as arbitrary Python code
- Complete remote code execution vulnerability
- Risk: any caller can execute `__import__('os').system('rm -rf /')` or exfiltrate secrets

## Blockers

1. **`eval(expression)` on unsanitized user input — RCE**
   - `expression` comes directly from the caller with no sanitization, allowlist, or sandboxing
   - Attacker sends `"__import__('os').popen('cat /etc/passwd').read()"` → server executes it
   - Fix: use a safe math parser — `ast.literal_eval` for simple literals, or `simpleeval` for expressions

## Suggested patch

```python
import ast
import operator

SAFE_OPS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.USub: operator.neg,
}

def _safe_eval(node):
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
    if isinstance(node, ast.BinOp) and type(node.op) in SAFE_OPS:
        return SAFE_OPS[type(node.op)](_safe_eval(node.left), _safe_eval(node.right))
    if isinstance(node, ast.UnaryOp) and type(node.op) in SAFE_OPS:
        return SAFE_OPS[type(node.op)](_safe_eval(node.operand))
    raise ValueError(f"Unsupported expression: {ast.dump(node)}")

def calculate(expression: str):
    try:
        tree = ast.parse(expression, mode='eval')
        result = _safe_eval(tree.body)
    except (ValueError, SyntaxError) as exc:
        return {"error": str(exc)}, 400
    return {"result": result}
```

## Tests

```python
def test_basic_math():
    assert calculate("2 + 3 * 4")["result"] == 14

def test_rejects_import():
    result, status = calculate("__import__('os').system('id')")
    assert status == 400

def test_rejects_string_literal():
    result, status = calculate("'hello'")
    assert status == 400

def test_rejects_empty():
    result, status = calculate("")
    assert status == 400
```

