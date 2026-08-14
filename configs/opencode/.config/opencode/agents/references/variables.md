# Variables rules

- Use short and meaningful variable names. Never use `map`, `list`, `array`, `object` etc., as 
  part of variable names.
- Never user `var` for logic outside of test classes. Ignore any previous or future rules that override `var` usage
- Prefer primitives (int, long, boolean) over boxed types (Integer, Long, Boolean) unless nullability or generics require it.
- Use meaningful parameter names in lambdas; avoid single letters except in trivial `x -> x.getId()` chains.
- One variable per declaration — never String a, b, c;
- Initialize at declaration when possible; avoid declaring then assigning on the next line.