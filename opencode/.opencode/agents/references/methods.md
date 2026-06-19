# Method rules

## General
- Use short, meaningful method names that reveal intent.
- A method must do only one thing, without mixing responsibilities
- A method must not exceed ~15-20 lines.
- When a method has more than 3 arguments, extract them into a parameter object.
- Prefer method overloading over null/boolean arguments; if more than 2-3 overloads are needed, use a builder or parameter object instead.
- Avoid flag (boolean) arguments that change behavior — split into separate named methods.
- Apply Command-Query-Builder Separation. See sections below
- Never return `null` — use `Optional<T>`, empty collections, or throw.
- Avoid mutating arguments, return a new instance instead.
- Validate arguments at entry with guard clauses (`Objects.requireNonNull`, `Validate.notNull`) — fail fast.
- Use guard clauses / early returns; avoid nesting deeper than 2 levels.
- Keep `final` parameters and locals unless mutation is required.
- Don't catch and swallow exceptions — handle, log with context, or rethrow.
- Use only unchecked exceptions but present them in the method signature. 
- Use "utility" methods on domain classes as they are not anemic objects. Avoid utility/helper classes 
- Order methods by:
    - access level: `private` -> `protected` -> `public`
    - purpose: init methods -> core logic methods -> helper/utility methods

## Command methods
Command methods are `void` and use **verb (+ adjective/noun)** for names. They update can state or just do some 
processing
```java
public class UserService {
	// State change
	public void activate(User user) {
		user.setActive(true);
		auditLog.record(user.getId(), "activated");
	}

	// Processing — no state change, just action
	public void notifyUnverified() {
		var unverified = userDao.findUnverified();
		unverified.forEach(emailService::sendReminder);
	}
}
```

The only exception is methods used in `Dao/Repository` objects, as they need to return result.
```java
public class UserDao {
	public User storeUser(String firstName, String lastName, String addressLine) {
		// Store the user into the DB
    }
}
```

## Query methods
A query method is one that returns a response. Use **nouns** for names. Avoid mixing the names with verbs, e.g. 
`create`, `get`, `set`, `add`, etc.
- General example:
```java
public class UserDao {
	User user(Long id);
	LocalDate birthDay(Long id);
}
```

## Builder methods
- `from/to` mapping methods
```java
public record UserUpdateRequest(String firstName, String lastName, String addressLine) {
	public User toUser() {
		return User.builder()
                .firstName(firstName)
                .lastName(lastName)
                .addressLine(addressLine)
                .build();
    }
}

public record UserResponse(tring firstName, String lastName, String addressLine) {
	public UserResponse fromUser(User user) {
		return UserResponse.builder()
		           .firstName(user.firstName())
		           .lastName(user.lastName())
		           .addressLine(user.addressLine())
		           .build();
	}
}
```

- `with` methods, similar to the standard Builder pattern - setting value and returning a new instance.
```java
public record User(Long id, String fullName, LocalDate birthDate) {
	public User withFullName(final String fullName, final LocalDate birthDate) {
		return new User(this.id, fullName, birthDate);
	}
}
```

